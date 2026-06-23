import 'dart:async';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:speech_to_text/speech_recognition_result.dart';

/// 语音识别方式
enum SttMode {
  /// 平台原生（Android/iOS 内置语音识别，免费、离线可用）
  platform,

  /// Whisper API（需要 LLM provider 配置 audio 模型）
  whisper,
}

/// 平台原生语音转文字服务
///
/// 基于 speech_to_text 包，使用 Android/iOS 系统内置的语音识别引擎。
/// 优点：免费、无需 API key、支持离线、中文识别质量好。
/// 适用场景：日常记账语音输入。
class PlatformSttService {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _initialized = false;

  /// 识别状态回调
  final StreamController<SttState> _stateController = StreamController<SttState>.broadcast();
  Stream<SttState> get stateStream => _stateController.stream;

  /// 实时识别文本回调（流式）
  final StreamController<String> _partialController = StreamController<String>.broadcast();
  Stream<String> get partialTextStream => _partialController.stream;

  /// 是否正在识别
  bool get isListening => _speech.isListening;

  /// 初始化语音识别引擎
  Future<bool> initialize() async {
    if (_initialized) return true;
    try {
      _initialized = await _speech.initialize(
        onError: (error) {
          _stateController.add(SttState.error(error.errorMsg));
        },
        onStatus: (status) {
          if (status == 'done' || status == 'notListening') {
            _stateController.add(SttState.stopped);
          }
        },
      );
      return _initialized;
    } catch (_) {
      _initialized = false;
      return false;
    }
  }

  /// 检查引擎是否可用（已初始化且设备支持）
  Future<bool> isAvailable() async {
    if (!_initialized) {
      return await initialize();
    }
    return _initialized;
  }

  /// 开始实时语音识别
  ///
  /// [localeId] 识别语言，如 'zh_CN'、'en_US'
  /// 识别结果通过 [partialTextStream] 流式返回
  Future<bool> startListening({String localeId = 'zh_CN'}) async {
    if (!_initialized) {
      final ok = await initialize();
      if (!ok) return false;
    }

    _stateController.add(SttState.listening);

    await _speech.listen(
      onResult: _onSpeechResult,
      localeId: localeId,
      listenMode: stt.ListenMode.dictation,
      cancelOnError: true,
      partialResults: true,
    );

    return true;
  }

  /// 停止识别并返回最终结果
  Future<String?> stopListening() async {
    await _speech.stop();
    _stateController.add(SttState.stopped);
    // 最终结果已经在 _lastFinalResult 中
    return _lastFinalResult;
  }

  /// 取消识别
  Future<void> cancel() async {
    await _speech.cancel();
    _lastFinalResult = null;
    _stateController.add(SttState.stopped);
  }

  String? _lastFinalResult;

  void _onSpeechResult(SpeechRecognitionResult result) {
    if (result.recognizedWords.isNotEmpty) {
      _partialController.add(result.recognizedWords);
    }
    if (result.finalResult) {
      _lastFinalResult = result.recognizedWords;
    }
  }

  /// 获取可用的识别语言列表
  Future<List<SttLocale>> getAvailableLocales() async {
    if (!_initialized) {
      await initialize();
    }
    final locales = await _speech.locales();
    return locales.map((l) => SttLocale(
      id: l.localeId,
      name: l.name,
    )).toList();
  }

  void dispose() {
    _speech.cancel();
    _stateController.close();
    _partialController.close();
  }
}

/// 识别状态
sealed class SttState {
  const SttState();
  static const idle = SttIdle();
  static const listening = SttListening();
  static const stopped = SttStopped();
  static SttError error(String message) => SttError(message);
}

class SttIdle extends SttState { const SttIdle(); }
class SttListening extends SttState { const SttListening(); }
class SttStopped extends SttState { const SttStopped(); }
class SttError extends SttState {
  final String message;
  const SttError(this.message);
}

/// 识别语言
class SttLocale {
  final String id;
  final String name;
  const SttLocale({required this.id, required this.name});
}
