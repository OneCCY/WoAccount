import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:wo_account/l10n/app_localizations.dart';
import '../../../../config/di/providers.dart';
import '../../../../config/database/app_database.dart';
import '../../../../core/locale/locale_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/repositories/account_book_repository.dart';
import '../widgets/create_book_sheet.dart';
import '../../../../core/widgets/toast.dart';

/// 账本列表页
/// 当前默认账本高亮卡片 + 其他账本列表 + 新建按钮
class AccountBookPage extends ConsumerStatefulWidget {
  const AccountBookPage({super.key});

  @override
  ConsumerState<AccountBookPage> createState() => _AccountBookPageState();
}

class _AccountBookPageState extends ConsumerState<AccountBookPage> {
  late final AccountBookRepository _repo;
  List<AccountBook> _books = [];
  Map<int, AccountBookStats> _statsMap = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _repo = ref.read(accountBookRepositoryProvider);
    _loadData();
  }

  Future<void> _loadData() async {
    final books = await _repo.getAll();
    final statsMap = <int, AccountBookStats>{};
    final now = DateTime.now();
    for (final book in books) {
      statsMap[book.id] = await _repo.getStats(book.id, now.year, now.month);
    }
    setState(() {
      _books = books;
      _statsMap = statsMap;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final currentBookId = ref.watch(currentBookProvider);
    final currentBook = _books.where((b) => b.id == currentBookId).firstOrNull ?? _books.firstOrNull;
    final otherBooks = _books.where((b) => b.id != currentBookId).toList();

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        title: Text(l10n.bookTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: l10n.bookRecycleBin,
            onPressed: () => context.push('/account-books/recycle-bin').then((_) => _loadData()),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 16),

                  // 当前账本高亮卡片
                  if (currentBook != null) _buildDefaultCard(currentBook, isCurrent: true),

                  const SizedBox(height: 16),

                  // 其他账本列表
                  ...otherBooks.map((b) => _buildBookItem(b, isCurrent: b.id == currentBookId)),

                  // 新建账本按钮
                  Padding(
                    padding: const EdgeInsets.all(AppDimensions.md),
                    child: OutlinedButton.icon(
                      onPressed: _onCreateBook,
                      icon: const Icon(Icons.add, size: 18),
                      label: Text(l10n.bookCreate),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 48),
                        side: BorderSide(color: context.colors.primary),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // 底部说明
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppDimensions.md),
                    child: Text(
                      l10n.bookDescription,
                      style: context.textStyles.caption.copyWith(color: context.colors.textTertiary),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }

  Widget _buildDefaultCard(AccountBook book, {bool isCurrent = false}) {
    final l10n = AppLocalizations.of(context)!;
    final stats = _statsMap[book.id];
    final typeLabel = _typeToLabel(book.type);
    final icon = book.icon ?? '📒';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.md),
      child: GestureDetector(
        onTap: () => _onBookTap(book),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF4CAF50), Color(0xFF66BB6A)],
            ),
            borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
            boxShadow: [
              BoxShadow(
                color: context.colors.primary.withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 头部：图标 + 名称 + 默认标签
              Row(
                children: [
                  Text(icon, style: const TextStyle(fontSize: 28)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(book.name, style: context.textStyles.h3.copyWith(color: Colors.white)),
                            if (isCurrent) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.25),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(l10n.bookCurrent, style: context.textStyles.caption.copyWith(color: Colors.white)),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(typeLabel, style: context.textStyles.caption.copyWith(color: Colors.white70)),
                      ],
                    ),
                  ),
                ],
              ),

              if (stats != null) ...[
                const SizedBox(height: 20),
                // 月度收支
                Row(
                  children: [
                    _buildStatItem(l10n.bookMonthlyExpense, context.localeProvider.currency.formatAmount(stats.totalExpense, decimals: 0)),
                    const SizedBox(width: 24),
                    _buildStatItem(l10n.bookMonthlyIncome, context.localeProvider.currency.formatAmount(stats.totalIncome, decimals: 0)),
                    const Spacer(),
                    _buildStatItem(l10n.bookTransactionCount, '${stats.count}'),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: context.textStyles.caption.copyWith(color: Colors.white70)),
        const SizedBox(height: 2),
        Text(value, style: context.textStyles.amountSmall.copyWith(color: Colors.white)),
      ],
    );
  }

  Widget _buildBookItem(AccountBook book, {bool isCurrent = false}) {
    final l10n = AppLocalizations.of(context)!;
    final stats = _statsMap[book.id];
    final typeLabel = _typeToLabel(book.type);
    final icon = book.icon ?? '📒';

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.md,
        vertical: 4,
      ),
      child: Slidable(
        endActionPane: ActionPane(
          motion: const DrawerMotion(),
          children: [
            SlidableAction(
              onPressed: (_) => _onSwitchTo(book),
              backgroundColor: context.colors.primary,
              foregroundColor: Colors.white,
              icon: Icons.swap_horiz,
              label: l10n.bookDetailSwitchTo,
            ),
            SlidableAction(
              onPressed: (_) => _onDeleteBook(book),
              backgroundColor: context.colors.error,
              foregroundColor: Colors.white,
              icon: Icons.delete_outline,
              label: l10n.bookDelete,
            ),
          ],
        ),
        child: GestureDetector(
          onTap: () => _onBookTap(book),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: context.colors.surface,
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            ),
            child: Row(
              children: [
                // 图标
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: context.colors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                  ),
                  child: Center(child: Text(icon, style: const TextStyle(fontSize: 22))),
                ),
                const SizedBox(width: 12),
                // 名称 + 类型 + 描述
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(book.name, style: context.textStyles.body),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                            decoration: BoxDecoration(
                              color: context.colors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(typeLabel, style: context.textStyles.caption.copyWith(color: context.colors.primary, fontSize: 10)),
                          ),
                          if (isCurrent) ...[
                            const SizedBox(width: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                              decoration: BoxDecoration(
                                color: context.colors.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(l10n.bookCurrent, style: context.textStyles.caption.copyWith(color: context.colors.primary, fontSize: 10)),
                            ),
                          ],
                        ],
                      ),
                      if (book.description != null && book.description!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          book.description!,
                          style: context.textStyles.caption.copyWith(color: context.colors.textTertiary),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // 交易笔数
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      l10n.bookCountUnit('${stats?.count ?? 0}'),
                      style: context.textStyles.caption.copyWith(color: context.colors.textSecondary),
                    ),
                    const SizedBox(height: 2),
                    Icon(Icons.chevron_right, size: 18, color: context.colors.textTertiary),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onBookTap(AccountBook book) {
    context.push('/account-books/detail', extra: book.id).then((_) => _loadData());
  }

  Future<void> _onSwitchTo(AccountBook book) async {
    await switchCurrentBook(ref, book.id);
    _loadData();
    if (mounted) {
      AppToast.show(context, AppLocalizations.of(context)!.bookSwitchedTo(book.name), duration: const Duration(milliseconds: 800));
    }
  }

  Future<void> _onDeleteBook(AccountBook book) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.bookDeleteTitle),
        content: Text(l10n.bookDeleteConfirm(book.name)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l10n.commonCancel)),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: context.colors.error),
            child: Text(l10n.bookDelete),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await _repo.delete(book.id);
      if (success) {
        _loadData();
        if (mounted) {
          AppToast.show(context, l10n.bookDeleted, duration: const Duration(milliseconds: 800));
        }
      }
    }
  }

  Future<void> _onCreateBook() async {
    final result = await CreateBookSheet.show(context);

    if (result != null) {
      final book = AccountBooksCompanion.insert(
        name: result['name'] as String,
        type: result['type'] as String,
        icon: Value(result['icon'] as String?),
        description: Value(result['description'] as String?),
      );
      await _repo.insert(book);
      _loadData();
    }
  }

  String _typeToLabel(String type) {
    final l10n = AppLocalizations.of(context)!;
    switch (type) {
      case 'personal': return l10n.bookTypePersonal;
      case 'family': return l10n.bookTypeFamily;
      case 'couple': return l10n.bookTypeCouple;
      case 'student': return l10n.bookTypeStudent;
      case 'travel': return l10n.bookTypeTravel;
      case 'business': return l10n.bookTypeBusiness;
      case 'wedding': return l10n.bookTypeWedding;
      case 'rental': return l10n.bookTypeRental;
      case 'investment': return l10n.bookTypeInvestment;
      case 'pet': return l10n.bookTypePet;
      case 'health': return l10n.bookTypeHealth;
      case 'event': return l10n.bookTypeEvent;
      case 'other': return l10n.bookTypeOther;
      default: return type; // 自定义类型直接显示原始文本
    }
  }
}
