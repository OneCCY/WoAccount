import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:wo_account/l10n/app_localizations.dart';
import '../../../../config/database/app_database.dart';
import '../../../../config/di/providers.dart';
import '../../../../config/di/ai_providers.dart';
import '../../../../core/ai/llm_error_resolver.dart';
import '../../../../core/ai/transaction_pipeline.dart';
import '../../../../core/ai/voice_transcription_orchestrator.dart';
import '../../../ai/data/storage/agent_config_storage.dart';
import '../../../../core/locale/locale_provider.dart';
import '../../../transaction/domain/repositories/transaction_repository.dart';
import '../../../category/domain/repositories/category_repository.dart';
import '../widgets/ai_input_bar.dart';
import '../widgets/budget_insight_card.dart';
import '../widgets/ai_assistant_entry.dart';
import '../widgets/ai_confirm_sheet.dart';
import '../../../../core/widgets/toast.dart';

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

  @override
  void initState() {
    super.initState();
    _transactionRepo = ref.read(transactionRepositoryProvider);
    _categoryRepo = ref.read(categoryRepositoryProvider);

    // 检查 AI 是否已配置，未配置则提示
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAiConfig();
      _checkVoiceEngine();
      _handleExternalInput();
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

  /// 检查语音引擎是否可用
  Future<void> _checkVoiceEngine() async {
    final sttService = ref.read(platformSttServiceProvider);
    final hasPlatform = await sttService.isAvailable();

    // 使用 AgentConfig 检测语音能力（v2.0）
    final voiceConfig = await AgentConfigStorage.load('voice_transcribe');
    final hasWhisper = voiceConfig != null &&
        voiceConfig.enabled &&
        voiceConfig.modelName.isNotEmpty;

    if (!hasPlatform && !hasWhisper && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.voiceErrorNoEngineAvailable),
          action: SnackBarAction(
            label: AppLocalizations.of(context)!.homePageGoSettings,
            onPressed: () => context.push('/settings/llm'),
          ),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  /// 语音录制完成回调
  Future<void> _handleVoiceRecorded(VoiceEndAction action, String filePath, String? platformText) async {
    final orchestrator = ref.read(voiceTranscriptionOrchestratorProvider);
    final pipeline = ref.read(transactionPipelineProvider);

    try {
      setState(() => _isLoading = true);

      final transcription = await orchestrator.transcribe(
        audioPath: filePath,
        platformText: platformText,
      );
      if (!mounted) return;

      if (action == VoiceEndAction.transcribeOnly) {
        _inputController.text = transcription.mergedText;
        _inputController.selection = TextSelection.fromPosition(
          TextPosition(offset: transcription.mergedText.length),
        );
      } else {
        final categoryTaxonomy = await _buildCategoryTaxonomy();
        final result = await pipeline.processVoiceResult(
          transcription: transcription,
          categoryTaxonomy: categoryTaxonomy,
        );
        if (!mounted) return;

        await _showConfirmForResult(result);
      }
    } catch (e) {
      if (!mounted) return;
      _showSnackBar(AppLocalizations.of(context)!.homePageRecordFailed(resolveLlmError(e, AppLocalizations.of(context)!)));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// 处理从外部传入的输入（如浮动按钮录音结果）
  void _handleExternalInput() {
    final extra = GoRouterState.of(context).extra;
    if (extra is Map<String, dynamic>) {
      final transcribedText = extra['transcribedText'] as String?;
      final transcription = extra['transcription'];

      if (transcribedText != null && transcribedText.isNotEmpty) {
        // 仅转文字模式：填入输入框
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _inputController.text = transcribedText;
          _inputController.selection = TextSelection.fromPosition(
            TextPosition(offset: transcribedText.length),
          );
        });
      } else if (transcription != null) {
        // 完整管线模式：来自浮动按钮的双引擎转写结果
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _handleTranscriptionFromFloating(transcription as DualTranscriptionResult);
        });
      }
    }
  }

  /// 处理从浮动按钮传来的双引擎转写结果（完整管线：转写→AI解析→确认卡片）
  Future<void> _handleTranscriptionFromFloating(DualTranscriptionResult transcription) async {
    final pipeline = ref.read(transactionPipelineProvider);
    try {
      setState(() => _isLoading = true);
      final categoryTaxonomy = await _buildCategoryTaxonomy();
      final result = await pipeline.processVoiceResult(
        transcription: transcription,
        categoryTaxonomy: categoryTaxonomy,
      );
      if (!mounted) return;

      await _showConfirmForResult(result);
    } catch (e) {
      if (!mounted) return;
      _showSnackBar(AppLocalizations.of(context)!.homePageRecordFailed(resolveLlmError(e, AppLocalizations.of(context)!)));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// 共享确认卡片逻辑：分类匹配 → 日期解析 → 显示确认卡片 → 保存
  Future<void> _showConfirmForResult(PipelineResult result) async {
    if (result.transactions.isEmpty) {
      _showSnackBar(AppLocalizations.of(context)!.homePageNoContent);
      return;
    }

    final txn = result.transactions.first;

    // 匹配分类
    final categories = await _categoryRepo.getAll();
    const otherKeys = {'catOtherTransfer', 'catOtherRepayment', 'catOtherSocial'};
    final isExpense = txn.type == 'expense';
    final isOther = txn.type == 'other';
    bool matchesType(Category c) {
      if (isOther) return !c.isExpense && c.l10nKey != null && otherKeys.contains(c.l10nKey);
      return c.isExpense == isExpense;
    }
    final matchedCategory = categories.firstWhere(
      (c) => c.name == txn.category && matchesType(c),
      orElse: () => categories.firstWhere(
        (c) => matchesType(c),
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
    final description = txn.description.isNotEmpty
        ? txn.description
        : result.normalizedText.replaceAll(RegExp(r'\d+\.?\d*'), '').trim();

    await AiConfirmSheet.show(
      context,
      originalInput: result.normalizedText,
      amount: txn.amount,
      category: matchedCategory.name,
      description: description,
      date: txnDate,
      confidence: txn.confidence,
      parseTimeMs: 0,
      onCancel: () => Navigator.of(context).pop(),
      onConfirm: () async {
        Navigator.of(context).pop();
        await _saveTransaction(
          input: result.normalizedText,
          amount: txn.amount,
          type: txn.type,
          categoryId: matchedCategory.id,
          description: description,
          date: txnDate,
          aiSource: txn.confidence > 0.85 ? 'llm' : 'rule',
          confidence: txn.confidence,
        );
      },
    );
  }

  Future<void> _handleAiInput(String input) async {
    setState(() => _isLoading = true);
    final stopwatch = Stopwatch()..start();

    try {
      // 使用 AI 服务解析（含降级策略：LLM → 规则引擎）
      final llmRepo = ref.read(llmRepositoryProvider);
      // 动态构建用户分类体系（包含最新分类和子分类）
      final categoryTaxonomy = await _buildCategoryTaxonomy();
      final locale = Localizations.localeOf(context).languageCode;
      final results = await llmRepo.parseTransaction(input, categoryTaxonomy: categoryTaxonomy, locale: locale);
      stopwatch.stop();
      if (!mounted) return;

      if (results.isEmpty) {
        _showSnackBar(AppLocalizations.of(context)!.homePageNoContent);
        return;
      }

      final result = results.first;

      // 根据分类名称匹配数据库中的分类
      final categories = await _categoryRepo.getAll();
      const otherKeys2 = {'catOtherTransfer', 'catOtherRepayment', 'catOtherSocial'};
      final isExp = result.type == 'expense';
      final isOth = result.type == 'other';
      bool matchesType(Category c) {
        if (isOth) return !c.isExpense && c.l10nKey != null && otherKeys2.contains(c.l10nKey);
        return c.isExpense == isExp;
      }
      final matchedCategory = categories.firstWhere(
        (c) => c.name == result.category && matchesType(c),
        orElse: () => categories.firstWhere(
          (c) => matchesType(c),
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
            type: result.type,
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
      _showSnackBar(AppLocalizations.of(context)!.homePageRecordFailed(resolveLlmError(e, AppLocalizations.of(context)!)));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _saveTransaction({
    required String input,
    required double amount,
    required String type,
    required int categoryId,
    required String description,
    required DateTime date,
    required String aiSource,
    required double confidence,
  }) async {
    try {
      await _transactionRepo.insert(TransactionsCompanion.insert(
        amount: amount,
        type: Value(type),
        description: description,
        categoryId: categoryId,
        transactionDate: date,
        originalInput: Value(input),
        aiSource: Value(aiSource),
        aiConfidence: Value(confidence),
        accountBookId: ref.read(currentBookProvider),
      ));
      if (!mounted) return;
      _showSnackBar(AppLocalizations.of(context)!.homePageRecordSuccess(context.localeProvider.currency.formatAmount(amount)));
    } catch (e) {
      if (!mounted) return;
      _showSnackBar(AppLocalizations.of(context)!.homePageSaveFailed(resolveLlmError(e, AppLocalizations.of(context)!)));
    }
  }

  /// 从数据库动态构建分类体系文本（用于 LLM 提示词）
  /// 使用单次 getAll 查询 + 内存分组，避免 N+1 查询
  Future<String> _buildCategoryTaxonomy() async {
    try {
      final allCats = await _categoryRepo.getAll();
      final childrenMap = <int, List<Category>>{};
      for (final c in allCats) {
        if (c.parentId != null) {
          childrenMap.putIfAbsent(c.parentId!, () => []).add(c);
        }
      }

      final parents = allCats.where((c) => c.parentId == null).toList();
      if (parents.isEmpty) return '';

      final expenseCats = parents.where((c) => c.isExpense).toList();
      const otherKeys = {'catOtherTransfer', 'catOtherRepayment', 'catOtherSocial'};
      final otherCats = parents.where((c) => !c.isExpense && c.l10nKey != null && otherKeys.contains(c.l10nKey)).toList();
      final incomeCats = parents.where((c) => !c.isExpense && (c.l10nKey == null || !otherKeys.contains(c.l10nKey!))).toList();

      final buffer = StringBuffer();

      if (expenseCats.isNotEmpty) {
        buffer.writeln('### 支出分类');
        for (final cat in expenseCats) {
          final children = childrenMap[cat.id] ?? [];
          if (children.isNotEmpty) {
            buffer.writeln('- ${cat.name}（${children.map((c) => c.name).join('、')}）');
          } else {
            buffer.writeln('- ${cat.name}');
          }
        }
        buffer.writeln();
      }

      if (incomeCats.isNotEmpty) {
        buffer.writeln('### 收入分类');
        for (final cat in incomeCats) {
          final children = childrenMap[cat.id] ?? [];
          if (children.isNotEmpty) {
            buffer.writeln('- ${cat.name}（${children.map((c) => c.name).join('、')}）');
          } else {
            buffer.writeln('- ${cat.name}');
          }
        }
        buffer.writeln();
      }

      if (otherCats.isNotEmpty) {
        buffer.writeln('### 其他分类');
        for (final cat in otherCats) {
          final children = childrenMap[cat.id] ?? [];
          if (children.isNotEmpty) {
            buffer.writeln('- ${cat.name}（${children.map((c) => c.name).join('、')}）');
          } else {
            buffer.writeln('- ${cat.name}');
          }
        }
      }

      return buffer.toString().trim();
    } catch (e) {
      debugPrint('[HomePage] _buildCategoryTaxonomy error: $e');
      return '';
    }
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    AppToast.show(context, message, duration: const Duration(seconds: 2));
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
        sttService: ref.read(platformSttServiceProvider),
      ),
    );
  }
}
