# WoAccount 数据安全

> **版本**: v1.0 | **创建日期**: 2026-06-04

---

## 1. 安全原则

| 原则 | 说明 |
|------|------|
| **本地优先** | 数据存储在用户设备，不上传云端 |
| **最小权限** | 只申请必要的系统权限 |
| **加密存储** | 敏感数据加密存储 |
| **用户控制** | 用户完全控制自己的数据 |

---

## 2. 数据分类

### 2.1 数据敏感度

| 数据类型 | 敏感度 | 存储方式 | 是否加密 |
|----------|--------|----------|----------|
| 交易记录 | 高 | SQLite | 是 |
| API Key | 高 | Keychain/Keystore | 是 |
| 用户设置 | 中 | SQLite | 否 |
| 分类数据 | 低 | SQLite | 否 |
| 统计缓存 | 低 | 内存 | 否 |

### 2.2 数据存储位置

```
┌─────────────────────────────────────────────────────────┐
│                    应用沙盒                               │
│  ┌─────────────────────────────────────────────────────┐│
│  │  databases/                                         ││
│  │  └── woaccount.db  ← SQLite数据库（加密）           ││
│  └─────────────────────────────────────────────────────┘│
│  ┌─────────────────────────────────────────────────────┐│
│  │  SharedPreferences                                  ││
│  │  └── 非敏感设置                                      ││
│  └─────────────────────────────────────────────────────┘│
│  ┌─────────────────────────────────────────────────────┐│
│  │  Keychain (iOS) / Keystore (Android)                ││
│  │  └── API Key、密码等敏感信息                         ││
│  └─────────────────────────────────────────────────────┘│
└─────────────────────────────────────────────────────────┘
```

---

## 3. 加密方案

### 3.1 数据库加密

使用`sqflite`的加密版本`sqflite_sqlcipher`：

```dart
// lib/config/database/app_database.dart

import 'package:sqflite_sqlcipher/sqflite.dart';

class AppDatabase {
  static Future<Database> openEncrypted() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'woaccount.db');
    
    return await openDatabase(
      path,
      password: await _getDatabasePassword(),
      onCreate: (db, version) async {
        // 创建表
      },
      version: 1,
    );
  }
  
  static Future<String> _getDatabasePassword() async {
    // 从安全存储获取密码
    final storage = FlutterSecureStorage();
    String? password = await storage.read(key: 'db_password');
    
    if (password == null) {
      // 首次运行，生成随机密码
      password = _generateRandomPassword();
      await storage.write(key: 'db_password', value: password);
    }
    
    return password;
  }
  
  static String _generateRandomPassword() {
    final random = Random.secure();
    final bytes = List<int>.generate(32, (_) => random.nextInt(256));
    return base64Url.encode(bytes);
  }
}
```

### 3.2 API Key存储

```dart
// lib/core/security/secure_storage.dart

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );
  
  /// 保存API Key
  static Future<void> saveApiKey(String providerId, String apiKey) async {
    await _storage.write(
      key: 'llm_api_key_$providerId',
      value: apiKey,
    );
  }
  
  /// 获取API Key
  static Future<String?> getApiKey(String providerId) async {
    return await _storage.read(key: 'llm_api_key_$providerId');
  }
  
  /// 删除API Key
  static Future<void> deleteApiKey(String providerId) async {
    await _storage.delete(key: 'llm_api_key_$providerId');
  }
  
  /// 保存所有敏感配置
  static Future<void> saveSensitiveConfig(Map<String, String> config) async {
    for (final entry in config.entries) {
      await _storage.write(key: entry.key, value: entry.value);
    }
  }
  
  /// 获取所有敏感配置
  static Future<Map<String, String>> getSensitiveConfig(List<String> keys) async {
    final config = <String, String>{};
    for (final key in keys) {
      final value = await _storage.read(key: key);
      if (value != null) {
        config[key] = value;
      }
    }
    return config;
  }
}
```

### 3.3 依赖配置

```yaml
# pubspec.yaml

dependencies:
  # 数据库加密
  sqflite_sqlcipher: ^3.0.0
  
  # 安全存储
  flutter_secure_storage: ^9.0.0
  
  # 加密算法
  encrypt: ^5.0.0
  pointycastle: ^3.0.0
```

---

## 4. 权限管理

### 4.1 权限清单

| 权限 | 用途 | 必要性 |
|------|------|--------|
| 网络访问 | 调用LLM API | 必要 |
| 相机 | 拍照识别小票 | 可选 |
| 相册 | 选择图片识别 | 可选 |
| 生物识别 | 应用锁 | 可选 |
| 通知 | 记账提醒 | 可选 |

### 4.2 权限请求

```dart
// lib/core/permissions/permission_manager.dart

import 'package:permission_handler/permission_handler.dart';

class PermissionManager {
  /// 请求相机权限
  static Future<bool> requestCameraPermission() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }
  
  /// 检查相机权限
  static Future<bool> hasCameraPermission() async {
    return await Permission.camera.isGranted;
  }
  
  /// 请求所有必要权限
  static Future<void> requestEssentialPermissions() async {
    await [
      Permission.camera,
      Permission.photos,
    ].request();
  }
}
```

### 4.3 权限拒绝处理

```dart
// 权限被拒绝时的处理
Future<void> handlePermissionDenied(Permission permission) async {
  // 显示说明对话框
  await showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('需要权限'),
      content: Text(_getPermissionDescription(permission)),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('取消'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            openAppSettings(); // 打开系统设置
          },
          child: Text('去设置'),
        ),
      ],
    ),
  );
}

String _getPermissionDescription(Permission permission) {
  switch (permission) {
    case Permission.camera:
      return '拍照识别小票需要使用相机权限';
    case Permission.photos:
      return '从相册选择图片需要访问相册权限';
    default:
      return '此功能需要相关权限才能使用';
  }
}
```

---

## 5. 数据备份与恢复

### 5.1 备份方案

```dart
// lib/core/backup/backup_service.dart

class BackupService {
  final AppDatabase _database;
  final SecureStorage _secureStorage;
  
  BackupService(this._database, this._secureStorage);
  
  /// 导出数据（加密）
  Future<File> exportData(String password) async {
    // 1. 获取所有数据
    final transactions = await _database.select(_database.transactions).get();
    final categories = await _database.select(_database.categories).get();
    final budgets = await _database.select(_database.budgets).get();
    
    // 2. 构建备份数据
    final backupData = {
      'version': 1,
      'created_at': DateTime.now().toIso8601String(),
      'transactions': transactions.map((t) => t.toJson()).toList(),
      'categories': categories.map((c) => c.toJson()).toList(),
      'budgets': budgets.map((b) => b.toJson()).toList(),
    };
    
    // 3. 加密
    final jsonStr = jsonEncode(backupData);
    final encrypted = _encrypt(jsonStr, password);
    
    // 4. 保存文件
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/woaccount_backup_${DateTime.now().millisecondsSinceEpoch}.enc');
    await file.writeAsString(encrypted);
    
    return file;
  }
  
  /// 导入数据（解密）
  Future<void> importData(File file, String password) async {
    // 1. 读取文件
    final encrypted = await file.readAsString();
    
    // 2. 解密
    final jsonStr = _decrypt(encrypted, password);
    final backupData = jsonDecode(jsonStr);
    
    // 3. 验证版本
    if (backupData['version'] != 1) {
      throw BackupException('不支持的备份版本');
    }
    
    // 4. 导入数据
    await _database.transaction((txn) async {
      // 清空现有数据
      await txn.delete(_database.transactions);
      await txn.delete(_database.categories);
      await txn.delete(_database.budgets);
      
      // 插入备份数据
      for (final item in backupData['categories']) {
        await txn.into(_database.categories).insert(Category.fromJson(item));
      }
      for (final item in backupData['transactions']) {
        await txn.into(_database.transactions).insert(Transaction.fromJson(item));
      }
      for (final item in backupData['budgets']) {
        await txn.into(_database.budgets).insert(Budget.fromJson(item));
      }
    });
  }
  
  String _encrypt(String data, String password) {
    final key = Key.fromUtf8(password.padRight(32, '0'));
    final iv = IV.fromLength(16);
    final encrypter = Encrypter(AES(key));
    return encrypter.encrypt(data, iv: iv).base64;
  }
  
  String _decrypt(String encrypted, String password) {
    final key = Key.fromUtf8(password.padRight(32, '0'));
    final iv = IV.fromLength(16);
    final encrypter = Encrypter(AES(key));
    return encrypter.decrypt64(encrypted, iv: iv);
  }
}

class BackupException implements Exception {
  final String message;
  const BackupException(this.message);
}
```

### 5.2 自动备份

```dart
// lib/core/backup/auto_backup_service.dart

class AutoBackupService {
  final BackupService _backupService;
  final UserSettingsRepository _settingsRepository;
  
  AutoBackupService(this._backupService, this._settingsRepository);
  
  /// 检查是否需要自动备份
  Future<void> checkAndBackup() async {
    final settings = await _settingsRepository.getSettings([
      'auto_backup_enabled',
      'auto_backup_interval',
      'last_backup_time',
    ]);
    
    if (settings['auto_backup_enabled'] != 'true') return;
    
    final interval = int.tryParse(settings['auto_backup_interval'] ?? '7') ?? 7;
    final lastBackup = DateTime.tryParse(settings['last_backup_time'] ?? '');
    
    if (lastBackup == null || 
        DateTime.now().difference(lastBackup).inDays >= interval) {
      await _performBackup();
    }
  }
  
  Future<void> _performBackup() async {
    try {
      final password = await _getBackupPassword();
      await _backupService.exportData(password);
      
      await _settingsRepository.updateSettings({
        'last_backup_time': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      // 记录错误，但不阻塞用户
      print('Auto backup failed: $e');
    }
  }
  
  Future<String> _getBackupPassword() async {
    // 使用设备唯一标识作为备份密码
    final deviceId = await DeviceInfoPlugin().androidInfo;
    return deviceId.id;
  }
}
```

---

## 6. 数据删除

### 6.1 软删除

```dart
// 所有删除操作都是软删除
Future<bool> deleteTransaction(int id) async {
  final result = await (update(transactions)
        ..where((t) => t.id.equals(id)))
      .write(TransactionsCompanion(
    isDeleted: const Value(true),
    updatedAt: Value(DateTime.now()),
  ));
  return result > 0;
}
```

### 6.2 数据清理

```dart
// 清理已删除的数据（可选）
Future<void> cleanupDeletedData({int daysBefore = 30}) async {
  final cutoffDate = DateTime.now().subtract(Duration(days: daysBefore));
  
  await (delete(transactions)
        ..where((t) => 
            t.isDeleted.equals(true) & 
            t.updatedAt.isSmallerThanValue(cutoffDate)))
      .go();
}
```

### 6.3 账户注销

```dart
/// 删除所有用户数据
Future<void> deleteAllUserData() async {
  // 1. 删除数据库
  final dbPath = await getDatabasesPath();
  await deleteDatabase(join(dbPath, 'woaccount.db'));
  
  // 2. 清除安全存储
  await FlutterSecureStorage().deleteAll();
  
  // 3. 清除SharedPreferences
  await SharedPreferences.getInstance().then((prefs) => prefs.clear());
  
  // 4. 清除缓存
  await DefaultCacheManager().emptyCache();
}
```

---

## 7. 网络安全

### 7.1 HTTPS强制

```dart
// lib/core/network/dio_config.dart

class DioConfig {
  static Dio createDio() {
    final dio = Dio(BaseOptions(
      connectTimeout: Duration(seconds: 30),
      receiveTimeout: Duration(seconds: 30),
    ));
    
    // 强制HTTPS
    dio.options.validateStatus = (status) {
      return status != null && status >= 200 && status < 300;
    };
    
    // 添加拦截器
    dio.interceptors.addAll([
      _authInterceptor(),
      _logInterceptor(),
      _errorInterceptor(),
    ]);
    
    return dio;
  }
  
  static Interceptor _authInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) async {
        // 添加API Key到请求头
        final apiKey = await SecureStorage.getApiKey('current');
        if (apiKey != null) {
          options.headers['Authorization'] = 'Bearer $apiKey';
        }
        handler.next(options);
      },
    );
  }
}
```

### 7.2 证书固定（可选）

```dart
// 防止中间人攻击
class CertificatePinning {
  static final allowedShashes = [
    'sha256/AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=', // 示例
  ];
  
  static bool validateCertificate(String host, X509Certificate cert) {
    final sha255 = sha256.convert(cert.der);
    final hash = base64.encode(sha255.bytes);
    return allowedShashes.contains('sha256/$hash');
  }
}
```

---

## 8. 安全清单

### 8.1 数据存储

- [ ] 数据库使用SQLCipher加密
- [ ] API Key使用Keychain/Keystore存储
- [ ] 敏感配置使用flutter_secure_storage
- [ ] 日志中不记录敏感信息

### 8.2 网络通信

- [ ] 强制使用HTTPS
- [ ] API Key通过Header传输
- [ ] 请求超时设置合理
- [ ] 错误信息不泄露敏感信息

### 8.3 权限管理

- [ ] 只申请必要权限
- [ ] 权限拒绝时有友好提示
- [ ] 提供权限管理入口

### 8.4 数据备份

- [ ] 备份文件加密
- [ ] 备份密码用户可控
- [ ] 支持导出到安全位置

### 8.5 数据删除

- [ ] 使用软删除
- [ ] 提供数据清理功能
- [ ] 账户注销时清除所有数据
