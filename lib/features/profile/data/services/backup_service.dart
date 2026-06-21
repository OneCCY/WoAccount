import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';

/// 备份频率
enum BackupFrequency {
  daily,   // 每天
  weekly,  // 每周
  monthly, // 每月
  manual;  // 仅手动

  String displayName(dynamic l10n) {
    // 使用 l10n 的方法由调用方传入，这里返回 key
    return name;
  }
}

/// 数据备份/恢复服务
class BackupService {
  static const _keyAutoBackup = 'autoBackup';
  static const _keyBackupFrequency = 'backupFrequency';
  static const _keyLastBackupTime = 'lastBackupTime';

  /// 是否启用自动备份
  Future<bool> isAutoBackupEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyAutoBackup) ?? true;
  }

  /// 设置自动备份开关
  Future<void> setAutoBackup(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyAutoBackup, enabled);
  }

  /// 获取备份频率
  Future<BackupFrequency> getBackupFrequency() async {
    final prefs = await SharedPreferences.getInstance();
    final index = prefs.getInt(_keyBackupFrequency) ?? 0;
    return BackupFrequency.values[index.clamp(0, BackupFrequency.values.length - 1)];
  }

  /// 设置备份频率
  Future<void> setBackupFrequency(BackupFrequency frequency) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyBackupFrequency, frequency.index);
  }

  /// 检查是否需要自动备份（启动时调用）
  Future<bool> shouldAutoBackup() async {
    final enabled = await isAutoBackupEnabled();
    if (!enabled) return false;

    final frequency = await getBackupFrequency();
    if (frequency == BackupFrequency.manual) return false;

    final prefs = await SharedPreferences.getInstance();
    final lastBackupMs = prefs.getInt(_keyLastBackupTime);
    if (lastBackupMs == null) return true;

    final lastBackup = DateTime.fromMillisecondsSinceEpoch(lastBackupMs);
    final now = DateTime.now();
    final diff = now.difference(lastBackup);

    switch (frequency) {
      case BackupFrequency.daily:
        return diff.inHours >= 24;
      case BackupFrequency.weekly:
        return diff.inDays >= 7;
      case BackupFrequency.monthly:
        return diff.inDays >= 30;
      case BackupFrequency.manual:
        return false;
    }
  }

  /// 执行自动备份（SQLite 复制），返回备份文件路径
  Future<String?> autoBackup() async {
    final should = await shouldAutoBackup();
    if (!should) return null;
    return createBackup();
  }

  /// 创建备份，返回备份文件路径
  Future<String> createBackup() async {
    final dbPath = await _getDbPath();
    final backupDir = await _getBackupDir();
    final timestamp = DateTime.now().toString().replaceAll(RegExp(r'[: .]'), '').substring(0, 14);
    final backupPath = p.join(backupDir.path, 'wo_account_backup_$timestamp.sqlite');

    await File(dbPath).copy(backupPath);

    // 更新最后备份时间
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyLastBackupTime, DateTime.now().millisecondsSinceEpoch);

    return backupPath;
  }

  /// 获取所有备份文件列表（按时间倒序）
  Future<List<FileSystemEntity>> listBackups() async {
    final dir = await _getBackupDir();
    if (!dir.existsSync()) return [];

    return dir.listSync()
        .where((f) => f.path.endsWith('.sqlite') && f.path.contains('backup'))
        .toList()
      ..sort((a, b) => b.statSync().modified.compareTo(a.statSync().modified));
  }

  /// 从备份文件恢复数据
  Future<void> restoreFromBackup(String backupPath) async {
    final dbPath = await _getDbPath();
    await File(backupPath).copy(dbPath);
  }

  /// 删除指定备份文件
  Future<void> deleteBackup(String backupPath) async {
    final file = File(backupPath);
    if (await file.exists()) {
      await file.delete();
    }
  }

  Future<String> _getDbPath() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    return p.join(dbFolder.path, 'wo_account.sqlite');
  }

  Future<Directory> _getBackupDir() async {
    final dir = Directory(p.join(
      (await getApplicationDocumentsDirectory()).path,
      'backups',
    ));
    if (!dir.existsSync()) {
      await dir.create(recursive: true);
    }
    return dir;
  }
}
