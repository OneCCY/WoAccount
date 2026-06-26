import 'dart:convert';
import 'package:dio/dio.dart';
import '../../../../core/ai/prompt_templates.dart';
import '../../../../core/ai/rule_engine.dart';
import '../../../../core/config/ai_provider_presets.dart';
import '../storage/provider_storage.dart';
import '../storage/agent_config_storage.dart';
import '../../domain/repositories/llm_repository.dart';
import '../models/llm_config.dart';

/// LLM 服务实现（Data 层）
///
/// 支持两种 API 格式：
/// - OpenAI 兼容格式（/v1/chat/completions）
/// - Anthropic Messages API 格式（/messages）
class LlmRepositoryImpl implements LlmRepository {
  final Dio _dio;

  LlmRepositoryImpl(this._dio);

  @override
  Future<LlmProvider?> getActiveProvider() async {
    final provider = await LlmConfigManager.getActiveProvider();
    if (provider != null && provider.isComplete) return provider;

    // v2 回退：从 ProviderStorage 获取第一个可用 provider
    final v2Providers = await ProviderStorage.loadAll();
    final ready = v2Providers.where((p) => p.isReady).toList();
    if (ready.isNotEmpty) {
      final p = ready.first;
      // 尝试从 AgentConfig 获取 text 模型名
      String? textModel;
      try {
        final configs = await AgentConfigStorage.loadAll();
        final tpConfig = configs['transaction_parser'];
        if (tpConfig != null && tpConfig.modelName.isNotEmpty) {
          textModel = tpConfig.modelName;
        }
      } catch (_) {}

      // 无 AgentConfig 时，从预设获取默认模型
      textModel ??= _getDefaultModelForProvider(p.providerKey);

      return LlmProvider(
        id: p.id,
        name: p.name,
        apiKey: p.apiKey,
        baseUrl: p.baseUrl,
        temperature: p.temperature,
        maxTokens: p.maxTokens,
        timeoutSeconds: p.timeoutSeconds,
        providerKey: p.providerKey ?? 'custom',
        models: {
          if (textModel != null) 'text': ModelConfig(modelName: textModel),
        },
      );
    }
    return null;
  }

  /// 根据 providerKey 获取预设默认模型名
  String? _getDefaultModelForProvider(String? providerKey) {
    if (providerKey == null) return null;
    final preset = getPresetByKey(providerKey);
    if (preset == null) return null;
    // 优先用 text 能力的默认模型
    final textModels = preset.defaultModelsByCapability['text'];
    if (textModels != null && textModels.isNotEmpty) return textModels.first;
    // 其次用 defaultModels 列表
    if (preset.defaultModels.isNotEmpty) return preset.defaultModels.first;
    return null;
  }

  /// 获取指定能力的模型名称
  /// 优先使用 request.model → request.capability 对应的模型 → text 模型
  String _resolveModel(LlmProvider provider, LlmRequest request) {
    if (request.model != null && request.model!.isNotEmpty) return request.model!;
    final cap = request.capability ?? ModelCapability.text;
    final capModel = provider.getModelForCapability(cap);
    if (capModel != null) return capModel;
    throw const LlmException('未配置对应能力的模型', errorCode: 'llmErrorNoModelForCapability');
  }

  @override
  Future<LlmResponse> chat(LlmRequest request, {LlmProvider? provider}) async {
    provider ??= await getActiveProvider();

    if (provider == null || !provider.isComplete) {
      throw const LlmException('请先在设置中添加并配置 AI 服务商', errorCode: 'llmErrorNoProviderConfigured');
    }

    final model = _resolveModel(provider, request);

    // 判断 API 格式
    final preset = getPresetByKey(provider.providerKey);
    final isAnthropic = preset?.apiFormat == ApiFormat.anthropic;

    try {
      if (isAnthropic) {
        return await _chatAnthropic(provider, request, model);
      } else {
        return await _chatOpenAI(provider, request, model);
      }
    } on DioException catch (e) {
      throw LlmException(_parseDioError(e), errorCode: _parseDioErrorCode(e));
    }
  }

  @override
  Stream<String> chatStream(LlmRequest request, {LlmProvider? provider}) async* {
    final resolvedProvider = provider ?? await getActiveProvider();
    if (resolvedProvider == null || !resolvedProvider.isComplete) {
      throw const LlmException('请先在设置中添加并配置 AI 服务商', errorCode: 'llmErrorNoProviderConfigured');
    }

    final model = _resolveModel(resolvedProvider, request);
    final preset = getPresetByKey(resolvedProvider.providerKey);
    final isAnthropic = preset?.apiFormat == ApiFormat.anthropic;

    final body = <String, dynamic>{
      'model': model,
      'messages': request.messages.map((m) => m.toJson()).toList(),
      'temperature': request.temperature ?? resolvedProvider.temperature,
      'max_tokens': request.maxTokens ?? resolvedProvider.maxTokens,
      'stream': true,
    };

    final url = isAnthropic
        ? '${resolvedProvider.baseUrl}/messages'
        : '${resolvedProvider.baseUrl}/chat/completions';

    final headers = isAnthropic
        ? {
            'x-api-key': resolvedProvider.apiKey,
            'Content-Type': 'application/json',
            'anthropic-version': '2023-06-01',
          }
        : {
            'Authorization': 'Bearer ${resolvedProvider.apiKey}',
            'Content-Type': 'application/json',
          };

    if (isAnthropic) {
      body['max_tokens'] = request.maxTokens ?? resolvedProvider.maxTokens;
    }

    final response = await _dio.post<ResponseBody>(
      url,
      options: Options(
        headers: headers,
        responseType: ResponseType.stream,
        receiveTimeout: Duration(seconds: resolvedProvider.timeoutSeconds * 3),
      ),
      data: body,
    );

    final stream = response.data!.stream;
    String buffer = '';

    await for (final chunk in stream) {
      buffer += String.fromCharCodes(chunk);
      // SSE 格式：按行解析
      while (buffer.contains('\n')) {
        final idx = buffer.indexOf('\n');
        final line = buffer.substring(0, idx).trim();
        buffer = buffer.substring(idx + 1);

        if (!line.startsWith('data: ')) continue;
        final data = line.substring(6);
        if (data == '[DONE]') return;

        try {
          final json = jsonDecode(data) as Map<String, dynamic>;
          String? delta;
          if (isAnthropic) {
            // Anthropic 格式
            if (json['type'] == 'content_block_delta') {
              final contentDelta = json['delta'] as Map<String, dynamic>?;
              delta = contentDelta?['text'] as String?;
            }
          } else {
            // OpenAI 格式
            final choices = json['choices'] as List?;
            if (choices != null && choices.isNotEmpty) {
              final deltaObj = choices[0]['delta'] as Map<String, dynamic>?;
              delta = deltaObj?['content'] as String?;
            }
          }
          if (delta != null && delta.isNotEmpty) {
            yield delta;
          }
        } catch (_) {
          // 忽略解析错误的行
        }
      }
    }
  }

  /// OpenAI 兼容格式调用
  Future<LlmResponse> _chatOpenAI(LlmProvider provider, LlmRequest request, String model) async {
    final body = <String, dynamic>{
      'model': model,
      'messages': request.messages.map((m) => m.toJson()).toList(),
      'temperature': request.temperature ?? provider.temperature,
      'max_tokens': request.maxTokens ?? provider.maxTokens,
    };
    // Structured Output: 强制 JSON 格式返回
    if (request.structuredOutput) {
      body['response_format'] = {'type': 'json_object'};
    }

    final response = await _dio.post(
      '${provider.baseUrl}/chat/completions',
      options: Options(
        headers: {
          'Authorization': 'Bearer ${provider.apiKey}',
          'Content-Type': 'application/json',
        },
        sendTimeout: Duration(seconds: provider.timeoutSeconds),
        receiveTimeout: Duration(seconds: provider.timeoutSeconds),
      ),
      data: body,
    );

    final data = response.data as Map<String, dynamic>;
    final usage = data['usage'] as Map<String, dynamic>? ?? {};
    final choices = data['choices'] as List<dynamic>;
    final messageContent =
        (choices[0] as Map<String, dynamic>)['message']['content'] as String;

    return LlmResponse(
      content: messageContent,
      model: data['model'] as String? ?? model,
      promptTokens: usage['prompt_tokens'] as int? ?? 0,
      completionTokens: usage['completion_tokens'] as int? ?? 0,
      totalTokens: usage['total_tokens'] as int? ?? 0,
    );
  }

  /// Anthropic Messages API 格式调用
  Future<LlmResponse> _chatAnthropic(LlmProvider provider, LlmRequest request, String model) async {
    // 分离 system 消息和 user/assistant 消息
    String? systemPrompt;
    final messages = <Map<String, dynamic>>[];
    for (final msg in request.messages) {
      if (msg.role == 'system') {
        systemPrompt = msg.content;
      } else {
        messages.add({'role': msg.role, 'content': msg.content});
      }
    }

    // 如果没有 user/assistant 消息，添加一个空的 user 消息
    if (messages.isEmpty) {
      messages.add({'role': 'user', 'content': 'Hello'});
    }

    final requestBody = <String, dynamic>{
      'model': model,
      'messages': messages,
      'max_tokens': request.maxTokens ?? provider.maxTokens,
    };

    // System prompt with context caching (缓存长 prompt 减少重复计算)
    if (systemPrompt != null) {
      requestBody['system'] = [
        {
          'type': 'text',
          'text': systemPrompt,
          'cache_control': {'type': 'ephemeral'},
        }
      ];
    }

    if (request.temperature != null || provider.temperature > 0) {
      requestBody['temperature'] = request.temperature ?? provider.temperature;
    }

    // Structured Output: 通过 tool_use 强制结构化 JSON 返回
    if (request.structuredOutput && request.jsonSchema != null) {
      requestBody['tools'] = [
        {
          'name': 'output_transaction',
          'description': 'Output the parsed transaction data',
          'input_schema': request.jsonSchema,
        }
      ];
      requestBody['tool_choice'] = {'type': 'tool', 'name': 'output_transaction'};
    }

    final response = await _dio.post(
      '${provider.baseUrl}/messages',
      options: Options(
        headers: {
          'x-api-key': provider.apiKey,
          'anthropic-version': '2023-06-01',
          'Content-Type': 'application/json',
        },
        sendTimeout: Duration(seconds: provider.timeoutSeconds),
        receiveTimeout: Duration(seconds: provider.timeoutSeconds),
      ),
      data: requestBody,
    );

    final data = response.data as Map<String, dynamic>;
    final usage = data['usage'] as Map<String, dynamic>? ?? {};
    final content = data['content'] as List<dynamic>;

    // 解析响应：优先从 tool_use 提取结构化数据，fallback 到 text
    String textContent;
    final toolUseBlock = content.where((b) => (b as Map<String, dynamic>)['type'] == 'tool_use').toList();
    if (toolUseBlock.isNotEmpty) {
      // tool_use 模式：input 就是结构化 JSON
      textContent = jsonEncode((toolUseBlock[0] as Map<String, dynamic>)['input']);
    } else {
      textContent = (content[0] as Map<String, dynamic>)['text'] as String;
    }

    return LlmResponse(
      content: textContent,
      model: data['model'] as String? ?? model,
      promptTokens: usage['input_tokens'] as int? ?? 0,
      completionTokens: usage['output_tokens'] as int? ?? 0,
      totalTokens: (usage['input_tokens'] as int? ?? 0) + (usage['output_tokens'] as int? ?? 0),
    );
  }

  @override
  Future<List<TransactionParseResult>> parseTransaction(
    String input, {
    LlmProvider? provider,
    String? categoryTaxonomy,
    String locale = 'zh',
    String? fewShotExamples,
    String? similarTransactions,
  }) async {
    // [Guardrails] 输入预处理 + 合理性校验
    final sanitizedInput = _validateInput(input);

    // 降级策略：先尝试 LLM，失败后用规则引擎
    try {
      provider ??= await getActiveProvider();
      if (provider == null || !provider.isComplete) {
        // 未配置 LLM，直接用规则引擎
        final ruleResult = RuleEngine.parse(sanitizedInput);
        if (ruleResult != null) return [ruleResult];
        throw const LlmException('请先在设置中添加 AI 服务商，或输入更明确的描述（如"午饭拉面25"）', errorCode: 'llmErrorNoProviderOrInput');
      }

      // 构建系统提示词（使用动态分类或默认分类，注入 RAG + Episodic Memory 上下文）
      final systemPrompt = PromptTemplates.parseTransactionSystem(
        categoryTaxonomy ?? _defaultCategoryTaxonomy,
        locale: locale,
        fewShotExamples: fewShotExamples,
        similarTransactions: similarTransactions,
      );

      // 调用 LLM（启用 Structured Output）
      final response = await chat(LlmRequest(
        messages: [
          ChatMessage(role: 'system', content: systemPrompt),
          ChatMessage(role: 'user', content: PromptTemplates.parseTransactionUser(sanitizedInput, locale: locale)),
        ],
        temperature: 0.0,
        capability: ModelCapability.text,
        structuredOutput: true,
        jsonSchema: _transactionJsonSchema,
      ), provider: provider);

      final results = _parseTransactionResponse(response.content);

      // [Reflection] 输出合理性自检
      return _validateAndReflect(results, sanitizedInput);
    } on LlmException catch (e) {
      // 非记账回复：LLM 返回了非 JSON 的对话式回复
      if (e.errorCode == 'llmErrorNonTransaction') {
        rethrow; // 向上传播，由 Pipeline 设置 nonTransactionResponse
      }
      // LLM 失败，降级到规则引擎
      final ruleResult = RuleEngine.parse(sanitizedInput);
      if (ruleResult != null) return [ruleResult];
      rethrow;
    }
  }

  /// 默认分类体系（当无法从数据库获取时的兜底）
  static const _defaultCategoryTaxonomy = '''
### 支出分类
- 餐饮美食（早餐、午餐、晚餐、夜宵、外卖、奶茶、咖啡、饮料、甜点、零食小吃、水果、买菜、聚餐请客）
- 交通出行（地铁、公交、打车、网约车、共享单车、高铁、火车、飞机、加油、充电、停车费、过路费、车辆保养）
- 居住（房租、水费、电费、燃气费、物业费、维修费、装修）
- 服饰美容（衣服、鞋子、配饰、理发、化妆品、护肤品）
- 日用百货（日用品、清洁用品、厨房用品、家居用品、文具）
- 数码科技（手机、电脑、配件、软件、游戏充值）
- 医疗健康（门诊、药品、体检、牙科、眼科、保健品）
- 教育学习（课程、书籍、培训、考试、文具）
- 休闲娱乐（电影、游戏、旅游、运动、演出、KTV）
- 社交人情（礼物、红包、份子钱、请客、聚餐）
- 子女养育（奶粉、玩具、学费、兴趣班、医疗）
- 赡养长辈（生活费、医疗、礼物、红包）
- 宠物（宠物食品、医疗、用品、美容）
- 工办公（办公用品、差旅、会议、打印）
- 金融保险（保险、手续费、税费、贷款利息）
- 其他支出（无法归类的支出）

### 收入分类
- 工资薪酬（月薪、日结、加班费、奖金、提成）
- 投资理财（股票、基金、利息、分红）
- 副业兼职（副业、freelance、兼职）
- 红包馈赠（红包、礼物、转账）
- 报销退款（报销、退货退款、保险理赔）
- 租金资产（房租收入、资产收益）
- 转账收入（转入）
- 其他收入（无法归类的收入）''';

  @override
  Future<bool> testConnection(LlmProvider provider) async {
    try {
      final preset = getPresetByKey(provider.providerKey);
      final isAnthropic = preset?.apiFormat == ApiFormat.anthropic;

      if (isAnthropic) {
        return await _testConnectionAnthropic(provider);
      } else {
        return await _testConnectionOpenAI(provider);
      }
    } catch (_) {
      return false;
    }
  }

  /// 测试 OpenAI 兼容连接
  Future<bool> _testConnectionOpenAI(LlmProvider provider) async {
    final response = await _dio.post(
      '${provider.baseUrl}/chat/completions',
      options: Options(
        headers: {
          'Authorization': 'Bearer ${provider.apiKey}',
          'Content-Type': 'application/json',
        },
        sendTimeout: Duration(seconds: provider.timeoutSeconds),
        receiveTimeout: Duration(seconds: provider.timeoutSeconds),
      ),
      data: {
        'model': provider.getModelForCapability(ModelCapability.text) ?? '',
        'messages': [
          {'role': 'user', 'content': 'Hello'}
        ],
        'max_tokens': 10,
      },
    );
    return response.statusCode == 200;
  }

  /// 测试 Anthropic 连接
  Future<bool> _testConnectionAnthropic(LlmProvider provider) async {
    final response = await _dio.post(
      '${provider.baseUrl}/messages',
      options: Options(
        headers: {
          'x-api-key': provider.apiKey,
          'anthropic-version': '2023-06-01',
          'Content-Type': 'application/json',
        },
        sendTimeout: Duration(seconds: provider.timeoutSeconds),
        receiveTimeout: Duration(seconds: provider.timeoutSeconds),
      ),
      data: {
        'model': provider.getModelForCapability(ModelCapability.text) ?? '',
        'messages': [
          {'role': 'user', 'content': 'Hello'}
        ],
        'max_tokens': 10,
      },
    );
    return response.statusCode == 200;
  }

  @override
  Future<Map<String, dynamic>> parseSearchQuery(String input, {String? categoryTaxonomy, String locale = 'zh'}) async {
    try {
      final provider = await getActiveProvider();
      if (provider == null || !provider.isComplete) {
        // 未配置 LLM，返回基础关键词查询
        return {
          'keyword': input,
          'keywordSynonyms': <String>[],
          'type': null,
          'minAmount': null,
          'maxAmount': null,
          'startDate': null,
          'endDate': null,
          'parentCategory': null,
          'subcategory': null,
          'payMethod': null,
          'aggregation': 'none',
          'sortBy': 'time',
          'intent': '关键词搜索',
        };
      }

      final systemPrompt = categoryTaxonomy != null
          ? PromptTemplates.searchQueryParseSystem(categoryTaxonomy)
          : PromptTemplates.searchQueryParseSystem(_defaultCategoryTaxonomy);

      final response = await chat(LlmRequest(
        messages: [
          ChatMessage(role: 'system', content: systemPrompt),
          ChatMessage(role: 'user', content: PromptTemplates.searchQueryParseUser(input)),
        ],
        temperature: 0.0,
        capability: ModelCapability.text,
      ));

      return _parseSearchQueryResponse(response.content, input);
    } on LlmException {
      // LLM 失败，返回基础关键词查询
      return {
        'keyword': input,
        'keywordSynonyms': <String>[],
        'type': null,
        'minAmount': null,
        'maxAmount': null,
        'startDate': null,
        'endDate': null,
        'parentCategory': null,
        'subcategory': null,
        'payMethod': null,
        'aggregation': 'none',
        'sortBy': 'time',
        'intent': '关键词搜索（LLM不可用）',
      };
    }
  }

  /// 解析 LLM 返回的搜索查询 JSON
  Map<String, dynamic> _parseSearchQueryResponse(String content, String fallbackInput) {
    try {
      final jsonMatch = RegExp(r'\{[\s\S]*\}').firstMatch(content);
      if (jsonMatch == null) {
        return {'keyword': fallbackInput, 'aggregation': 'none', 'sortBy': 'time'};
      }
      final raw = jsonDecode(jsonMatch.group(0)!) as Map<String, dynamic>;
      return {
        'keyword': raw['keyword'] as String?,
        'keywordSynonyms': (raw['keywordSynonyms'] as List<dynamic>?)?.cast<String>() ?? [],
        'type': raw['type'] as String?,
        'minAmount': (raw['minAmount'] as num?)?.toDouble(),
        'maxAmount': (raw['maxAmount'] as num?)?.toDouble(),
        'startDate': raw['startDate'] as String?,
        'endDate': raw['endDate'] as String?,
        'parentCategory': raw['parentCategory'] as String?,
        'subcategory': raw['subcategory'] as String?,
        'payMethod': raw['payMethod'] as String?,
        'aggregation': raw['aggregation'] as String? ?? 'none',
        'sortBy': raw['sortBy'] as String? ?? 'time',
        'intent': raw['intent'] as String?,
      };
    } catch (_) {
      return {'keyword': fallbackInput, 'aggregation': 'none', 'sortBy': 'time'};
    }
  }

  @override
  Future<String> generateSearchSummary(String userQuery, Map<String, dynamic> stats, {String? categoryTaxonomy}) async {
    try {
      final provider = await getActiveProvider();
      if (provider == null || !provider.isComplete) {
        return _generateLocalSummary(stats);
      }

      final statsText = StringBuffer()
        ..writeln('用户查询: $userQuery')
        ..writeln('匹配笔数: ${stats['count']}')
        ..writeln('总支出: ${stats['totalExpense']}')
        ..writeln('总收入: ${stats['totalIncome']}');
      if (stats['average'] != null) {
        statsText.writeln('平均金额: ${stats['average']}');
      }
      if (stats['maxAmount'] != null) {
        statsText.writeln('最大单笔: ${stats['maxAmount']}');
        if (stats['maxDescription'] != null) {
          statsText.writeln('最大单笔描述: ${stats['maxDescription']}');
        }
      }
      if (stats['topCategories'] != null) {
        statsText.writeln('分类分布: ${stats['topCategories']}');
      }

      final response = await chat(LlmRequest(
        messages: [
          ChatMessage(role: 'system', content: PromptTemplates.searchSummarySystem(categoryTaxonomy: categoryTaxonomy)),
          ChatMessage(role: 'user', content: statsText.toString()),
        ],
        temperature: 0.3,
        capability: ModelCapability.text,
      ));

      return response.content;
    } catch (_) {
      return _generateLocalSummary(stats);
    }
  }

  @override
  Stream<String> generateSearchSummaryStream(String userQuery, Map<String, dynamic> stats, {String? categoryTaxonomy}) async* {
    final provider = await getActiveProvider();
    if (provider == null || !provider.isComplete) {
      yield _generateLocalSummary(stats);
      return;
    }

    final statsText = StringBuffer()
      ..writeln('用户查询: $userQuery')
      ..writeln('匹配笔数: ${stats['count']}')
      ..writeln('总支出: ${stats['totalExpense']}')
      ..writeln('总收入: ${stats['totalIncome']}');
    if (stats['average'] != null) statsText.writeln('平均金额: ${stats['average']}');
    if (stats['maxAmount'] != null) {
      statsText.writeln('最大单笔: ${stats['maxAmount']}');
      if (stats['maxDescription'] != null) statsText.writeln('最大单笔描述: ${stats['maxDescription']}');
    }
    if (stats['topCategories'] != null) statsText.writeln('分类分布: ${stats['topCategories']}');

    try {
      yield* chatStream(LlmRequest(
        messages: [
          ChatMessage(role: 'system', content: PromptTemplates.searchSummarySystem(categoryTaxonomy: categoryTaxonomy)),
          ChatMessage(role: 'user', content: statsText.toString()),
        ],
        temperature: 0.3,
        capability: ModelCapability.text,
      ));
    } catch (_) {
      yield _generateLocalSummary(stats);
    }
  }

  /// 本地生成简单统计摘要（LLM 不可用时的降级）
  String _generateLocalSummary(Map<String, dynamic> stats) {
    final count = stats['count'] as int? ?? 0;
    final totalExpense = stats['totalExpense'] as double? ?? 0;
    final totalIncome = stats['totalIncome'] as double? ?? 0;
    final buffer = StringBuffer();

    if (count == 0) return '未找到匹配的账单记录';

    buffer.writeln('📊 共 $count 笔交易');
    if (totalExpense > 0) buffer.writeln('💸 总支出: ¥${totalExpense.toStringAsFixed(2)}');
    if (totalIncome > 0) buffer.writeln('💰 总收入: ¥${totalIncome.toStringAsFixed(2)}');
    if (stats['average'] != null) {
      buffer.writeln('📈 平均: ¥${(stats['average'] as double).toStringAsFixed(2)}');
    }
    if (stats['maxAmount'] != null) {
      buffer.writeln('🔝 最大单笔: ¥${(stats['maxAmount'] as double).toStringAsFixed(2)}');
    }
    return buffer.toString();
  }

  /// 从 LLM 响应中提取 JSON 字符串（括号计数器算法）
  ///
  /// 替代贪婪正则，正确处理嵌套括号和前后附带文字的情况。
  String? _extractJson(String content) {
    final start = content.indexOf(RegExp(r'[\[{]'));
    if (start == -1) return null;
    final opener = content[start];
    final closer = opener == '[' ? ']' : '}';
    int depth = 0;
    bool inString = false;
    bool escaped = false;
    for (int i = start; i < content.length; i++) {
      final ch = content[i];
      if (escaped) {
        escaped = false;
        continue;
      }
      if (ch == '\\') {
        escaped = true;
        continue;
      }
      if (ch == '"') {
        inString = !inString;
        continue;
      }
      if (inString) continue;
      if (ch == opener) depth++;
      if (ch == closer) depth--;
      if (depth == 0) return content.substring(start, i + 1);
    }
    // 括号未闭合，返回从 start 到末尾（让 jsonDecode 报错）
    return content.substring(start);
  }

  /// 解析 LLM 返回的交易 JSON（支持单笔和多笔）
  List<TransactionParseResult> _parseTransactionResponse(String content) {
    try {
      // 优先尝试直接解析（Structured Output 模式下 content 就是纯 JSON）
      final directParse = _tryParseTransactionJson(content);
      if (directParse != null) return directParse;

      // Fallback: 用括号计数器提取 JSON 片段
      final jsonStr = _extractJson(content);
      if (jsonStr == null) {
        // 没有 JSON → LLM 的对话式回复，标记为非记账
        throw LlmException(content, errorCode: 'llmErrorNonTransaction', data: content);
      }

      final extractParse = _tryParseTransactionJson(jsonStr);
      if (extractParse != null) return extractParse;

      throw LlmException(content, errorCode: 'llmErrorNonTransaction', data: content);
    } catch (e) {
      if (e is LlmException) rethrow;
      throw LlmException('解析 AI 响应失败: $e', errorCode: 'llmErrorParseFailed');
    }
  }

  /// 尝试将 JSON 字符串解析为交易结果列表
  List<TransactionParseResult>? _tryParseTransactionJson(String jsonStr) {
    try {
      final raw = jsonDecode(jsonStr);

      // 处理数组格式（多笔交易）
      if (raw is List) {
        return raw.map((item) => _parseSingleTransaction(item as Map<String, dynamic>)).toList();
      }

      // 处理单对象格式（兼容旧格式）
      if (raw is Map<String, dynamic>) {
        return [_parseSingleTransaction(raw)];
      }

      return null;
    } catch (_) {
      return null;
    }
  }

  TransactionParseResult _parseSingleTransaction(Map<String, dynamic> json) {
    // 类型宽容处理：amount 可能是 String "25" 或 num 25
    double parseAmount(dynamic value) {
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0;
      return 0;
    }

    return TransactionParseResult(
      type: json['type'] as String? ?? 'expense',
      amount: parseAmount(json['amount']),
      category: json['category'] as String? ?? '',
      subcategory: json['subcategory'] as String?,
      description: json['description'] as String? ?? '',
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.8,
      date: json['date'] as String?,
      note: json['note'] as String?,
      payMethod: json['payMethod'] as String?,
    );
  }

  // ==================== Guardrails：输入校验 ====================

  /// 输入预处理 + 安全过滤
  String _validateInput(String input) {
    final trimmed = input.trim();

    // 最小有效长度
    if (trimmed.length < 2) {
      throw const LlmException('输入内容太短，请输入消费描述', errorCode: 'inputTooShort');
    }

    // 截断过长输入（>500 字符可能是误粘贴）
    final sanitized = trimmed.length > 500 ? trimmed.substring(0, 500) : trimmed;

    // 过滤纯标点/纯空白
    if (RegExp(r'^[\s\p{P}]*$', unicode: true).hasMatch(sanitized)) {
      throw const LlmException('请输入有效的消费描述', errorCode: 'inputInvalid');
    }

    return sanitized;
  }

  // ==================== Reflection：输出合理性自检 ====================

  /// 对 LLM 解析结果进行合理性自检
  ///
  /// 检查金额、类型、日期的合理性，标记异常但不阻断流程。
  List<TransactionParseResult> _validateAndReflect(
    List<TransactionParseResult> results,
    String originalInput,
  ) {
    return results.map((r) {
      String? warningNote = r.note;
      double adjustedConfidence = r.confidence;
      String adjustedType = r.type;

      // 1. 金额合理性
      if (r.amount <= 0) {
        warningNote = _appendNote(warningNote, '⚠️ 金额异常（≤0），请修改');
        adjustedConfidence *= 0.3;
      } else if (r.amount > 100000) {
        warningNote = _appendNote(warningNote, '⚠️ 金额较大（¥${r.amount.toStringAsFixed(0)}），请确认');
        adjustedConfidence *= 0.8;
      }

      // 2. 类型一致性：含明确支出关键词但识别为收入
      if (r.type == 'income' && _hasExpenseKeywords(originalInput)) {
        adjustedType = 'expense';
        warningNote = _appendNote(warningNote, '已自动修正为支出');
        adjustedConfidence *= 0.7;
      }

      // 3. 日期合理性：不应是未来日期（除非明确提到"明天"、"下周"等）
      if (r.date != null && !_hasFutureDateKeywords(originalInput)) {
        final parsed = DateTime.tryParse(r.date!);
        if (parsed != null && parsed.isAfter(DateTime.now().add(const Duration(days: 1)))) {
          warningNote = _appendNote(warningNote, '⚠️ 日期是未来日期，请确认');
          adjustedConfidence *= 0.7;
        }
      }

      // 4. 分类-金额一致性：早餐超 200、奶茶超 100 等异常
      final sub = r.subcategory ?? '';
      if (sub == '早餐' && r.amount > 200) {
        warningNote = _appendNote(warningNote, '⚠️ 早餐金额偏高，请确认');
        adjustedConfidence *= 0.8;
      }

      // 5. 空分类检查
      if (r.category.isEmpty) {
        warningNote = _appendNote(warningNote, '⚠️ 未能识别分类，请手动选择');
        adjustedConfidence *= 0.5;
      }

      return TransactionParseResult(
        type: adjustedType,
        amount: r.amount,
        category: r.category,
        subcategory: r.subcategory,
        description: r.description,
        confidence: adjustedConfidence.clamp(0.0, 1.0),
        date: r.date,
        note: warningNote,
        payMethod: r.payMethod,
      );
    }).toList();
  }

  /// 追加警告信息到 note 字段
  String? _appendNote(String? existing, String warning) {
    if (existing == null || existing.isEmpty) return warning;
    return '$existing；$warning';
  }

  /// 检查输入是否包含支出关键词（用于类型修正）
  static bool _hasExpenseKeywords(String input) {
    const keywords = ['买', '吃', '喝', '花', '付', '充值', '消费', '打车', '地铁', '公交',
        '房租', '水电', '药', '课', '票', '费', '税', '加油', '停车', '理发', '剪发',
        'bought', 'paid', 'spent', 'ride', 'rent', 'fee'];
    return keywords.any((k) => input.contains(k));
  }

  /// 检查输入是否包含未来日期关键词
  static bool _hasFutureDateKeywords(String input) {
    const keywords = ['明天', '后天', '下周', '下月', '下个', '明天的',
        'tomorrow', 'next week', 'next month'];
    return keywords.any((k) => input.contains(k));
  }

  // ==================== Structured Output JSON Schema ====================

  /// 记账解析的 JSON Schema（用于 Anthropic tool_use）
  static const _transactionJsonSchema = {
    'type': 'object',
    'properties': {
      'transactions': {
        'type': 'array',
        'items': {
          'type': 'object',
          'properties': {
            'type': {'type': 'string', 'enum': ['expense', 'income']},
            'amount': {'type': 'number'},
            'category': {'type': 'string'},
            'subcategory': {'type': 'string'},
            'description': {'type': 'string'},
            'date': {'type': 'string', 'pattern': r'^\d{4}-\d{2}-\d{2}$'},
            'note': {'type': 'string'},
            'payMethod': {'type': 'string'},
            'confidence': {'type': 'number', 'minimum': 0, 'maximum': 1},
          },
          'required': ['type', 'amount', 'category', 'description', 'date', 'confidence'],
        },
      },
    },
    'required': ['transactions'],
  };

  /// 解析 Dio 错误
  String _parseDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return '请求超时，请检查网络连接';
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        if (statusCode == 401) return 'API Key 无效，请检查设置';
        if (statusCode == 429) return '请求过于频繁，请稍后再试';
        if (statusCode == 403) return '访问被拒绝，请检查 API Key 权限';
        return '请求失败 ($statusCode)';
      case DioExceptionType.connectionError:
        return '网络连接失败，请检查网络';
      default:
        return '请求失败: ${e.message}';
    }
  }

  /// 解析 Dio 错误对应的 l10n errorCode
  String _parseDioErrorCode(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'llmErrorTimeout';
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        if (statusCode == 401) return 'llmErrorInvalidApiKey';
        if (statusCode == 429) return 'llmErrorRateLimit';
        if (statusCode == 403) return 'llmErrorForbidden';
        return 'llmErrorRequestFailed';
      case DioExceptionType.connectionError:
        return 'llmErrorNetworkFailed';
      default:
        return 'llmErrorRequestFailedWithMessage';
    }
  }
}
