import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:go_router/go_router.dart';
import 'package:wo_account/l10n/app_localizations.dart';
import '../../../../config/database/app_database.dart';
import '../../../../config/di/providers.dart';
import '../../../../config/di/ai_providers.dart';
import '../../../../core/ai/llm_error_resolver.dart';
import '../../../../core/ai/transaction_pipeline.dart';
import '../../../../core/config/ai_provider_presets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../ai/data/models/llm_config.dart';
import '../../../category/domain/repositories/category_repository.dart';
import '../../../transaction/domain/repositories/transaction_repository.dart';
import '../../domain/repositories/chat_repository.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/chat_input_bar.dart';
import '../widgets/confirm_card.dart';
import '../widgets/saved_card.dart';
import '../../../../core/widgets/page_refresh_mixin.dart';
import '../../../../core/widgets/toast.dart';

/// AI 记账对话页
class AiChatPage extends ConsumerStatefulWidget {
  const AiChatPage({super.key});

  @override
  ConsumerState<AiChatPage> createState() => _AiChatPageState();
}

class _AiChatPageState extends ConsumerState<AiChatPage> with PageRefreshMixin {
  final _scrollController = ScrollController();
  final _pageSize = 20;
  final String _conversationId = 'default';

  @override
  String get routePath => '/';

  @override
  void onRefresh() {
    _loadUserProfile();
    _loadAiProviderIcon();
  }

  List<_ChatItem> _items = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  bool _isAiResponding = false;

  String? _userAvatarPath;
  String _aiIcon = '🤖';

  late final ChatRepository _chatRepo;
  late final TransactionRepository _txnRepo;
  late final CategoryRepository _catRepo;
  late final int _bookId;
  late final TransactionPipeline _pipeline;

  @override
  void initState() {
    super.initState();
    _chatRepo = ref.read(chatRepositoryProvider);
    _txnRepo = ref.read(transactionRepositoryProvider);
    _catRepo = ref.read(categoryRepositoryProvider);
    _bookId = ref.read(currentBookProvider);

    // 初始化统一记账管线
    _pipeline = ref.read(transactionPipelineProvider);

    _scrollController.addListener(_onScroll);
    _loadInitialMessages().then((_) => _handleExternalInput());
    _loadUserProfile();
    _loadAiProviderIcon();
  }

  /// 加载用户头像
  Future<void> _loadUserProfile() async {
    try {
      final db = ref.read(appDatabaseProvider);
      final profiles = await db.select(db.userProfiles).get();
      if (!mounted) return;
      if (profiles.isNotEmpty) {
        setState(() => _userAvatarPath = profiles.first.avatarPath);
      }
    } catch (e) {
      debugPrint('[AiChatPage] _loadUserProfile error: $e');
    }
  }

  /// 加载当前 AI 模型图标
  Future<void> _loadAiProviderIcon() async {
    try {
      final provider = await LlmConfigManager.getActiveProvider();
      if (!mounted) return;
      if (provider != null) {
        final preset = getPresetByKey(provider.providerKey);
        if (preset != null) {
          setState(() => _aiIcon = preset.icon);
        }
      }
    } catch (e) {
      debugPrint('[AiChatPage] _loadAiProviderIcon error: $e');
    }
  }

  /// 处理从外部传入的输入（如浮动按钮录音结果）
  void _handleExternalInput() {
    final extra = GoRouterState.of(context).extra;
    if (extra is Map<String, dynamic>) {
      final transcribedText = extra['transcribedText'] as String?;
      final voicePath = extra['voicePath'] as String?;

      if (transcribedText != null && transcribedText.isNotEmpty) {
        // 仅转文字模式：填入输入框
        // 通过延迟确保 build 完成后再处理
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _processInput(text: transcribedText);
        });
      } else if (voicePath != null && voicePath.isNotEmpty) {
        // 完整管线模式：语音→转文字→AI解析
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _processInput(voicePath: voicePath);
        });
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialMessages() async {
    setState(() => _isLoading = true);
    try {
      final messages = await _chatRepo.getMessages(
        bookId: _bookId,
        conversationId: _conversationId,
        limit: _pageSize,
      );
      if (!mounted) return;
      setState(() {
        _items = messages.map((m) => _ChatItem.fromMessage(m)).toList();
        _isLoading = false;
        _hasMore = messages.length >= _pageSize;
      });
      _scrollToBottom();
    } catch (e) {
      debugPrint('[AiChatPage] _loadInitialMessages error: $e');
      if (!mounted) return;
      setState(() {
        _items = [];
        _isLoading = false;
        _hasMore = false;
      });
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels <= 50 && !_isLoadingMore && _hasMore) {
      _loadMoreMessages();
    }
  }

  Future<void> _loadMoreMessages() async {
    if (_items.isEmpty) return;
    final firstMsg = _items.where((i) => i.message != null).firstOrNull;
    if (firstMsg?.message == null) return;
    setState(() => _isLoadingMore = true);

    final older = await _chatRepo.getMessages(
      bookId: _bookId,
      conversationId: _conversationId,
      limit: _pageSize,
      before: firstMsg!.message!.createdAt,
    );

    setState(() {
      _items = [...older.map((m) => _ChatItem.fromMessage(m)), ..._items];
      _isLoadingMore = false;
      _hasMore = older.length >= _pageSize;
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // ==================== 统一输入处理 ====================

  /// 统一处理入口：文本/语音/图片都走此方法
  Future<void> _processInput({
    String? text,
    String? voicePath,
    String? imagePath,
  }) async {
    if (_isAiResponding) return;

    InputSource source;
    String displayText;
    String? mediaFilePath;

    if (text != null && text.trim().isNotEmpty) {
      source = InputSource.text;
      displayText = text.trim();
    } else if (voicePath != null) {
      source = InputSource.voice;
      displayText = AppLocalizations.of(context)!.chatPageVoicePlaceholder; // 先显示占位，转写后更新
      mediaFilePath = voicePath;
    } else if (imagePath != null) {
      source = InputSource.image;
      displayText = AppLocalizations.of(context)!.chatPageImagePlaceholder;
      mediaFilePath = imagePath;
    } else {
      return;
    }

    // 1. 保存并显示用户消息
    final userMsgId = await _chatRepo.insertMessage(
      ConversationMessagesCompanion.insert(
        conversationId: _conversationId,
        role: 'user',
        content: displayText,
        accountBookId: _bookId,
        mediaType: Value(source == InputSource.text ? null : source.name),
        mediaFilePath: Value(mediaFilePath),
      ),
    );

    setState(() {
      _items.add(_ChatItem.user(ConversationMessage(
        id: userMsgId,
        conversationId: _conversationId,
        role: 'user',
        content: displayText,
        accountBookId: _bookId,
        createdAt: DateTime.now(),
        mediaType: source == InputSource.text ? null : source.name,
        mediaFilePath: mediaFilePath,
      )));
      _isAiResponding = true;
    });
    _scrollToBottom();

    // 2. 通过统一管线处理
    try {
      final provider = await ref.read(llmRepositoryProvider).getActiveProvider();
      if (!mounted) return;
      if (provider == null || !provider.isComplete) {
        throw LlmException(AppLocalizations.of(context)!.chatPageConfigAiError);
      }

      PipelineResult result;
      switch (source) {
        case InputSource.text:
          result = await _pipeline.processText(displayText);
          break;
        case InputSource.voice:
          result = await _pipeline.processVoice(
            audioTempPath: voicePath!,
            provider: provider,
          );
          if (!mounted) return;
          // 更新用户消息为转写文本
          await _chatRepo.insertMessage(
            ConversationMessagesCompanion.insert(
              conversationId: _conversationId,
              role: 'assistant',
              content: AppLocalizations.of(context)!.chatPageVoiceTranscription(result.normalizedText),
              accountBookId: _bookId,
            ),
          );
          setState(() {
            _items.add(_ChatItem.assistant(ConversationMessage(
              id: 0,
              conversationId: _conversationId,
              role: 'assistant',
              content: AppLocalizations.of(context)!.chatPageVoiceTranscription(result.normalizedText),
              accountBookId: _bookId,
              createdAt: DateTime.now(),
            )));
          });
          break;
        case InputSource.image:
          result = await _pipeline.processImage(
            imageTempPath: imagePath!,
            provider: provider,
          );
          if (!mounted) return;
          // 显示图片识别结果
          await _chatRepo.insertMessage(
            ConversationMessagesCompanion.insert(
              conversationId: _conversationId,
              role: 'assistant',
              content: AppLocalizations.of(context)!.chatPageImageRecognition(result.normalizedText),
              accountBookId: _bookId,
            ),
          );
          setState(() {
            _items.add(_ChatItem.assistant(ConversationMessage(
              id: 0,
              conversationId: _conversationId,
              role: 'assistant',
              content: AppLocalizations.of(context)!.chatPageImageRecognition(result.normalizedText),
              accountBookId: _bookId,
              createdAt: DateTime.now(),
            )));
          });
          break;
      }

      // 3. 为每笔交易匹配分类并生成确认卡片
      final confirmCards = <ConfirmData>[];
      for (final txn in result.transactions) {
        final matchedCategory = await _matchCategory(txn.category, txn.type);
        final matchedSub = await _matchSubcategory(matchedCategory.id, txn.subcategory);

        DateTime txnDate = DateTime.now();
        if (txn.date != null && txn.date!.isNotEmpty) {
          try {
            txnDate = DateTime.parse(txn.date!);
          } catch (_) {}
        }

        confirmCards.add(ConfirmData(
          originalInput: result.normalizedText,
          amount: txn.amount,
          type: txn.type,
          category: matchedCategory.name,
          categoryId: matchedCategory.id,
          subcategory: matchedSub?.name ?? (mounted ? AppLocalizations.of(context)!.chatPageNoSubcategory : 'N/A'),
          parentCategoryId: matchedSub?.id,
          description: txn.description.isNotEmpty
              ? txn.description
              : result.normalizedText.replaceAll(RegExp(r'\d+\.?\d*'), '').trim(),
          note: txn.note,
          payMethod: txn.payMethod,
          date: txnDate,
          confidence: txn.confidence,
          mediaFilePath: result.mediaFilePath,
          mediaType: source == InputSource.text ? null : source.name,
        ));
      }

      // 4. 显示确认卡片
      if (!mounted) return;
      setState(() {
        for (final card in confirmCards) {
          _items.add(_ChatItem.confirm(card));
        }
        _isAiResponding = false;
      });
    } catch (e) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      final errorMsg = l10n.chatPageParseError(resolveLlmError(e, l10n));
      await _chatRepo.insertMessage(
        ConversationMessagesCompanion.insert(
          conversationId: _conversationId,
          role: 'assistant',
          content: errorMsg,
          accountBookId: _bookId,
        ),
      );
      setState(() {
        _items.add(_ChatItem.assistant(ConversationMessage(
          id: 0,
          conversationId: _conversationId,
          role: 'assistant',
          content: errorMsg,
          accountBookId: _bookId,
          createdAt: DateTime.now(),
        )));
        _isAiResponding = false;
      });
    }
    _scrollToBottom();
  }

  // ==================== 分类匹配 ====================

  Future<Category> _matchCategory(String categoryName, String type) async {
    final categories = await _catRepo.getTopLevel();
    if (!mounted) throw Exception('Widget disposed');
    if (categories.isEmpty) {
      throw Exception(AppLocalizations.of(context)!.chatPageNoCategoryError);
    }

    final isExpense = type == 'expense';

    for (final c in categories) {
      if (c.name == categoryName && c.isExpense == isExpense) return c;
    }
    for (final c in categories) {
      if ((c.name.contains(categoryName) || categoryName.contains(c.name)) && c.isExpense == isExpense) {
        return c;
      }
    }
    for (final c in categories) {
      if (c.isExpense == isExpense) return c;
    }
    return categories.first;
  }

  Future<Category?> _matchSubcategory(int parentId, String? subcategoryName) async {
    if (subcategoryName == null || subcategoryName.isEmpty) return null;

    final children = await _catRepo.getChildren(parentId);

    for (final c in children) {
      if (c.name == subcategoryName) return c;
    }
    for (final c in children) {
      if (c.name.contains(subcategoryName) || subcategoryName.contains(c.name)) {
        return c;
      }
    }

    try {
      final newId = await _catRepo.insert(CategoriesCompanion.insert(
        name: subcategoryName,
        icon: const Value('📦'),
        color: const Value('#607D8B'),
        parentId: Value(parentId),
        level: const Value(2),
        isSystem: const Value(false),
        isExpense: Value(true),
        sortOrder: Value(children.length + 1),
      ));
      return await _catRepo.getById(newId);
    } catch (_) {
      return null;
    }
  }

  // ==================== 确认/取消 ====================

  Future<void> _confirmSave(ConfirmData data) async {
    try {
      await _txnRepo.insert(TransactionsCompanion.insert(
        amount: data.amount,
        type: Value(data.type),
        description: data.description,
        note: Value(data.note),
        categoryId: data.categoryId,
        parentCategoryId: Value(data.parentCategoryId),
        transactionDate: data.date,
        payMethod: Value(data.payMethod),
        originalInput: Value(data.originalInput),
        aiSource: Value(data.confidence > 0.85 ? 'llm' : 'rule'),
        aiConfidence: Value(data.confidence),
        accountBookId: _bookId,
        mediaFilePath: Value(data.mediaFilePath),
        mediaType: Value(data.mediaType),
      ));

      if (!mounted) return;

      setState(() {
        final idx = _items.indexWhere((i) => i.isConfirm && i.confirmData == data);
        if (idx != -1) _items.removeAt(idx);

        _items.add(_ChatItem.saved(SavedData(
          amount: data.amount,
          type: data.type,
          category: data.category,
          description: data.description,
          date: data.date,
          payMethod: data.payMethod,
        )));
      });
      _scrollToBottom();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.chatPageSaveFailed(resolveLlmError(e, AppLocalizations.of(context)!))),
            behavior: SnackBarBehavior.floating,
            backgroundColor: context.colors.error,
          ),
        );
      }
    }
  }

  void _cancelConfirm(ConfirmData data) {
    setState(() {
      final idx = _items.indexWhere((i) => i.isConfirm && i.confirmData == data);
      if (idx != -1) _items.removeAt(idx);
    });
  }

  void _updateConfirm(ConfirmData oldData, ConfirmData newData) {
    setState(() {
      final idx = _items.indexWhere((i) => i.isConfirm && i.confirmData == oldData);
      if (idx != -1) {
        _items[idx] = _ChatItem.confirm(newData);
      }
    });
  }

  /// 删除单条消息
  Future<void> _deleteMessage(_ChatItem item) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.commonDelete),
        content: Text(l10n.chatDeleteMsgConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.commonCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.commonDelete, style: TextStyle(color: context.colors.error)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    // 从数据库删除
    if (item.message != null && item.message!.id > 0) {
      await _chatRepo.deleteMessage(item.message!.id);
    }
    if (!mounted) return;
    setState(() {
      _items.remove(item);
    });
  }

  /// 复制消息内容到剪贴板
  void _copyMessage(String content) {
    Clipboard.setData(ClipboardData(text: content));
    AppToast.show(context, AppLocalizations.of(context)!.chatCopyMessage, duration: const Duration(milliseconds: 1200));
  }

  /// 长按消息弹出操作菜单
  void _showMessageActions(_ChatItem item) {
    final l10n = AppLocalizations.of(context)!;
    final content = item.message?.content ?? '';
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: context.colors.textTertiary.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 8),
              if (content.isNotEmpty)
                ListTile(
                  leading: Icon(Icons.copy, color: context.colors.textSecondary),
                  title: Text(l10n.chatActionCopy),
                  onTap: () {
                    Navigator.of(ctx).pop();
                    _copyMessage(content);
                  },
                ),
              ListTile(
                leading: Icon(Icons.delete_outline, color: context.colors.error),
                title: Text(l10n.chatActionDelete, style: TextStyle(color: context.colors.error)),
                onTap: () {
                  Navigator.of(ctx).pop();
                  _deleteMessage(item);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==================== UI ====================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      body: Column(
        children: [
          SizedBox(height: MediaQuery.of(context).padding.top),
          _buildTopBar(),
          Expanded(child: _buildMessageList()),
          if (_isAiResponding) _buildTypingIndicator(),
          ChatInputBar(
            onSubmit: (text) => _processInput(text: text),
            onVoiceRecorded: (path) => _processInput(voicePath: path),
            onImageCaptured: (path) => _processInput(imagePath: path),
            isLoading: _isAiResponding,
            onManualEntry: () => context.push('/manual-entry'),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.md, vertical: AppDimensions.sm),
      color: context.colors.surface,
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.go('/transactions'),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: context.colors.surfaceSecondary,
                borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.receipt_long_outlined, size: 16, color: context.colors.textSecondary),
                  const SizedBox(width: 4),
                  Text(l10n.navTransactions, style: AppTextStyles.caption.copyWith(color: context.colors.textSecondary)),
                ],
              ),
            ),
          ),
          const Spacer(),
          Text(l10n.chatPageTitle, style: AppTextStyles.h3.copyWith(fontSize: 16)),
          const Spacer(),
          // 清空对话按钮
          GestureDetector(
            onTap: _onDeleteConversation,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: context.colors.surfaceSecondary,
                borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
              ),
              child: Icon(Icons.delete_outline, size: 16, color: context.colors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }

  void _onDeleteConversation() {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.chatDeleteTitle),
        content: Text(l10n.chatDeleteMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.commonCancel),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              await _chatRepo.deleteConversation(_bookId, _conversationId);
              if (!mounted) return;
              setState(() {
                _items = [];
                _hasMore = false;
              });
              AppToast.show(context, l10n.chatDeleteSuccess, duration: const Duration(milliseconds: 1500));
            },
            child: Text(l10n.commonDelete, style: TextStyle(color: context.colors.error)),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator(color: context.colors.primary));
    }
    if (_items.isEmpty) return _buildEmptyState();

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        itemCount: _items.length + (_isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (_isLoadingMore && index == 0) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))),
            );
          }

          final itemIndex = _isLoadingMore ? index - 1 : index;
          if (itemIndex < 0 || itemIndex >= _items.length) return const SizedBox.shrink();

          final item = _items[itemIndex];

          if (item.isConfirm && item.confirmData != null) {
            final data = item.confirmData!;
            return ConfirmCard(
              data: data,
              onConfirm: () => _confirmSave(data),
              onCancel: () => _cancelConfirm(data),
              onEdit: (newData) => _updateConfirm(data, newData),
              aiIcon: _aiIcon,
            );
          }

          if (item.isSaved && item.savedData != null) {
            final data = item.savedData!;
            return SavedCard(
              amount: data.amount,
              type: data.type,
              category: data.category,
              description: data.description,
              date: data.date,
              payMethod: data.payMethod,
              aiIcon: _aiIcon,
            );
          }

          if (item.message != null) {
            final msg = item.message!;
            return ChatBubble(
              isUser: msg.role == 'user',
              content: msg.content,
              time: msg.createdAt,
              mediaType: _parseMediaType(msg.mediaType),
              mediaFilePath: msg.mediaFilePath,
              userAvatarPath: _userAvatarPath,
              aiIcon: _aiIcon,
              onLongPress: () => _showMessageActions(item),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  MessageMediaType _parseMediaType(String? type) {
    switch (type) {
      case 'voice':
        return MessageMediaType.voice;
      case 'image':
        return MessageMediaType.image;
      default:
        return MessageMediaType.text;
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.chat_bubble_outline, size: 64, color: context.colors.textTertiary),
          const SizedBox(height: 16),
          Text(AppLocalizations.of(context)!.chatPageEmptyTitle, style: AppTextStyles.h3.copyWith(color: context.colors.textSecondary)),
          const SizedBox(height: 8),
          Text(AppLocalizations.of(context)!.chatPageEmptyHint,
              style: AppTextStyles.body.copyWith(color: context.colors.textTertiary)),
          const SizedBox(height: 4),
          Text(AppLocalizations.of(context)!.chatPageEmptyInstruction,
              style: AppTextStyles.caption.copyWith(color: context.colors.textTertiary)),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: context.colors.textTertiary)),
            const SizedBox(width: 8),
            Text(AppLocalizations.of(context)!.chatPageAiParsing, style: AppTextStyles.caption),
          ],
        ),
      ),
    );
  }
}

// ==================== 内部数据模型 ====================

class _ChatItem {
  final ConversationMessage? message;
  final ConfirmData? confirmData;
  final SavedData? savedData;
  final bool isConfirm;
  final bool isSaved;

  _ChatItem.user(this.message) : confirmData = null, savedData = null, isConfirm = false, isSaved = false;
  _ChatItem.assistant(this.message) : confirmData = null, savedData = null, isConfirm = false, isSaved = false;
  _ChatItem.confirm(this.confirmData) : message = null, savedData = null, isConfirm = true, isSaved = false;
  _ChatItem.saved(this.savedData) : message = null, confirmData = null, isConfirm = false, isSaved = true;

  static _ChatItem fromMessage(ConversationMessage m) {
    return m.role == 'user' ? _ChatItem.user(m) : _ChatItem.assistant(m);
  }
}

/// 已保存账单数据（用于展示保存成功卡片）
class SavedData {
  final double amount;
  final String type;
  final String category;
  final String description;
  final DateTime date;
  final String? payMethod;

  const SavedData({
    required this.amount,
    required this.type,
    required this.category,
    required this.description,
    required this.date,
    this.payMethod,
  });
}

/// AI 解析确认数据（可编辑）
class ConfirmData {
  final String originalInput;
  double amount;
  String type;
  String category;
  int categoryId;
  String? subcategory;
  int? parentCategoryId;
  String description;
  String? note;
  String? payMethod;
  DateTime date;
  final double confidence;
  final String? mediaFilePath;
  final String? mediaType;

  ConfirmData({
    required this.originalInput,
    required this.amount,
    required this.type,
    required this.category,
    required this.categoryId,
    this.subcategory,
    this.parentCategoryId,
    required this.description,
    this.note,
    this.payMethod,
    required this.date,
    required this.confidence,
    this.mediaFilePath,
    this.mediaType,
  });

  ConfirmData copyWith({
    double? amount,
    String? type,
    String? category,
    int? categoryId,
    String? subcategory,
    int? parentCategoryId,
    String? description,
    String? note,
    String? payMethod,
    DateTime? date,
  }) {
    return ConfirmData(
      originalInput: originalInput,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      category: category ?? this.category,
      categoryId: categoryId ?? this.categoryId,
      subcategory: subcategory ?? this.subcategory,
      parentCategoryId: parentCategoryId ?? this.parentCategoryId,
      description: description ?? this.description,
      note: note ?? this.note,
      payMethod: payMethod ?? this.payMethod,
      date: date ?? this.date,
      confidence: confidence,
      mediaFilePath: mediaFilePath,
      mediaType: mediaType,
    );
  }
}
