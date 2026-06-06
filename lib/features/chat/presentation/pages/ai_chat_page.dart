import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../config/database/app_database.dart';
import '../../../../config/di/providers.dart';
import '../../../../config/di/ai_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../category/domain/repositories/category_repository.dart';
import '../../../transaction/domain/repositories/transaction_repository.dart';
import '../../domain/repositories/chat_repository.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/chat_input_bar.dart';
import '../widgets/confirm_card.dart';

/// AI 记账对话页
class AiChatPage extends ConsumerStatefulWidget {
  const AiChatPage({super.key});

  @override
  ConsumerState<AiChatPage> createState() => _AiChatPageState();
}

class _AiChatPageState extends ConsumerState<AiChatPage> {
  final _scrollController = ScrollController();
  final _pageSize = 20;
  final String _conversationId = 'default';

  List<_ChatItem> _items = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  bool _isAiResponding = false;

  late final ChatRepository _chatRepo;
  late final TransactionRepository _txnRepo;
  late final CategoryRepository _catRepo;

  @override
  void initState() {
    super.initState();
    _chatRepo = ref.read(chatRepositoryProvider);
    _txnRepo = ref.read(transactionRepositoryProvider);
    _catRepo = ref.read(categoryRepositoryProvider);
    _scrollController.addListener(_onScroll);
    _loadInitialMessages();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialMessages() async {
    setState(() => _isLoading = true);
    final messages = await _chatRepo.getMessages(
      conversationId: _conversationId,
      limit: _pageSize,
    );
    setState(() {
      _items = messages.map((m) => _ChatItem.fromMessage(m)).toList();
      _isLoading = false;
      _hasMore = messages.length >= _pageSize;
    });
    _scrollToBottom();
  }

  void _onScroll() {
    if (_scrollController.position.pixels <= 50 && !_isLoadingMore && _hasMore) {
      _loadMoreMessages();
    }
  }

  Future<void> _loadMoreMessages() async {
    if (_items.isEmpty) return;
    final firstMsg = _items.firstWhere((i) => i.message != null);
    setState(() => _isLoadingMore = true);

    final older = await _chatRepo.getMessages(
      conversationId: _conversationId,
      limit: _pageSize,
      before: firstMsg.message!.createdAt,
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

  /// 发送文本 → AI 解析 → 显示确认卡片
  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty || _isAiResponding) return;

    // 1. 保存并显示用户消息
    final userMsgId = await _chatRepo.insertMessage(
      ConversationMessagesCompanion.insert(
        conversationId: _conversationId,
        role: 'user',
        content: text,
      ),
    );
    setState(() {
      _items.add(_ChatItem.user(ConversationMessage(
        id: userMsgId,
        conversationId: _conversationId,
        role: 'user',
        content: text,
        createdAt: DateTime.now(),
      )));
      _isAiResponding = true;
    });
    _scrollToBottom();

    // 2. AI 解析
    try {
      final llmRepo = ref.read(llmRepositoryProvider);
      final result = await llmRepo.parseTransaction(text);

      // 3. 匹配分类
      final categories = await _catRepo.getAll();
      final matchedCategory = categories.firstWhere(
        (c) => c.name == result.category,
        orElse: () => categories.firstWhere(
          (c) => c.isExpense == (result.type == 'expense'),
          orElse: () => categories.first,
        ),
      );

      DateTime txnDate = DateTime.now();
      if (result.date != null) {
        try { txnDate = DateTime.parse(result.date!); } catch (_) {}
      }

      // 4. 显示确认卡片（不自动保存）
      setState(() {
        _items.add(_ChatItem.confirm(ConfirmData(
          originalInput: text,
          amount: result.amount,
          type: result.type,
          category: matchedCategory.name,
          categoryId: matchedCategory.id,
          subcategory: result.subcategory,
          description: result.description.isNotEmpty
              ? result.description
              : text.replaceAll(RegExp(r'\d+\.?\d*'), '').trim(),
          date: txnDate,
          confidence: result.confidence,
        )));
        _isAiResponding = false;
      });
    } catch (e) {
      // 解析失败，保存错误消息
      final errorMsg = '❌ 解析失败：$e\n\n请尝试更明确的描述，如"午饭拉面25"';
      final aiMsgId = await _chatRepo.insertMessage(
        ConversationMessagesCompanion.insert(
          conversationId: _conversationId,
          role: 'assistant',
          content: errorMsg,
        ),
      );
      setState(() {
        _items.add(_ChatItem.assistant(ConversationMessage(
          id: aiMsgId,
          conversationId: _conversationId,
          role: 'assistant',
          content: errorMsg,
          createdAt: DateTime.now(),
        )));
        _isAiResponding = false;
      });
    }
    _scrollToBottom();
  }

  /// 用户确认保存
  Future<void> _confirmSave(ConfirmData data) async {
    // 保存交易
    await _txnRepo.insert(TransactionsCompanion.insert(
      amount: data.amount,
      description: data.description,
      categoryId: data.categoryId,
      transactionDate: data.date,
      originalInput: Value(data.originalInput),
      aiSource: Value(data.confidence > 0.85 ? 'llm' : 'rule'),
      aiConfidence: Value(data.confidence),
    ));

    // 保存 AI 确认消息
    final amountPrefix = data.type == 'expense' ? '-' : '+';
    final summary = '✅ 已保存\n'
        '$amountPrefix¥${data.amount.toStringAsFixed(2)} · ${data.category}\n'
        '${data.description} · ${DateFormat('MM/dd').format(data.date)}';

    final aiMsgId = await _chatRepo.insertMessage(
      ConversationMessagesCompanion.insert(
        conversationId: _conversationId,
        role: 'assistant',
        content: summary,
      ),
    );

    setState(() {
      // 移除确认卡片，替换为保存成功消息
      _items.removeWhere((i) => i.isConfirm);
      _items.add(_ChatItem.assistant(ConversationMessage(
        id: aiMsgId,
        conversationId: _conversationId,
        role: 'assistant',
        content: summary,
        createdAt: DateTime.now(),
      )));
    });
    _scrollToBottom();
  }

  /// 用户取消确认
  void _cancelConfirm() {
    setState(() {
      _items.removeWhere((i) => i.isConfirm);
    });
  }

  /// 修改确认数据
  void _updateConfirm(ConfirmData newData) {
    setState(() {
      final idx = _items.indexWhere((i) => i.isConfirm);
      if (idx != -1) {
        _items[idx] = _ChatItem.confirm(newData);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          SizedBox(height: MediaQuery.of(context).padding.top),
          _buildTopBar(),
          Expanded(child: _buildMessageList()),
          if (_isAiResponding) _buildTypingIndicator(),
          ChatInputBar(
            onSubmit: _sendMessage,
            isLoading: _isAiResponding,
            onManualEntry: () => context.push('/manual-entry'),
            onCamera: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('拍照识别功能开发中'), behavior: SnackBarBehavior.floating),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.md, vertical: AppDimensions.sm),
      color: AppColors.surface,
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.go('/transactions'),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.surfaceSecondary,
                borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.receipt_long_outlined, size: 16, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Text('账单', style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
                ],
              ),
            ),
          ),
          const Spacer(),
          Text('AI 记账', style: AppTextStyles.h3.copyWith(fontSize: 16)),
          const Spacer(),
          const SizedBox(width: 56), // 占位保持居中
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
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
            return ConfirmCard(
              data: item.confirmData!,
              onConfirm: () => _confirmSave(item.confirmData!),
              onCancel: _cancelConfirm,
              onEdit: _updateConfirm,
            );
          }

          if (item.message != null) {
            return ChatBubble(
              isUser: item.message!.role == 'user',
              content: item.message!.content,
              time: item.message!.createdAt,
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.chat_bubble_outline, size: 64, color: AppColors.textTertiary),
          const SizedBox(height: 16),
          Text('开始记账吧', style: AppTextStyles.h3.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 8),
          Text('试试输入 "午饭拉面25" 或 "打车去公司28"',
              style: AppTextStyles.body.copyWith(color: AppColors.textTertiary)),
          const SizedBox(height: 4),
          Text('长按记账按钮可语音输入 🎤',
              style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary)),
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
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.textTertiary)),
            const SizedBox(width: 8),
            Text('AI 正在解析...', style: AppTextStyles.caption),
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
  final bool isConfirm;

  _ChatItem.user(this.message) : confirmData = null, isConfirm = false;
  _ChatItem.assistant(this.message) : confirmData = null, isConfirm = false;
  _ChatItem.confirm(this.confirmData) : message = null, isConfirm = true;

  static _ChatItem fromMessage(ConversationMessage m) {
    return m.role == 'user' ? _ChatItem.user(m) : _ChatItem.assistant(m);
  }
}

/// AI 解析确认数据（可编辑）
class ConfirmData {
  final String originalInput;
  double amount;
  String type; // expense / income
  String category;
  int categoryId;
  String? subcategory;
  String description;
  DateTime date;
  final double confidence;

  ConfirmData({
    required this.originalInput,
    required this.amount,
    required this.type,
    required this.category,
    required this.categoryId,
    this.subcategory,
    required this.description,
    required this.date,
    required this.confidence,
  });

  ConfirmData copyWith({
    double? amount,
    String? type,
    String? category,
    int? categoryId,
    String? subcategory,
    String? description,
    DateTime? date,
  }) {
    return ConfirmData(
      originalInput: originalInput,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      category: category ?? this.category,
      categoryId: categoryId ?? this.categoryId,
      subcategory: subcategory ?? this.subcategory,
      description: description ?? this.description,
      date: date ?? this.date,
      confidence: confidence,
    );
  }
}
