# WoAccount 交互流程设计

> **版本**: v1.0 | **创建日期**: 2026-06-04

---

## 1. 页面导航结构

```
┌─────────────────────────────────────────────────────────┐
│                      底部导航栏                           │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐    │
│  │    账单      │  │    记账      │  │    我的      │    │
│  │  (左Tab)    │  │  (中Tab)    │  │  (右Tab)    │    │
│  └──────┬──────┘  └──────┬──────┘  └──────┬──────┘    │
│         │                │                │            │
│         ▼                ▼                ▼            │
│  TransactionList    HomePage         ProfilePage       │
└─────────────────────────────────────────────────────────┘
```

---

## 2. 核心交互流程

### 2.1 记账流程（手动）

```
用户点击 ➕ 按钮
       │
       ▼
┌─────────────────────────────────────┐
│         手动记账页面                  │
│  ┌─────────────────────────────┐   │
│  │  [支出]  [收入]  [其他]     │   │
│  └─────────────────────────────┘   │
│  ┌──┬──┬──┬──┬──┐                 │
│  │🍜│🚗│🛒│🏠│🎮│ ← 分类网格     │
│  │餐饮│交通│购物│住房│娱乐│         │
│  └──┴──┴──┴──┴──┘                 │
│  ┌─────────────────────────────┐   │
│  │  添加备注...          0.00  │   │
│  └─────────────────────────────┘   │
│  ┌──┬──┬──┬────┐                  │
│  │1 │2 │3 │今天 │                  │
│  │4 │5 │6 │ +  │                  │
│  │7 │8 │9 │ -  │                  │
│  │. │0 │⌫ │完成 │                  │
│  └──┴──┴──┴────┘                  │
└─────────────────────────────────────┘
       │
       │ 用户输入金额并点击"完成"
       ▼
┌─────────────────────────────────────┐
│         保存成功                      │
│  - 金额飞入列表动画                  │
│  - 显示成功提示                      │
│  - 返回记账首页                      │
└─────────────────────────────────────┘
```

### 2.2 记账流程（AI）

```
用户在输入框输入："午饭拉面25"
       │
       ▼
┌─────────────────────────────────────┐
│         AI解析中...                  │
│  - 显示加载动画                      │
│  - 显示"正在识别..."                 │
└─────────────────────────────────────┘
       │
       ▼
┌─────────────────────────────────────┐
│         AI解析结果卡片                │
│  ┌─────────────────────────────┐   │
│  │  原始输入: 午饭拉面25        │   │
│  │                             │   │
│  │  💰 金额:     ¥25.00       │   │
│  │  🍜 分类:     餐饮 > 午餐   │   │
│  │  📝 描述:     午饭拉面       │   │
│  │  📅 日期:     今天          │   │
│  │  ⚡ 置信度:   95%           │   │
│  │                             │   │
│  │  [修改]        [确认记账]   │   │
│  └─────────────────────────────┘   │
└─────────────────────────────────────┘
       │
       │ 用户点击"确认记账"
       ▼
┌─────────────────────────────────────┐
│         保存成功                      │
└─────────────────────────────────────┘
```

### 2.3 分类选择流程

```
用户点击分类（如"餐饮"）
       │
       ▼
┌─────────────────────────────────────┐
│         二级分类浮层                  │
│  ┌─────────────────────────────┐   │
│  │  餐饮                    ✕  │   │
│  ├─────────────────────────────┤   │
│  │  🥐    🍱    🍲    ☕    🍪  │   │
│  │  早餐  午餐  晚餐  饮料  零食│   │
│  └─────────────────────────────┘   │
└─────────────────────────────────────┘
       │
       │ 用户选择子分类（如"午餐"）
       ▼
┌─────────────────────────────────────┐
│         已选分类显示                  │
│  "餐饮/午餐"                        │
└─────────────────────────────────────┘
```

---

## 3. 手势交互

### 3.1 列表手势

| 手势 | 位置 | 效果 |
|------|------|------|
| 左滑 | 交易列表项 | 显示删除按钮 |
| 右滑 | 已滑开的项 | 关闭删除按钮 |
| 下拉 | 列表顶部 | 刷新数据 |
| 长按 | 列表项 | 编辑/复制选项 |

### 3.2 实现示例

```dart
// 左滑删除
class SwipeToDeleteItem extends StatefulWidget {
  final Widget child;
  final VoidCallback onDelete;
  
  const SwipeToDeleteItem({
    required this.child,
    required this.onDelete,
  });
  
  @override
  State<SwipeToDeleteItem> createState() => _SwipeToDeleteItemState();
}

class _SwipeToDeleteItemState extends State<SwipeToDeleteItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _animation;
  double _dragExtent = 0;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    _animation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset(-0.3, 0),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));
  }
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragUpdate: (details) {
        setState(() {
          _dragExtent += details.delta.dx;
          _dragExtent = _dragExtent.clamp(-100, 0);
        });
      },
      onHorizontalDragEnd: (details) {
        if (_dragExtent < -60) {
          _controller.forward();
        } else {
          _controller.reverse();
        }
        setState(() => _dragExtent = 0);
      },
      child: SlideTransition(
        position: _animation,
        child: Stack(
          children: [
            widget.child,
            if (_controller.isCompleted)
              Positioned(
                right: 0,
                top: 0,
                bottom: 0,
                child: GestureDetector(
                  onTap: widget.onDelete,
                  child: Container(
                    width: 72,
                    color: Colors.red,
                    alignment: Alignment.center,
                    child: Text(
                      '删除',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
```

---

## 4. 动画设计

### 4.1 页面转场动画

```dart
// 从底部滑入（手动记账页面）
GoRoute(
  path: '/manual-entry',
  pageBuilder: (context, state) => CustomTransitionPage(
    child: ManualEntryPage(),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return SlideTransition(
        position: Tween<Offset>(
          begin: Offset(0, 1),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        )),
        child: child,
      );
    },
    transitionDuration: Duration(milliseconds: 400),
  ),
);

// 从右侧滑入（详情页面）
GoRoute(
  path: '/transaction/:id',
  pageBuilder: (context, state) => CustomTransitionPage(
    child: TransactionDetailPage(),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return SlideTransition(
        position: Tween<Offset>(
          begin: Offset(1, 0),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        )),
        child: child,
      );
    },
    transitionDuration: Duration(milliseconds: 350),
  ),
);
```

### 4.2 列表加载动画

```dart
// 依次淡入
class StaggeredListView extends StatelessWidget {
  final List<Widget> children;
  
  const StaggeredListView({required this.children});
  
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: children.length,
      itemBuilder: (context, index) {
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(0, 20 * (1 - value)),
              child: Opacity(
                opacity: value,
                child: child,
              ),
            );
          },
          child: children[index],
        );
      },
    );
  }
}
```

### 4.3 金额变化动画

```dart
// 数字滚动效果
class AnimatedAmount extends StatelessWidget {
  final double amount;
  final TextStyle style;
  
  const AnimatedAmount({
    required this.amount,
    required this.style,
  });
  
  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: amount),
      duration: Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Text(
          '¥${value.toStringAsFixed(2)}',
          style: style,
        );
      },
    );
  }
}
```

### 4.4 按钮按压效果

```dart
// 按压缩放
class PressableButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  
  const PressableButton({
    required this.child,
    required this.onTap,
  });
  
  @override
  State<PressableButton> createState() => _PressableButtonState();
}

class _PressableButtonState extends State<PressableButton> {
  bool _isPressed = false;
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.95 : 1.0,
        duration: Duration(milliseconds: 100),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}
```

---

## 5. 反馈设计

### 5.1 成功反馈

```dart
// 记账成功
void showSuccessFeedback(BuildContext context) {
  // 1. 震动反馈
  HapticFeedback.lightImpact();
  
  // 2. 显示SnackBar
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          Icon(Icons.check_circle, color: Colors.white),
          SizedBox(width: 8),
          Text('记账成功'),
        ],
      ),
      backgroundColor: AppColors.success,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      duration: Duration(seconds: 2),
    ),
  );
}
```

### 5.2 错误反馈

```dart
// 显示错误
void showErrorFeedback(BuildContext context, String message) {
  // 1. 震动反馈
  HapticFeedback.heavyImpact();
  
  // 2. 显示SnackBar
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.white),
          SizedBox(width: 8),
          Expanded(child: Text(message)),
        ],
      ),
      backgroundColor: AppColors.error,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      action: SnackBarAction(
        label: '重试',
        textColor: Colors.white,
        onPressed: () {
          // 重试逻辑
        },
      ),
    ),
  );
}
```

### 5.3 确认对话框

```dart
// 删除确认
Future<bool> showDeleteConfirmation(BuildContext context) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Text('确认删除'),
      content: Text('删除后无法恢复，确定要删除吗？'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text('取消'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          style: TextButton.styleFrom(
            foregroundColor: AppColors.error,
          ),
          child: Text('删除'),
        ),
      ],
    ),
  );
  
  return result ?? false;
}
```

---

## 6. 加载状态

### 6.1 骨架屏

```dart
// 交易列表骨架屏
class TransactionListSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 10,
      itemBuilder: (context, index) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              // 图标占位
              ShimmerWidget(
                width: 40,
                height: 40,
                borderRadius: 10,
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 标题占位
                    ShimmerWidget(
                      width: 120,
                      height: 16,
                    ),
                    SizedBox(height: 4),
                    // 副标题占位
                    ShimmerWidget(
                      width: 80,
                      height: 12,
                    ),
                  ],
                ),
              ),
              // 金额占位
              ShimmerWidget(
                width: 60,
                height: 20,
              ),
            ],
          ),
        );
      },
    );
  }
}

class ShimmerWidget extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;
  
  const ShimmerWidget({
    required this.width,
    required this.height,
    this.borderRadius = 4,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}
```

### 6.2 加载指示器

```dart
// 全屏加载
class FullScreenLoading extends StatelessWidget {
  final String message;
  
  const FullScreenLoading({this.message = '加载中...'});
  
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: AppColors.primary,
          ),
          SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
```

---

## 7. 空状态设计

### 7.1 空列表

```dart
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? actionText;
  final VoidCallback? onAction;
  
  const EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.actionText,
    this.onAction,
  });
  
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: AppColors.textHint,
            ),
            SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            if (actionText != null && onAction != null) ...[
              SizedBox(height: 24),
              PrimaryButton(
                text: actionText!,
                onPressed: onAction,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// 使用示例
EmptyState(
  icon: Icons.receipt_long_outlined,
  title: '暂无交易记录',
  subtitle: '点击下方按钮开始记账',
  actionText: '记一笔',
  onAction: () => context.push('/manual-entry'),
)
```

---

## 8. 交互流程清单

### 8.1 记账流程

- [ ] 手动记账完整流程
- [ ] AI记账完整流程
- [ ] 分类选择流程
- [ ] 日期选择流程
- [ ] 备注输入流程

### 8.2 查询流程

- [ ] 按日期查询
- [ ] 按分类查询
- [ ] 搜索功能
- [ ] AI对话查询

### 8.3 设置流程

- [ ] LLM配置流程
- [ ] 主题切换流程
- [ ] 数据备份流程
- [ ] 数据恢复流程

### 8.4 异常流程

- [ ] 网络断开提示
- [ ] AI解析失败降级
- [ ] 数据库错误处理
- [ ] 权限拒绝处理
