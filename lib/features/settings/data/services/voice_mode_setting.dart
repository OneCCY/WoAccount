import 'package:shared_preferences/shared_preferences.dart';
import '../../../chat/presentation/widgets/chat_input_bar.dart';

/// 语音输入模式设置管理
class VoiceModeSetting {
  static const _key = 'voice_input_mode';

  /// 获取当前语音输入模式
  static Future<VoiceInputMode> getMode() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_key);
    return value == 'whisper' ? VoiceInputMode.whisper : VoiceInputMode.platform;
  }

  /// 保存语音输入模式
  static Future<void> setMode(VoiceInputMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, mode == VoiceInputMode.whisper ? 'whisper' : 'platform');
  }
}
