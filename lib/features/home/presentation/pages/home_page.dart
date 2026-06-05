import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:drift/drift.dart' hide Column;
import '../../../../config/database/app_database.dart';
import '../../../../config/di/providers.dart';
import '../../../transaction/domain/repositories/transaction_repository.dart';
import '../../../category/domain/repositories/category_repository.dart';
import '../widgets/ai_input_bar.dart';
import '../widgets/budget_insight_card.dart';
import '../widgets/ai_assistant_entry.dart';
import '../widgets/ai_confirm_sheet.dart';

/// 首页（记账入口）
/// 布局：预算提醒 → AI 助手入口 → 留白 → 底部输入栏
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
      final amount = _extractAmount(input);
      if (amount == null) {
        _showSnackBar('未识别到金额，请输入如"午饭拉面25"');
        return;
      }

      final categories = await _categoryRepo.getAll();
      final defaultCategory = categories.firstWhere(
        (c) => c.name == '餐饮',
        orElse: () => categories.first,
      );

      // 显示确认卡片
      if (!mounted) return;
      await AiConfirmSheet.show(
        context,
        originalInput: input,
        amount: amount,
        category: defaultCategory.name,
        description: input.replaceAll(RegExp(r'\d+\.?\d*'), '').trim(),
        date: DateTime.now(),
        confidence: 0.85,
        parseTimeMs: 120,
        onCancel: () => Navigator.of(context).pop(),
        onConfirm: () async {
          Navigator.of(context).pop();
          await _saveTransaction(input, amount, defaultCategory.id);
        },
      );
    } catch (e) {
      _showSnackBar('记账失败：$e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _saveTransaction(String input, double amount, int categoryId) async {
    try {
      await _transactionRepo.insert(TransactionsCompanion.insert(
        amount: amount,
        description: input.replaceAll(RegExp(r'\d+\.?\d*'), '').trim(),
        categoryId: categoryId,
        transactionDate: DateTime.now(),
        originalInput: Value(input),
        aiSource: const Value('rule'),
      ));
      _showSnackBar('记账成功：¥${amount.toStringAsFixed(2)}');
    } catch (e) {
      _showSnackBar('保存失败：$e');
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
          borderRadius: BorderRadius.circular(8),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 无 AppBar，匹配原型
      body: Column(
        children: [
          // 安全区留白
          SizedBox(height: MediaQuery.of(context).padding.top),

          // 预算提醒卡片
          const BudgetInsightCard(
            message: '今日消费已超过日均预算的80%',
          ),

          // AI 助手入口
          AiAssistantEntry(
            onTap: () {
              context.push('/ai-assistant');
            },
          ),

          // 中间留白
          const Spacer(),
        ],
      ),

      // 底部固定输入栏
      bottomNavigationBar: AiInputBar(
        onSubmit: _handleAiInput,
        isLoading: _isLoading,
        onManualEntry: () {
          context.push('/manual-entry');
        },
        onCamera: () {
          // TODO: 拍照识别
        },
      ),
    );
  }
}
