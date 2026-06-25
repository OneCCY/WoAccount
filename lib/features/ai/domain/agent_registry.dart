import '../data/models/ai_agent.dart';

/// Agent 注册表 — 预置 Agent 定义
///
/// 所有 Agent 定义为代码常量，不可变。
/// 新增 Agent 只需在此添加定义即可。
class AgentRegistry {
  AgentRegistry._();

  static final Map<String, AiAgent> _agents = {
    for (final a in _builtinAgents) a.id: a,
  };

  /// 获取指定 Agent
  static AiAgent? get(String agentId) => _agents[agentId];

  /// 获取所有 Agent
  static List<AiAgent> get all => _builtinAgents;

  /// 获取已启用的 Agent（基于用户配置）
  static List<AiAgent> get builtins => _builtinAgents;
}

/// 预置 Agent 定义列表
const _builtinAgents = [
  // ── transaction_parser ──────────────────────────
  AiAgent(
    id: 'transaction_parser',
    nameKey: 'agentTransactionParser',
    descriptionKey: 'agentTransactionParserDesc',
    icon: '💰',
    recommendedProfile: ModelProfile.cheap,
    defaultTimeout: 10,
    builtinToolIds: ['get_categories', 'get_exchange_rate', 'resolve_reference'],
    outputSchema: {
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
              'date': {'type': 'string'},
              'note': {'type': 'string'},
              'payMethod': {'type': 'string'},
              'confidence': {'type': 'number'},
            },
            'required': ['type', 'amount', 'category', 'description', 'confidence'],
          },
        },
      },
      'required': ['transactions'],
    },
    testCases: [
      AgentTestCase(
        input: '今天买菜花了50',
        expectedOutput: {'type': 'expense', 'amount': 50},
        mustIncludeFields: ['type', 'amount', 'category'],
      ),
      AgentTestCase(
        input: '工资到账8000',
        expectedOutput: {'type': 'income', 'amount': 8000},
        mustIncludeFields: ['type', 'amount', 'category'],
      ),
      AgentTestCase(
        input: '午饭花了25，打车15',
        expectedOutput: {'count': 2},
        mustIncludeFields: ['type', 'amount', 'category'],
      ),
    ],
  ),

  // ── receipt_ocr ─────────────────────────────────
  AiAgent(
    id: 'receipt_ocr',
    nameKey: 'agentReceiptOcr',
    descriptionKey: 'agentReceiptOcrDesc',
    icon: '🧾',
    recommendedProfile: ModelProfile.balanced,
    defaultTimeout: 15,
    builtinToolIds: [],
    outputSchema: {
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
              'description': {'type': 'string'},
              'date': {'type': 'string'},
              'confidence': {'type': 'number'},
            },
            'required': ['type', 'amount', 'category', 'description', 'confidence'],
          },
        },
      },
      'required': ['transactions'],
    },
    testCases: [],
  ),

  // ── voice_transcribe ────────────────────────────
  AiAgent(
    id: 'voice_transcribe',
    nameKey: 'agentVoiceTranscribe',
    descriptionKey: 'agentVoiceTranscribeDesc',
    icon: '🎤',
    recommendedProfile: ModelProfile.cheap,
    defaultTimeout: 30,
    builtinToolIds: [],
    outputSchema: {
      'type': 'object',
      'properties': {
        'text': {'type': 'string'},
      },
      'required': ['text'],
    },
    systemPrompt: '',
    testCases: [],
  ),

  // ── finance_search ──────────────────────────────
  AiAgent(
    id: 'finance_search',
    nameKey: 'agentFinanceSearch',
    descriptionKey: 'agentFinanceSearchDesc',
    icon: '🔍',
    recommendedProfile: ModelProfile.balanced,
    defaultTimeout: 15,
    builtinToolIds: ['get_transactions', 'get_budgets', 'get_categories', 'calculate_total'],
    outputSchema: null,
    systemPrompt: '',
    testCases: [],
  ),
];
