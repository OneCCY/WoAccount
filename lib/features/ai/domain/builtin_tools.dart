import 'package:drift/drift.dart';
import '../../../config/database/app_database.dart';
import 'tool_registry.dart';

/// 注册所有内置工具
///
/// 需要在应用启动时调用，传入 AppDatabase 实例。
void registerBuiltinTools(AppDatabase db) {
  ToolRegistry.register(GetCategoriesTool(db));
  ToolRegistry.register(GetExchangeRateTool());
  ToolRegistry.register(GetTransactionsTool(db));
  ToolRegistry.register(GetBudgetsTool(db));
  ToolRegistry.register(CalculateTotalTool(db));
  ToolRegistry.register(ResolveReferenceTool(db));
}

// ── get_categories ───────────────────────────────────

class GetCategoriesTool extends BuiltinTool {
  final AppDatabase _db;
  GetCategoriesTool(this._db);

  @override String get id => 'get_categories';
  @override String get name => '获取分类列表';
  @override String get description => '获取用户的所有支出/收入分类及其子分类';
  @override Map<String, dynamic> get schema => {
    'type': 'object',
    'properties': {
      'type': {
        'type': 'string',
        'enum': ['expense', 'income'],
        'description': '分类类型：expense=支出，income=收入，不传返回全部',
      },
    },
  };

  @override
  Future<dynamic> execute(Map<String, dynamic> params) async {
    final type = params['type'] as String?;
    final categories = await _db.select(_db.categories).get();
    final filtered = type != null
        ? categories.where((c) => type == 'expense' ? c.isExpense : !c.isExpense).toList()
        : categories;
    return filtered.map((c) => {
      'id': c.id,
      'name': c.name,
      'type': c.isExpense ? 'expense' : 'income',
      'icon': c.icon,
      'parentId': c.parentId,
    }).toList();
  }
}

// ── get_exchange_rate ────────────────────────────────

class GetExchangeRateTool extends BuiltinTool {
  @override String get id => 'get_exchange_rate';
  @override String get name => '获取汇率';
  @override String get description => '获取两种货币之间的汇率';
  @override Map<String, dynamic> get schema => {
    'type': 'object',
    'properties': {
      'from': {'type': 'string', 'description': '源货币代码，如 USD'},
      'to': {'type': 'string', 'description': '目标货币代码，如 CNY'},
    },
    'required': ['from', 'to'],
  };

  @override
  Future<dynamic> execute(Map<String, dynamic> params) async {
    final from = (params['from'] as String).toUpperCase();
    final to = (params['to'] as String).toUpperCase();
    // 简化实现：返回常用汇率（后续可接入外部 API）
    const rates = {
      'USD_CNY': 7.25, 'CNY_USD': 0.138,
      'EUR_CNY': 7.85, 'CNY_EUR': 0.127,
      'JPY_CNY': 0.048, 'CNY_JPY': 20.83,
      'GBP_CNY': 9.15, 'CNY_GBP': 0.109,
      'USD_EUR': 0.92, 'EUR_USD': 1.087,
    };
    final key = '${from}_$to';
    final rate = rates[key];
    if (rate != null) {
      return {'from': from, 'to': to, 'rate': rate};
    }
    return {'error': '暂不支持 $from → $to 的汇率查询'};
  }
}

// ── get_transactions ─────────────────────────────────

class GetTransactionsTool extends BuiltinTool {
  final AppDatabase _db;
  GetTransactionsTool(this._db);

  @override String get id => 'get_transactions';
  @override String get name => '查询交易记录';
  @override String get description => '按条件查询交易记录';
  @override Map<String, dynamic> get schema => {
    'type': 'object',
    'properties': {
      'startDate': {'type': 'string', 'description': '开始日期 YYYY-MM-DD'},
      'endDate': {'type': 'string', 'description': '结束日期 YYYY-MM-DD'},
      'type': {'type': 'string', 'enum': ['expense', 'income']},
      'categoryName': {'type': 'string', 'description': '分类名称'},
      'keyword': {'type': 'string', 'description': '关键词搜索'},
      'limit': {'type': 'integer', 'description': '返回数量上限', 'default': 20},
    },
  };

  @override
  Future<dynamic> execute(Map<String, dynamic> params) async {
    final limit = params['limit'] as int? ?? 20;
    final query = _db.select(_db.transactions)
      ..where((t) => t.isDeleted.equals(false))
      ..orderBy([(t) => OrderingTerm.desc(t.transactionDate)])
      ..limit(limit);

    final results = await query.get();
    return results.map((t) => {
      'id': t.id,
      'amount': t.amount,
      'type': t.type,
      'description': t.description,
      'date': t.transactionDate.toIso8601String().substring(0, 10),
      'categoryId': t.categoryId,
      'note': t.note,
    }).toList();
  }
}

// ── get_budgets ──────────────────────────────────────

class GetBudgetsTool extends BuiltinTool {
  final AppDatabase _db;
  GetBudgetsTool(this._db);

  @override String get id => 'get_budgets';
  @override String get name => '查询预算';
  @override String get description => '查询当前预算设置和使用情况';
  @override Map<String, dynamic> get schema => {
    'type': 'object',
    'properties': {
      'month': {'type': 'string', 'description': '月份 YYYY-MM，不传则当月'},
    },
  };

  @override
  Future<dynamic> execute(Map<String, dynamic> params) async {
    final budgets = await _db.select(_db.budgets).get();
    return budgets.map((b) => {
      'id': b.id,
      'amount': b.amount,
      'categoryId': b.categoryId,
      'period': b.period,
    }).toList();
  }
}

// ── calculate_total ──────────────────────────────────

class CalculateTotalTool extends BuiltinTool {
  final AppDatabase _db;
  CalculateTotalTool(this._db);

  @override String get id => 'calculate_total';
  @override String get name => '计算金额汇总';
  @override String get description => '按时间范围和类型计算交易金额汇总';
  @override Map<String, dynamic> get schema => {
    'type': 'object',
    'properties': {
      'startDate': {'type': 'string', 'description': '开始日期 YYYY-MM-DD'},
      'endDate': {'type': 'string', 'description': '结束日期 YYYY-MM-DD'},
      'type': {'type': 'string', 'enum': ['expense', 'income']},
    },
    'required': ['startDate', 'endDate'],
  };

  @override
  Future<dynamic> execute(Map<String, dynamic> params) async {
    final startStr = params['startDate'] as String;
    final endStr = params['endDate'] as String;
    final type = params['type'] as String?;
    final start = DateTime.parse(startStr);
    final end = DateTime.parse(endStr);

    final query = _db.select(_db.transactions)
      ..where((t) => t.isDeleted.equals(false) &
          t.transactionDate.isBiggerOrEqualValue(start) &
          t.transactionDate.isSmallerOrEqualValue(end));
    if (type != null) {
      query.where((t) => t.type.equals(type));
    }
    final results = await query.get();
    final total = results.fold<double>(0, (sum, t) => sum + t.amount);
    return {
      'total': total,
      'count': results.length,
      'startDate': startStr,
      'endDate': endStr,
      if (type != null) 'type': type,
    };
  }
}

// ── resolve_reference ────────────────────────────────

class ResolveReferenceTool extends BuiltinTool {
  final AppDatabase _db;
  ResolveReferenceTool(this._db);

  @override String get id => 'resolve_reference';
  @override String get name => '解析指代';
  @override String get description => '解析用户输入中的指代词，如"上次那样"、"跟昨天一样"';
  @override Map<String, dynamic> get schema => {
    'type': 'object',
    'properties': {
      'input': {'type': 'string', 'description': '用户的原始输入文本'},
      'bookId': {'type': 'integer', 'description': '账本 ID'},
    },
    'required': ['input'],
  };

  static const _referencePatterns = [
    _RefPattern('跟上次一样', _RefType.lastTransaction),
    _RefPattern('跟上次一样', _RefType.lastTransaction),
    _RefPattern('上次那样', _RefType.lastTransaction),
    _RefPattern('和上次一样', _RefType.lastTransaction),
    _RefPattern('同上次', _RefType.lastTransaction),
    _RefPattern('same as last', _RefType.lastTransaction),
    _RefPattern('same as before', _RefType.lastTransaction),
    _RefPattern('跟昨天一样', _RefType.sameDayYesterday),
    _RefPattern('跟昨天一样', _RefType.sameDayYesterday),
    _RefPattern('和昨天一样', _RefType.sameDayYesterday),
    _RefPattern('like yesterday', _RefType.sameDayYesterday),
  ];

  @override
  Future<dynamic> execute(Map<String, dynamic> params) async {
    final input = params['input'] as String;
    final bookId = params['bookId'] as int?;

    String? matchedKeyword;
    _RefType? refType;

    for (final p in _referencePatterns) {
      if (input.contains(p.keyword)) {
        matchedKeyword = p.keyword;
        refType = p.type;
        break;
      }
    }
    if (matchedKeyword == null || refType == null) {
      return {'resolved': false, 'originalInput': input};
    }

    try {
      String? description;
      if (refType == _RefType.lastTransaction) {
        final query = _db.select(_db.transactions)
          ..where((t) => t.isDeleted.equals(false))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])
          ..limit(1);
        if (bookId != null) {
          query.where((t) => t.accountBookId.equals(bookId));
        }
        final results = await query.get();
        if (results.isNotEmpty) {
          final t = results.first;
          final catName = await _getCategoryName(t.categoryId);
          description = '${t.description} ${t.amount}元 ($catName)';
        }
      } else {
        final yesterday = DateTime.now().subtract(const Duration(days: 1));
        final start = DateTime(yesterday.year, yesterday.month, yesterday.day);
        final end = start.add(const Duration(days: 1));
        final query = _db.select(_db.transactions)
          ..where((t) => t.isDeleted.equals(false) &
              t.transactionDate.isBiggerOrEqualValue(start) &
              t.transactionDate.isSmallerThanValue(end))
          ..orderBy([(t) => OrderingTerm.desc(t.transactionDate)])
          ..limit(1);
        if (bookId != null) {
          query.where((t) => t.accountBookId.equals(bookId));
        }
        final results = await query.get();
        if (results.isNotEmpty) {
          final t = results.first;
          final catName = await _getCategoryName(t.categoryId);
          description = '${t.description} ${t.amount}元 ($catName)';
        }
      }

      if (description != null) {
        final resolved = input.replaceFirst(matchedKeyword, description);
        return {'resolved': true, 'originalInput': input, 'resolvedInput': resolved};
      }
    } catch (_) {
      // 查询失败，返回未解析
    }
    return {'resolved': false, 'originalInput': input};
  }

  Future<String> _getCategoryName(int categoryId) async {
    final query = _db.select(_db.categories)
      ..where((c) => c.id.equals(categoryId))
      ..limit(1);
    final results = await query.get();
    return results.isNotEmpty ? results.first.name : '未知分类';
  }
}

enum _RefType { lastTransaction, sameDayYesterday }

class _RefPattern {
  final String keyword;
  final _RefType type;
  const _RefPattern(this.keyword, this.type);
}
