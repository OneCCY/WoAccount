import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

/// 媒体类型
enum MediaType {
  image('images', 'jpg'),
  audio('audio', 'm4a');

  final String subDir;
  final String extension;
  const MediaType(this.subDir, this.extension);
}

/// 媒体文件本地存储服务
///
/// 目录结构：
/// {appDir}/media/
///   images/
///     2026/06/1717812345678.jpg
///   audio/
///     2026/06/1717812345678.m4a
class MediaStorageService {
  static const _mediaDir = 'media';

  /// 获取应用媒体根目录
  Future<String> _getBaseDir() async {
    final appDir = await getApplicationDocumentsDirectory();
    return p.join(appDir.path, _mediaDir);
  }

  /// 获取指定类型的媒体目录（自动创建）
  Future<Directory> _getTypeDir(MediaType type) async {
    final base = await _getBaseDir();
    final now = DateTime.now();
    final subPath = p.join(
      base,
      type.subDir,
      '${now.year}',
      now.month.toString().padLeft(2, '0'),
    );
    final dir = Directory(subPath);
    if (!dir.existsSync()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  /// 保存图片字节数据，返回完整文件路径
  Future<String> saveImage(Uint8List bytes, {String? filename}) async {
    final dir = await _getTypeDir(MediaType.image);
    final name = filename ?? '${DateTime.now().millisecondsSinceEpoch}.jpg';
    final file = File(p.join(dir.path, name));
    await file.writeAsBytes(bytes);
    return file.path;
  }

  /// 保存图片文件（从临时路径复制到永久存储），返回完整文件路径
  Future<String> saveImageFile(String tempPath, {String? filename}) async {
    final dir = await _getTypeDir(MediaType.image);
    final name = filename ?? '${DateTime.now().millisecondsSinceEpoch}.jpg';
    final destPath = p.join(dir.path, name);
    final tempFile = File(tempPath);
    if (tempFile.existsSync()) {
      await tempFile.copy(destPath);
    }
    return destPath;
  }

  /// 保存音频文件（从临时路径移动到永久存储），返回完整文件路径
  Future<String> saveAudio(String tempPath, {String? filename}) async {
    final dir = await _getTypeDir(MediaType.audio);
    final name = filename ?? '${DateTime.now().millisecondsSinceEpoch}.m4a';
    final destPath = p.join(dir.path, name);
    final tempFile = File(tempPath);
    if (tempFile.existsSync()) {
      await tempFile.copy(destPath);
      // 不删除临时文件，由调用方决定
    }
    return destPath;
  }

  /// 删除媒体文件
  Future<void> deleteFile(String filePath) async {
    final file = File(filePath);
    if (file.existsSync()) {
      await file.delete();
    }
  }

  /// 获取文件大小（字节）
  Future<int> getFileSize(String filePath) async {
    final file = File(filePath);
    if (!file.existsSync()) return 0;
    return await file.length();
  }

  /// 检查文件是否存在
  bool fileExists(String filePath) {
    return File(filePath).existsSync();
  }
}
