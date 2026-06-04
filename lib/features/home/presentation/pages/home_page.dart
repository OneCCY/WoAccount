import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' hide Column;
import '../../../../config/database/app_database.dart';
import '../../../../config/di/providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../transaction/domain/repositories/transaction_repository.dart';
import '../../../category/domain/repositories/category_repository.dart';
import '../widgets/ai_input_bar.dart';
import '../widgets/today_transactions.dart';

/// 首页（记账入口）
class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  bool _isLoading = false;

  late final TransactionRepository _transactionRepo;
  late final CategoryRepository _categoryRepo;

  @override
  void initState() {
    super.initState();
    _transactionRepo = ref.read(transactionRepositoryProvider);
    _categoryRepo = ref.read(categoryRepositoryProvider);
  }

  Future<void> _handleAiInput(String input) async {
    setState(() => _isLoading = true);

    try {
      // TODO: 接入 AI 解析引擎，当前使用简单规则提取金额
      final amount = _extractAmount(input);
      if (amount == null) {
        _showSnackBar('未识别到金额，请输入如"午饭拉面25"');
        return;
      }

      // 获取默认分类（餐饮）
      final categories = await _categoryRepo.getAll();
      final defaultCategory = categories.firstWhere(
        (c) => c.name == '餐饮',
        orElse: () => categories.first,
      );

      // 保存交易
      await _transactionRepo.insert(TransactionsCompanion.insert(
        amount: amount,
        description: input.replaceAll(RegExp(r'\d+\.?\d*'), '').trim(),
        categoryId: defaultCategory.id,
        transactionDate: DateTime.now(),
        originalInput: Value(input),
        aiSource: const Value('rule'),
      ));

      _showSnackBar('记账成功：¥${amount.toStringAsFixed(2)}');
    } catch (e) {
      _showSnackBar('记账失败：$e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  double? _extractAmount(String input) {
    final regex = RegExp(r'(\d+\.?\d*)');
    final match = regex.firstMatch(input);
    return match != null ? double.tryParse(match.group(1)!) : null;
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('记账'),
        actions: [
          IconButton(
            icon: const Icon(Icons.auto_awesome_outlined),
            onPressed: () {
              // TODO: 打开 AI 助手页面
            },
            tooltip: 'AI 助手',
          ),
        ],
      ),
      body: Column(
        children: [
          // AI 输入框
          AiInputBar(
            onSubmit: _handleAiInput,
            isLoading: _isLoading,
          ),
          // 今日账单标题
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppDimensions.md,
              AppDimensions.md,
              AppDimensions.md,
              AppDimensions.sm,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '今日账单',
                  style: AppTextStyles.h3.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  _formatDate(DateTime.now()),
                  style: AppTextStyles.footnote.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          // 今日账单列表
          Expanded(
            child: SingleChildScrollView(
              child: TodayTransactions(repository: _transactionRepo),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);

    if (target == today) return '今天';
    if (target == today.subtract(const Duration(days: 1))) return '昨天';
    return '${date.month}月${date.day}日';
  }
}
