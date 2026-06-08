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
  late final int _bookId;

  @override
  void initState() {
    super.initState();
    _chatRepo = ref.read(chatRepositoryProvider);
    _txnRepo = ref.read(transactionRepositoryProvider);
    _catRepo = ref.read(categoryRepositoryProvider);
    _bookId = ref.read(currentBookProvider);
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
      bookId: _bookId,
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
      bookId: _bookId,
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

  /// 智能匹配分类（一级分类）
  Future<Category> _matchCategory(String categoryName, String type) async {
    final categories = await _catRepo.getTopLevel();
    if (categories.isEmpty) {
      throw Exception('没有可用分类，请先在分类管理中添加分类');
    }

    final isExpense = type == 'expense';

    // 精确匹配
    for (final c in categories) {
      if (c.name == categoryName && c.isExpense == isExpense) return c;
    }

    // 模糊匹配（包含关系）
    for (final c in categories) {
      if ((c.name.contains(categoryName) || categoryName.contains(c.name)) && c.isExpense == isExpense) {
        return c;
      }
    }

    // 按类型匹配第一个
    for (final c in categories) {
      if (c.isExpense == isExpense) return c;
    }

    return categories.first;
  }

  /// 智能匹配二级分类
  Future<Category?> _matchSubcategory(int parentId, String? subcategoryName) async {
    if (subcategoryName == null || subcategoryName.isEmpty) return null;

    final children = await _catRepo.getChildren(parentId);

    // 精确匹配
    for (final c in children) {
      if (c.name == subcategoryName) return c;
    }

    // 模糊匹配
    for (final c in children) {
      if (c.name.contains(subcategoryName) || subcategoryName.contains(c.name)) {
        return c;
      }
    }

    // 未找到，自动创建
    try {
      final newId = await _catRepo.insert(CategoriesCompanion.insert(
        name: subcategoryName,
        icon: const Value('📦'),
        color: const Value('#607D8B'),
        parentId: Value(parentId),
        level: const Value(2),
        isSystem: const Value(false),
        isExpense: Value(true), // 继承父分类
        sortOrder: Value(children.length + 1),
      ));
      return await _catRepo.getById(newId);
    } catch (_) {
      return null; // 创建失败返回null
    }
  }

  /// 发送文本 → AI 解析 → 显示确认卡片（支持多笔）
  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty || _isAiResponding) return;

    // 1. 保存并显示用户消息
    final userMsgId = await _chatRepo.insertMessage(
      ConversationMessagesCompanion.insert(
        conversationId: _conversationId,
        role: 'user',
        content: text,
        accountBookId: _bookId,
      ),
    );
    setState(() {
      _items.add(_ChatItem.user(ConversationMessage(
        id: userMsgId,
        conversationId: _conversationId,
        role: 'user',
        content: text,
        accountBookId: _bookId,
        createdAt: DateTime.now(),
      )));
      _isAiResponding = true;
    });
    _scrollToBottom();

    // 2. AI 解析
    try {
      final llmRepo = ref.read(llmRepositoryProvider);
      final results = await llmRepo.parseTransaction(text);

      // 3. 为每笔交易匹配分类并生成确认卡片
      final confirmCards = <ConfirmData>[];
      for (final result in results) {
        final matchedCategory = await _matchCategory(result.category, result.type);
        final matchedSub = await _matchSubcategory(matchedCategory.id, result.subcategory);

        DateTime txnDate = DateTime.now();
        if (result.date != null && result.date!.isNotEmpty) {
          try {
            txnDate = DateTime.parse(result.date!);
          } catch (_) {
            // 解析失败用今天
          }
        }

        confirmCards.add(ConfirmData(
          originalInput: text,
          amount: result.amount,
          type: result.type,
          category: matchedCategory.name,
          categoryId: matchedCategory.id,
          subcategory: matchedSub?.name ?? '暂无',
          subcategoryId: matchedSub?.id,
          description: result.description.isNotEmpty
              ? result.description
              : text.replaceAll(RegExp(r'\d+\.?\d*'), '').trim(),
          date: txnDate,
          confidence: result.confidence,
        ));
      }

      // 4. 显示确认卡片
      setState(() {
        for (final card in confirmCards) {
          _items.add(_ChatItem.confirm(card));
        }
        _isAiResponding = false;
      });
    } catch (e) {
      final errorMsg = '❌ 解析失败：$e\n\n请尝试更明确的描述，如"午饭拉面25"';
      final aiMsgId = await _chatRepo.insertMessage(
        ConversationMessagesCompanion.insert(
          conversationId: _conversationId,
          role: 'assistant',
          content: errorMsg,
          accountBookId: _bookId,
        ),
      );
      setState(() {
        _items.add(_ChatItem.assistant(ConversationMessage(
          id: aiMsgId,
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

  /// 用户确认保存单笔
  Future<void> _confirmSave(ConfirmData data) async {
    try {
      await _txnRepo.insert(TransactionsCompanion.insert(
        amount: data.amount,
        description: data.description,
        categoryId: data.categoryId,
        subcategoryId: Value(data.subcategoryId),
        transactionDate: data.date,
        originalInput: Value(data.originalInput),
        aiSource: Value(data.confidence > 0.85 ? 'llm' : 'rule'),
        aiConfidence: Value(data.confidence),
        accountBookId: _bookId,
      ));

      final amountPrefix = data.type == 'expense' ? '-' : '+';
      final summary = '✅ 已保存\n'
          '$amountPrefix¥${data.amount.toStringAsFixed(2)} · ${data.category}\n'
          '${data.description} · ${DateFormat('MM/dd').format(data.date)}';

      final aiMsgId = await _chatRepo.insertMessage(
        ConversationMessagesCompanion.insert(
          conversationId: _conversationId,
          role: 'assistant',
          content: summary,
          accountBookId: _bookId,
        ),
      );

      setState(() {
        // 只移除当前这条确认卡片
        final idx = _items.indexWhere((i) => i.isConfirm && i.confirmData == data);
        if (idx != -1) _items.removeAt(idx);

        _items.add(_ChatItem.assistant(ConversationMessage(
          id: aiMsgId,
          conversationId: _conversationId,
          role: 'assistant',
          content: summary,
          accountBookId: _bookId,
          createdAt: DateTime.now(),
        )));
      });
      _scrollToBottom();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('保存失败: $e'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  /// 用户取消确认
  void _cancelConfirm(ConfirmData data) {
    setState(() {
      final idx = _items.indexWhere((i) => i.isConfirm && i.confirmData == data);
      if (idx != -1) _items.removeAt(idx);
    });
  }

  /// 修改确认数据
  void _updateConfirm(ConfirmData oldData, ConfirmData newData) {
    setState(() {
      final idx = _items.indexWhere((i) => i.isConfirm && i.confirmData == oldData);
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
                const SnackBar(content: Text('拍照识别功能开发中'), behavior: SnackBarBehavior.floating, duration: Duration(milliseconds: 500)),
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
          const SizedBox(width: 56),
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
            final data = item.confirmData!;
            return ConfirmCard(
              data: data,
              onConfirm: () => _confirmSave(data),
              onCancel: () => _cancelConfirm(data),
              onEdit: (newData) => _updateConfirm(data, newData),
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
          Text('试试输入 "午饭拉面25" 或 "吃饭24，洗衣服34"',
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
  String type;
  String category;
  int categoryId;
  String? subcategory;
  int? subcategoryId;
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
    this.subcategoryId,
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
    int? subcategoryId,
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
      subcategoryId: subcategoryId ?? this.subcategoryId,
      description: description ?? this.description,
      date: date ?? this.date,
      confidence: confidence,
    );
  }
}
