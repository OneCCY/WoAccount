# AI 图片识别优化方案

> 目标：消除 OOM 风险、减少延迟和 token 费用、提升识别准确度
> 涉及文件：`image_recognition_service.dart`、`transaction_pipeline.dart`、`ai_chat_page.dart`、`llm_repository_impl.dart`

---

## 优化项 1：图片压缩后再发送

**问题**: `image_recognition_service.dart:38-39` 将整张图片全量读入内存再 base64 编码。手机照片 3-5MB → base64 后 4-7MB，低端设备 OOM 风险。且大图片增加上传时间和 token 消耗（Vision 模型按图片 token 计费）。

**文件**: `lib/features/vision_ai/data/services/image_recognition_service.dart:38-43`

**方案**:
- 在 base64 编码前增加图片压缩/缩放步骤：
  ```dart
  // 1. 读取原始图片
  final imageBytes = await file.readAsBytes();
  
  // 2. 解码并缩放（最长边不超过 2048px）
  final codec = await instantiateImageCodec(imageBytes);
  final frame = await codec.getNextFrame();
  final original = frame.image;
  
  int targetWidth = original.width;
  int targetHeight = original.height;
  const maxDimension = 2048;
  if (targetWidth > maxDimension || targetHeight > maxDimension) {
    final ratio = maxDimension / max(targetWidth, targetHeight);
    targetWidth = (targetWidth * ratio).round();
    targetHeight = (targetHeight * ratio).round();
  }
  
  // 3. 绘制缩放后的图片并编码为 JPEG（质量 85%）
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  canvas.drawImageRect(original, ...);
  final resized = await recorder.endRecording().toImage(targetWidth, targetHeight);
  final byteData = await resized.toByteData(format: ui.ImageByteFormat.png);
  
  // 4. base64 编码
  final base64Image = base64Encode(byteData!.buffer.asUint8List());
  ```
- 引入 `flutter_image_compress` 包（更高效的原生压缩）或使用 `dart:ui` 轻量方案
- 预期效果：5MB 照片 → ~200-500KB，上传速度提升 10x，token 费用降低 80%

**依赖**: 需评估是否引入 `flutter_image_compress` 包。如果不想增加依赖，使用 `dart:ui` + `ImageByteFormat.png` 即可。

**验证**: 3000×4000 照片压缩后 < 500KB，识别准确度不下降

---

## 优化项 2：单步图片记账（合并两次 LLM 调用）

**问题**: 当前图片识别走两步 LLM 调用：
1. `image_recognition_service.dart` — Vision 模型识别图片 → 纯文本
2. `llm_repository_impl.dart:parseTransaction` — Text 模型解析记账 → JSON

两次调用 = 2 倍延迟（3-8s → 5-12s）+ 2 倍 token 费用。对于 GPT-4o / Claude Sonnet 这种同时支持 vision + structured output 的模型，完全可以一步完成。

**文件**: `lib/core/ai/transaction_pipeline.dart:139-167`、`lib/features/vision_ai/data/services/image_recognition_service.dart`

**方案**:
- 新增 `ImageRecognitionService.recognizeTransaction` 方法，直接返回 `List<TransactionParseResult>`：
  ```dart
  /// 一步完成：图片 → 结构化交易数据
  Future<List<TransactionParseResult>> recognizeTransaction(
    LlmProvider provider,
    String imagePath, {
    String? categoryTaxonomy,
    String locale = 'zh',
  }) async {
    final model = provider.getModelForCapability(ModelCapability.vision);
    // 构建包含分类体系的 vision prompt
    final prompt = _buildTransactionVisionPrompt(categoryTaxonomy, locale);
    // 直接要求 vision 模型返回 JSON
    final responseText = await _callVisionApi(provider, model, imagePath, prompt);
    return _parseTransactionResponse(responseText);
  }
  ```
- 新增 `_buildTransactionVisionPrompt`，将记账解析的 JSON schema 要求嵌入到 vision prompt 中
- 修改 `TransactionPipeline.processImage`：
  ```dart
  Future<PipelineResult> processImage({...}) async {
    final savedPath = await _mediaStorage.saveImageFile(imageTempPath);
    
    // 优先尝试单步识别
    try {
      final results = await _imageService.recognizeTransaction(
        provider, savedPath, categoryTaxonomy: categoryTaxonomy, locale: locale,
      );
      if (results.isNotEmpty) {
        return PipelineResult(normalizedText: '图片识别', transactions: results, source: InputSource.image, mediaFilePath: savedPath);
      }
    } catch (_) {}
    
    // 降级：两步流程（原有逻辑）
    final recognizedText = await _imageService.recognize(provider, savedPath);
    final results = await _llmRepo.parseTransaction(recognizedText, ...);
    return PipelineResult(...);
  }
  ```
- 判断是否支持单步：检查 vision 模型是否为 gpt-4o/claude-sonnet/qwen-vl-max 等高能力模型

**改动文件**:
- `image_recognition_service.dart`: 新增 `recognizeTransaction` 和相关方法
- `transaction_pipeline.dart`: 修改 `processImage` 逻辑
- `llm_repository_impl.dart`: 将 `_parseTransactionResponse` 提取为公共方法或工具方法

**验证**: 使用 GPT-4o 拍小票 → 1 次 API 调用 → 直接出确认卡片（延迟从 ~8s 降至 ~4s）

---

## 优化项 3：图片格式支持扩展

**问题**: `image_recognition_service.dart:42-43` 只判断 PNG 和 JPEG 两种格式。iOS 默认 HEIC/HEIF，部分 Android 使用 WebP。

**文件**: `lib/features/vision_ai/data/services/image_recognition_service.dart:42-43`

**方案**:
- 扩展 MIME 类型映射：
  ```dart
  String _detectMimeType(String path) {
    final ext = path.toLowerCase().split('.').last;
    switch (ext) {
      case 'png': return 'image/png';
      case 'jpg':
      case 'jpeg': return 'image/jpeg';
      case 'webp': return 'image/webp';
      case 'heic': return 'image/heic';
      case 'heif': return 'image/heif';
      case 'gif': return 'image/gif';
      case 'bmp': return 'image/bmp';
      default: return 'image/jpeg';  // 安全兜底
    }
  }
  ```
- 如果实施了优化项 1（图片压缩），压缩后的输出统一为 JPEG，则此问题自动解决

**验证**: 选择 HEIC 格式照片 → 正确识别为 `image/heic` → API 调用成功

---

## 优化项 4：图片识别结果的结构化回退

**问题**: 当前 `image_recognition_service.dart` 的 `_defaultReceiptPrompt`（第 153-165 行）只要求返回纯文本描述，再由 text 模型解析。但如果走单步流程（优化项 2），需要直接返回 JSON。对于不支持 JSON mode 的 vision 模型，需要有鲁棒的回退。

**文件**: `lib/features/vision_ai/data/services/image_recognition_service.dart:153-165`

**方案**:
- 将 `_defaultReceiptPrompt` 分为两个版本：
  - `_receiptTextPrompt`: 现有的纯文本描述（用于两步流程）
  - `_receiptJsonPrompt`: 要求返回 JSON 的 prompt（用于单步流程），包含分类体系
- `_receiptJsonPrompt` 内容：
  ```
  请识别这张图片中的消费信息，严格按以下 JSON 格式输出：
  
  $categoryTaxonomy
  
  [
    {
      "type": "expense",
      "amount": 数字,
      "category": "一级分类名",
      "subcategory": "二级分类名",
      "description": "消费描述",
      "date": "YYYY-MM-DD",
      "payMethod": "支付方式",
      "confidence": 0.0-1.0
    }
  ]
  
  如果图片不是消费相关，返回空数组 []。
  ```
- 增加 JSON 解析失败的降级：先尝试 JSON 解析，失败则将响应文本作为 `recognizedText` 走两步流程

**验证**: 拍外卖订单截图 → 直接返回结构化 JSON → 确认卡片直接展示

---

## 优化项 5：图片识别增加 temperature 和 max_tokens 优化

**问题**: `image_recognition_service.dart:98` 和 `:131` 硬编码 `max_tokens: 2000`，且没有设置 `temperature`。对于小票识别这种确定性任务，应该用更低的 temperature 和更精确的 max_tokens。

**文件**: `lib/features/vision_ai/data/services/image_recognition_service.dart:82-99`、`:126-145`

**方案**:
- 增加 `temperature: 0.0`（小票识别不需要创造性）
- 根据任务类型调整 `max_tokens`：
  - 纯文本描述模式：500（小票描述通常不超过 500 token）
  - JSON 结构化模式：1000（JSON 格式更冗长但也不需要 2000）
- 从 `LlmProvider` 的配置继承 temperature（如果用户设置了自定义值）

**验证**: 小票识别返回结果不变，但 token 消耗减少 ~50%

---

## 优化项 6：图片预览和确认流程优化

**问题**: 用户拍照后，图片直接进入 AI 处理，如果图片模糊或拍错了，要等整个流程完成后才知道失败。

**文件**: `lib/features/chat/presentation/pages/ai_chat_page.dart:343-370`

**方案**:
- 拍照/选图后先显示图片预览 + "确认识别"按钮
- 用户可以在预览阶段：重新拍照、旋转/裁剪图片
- 确认后再触发 AI 识别
- 这也给了用户一个"冷静期"，减少误操作

**改动文件**:
- `ai_chat_page.dart`: 修改 `_processInput` 中 image 分支
- 新增 `chat_image_preview.dart` widget（可选，如果不想新增文件可在现有 chat bubble 中扩展）

**验证**: 拍照后先看到预览 → 确认 → 才开始 AI 识别

---

## 执行顺序建议

| 顺序 | 优化项 | 难度 | 预期收益 |
|------|--------|------|----------|
| 1 | 图片格式支持扩展 | ⭐ | 兼容性提升 |
| 2 | temperature/max_tokens 优化 | ⭐ | token 费用降低 |
| 3 | 图片压缩 | ⭐⭐ | OOM 消除 + 带宽减少 80% |
| 4 | 单步图片记账 | ⭐⭐⭐ | 延迟减半 + 费用减半 |
| 5 | 结构化回退 | ⭐⭐ | 鲁棒性提升 |
| 6 | 图片预览确认 | ⭐⭐ | 用户体验提升 |
