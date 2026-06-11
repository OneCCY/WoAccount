import 'package:wo_account/features/ai/data/models/llm_config.dart';
import 'package:wo_account/l10n/app_localizations.dart';

/// Resolves [LlmException] error codes to localized messages.
///
/// Data-layer code throws [LlmException] with an [LlmException.errorCode]
/// matching an ARB key. UI-layer code calls [resolveLlmError] to get the
/// localized user-facing message.
String resolveLlmError(Object error, AppLocalizations l10n) {
  if (error is LlmException && error.errorCode != null) {
    final resolved = _resolve(error.errorCode!, l10n, error.message);
    if (resolved != null) return resolved;
  }
  // Fallback: strip "LlmException: " prefix from toString()
  final s = error.toString();
  return s.startsWith('LlmException: ') ? s.substring(14) : s;
}

String? _resolve(String errorCode, AppLocalizations l10n, String fallback) {
  switch (errorCode) {
    // --- LLM errors ---
    case 'llmErrorNoModelForCapability':
      return l10n.llmErrorNoModelForCapability;
    case 'llmErrorNoProviderConfigured':
      return l10n.llmErrorNoProviderConfigured;
    case 'llmErrorNoProviderOrInput':
      return l10n.llmErrorNoProviderOrInput;
    case 'llmErrorCannotParseResponse':
      return l10n.llmErrorCannotParseResponse;
    case 'llmErrorInvalidResponseFormat':
      return l10n.llmErrorInvalidResponseFormat;
    case 'llmErrorParseFailed':
      return l10n.llmErrorParseFailed(fallback);
    case 'llmErrorTimeout':
      return l10n.llmErrorTimeout;
    case 'llmErrorInvalidApiKey':
      return l10n.llmErrorInvalidApiKey;
    case 'llmErrorRateLimit':
      return l10n.llmErrorRateLimit;
    case 'llmErrorForbidden':
      return l10n.llmErrorForbidden;
    case 'llmErrorRequestFailed':
      return l10n.llmErrorRequestFailed(fallback);
    case 'llmErrorNetworkFailed':
      return l10n.llmErrorNetworkFailed;
    case 'llmErrorRequestFailedWithMessage':
      return l10n.llmErrorRequestFailedWithMessage(fallback);
    // --- Vision errors ---
    case 'visionErrorNoModelConfigured':
      return l10n.visionErrorNoModelConfigured;
    case 'visionErrorImageNotFound':
      return l10n.visionErrorImageNotFound;
    case 'visionErrorRecognitionFailed':
      return l10n.visionErrorRecognitionFailed(fallback);
    // --- Voice errors ---
    case 'voiceErrorNoModelConfigured':
      return l10n.voiceErrorNoModelConfigured;
    case 'voiceErrorAudioNotFound':
      return l10n.voiceErrorAudioNotFound;
    case 'voiceErrorInvalidResponseFormat':
      return l10n.voiceErrorInvalidResponseFormat;
    case 'voiceErrorTranscriptionFailed':
      return l10n.voiceErrorTranscriptionFailed(fallback);
    // --- Pipeline errors ---
    case 'pipelineErrorEmptyVoiceResult':
      return l10n.pipelineErrorEmptyVoiceResult;
    case 'pipelineErrorEmptyImageResult':
      return l10n.pipelineErrorEmptyImageResult;
    // --- Settings errors ---
    case 'llmSettingsGetModelListError':
      return l10n.llmSettingsGetModelListError;
    default:
      return null;
  }
}
