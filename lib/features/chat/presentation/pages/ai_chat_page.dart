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

/// AI 记账对话页
/// 替代原首页，作为主要的记账交互界面
class AiChatPage extends ConsumerStatefulWidget {
  const AiChatPage({super.key});

  @override
  ConsumerState<AiChatPage> createState() => _AiChatPageState();
}

class _AiChatPageState extends ConsumerState<AiChatPage> {
  final _scrollController = ScrollController();
  final _pageSize = 20;

  final String _conversationId = 'default';
  List<ConversationMessage> _messages = [];
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

  /// 加载初始消息（最新 N 条）
  Future<void> _loadInitialMessages() async {
    setState(() => _isLoading = true);
    final messages = await _chatRepo.getMessages(
      conversationId: _conversationId,
      limit: _pageSize,
    );
    setState(() {
      _messages = messages;
      _isLoading = false;
      _hasMore = messages.length >= _pageSize;
    });
    _scrollToBottom();
  }

  /// 滚动到底部时加载更多（向上翻页）
  void _onScroll() {
    if (_scrollController.position.pixels <= 50 &&
        !_isLoadingMore &&
        _hasMore) {
      _loadMoreMessages();
    }
  }

  /// 加载更早的消息
  Future<void> _loadMoreMessages() async {
    if (_messages.isEmpty) return;
    setState(() => _isLoadingMore = true);

    final olderMessages = await _chatRepo.getMessages(
      conversationId: _conversationId,
      limit: _pageSize,
      before: _messages.first.createdAt,
    );

    setState(() {
      _messages = [...olderMessages, ..._messages];
      _isLoadingMore = false;
      _hasMore = olderMessages.length >= _pageSize;
    });
  }

  /// 滚动到底部
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

  /// 发送用户消息并获取 AI 响应
  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty || _isAiResponding) return;

    // 1. 保存用户消息
    final userMsgId = await _chatRepo.insertMessage(
      ConversationMessagesCompanion.insert(
        conversationId: _conversationId,
        role: 'user',
        content: text,
      ),
    );

    // 2. 立即显示用户消息
    final userMsg = ConversationMessage(
      id: userMsgId,
      conversationId: _conversationId,
      role: 'user',
      content: text,
      createdAt: DateTime.now(),
    );
    setState(() {
      _messages.add(userMsg);
      _isAiResponding = true;
    });
    _scrollToBottom();

    // 3. AI 解析并回复
    try {
      final llmRepo = ref.read(llmRepositoryProvider);
      final result = await llmRepo.parseTransaction(text);

      // 4. 匹配数据库分类
      final categories = await _catRepo.getAll();
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

      // 5. 构造 AI 回复
      final amountPrefix = result.type == 'expense' ? '-' : '+';
      final aiResponse = '已识别到一笔${result.type == 'expense' ? '支出' : '收入'}：\n'
          '💰 金额：$amountPrefix¥${result.amount.toStringAsFixed(2)}\n'
          '📂 分类：${matchedCategory.name}${result.subcategory != null ? ' > ${result.subcategory}' : ''}\n'
          '📝 描述：${result.description}\n'
          '📅 日期：${DateFormat('yyyy-MM-dd').format(txnDate)}\n'
          '🎯 置信度：${(result.confidence * 100).toInt()}%\n\n'
          '已自动保存到账单 ✅';

      // 6. 保存交易记录
      await _txnRepo.insert(TransactionsCompanion.insert(
        amount: result.amount,
        description: result.description.isNotEmpty
            ? result.description
            : text.replaceAll(RegExp(r'\d+\.?\d*'), '').trim(),
        categoryId: matchedCategory.id,
        transactionDate: txnDate,
        originalInput: Value(text),
        aiSource: Value(result.confidence > 0.85 ? 'llm' : 'rule'),
        aiConfidence: Value(result.confidence),
      ));

      // 7. 保存 AI 回复
      final aiMsgId = await _chatRepo.insertMessage(
        ConversationMessagesCompanion.insert(
          conversationId: _conversationId,
          role: 'assistant',
          content: aiResponse,
        ),
      );

      final aiMsg = ConversationMessage(
        id: aiMsgId,
        conversationId: _conversationId,
        role: 'assistant',
        content: aiResponse,
        createdAt: DateTime.now(),
      );
      setState(() {
        _messages.add(aiMsg);
        _isAiResponding = false;
      });
    } catch (e) {
      // 错误回复
      final errorMsg = '❌ 解析失败：$e\n\n请尝试更明确的描述，如"午饭拉面25"';
      final aiMsgId = await _chatRepo.insertMessage(
        ConversationMessagesCompanion.insert(
          conversationId: _conversationId,
          role: 'assistant',
          content: errorMsg,
        ),
      );
      final aiMsg = ConversationMessage(
        id: aiMsgId,
        conversationId: _conversationId,
        role: 'assistant',
        content: errorMsg,
        createdAt: DateTime.now(),
      );
      setState(() {
        _messages.add(aiMsg);
        _isAiResponding = false;
      });
    }
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // 顶部安全区
          SizedBox(height: MediaQuery.of(context).padding.top),

          // 顶部栏
          _buildTopBar(),

          // 聊天消息列表
          Expanded(child: _buildMessageList()),

          // AI 正在输入指示
          if (_isAiResponding) _buildTypingIndicator(),

          // 底部输入栏
          ChatInputBar(
            onSubmit: _sendMessage,
            isLoading: _isAiResponding,
            onManualEntry: () => context.push('/manual-entry'),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppDimensions.md,
        vertical: AppDimensions.sm,
      ),
      color: AppColors.surface,
      child: Row(
        children: [
          // 左侧记账按钮
          GestureDetector(
            onTap: () => context.push('/manual-entry'),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primarySurface,
                borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add, size: 16, color: AppColors.primary),
                  const SizedBox(width: 4),
                  Text('记账', style: AppTextStyles.caption.copyWith(color: AppColors.primary)),
                ],
              ),
            ),
          ),
          const Spacer(),
          Text('AI 记账', style: AppTextStyles.h3.copyWith(fontSize: 16)),
          const Spacer(),
          // 右侧跳转到账单
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
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }

    if (_messages.isEmpty) {
      return _buildEmptyState();
    }

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        itemCount: _messages.length + (_isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          // 加载更多指示器
          if (_isLoadingMore && index == 0) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            );
          }

          final msgIndex = _isLoadingMore ? index - 1 : index;
          if (msgIndex < 0 || msgIndex >= _messages.length) {
            return const SizedBox.shrink();
          }

          final msg = _messages[msgIndex];
          return ChatBubble(
            isUser: msg.role == 'user',
            content: msg.content,
            time: msg.createdAt,
          );
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
          Text(
            '试试输入 "午饭拉面25" 或 "打车去公司28"',
            style: AppTextStyles.body.copyWith(color: AppColors.textTertiary),
          ),
          const SizedBox(height: 8),
          Text(
            '长按麦克风按钮可语音输入 🎤',
            style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      alignment: Alignment.centerLeft,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.textTertiary,
                  ),
                ),
                const SizedBox(width: 8),
                Text('AI 正在解析...', style: AppTextStyles.caption),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
