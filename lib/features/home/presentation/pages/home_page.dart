import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:wo_account/l10n/app_localizations.dart';
import '../../../../config/database/app_database.dart';
import '../../../../config/di/providers.dart';
import '../../../../config/di/ai_providers.dart';
import '../../../../core/ai/transaction_pipeline.dart';
import '../../../../core/locale/locale_provider.dart';
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
  final _inputController = TextEditingController();

  late final TransactionRepository _transactionRepo;
  late final CategoryRepository _categoryRepo;
  late final int _bookId;

  @override
  void initState() {
    super.initState();
    _transactionRepo = ref.read(transactionRepositoryProvider);
    _categoryRepo = ref.read(categoryRepositoryProvider);
    _bookId = ref.read(currentBookProvider);

    // 检查 AI 是否已配置，未配置则提示
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAiConfig();
    });
  }

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  /// 检查 AI 服务是否已配置
  Future<void> _checkAiConfig() async {
    final llmRepo = ref.read(llmRepositoryProvider);
    final provider = await llmRepo.getActiveProvider();
    if ((provider == null || !provider.isComplete) && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.homePageAiNotConfigured),
          action: SnackBarAction(
            label: AppLocalizations.of(context)!.homePageGoSettings,
            onPressed: () => context.push('/settings/llm'),
          ),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  /// 语音录制完成回调
  Future<void> _handleVoiceRecorded(VoiceEndAction action, String filePath) async {
    final llmRepo = ref.read(llmRepositoryProvider);
    final provider = await llmRepo.getActiveProvider();
    if (!mounted) return;
    if (provider == null || !provider.isComplete) {
      _showSnackBar(AppLocalizations.of(context)!.homePageAiNotConfigured);
      return;
    }

    final pipeline = ref.read(transactionPipelineProvider);

    if (action == VoiceEndAction.transcribeOnly) {
      // 仅转文字，填入输入框
      try {
        setState(() => _isLoading = true);
        final text = await pipeline.transcribeOnly(
          audioTempPath: filePath,
          provider: provider,
        );
        if (!mounted) return;
        _inputController.text = text;
        _inputController.selection = TextSelection.fromPosition(
          TextPosition(offset: text.length),
        );
      } catch (e) {
        if (!mounted) return;
        _showSnackBar(AppLocalizations.of(context)!.homePageRecordFailed(e.toString()));
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    } else {
      // 完整管线：语音→转文字→AI解析→确认卡片
      try {
        setState(() => _isLoading = true);
        final result = await pipeline.processVoice(
          audioTempPath: filePath,
          provider: provider,
        );
        if (!mounted) return;

        if (result.transactions.isEmpty) {
          _showSnackBar(AppLocalizations.of(context)!.homePageNoContent);
          return;
        }

        final txn = result.transactions.first;

        // 匹配分类
        final categories = await _categoryRepo.getAll();
        final matchedCategory = categories.firstWhere(
          (c) => c.name == txn.category,
          orElse: () => categories.firstWhere(
            (c) => c.isExpense == (txn.type == 'expense'),
            orElse: () => categories.first,
          ),
        );

        // 解析日期
        DateTime txnDate = DateTime.now();
        if (txn.date != null && txn.date!.isNotEmpty) {
          try {
            txnDate = DateTime.parse(txn.date!);
          } catch (_) {}
        }

        // 显示确认卡片
        if (!mounted) return;
        await AiConfirmSheet.show(
          context,
          originalInput: result.normalizedText,
          amount: txn.amount,
          category: matchedCategory.name,
          description: txn.description.isNotEmpty
              ? txn.description
              : result.normalizedText.replaceAll(RegExp(r'\d+\.?\d*'), '').trim(),
          date: txnDate,
          confidence: txn.confidence,
          parseTimeMs: 0,
          onCancel: () => Navigator.of(context).pop(),
          onConfirm: () async {
            Navigator.of(context).pop();
            await _saveTransaction(
              input: result.normalizedText,
              amount: txn.amount,
              categoryId: matchedCategory.id,
              description: txn.description.isNotEmpty
                  ? txn.description
                  : result.normalizedText.replaceAll(RegExp(r'\d+\.?\d*'), '').trim(),
              date: txnDate,
              aiSource: txn.confidence > 0.85 ? 'llm' : 'rule',
              confidence: txn.confidence,
            );
          },
        );
      } catch (e) {
        if (!mounted) return;
        _showSnackBar(AppLocalizations.of(context)!.homePageRecordFailed(e.toString()));
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleAiInput(String input) async {
    setState(() => _isLoading = true);
    final stopwatch = Stopwatch()..start();

    try {
      // 使用 AI 服务解析（含降级策略：LLM → 规则引擎）
      final llmRepo = ref.read(llmRepositoryProvider);
      final results = await llmRepo.parseTransaction(input);
      stopwatch.stop();
      if (!mounted) return;

      if (results.isEmpty) {
        _showSnackBar(AppLocalizations.of(context)!.homePageNoContent);
        return;
      }

      final result = results.first;

      // 根据分类名称匹配数据库中的分类
      final categories = await _categoryRepo.getAll();
      final matchedCategory = categories.firstWhere(
        (c) => c.name == result.category,
        orElse: () => categories.firstWhere(
          (c) => c.isExpense == (result.type == 'expense'),
          orElse: () => categories.first,
        ),
      );

      // 解析日期
      DateTime txnDate = DateTime.now();
      if (result.date != null) {
        try {
          txnDate = DateTime.parse(result.date!);
        } catch (_) {}
      }

      // 显示确认卡片
      if (!mounted) return;
      await AiConfirmSheet.show(
        context,
        originalInput: input,
        amount: result.amount,
        category: matchedCategory.name,
        description: result.description.isNotEmpty
            ? result.description
            : input.replaceAll(RegExp(r'\d+\.?\d*'), '').trim(),
        date: txnDate,
        confidence: result.confidence,
        parseTimeMs: stopwatch.elapsedMilliseconds,
        onCancel: () => Navigator.of(context).pop(),
        onConfirm: () async {
          Navigator.of(context).pop();
          await _saveTransaction(
            input: input,
            amount: result.amount,
            categoryId: matchedCategory.id,
            description: result.description.isNotEmpty
                ? result.description
                : input.replaceAll(RegExp(r'\d+\.?\d*'), '').trim(),
            date: txnDate,
            aiSource: result.confidence > 0.85 ? 'llm' : 'rule',
            confidence: result.confidence,
          );
        },
      );
    } catch (e) {
      if (!mounted) return;
      _showSnackBar(AppLocalizations.of(context)!.homePageRecordFailed(e.toString()));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _saveTransaction({
    required String input,
    required double amount,
    required int categoryId,
    required String description,
    required DateTime date,
    required String aiSource,
    required double confidence,
  }) async {
    try {
      await _transactionRepo.insert(TransactionsCompanion.insert(
        amount: amount,
        description: description,
        categoryId: categoryId,
        transactionDate: date,
        originalInput: Value(input),
        aiSource: Value(aiSource),
        aiConfidence: Value(confidence),
        accountBookId: _bookId,
      ));
      if (!mounted) return;
      _showSnackBar(AppLocalizations.of(context)!.homePageRecordSuccess(context.localeProvider.currency.formatAmount(amount)));
    } catch (e) {
      if (!mounted) return;
      _showSnackBar(AppLocalizations.of(context)!.homePageSaveFailed(e.toString()));
    }
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
          BudgetInsightCard(
            message: AppLocalizations.of(context)!.homePageBudgetAlert,
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
        controller: _inputController,
        onVoiceRecorded: _handleVoiceRecorded,
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
