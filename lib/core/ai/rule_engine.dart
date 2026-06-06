import '../../features/ai/data/models/llm_config.dart';

/// 分类规则
class CategoryRule {
  final String category;
  final String? subcategory;
  final double confidence;
  final String type; // expense / income

  const CategoryRule(this.category, this.subcategory, this.confidence,
      {this.type = 'expense'});
}

/// 规则引擎 —— 离线时的关键词匹配记账解析
class RuleEngine {
  RuleEngine._();

  /// 关键词 → 分类映射表
  static final Map<String, CategoryRule> _rules = {
    // 餐饮
    '饭': const CategoryRule('餐饮', '餐食', 0.8),
    '面': const CategoryRule('餐饮', '面食', 0.8),
    '拉面': const CategoryRule('餐饮', '面食', 0.9),
    '火锅': const CategoryRule('餐饮', '火锅', 0.9),
    '烧烤': const CategoryRule('餐饮', '烧烤', 0.9),
    '奶茶': const CategoryRule('餐饮', '饮料', 0.9),
    '咖啡': const CategoryRule('餐饮', '饮料', 0.9),
    '外卖': const CategoryRule('餐饮', '外卖', 0.9),
    '早餐': const CategoryRule('餐饮', '早餐', 0.9),
    '午餐': const CategoryRule('餐饮', '午餐', 0.9),
    '晚餐': const CategoryRule('餐饮', '晚餐', 0.9),
    '午饭': const CategoryRule('餐饮', '午餐', 0.9),
    '晚饭': const CategoryRule('餐饮', '晚餐', 0.9),
    '宵夜': const CategoryRule('餐饮', '宵夜', 0.9),
    '零食': const CategoryRule('餐饮', '零食', 0.85),
    '饮料': const CategoryRule('餐饮', '饮料', 0.85),
    '下午茶': const CategoryRule('餐饮', '下午茶', 0.9),

    // 交通
    '打车': const CategoryRule('交通', '打车', 0.9),
    '滴滴': const CategoryRule('交通', '打车', 0.9),
    '地铁': const CategoryRule('交通', '公交地铁', 0.9),
    '公交': const CategoryRule('交通', '公交地铁', 0.9),
    '加油': const CategoryRule('交通', '加油', 0.9),
    '停车': const CategoryRule('交通', '停车', 0.9),
    '火车': const CategoryRule('交通', '火车', 0.9),
    '机票': const CategoryRule('交通', '飞机', 0.9),
    '飞机': const CategoryRule('交通', '飞机', 0.9),

    // 购物
    '超市': const CategoryRule('购物', '日用品', 0.8),
    '淘宝': const CategoryRule('购物', '网购', 0.9),
    '京东': const CategoryRule('购物', '网购', 0.9),
    '衣服': const CategoryRule('购物', '衣物', 0.9),
    'T恤': const CategoryRule('购物', '衣物', 0.9),
    '鞋': const CategoryRule('购物', '衣物', 0.85),
    '手机': const CategoryRule('购物', '电子产品', 0.85),
    '电脑': const CategoryRule('购物', '电子产品', 0.85),

    // 住房
    '房租': const CategoryRule('住房', '房租', 0.95),
    '水电': const CategoryRule('住房', '水电燃气', 0.9),
    '物业': const CategoryRule('住房', '物业', 0.9),
    '燃气': const CategoryRule('住房', '水电燃气', 0.9),

    // 娱乐
    '电影': const CategoryRule('娱乐', '电影', 0.9),
    '游戏': const CategoryRule('娱乐', '游戏', 0.9),
    '旅游': const CategoryRule('娱乐', '旅游', 0.9),
    '景点': const CategoryRule('娱乐', '旅游', 0.85),
    '门票': const CategoryRule('娱乐', '旅游', 0.8),

    // 教育
    '课程': const CategoryRule('教育', '课程', 0.85),
    '书': const CategoryRule('教育', '书籍', 0.8),
    '培训': const CategoryRule('教育', '培训', 0.85),

    // 医疗
    '医院': const CategoryRule('医疗', '看病', 0.9),
    '药': const CategoryRule('医疗', '药品', 0.8),
    '挂号': const CategoryRule('医疗', '挂号', 0.9),
    '体检': const CategoryRule('医疗', '体检', 0.9),

    // 社交
    '红包': const CategoryRule('社交', '红包', 0.9),
    '礼物': const CategoryRule('社交', '礼物', 0.9),
    '份子钱': const CategoryRule('社交', '份子钱', 0.9),
    '聚餐': const CategoryRule('社交', '聚餐', 0.85),

    // 收入
    '工资': const CategoryRule('工资', null, 0.95, type: 'income'),
    '发工资': const CategoryRule('工资', null, 0.95, type: 'income'),
    '月薪': const CategoryRule('工资', null, 0.95, type: 'income'),
    '奖金': const CategoryRule('奖金', null, 0.9, type: 'income'),
    '年终奖': const CategoryRule('奖金', null, 0.95, type: 'income'),
    '退款': const CategoryRule('退款', null, 0.9, type: 'income'),
    '兼职': const CategoryRule('兼职', null, 0.85, type: 'income'),
  };

  /// 时间词映射
  static final Map<String, DateTime Function()> _timeWords = {
    '昨天': () => DateTime.now().subtract(const Duration(days: 1)),
    '前天': () => DateTime.now().subtract(const Duration(days: 2)),
    '今天': () => DateTime.now(),
  };

  /// 规则引擎解析
  static TransactionParseResult? parse(String input) {
    // 1. 提取金额
    final amount = _extractAmount(input);
    if (amount == null) return null;

    // 2. 匹配分类（按置信度排序，取最高）
    CategoryRule? matchedRule;
    for (final entry in _rules.entries) {
      if (input.contains(entry.key)) {
        if (matchedRule == null || entry.value.confidence > matchedRule.confidence) {
          matchedRule = entry.value;
        }
      }
    }

    if (matchedRule == null) return null;

    // 3. 解析时间
    String? dateStr;
    for (final entry in _timeWords.entries) {
      if (input.contains(entry.key)) {
        final date = entry.value();
        dateStr =
            '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
        break;
      }
    }

    // 4. 返回结果
    return TransactionParseResult(
      type: matchedRule.type,
      amount: amount,
      category: matchedRule.category,
      subcategory: matchedRule.subcategory,
      description: _cleanDescription(input),
      confidence: matchedRule.confidence,
      date: dateStr,
    );
  }

  /// 提取金额
  static double? _extractAmount(String input) {
    // 匹配 "1千" "1万" 等
    final chineseMatch = RegExp(r'(\d+\.?\d*)(千|万)').firstMatch(input);
    if (chineseMatch != null) {
      final num = double.parse(chineseMatch.group(1)!);
      final unit = chineseMatch.group(2)!;
      return unit == '千' ? num * 1000 : num * 10000;
    }

    // 匹配普通数字
    final regex = RegExp(r'(\d+\.?\d*)');
    final match = regex.firstMatch(input);
    return match != null ? double.tryParse(match.group(1)!) : null;
  }

  /// 清洗描述（移除金额数字）
  static String _cleanDescription(String input) {
    return input
        .replaceAll(RegExp(r'\d+\.?\d*(千|万)?元?'), '')
        .replaceAll(RegExp(r'[，。！？、]'), '')
        .trim();
  }
}
