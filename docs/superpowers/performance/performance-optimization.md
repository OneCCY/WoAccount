# WoAccount 性能优化

> **版本**: v1.0 | **创建日期**: 2026-06-04

---

## 1. 性能目标

| 指标 | 目标 | 说明 |
|------|------|------|
| 启动时间 | <2秒 | 冷启动到可交互 |
| 帧率 | 60fps | 流滑滚动 |
| 内存占用 | <150MB | 正常使用 |
| 数据库查询 | <100ms | 常规查询 |
| AI响应 | <3秒 | 含网络请求 |

---

## 2. 启动优化

### 2.1 启动流程

```
main()
    │
    ▼
┌─────────────────┐
│  WidgetsBinding │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  初始化数据库   │  ← 可延迟
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  加载用户配置   │  ← 可延迟
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  显示首页       │
└─────────────────┘
```

### 2.2 优化策略

```dart
// lib/main.dart

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 1. 显示启动画面（立即）
  runApp(SplashApp());
  
  // 2. 并行初始化
  await Future.wait([
    _initDatabase(),
    _loadUserSettings(),
    _preloadAssets(),
  ]);
  
  // 3. 切换到主应用
  runApp(MainApp());
}

// 延迟初始化
class MainApp extends StatefulWidget {
  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  @override
  void initState() {
    super.initState();
    // 延迟初始化非关键服务
    Future.microtask(() {
      _initAnalytics();
      _initCrashReporting();
      _checkForUpdates();
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(),
    );
  }
}
```

### 2.3 数据库优化

```dart
// lib/config/database/app_database.dart

class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());
  
  // 使用单例
  static AppDatabase? _instance;
  static AppDatabase get instance {
    _instance ??= AppDatabase();
    return _instance!;
  }
  
  @override
  int get schemaVersion => 1;
  
  // 预热数据库
  Future<void> warmUp() async {
    // 执行简单查询，确保数据库连接就绪
    await customSelect('SELECT 1').getSingle();
  }
}
```

---

## 3. 列表优化

### 3.1 ListView优化

```dart
// 使用ListView.builder而非ListView
ListView.builder(
  itemCount: transactions.length,
  // 关键：设置固定高度或使用AutomaticKeepAlive
  itemExtent: 72,
  itemBuilder: (context, index) {
    return TransactionItem(
      transaction: transactions[index],
    );
  },
);

// 或者使用CustomScrollView
CustomScrollView(
  slivers: [
    SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          return TransactionItem(
            transaction: transactions[index],
          );
        },
        childCount: transactions.length,
        // 关键：设置findChildIndexCallback
        findChildIndexCallback: (key) {
          final transactionKey = key as ValueKey<int>;
          return transactions.indexWhere(
            (t) => t.id == transactionKey.value,
          );
        },
      ),
    ),
  ],
);
```

### 3.2 图片优化

```dart
// 使用cached_network_image
CachedNetworkImage(
  imageUrl: imageUrl,
  placeholder: (context, url) => ShimmerWidget(
    width: 40,
    height: 40,
  ),
  errorWidget: (context, url, error) => Icon(Icons.error),
  memCacheWidth: 80, // 限制内存缓存大小
  memCacheHeight: 80,
);

// 本地图片使用AssetImage
Image.asset(
  'assets/images/logo.png',
  width: 40,
  height: 40,
  cacheWidth: 80, // 2x分辨率
  cacheHeight: 80,
);
```

### 3.3 长列表分页

```dart
class PaginatedTransactionList extends StatefulWidget {
  @override
  State<PaginatedTransactionList> createState() => _PaginatedTransactionListState();
}

class _PaginatedTransactionListState extends State<PaginatedTransactionList> {
  final List<Transaction> _transactions = [];
  int _page = 0;
  bool _hasMore = true;
  bool _isLoading = false;
  
  @override
  void initState() {
    super.initState();
    _loadMore();
  }
  
  Future<void> _loadMore() async {
    if (_isLoading || !_hasMore) return;
    
    setState(() => _isLoading = true);
    
    final newTransactions = await _repository.getPage(_page, 20);
    
    setState(() {
      _transactions.addAll(newTransactions);
      _page++;
      _hasMore = newTransactions.length == 20;
      _isLoading = false;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: _transactions.length + (_hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _transactions.length) {
          _loadMore();
          return Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            ),
          );
        }
        return TransactionItem(
          transaction: _transactions[index],
        );
      },
    );
  }
}
```

---

## 4. 状态管理优化

### 4.1 Provider优化

```dart
// 使用select减少重建
class TransactionAmount extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 只在amount变化时重建
    final amount = ref.watch(
      transactionProvider.select((state) => state.totalAmount),
    );
    
    return Text('¥${amount.toStringAsFixed(2)}');
  }
}

// 使用autoDispose自动释放
final transactionProvider = StateNotifierProvider.autoDispose<
    TransactionNotifier, TransactionState>((ref) {
  return TransactionNotifier();
});
```

### 4.2 避免不必要的重建

```dart
// 使用const构造函数
class TransactionItem extends StatelessWidget {
  final Transaction transaction;
  
  const TransactionItem({
    required this.transaction,
  });
  
  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(transaction.description),
      trailing: Text('¥${transaction.amount}'),
    );
  }
}

// 使用RepaintBoundary隔离重绘区域
RepaintBoundary(
  child: TransactionChart(data: chartData),
);
```

---

## 5. 数据库优化

### 5.1 索引优化

```dart
// lib/config/database/tables/transactions.dart

@DataClassName('Transaction')
class Transactions extends Table {
  // ... 其他字段
  
  @override
  List<Index> get indexes => [
    // 日期索引（常用查询）
    Index('idx_transaction_date', [transactionDate]),
    // 分类索引
    Index('idx_transaction_category', [categoryId]),
    // 复合索引
    Index('idx_transaction_date_type', [transactionDate, type]),
  ];
}
```

### 5.2 查询优化

```dart
// 使用Stream而非Future（实时更新）
Stream<List<Transaction>> watchToday() {
  final now = DateTime.now();
  final startOfDay = DateTime(now.year, now.month, now.day);
  final endOfDay = startOfDay.add(Duration(days: 1));
  
  return (select(transactions)
        ..where((t) => 
            t.transactionDate.isBetweenValues(startOfDay, endOfDay) &
            t.isDeleted.equals(false))
        ..orderBy([(t) => OrderingTerm.desc(t.transactionDate)]))
      .watch();
}

// 只查询需要的字段
Future<List<TransactionSummary>> getSummaries() async {
  return await customSelect(
    'SELECT id, amount, category_id FROM transactions WHERE is_deleted = 0',
    readsFrom: {transactions},
  ).get().then((rows) => rows.map((r) => TransactionSummary(
    id: r.read<int>('id'),
    amount: r.read<double>('amount'),
    categoryId: r.read<int>('category_id'),
  )).toList());
}
```

### 5.3 批量操作

```dart
// 使用事务批量插入
Future<void> insertBatch(List<TransactionsCompanion> items) async {
  await batch((batch) {
    batch.insertAll(transactions, items);
  });
}
```

---

## 6. 内存优化

### 6.1 图片内存管理

```dart
// 限制图片缓存
class AppImageCache {
  static const int maxCacheSize = 100; // 最大缓存100张图片
  
  static void configure() {
    PaintingBinding.instance.imageCache.maximumSize = maxCacheSize;
    PaintingBinding.instance.imageCache.maximumSizeBytes = 100 * 1024 * 1024; // 100MB
  }
}
```

### 6.2 及时释放资源

```dart
class MyWidget extends StatefulWidget {
  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  late final StreamSubscription _subscription;
  late final AnimationController _controller;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    _subscription = someStream.listen((data) {
      // 处理数据
    });
  }
  
  @override
  void dispose() {
    _subscription.cancel();
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
```

### 6.3 避免内存泄漏

```dart
// 使用WeakReference避免循环引用
class TransactionNotifier extends StateNotifier<TransactionState> {
  final WeakReference<AppDatabase> _databaseRef;
  
  TransactionNotifier(AppDatabase database)
      : _databaseRef = WeakReference(database),
        super(TransactionState.initial());
  
  Future<void> load() async {
    final database = _databaseRef.target;
    if (database == null) return; // 数据库已被释放
    
    final data = await database.select(database.transactions).get();
    state = TransactionState.loaded(data);
  }
}
```

---

## 7. 网络优化

### 7.1 请求缓存

```dart
class LlmCache {
  static final Map<String, CacheEntry> _cache = {};
  static const Duration _ttl = Duration(hours: 24);
  static const int _maxSize = 1000;
  
  static String? get(String key) {
    final entry = _cache[key];
    if (entry == null) return null;
    
    if (DateTime.now().difference(entry.createdAt) > _ttl) {
      _cache.remove(key);
      return null;
    }
    
    return entry.value;
  }
  
  static void set(String key, String value) {
    if (_cache.length >= _maxSize) {
      // 清理过期缓存
      _cache.removeWhere((key, entry) {
        return DateTime.now().difference(entry.createdAt) > _ttl;
      });
    }
    
    _cache[key] = CacheEntry(value, DateTime.now());
  }
}
```

### 7.2 请求合并

```dart
class RequestDeduplicator {
  static final Map<String, Future<dynamic>> _pending = {};
  
  static Future<T> deduplicate<T>(
    String key,
    Future<T> Function() request,
  ) {
    if (_pending.containsKey(key)) {
      return _pending[key] as Future<T>;
    }
    
    final future = request().whenComplete(() {
      _pending.remove(key);
    });
    
    _pending[key] = future;
    return future;
  }
}
```

### 7.3 离线队列

```dart
class OfflineQueue {
  static final List<PendingRequest> _queue = [];
  
  static void add(PendingRequest request) {
    _queue.add(request);
    _saveToDisk();
  }
  
  static Future<void> process() async {
    if (_queue.isEmpty) return;
    
    final connectivity = Connectivity();
    final result = await connectivity.checkConnectivity();
    if (result == ConnectivityResult.none) return;
    
    while (_queue.isNotEmpty) {
      final request = _queue.first;
      try {
        await request.execute();
        _queue.removeAt(0);
      } catch (e) {
        break; // 网络又断了
      }
    }
    
    _saveToDisk();
  }
  
  static Future<void> _saveToDisk() async {
    // 保存到本地，下次启动时恢复
  }
}
```

---

## 8. 渲染优化

### 8.1 避免布局抖动

```dart
// 使用SizedBox固定尺寸
SizedBox(
  width: 100,
  height: 40,
  child: Text('固定尺寸'),
);

// 使用ConstrainedBox设置约束
ConstrainedBox(
  constraints: BoxConstraints(
    minWidth: 100,
    maxWidth: 200,
    minHeight: 40,
  ),
  child: Text('约束尺寸'),
);
```

### 8.2 减少Widget树深度

```dart
// 不推荐
Container(
  padding: EdgeInsets.all(16),
  child: Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Text('内容'),
  ),
);

// 推荐
DecoratedBox(
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(12),
  ),
  child: Padding(
    padding: EdgeInsets.all(16),
    child: Text('内容'),
  ),
);
```

### 8.3 使用const

```dart
// 使用const减少重建
const Text('标题');
const Icon(Icons.home);
const SizedBox(width: 8);
```

---

## 9. 性能监控

### 9.1 帧率监控

```dart
class PerformanceMonitor {
  static void startFrameRateMonitoring() {
    SchedulerBinding.instance.addTimingsCallback((timings) {
      for (final timing in timings) {
        final buildDuration = timing.buildDuration;
        final rasterDuration = timing.rasterDuration;
        
        if (buildDuration.inMilliseconds > 16) {
          print('Slow build: ${buildDuration.inMilliseconds}ms');
        }
        if (rasterDuration.inMilliseconds > 16) {
          print('Slow raster: ${rasterDuration.inMilliseconds}ms');
        }
      }
    });
  }
}
```

### 9.2 内存监控

```dart
class MemoryMonitor {
  static void logMemoryUsage() {
    final info = ProcessInfo.currentRss;
    print('Memory usage: ${info ~/ 1024 ~/ 1024}MB');
  }
}
```

---

## 10. 优化清单

### 10.1 启动优化

- [ ] 延迟初始化非关键服务
- [ ] 数据库预热
- [ ] 启动画面优化

### 10.2 列表优化

- [ ] 使用ListView.builder
- [ ] 设置itemExtent
- [ ] 图片缓存优化
- [ ] 分页加载

### 10.3 状态管理优化

- [ ] 使用select减少重建
- [ ] 使用autoDispose
- [ ] 避免不必要的重建

### 10.4 数据库优化

- [ ] 添加索引
- [ ] 使用Stream
- [ ] 批量操作

### 10.5 内存优化

- [ ] 限制图片缓存
- [ ] 及时释放资源
- [ ] 避免内存泄漏

### 10.6 网络优化

- [ ] 请求缓存
- [ ] 请求合并
- [ ] 离线队列
