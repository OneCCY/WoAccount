import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wo_account/l10n/app_localizations.dart';
import '../../../../config/di/providers.dart';
import '../../../../config/database/app_database.dart';
import '../../../../core/locale/locale_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/repositories/account_book_repository.dart';
import '../../../../core/widgets/toast.dart';

/// 账本详情页
/// 显示账本信息、月度统计，支持设为默认、切换、清空数据、删除
class AccountBookDetailPage extends ConsumerStatefulWidget {
  final int bookId;

  const AccountBookDetailPage({super.key, required this.bookId});

  @override
  ConsumerState<AccountBookDetailPage> createState() => _AccountBookDetailPageState();
}

class _AccountBookDetailPageState extends ConsumerState<AccountBookDetailPage> {
  late final AccountBookRepository _repo;
  AccountBook? _book;
  AccountBookStats? _stats;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _repo = ref.read(accountBookRepositoryProvider);
    _loadData();
  }

  Future<void> _loadData() async {
    final book = await _repo.getById(widget.bookId);
    AccountBookStats? stats;
    if (book != null) {
      final now = DateTime.now();
      stats = await _repo.getStats(book.id, now.year, now.month);
    }
    setState(() {
      _book = book;
      _stats = stats;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.bookDetailTitle)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final book = _book;
    if (book == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.bookDetailTitle)),
        body: Center(child: Text(l10n.bookDetailNotExist)),
      );
    }

    final icon = book.icon ?? '📒';
    final typeLabel = _typeToLabel(book.type);

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        title: Text(l10n.bookDetailTitle),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 24),

            // 账本图标 + 名称
            Text(icon, style: const TextStyle(fontSize: 48)),
            const SizedBox(height: 12),
            Text(book.name, style: context.textStyles.h2),
            const SizedBox(height: 4),
            Text(typeLabel, style: context.textStyles.caption.copyWith(color: context.colors.textTertiary)),

            // 月度统计
            if (_stats != null) ...[
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppDimensions.md),
                child: Row(
                  children: [
                    Expanded(child: _buildStatCard(context, l10n.bookMonthlyExpense, context.localeProvider.currency.formatAmount(_stats!.totalExpense, decimals: 0), context.colors.error)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildStatCard(context, l10n.bookMonthlyIncome, context.localeProvider.currency.formatAmount(_stats!.totalIncome, decimals: 0), context.colors.success)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildStatCard(context, l10n.bookDetailExpenseCount, '${_stats!.count}', context.colors.textSecondary)),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 32),

            // 功能菜单
            _buildMenuSection(context, l10n.bookDetailNormalSection, [
              _MenuItemData(Icons.swap_horiz, l10n.bookDetailSwitchTo, onTap: () => _onSwitchToBook(book)),
            ]),

            const SizedBox(height: 16),

            // 危险区域
            _buildMenuSection(context, l10n.bookDetailDangerSection, [
              _MenuItemData(Icons.delete_sweep_outlined, l10n.bookDetailClearData, onTap: () => _onClearData(book), isDestructive: true),
              if (book.id != ref.watch(currentBookProvider))
                _MenuItemData(Icons.delete_forever_outlined, l10n.bookDeleteTitle, onTap: () => _onDeleteBook(book), isDestructive: true),
              if (book.id == ref.watch(currentBookProvider))
                _MenuItemData(Icons.lock_outline, l10n.bookDetailDefaultNotDeletable, isDestructive: true),
            ]),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      ),
      child: Column(
        children: [
          Text(label, style: context.textStyles.caption.copyWith(color: context.colors.textTertiary)),
          const SizedBox(height: 6),
          Text(value, style: context.textStyles.amountSmall.copyWith(color: color)),
        ],
      ),
    );
  }

  Widget _buildMenuSection(BuildContext context, String title, List<_MenuItemData> items) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(title, style: context.textStyles.footnote.copyWith(
              color: title == AppLocalizations.of(context)!.bookDetailDangerSection ? context.colors.error : context.colors.textTertiary,
            )),
          ),
          Container(
            decoration: BoxDecoration(
              color: context.colors.surface,
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            ),
            child: Column(
              children: items.asMap().entries.map((entry) {
                final item = entry.value;
                final isLast = entry.key == items.length - 1;
                return Column(
                  children: [
                    ListTile(
                      leading: Icon(item.icon, color: item.isDestructive ? context.colors.error : context.colors.textSecondary, size: 22),
                      title: Text(
                        item.label,
                        style: context.textStyles.body.copyWith(
                          color: item.isDestructive ? context.colors.error : null,
                        ),
                      ),
                      trailing: item.onTap != null
                          ? const Icon(Icons.chevron_right, size: 20)
                          : null,
                      onTap: item.onTap,
                    ),
                    if (!isLast)
                      Divider(height: 1, indent: 56, color: context.colors.separator),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _onSwitchToBook(AccountBook book) async {
    await switchCurrentBook(ref, book.id);
    if (mounted) {
      AppToast.show(context, AppLocalizations.of(context)!.bookSwitchedTo(book.name), duration: const Duration(milliseconds: 800));
      Navigator.pop(context);
    }
  }

  Future<void> _onClearData(AccountBook book) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.bookDetailClearTitle),
        content: Text(l10n.bookDetailClearConfirm(book.name)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l10n.commonCancel)),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: context.colors.error),
            child: Text(l10n.bookDetailClear),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _repo.clearData(book.id);
      if (mounted) {
        AppToast.show(context, l10n.bookDetailCleared, duration: const Duration(milliseconds: 800));
        _loadData();
      }
    }
  }

  Future<void> _onDeleteBook(AccountBook book) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.bookDeleteTitle),
        content: Text(l10n.bookDetailDeleteConfirm(book.name)),
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
      if (success && mounted) {
        Navigator.pop(context);
        AppToast.show(context, l10n.bookDeleted, duration: const Duration(milliseconds: 800));
      }
    }
  }

  String _typeToLabel(String type) {
    final l10n = AppLocalizations.of(context)!;
    switch (type) {
      case 'personal': return l10n.bookDetailTypePersonal;
      case 'family': return l10n.bookDetailTypeFamily;
      case 'couple': return l10n.bookTypeCouple;
      case 'student': return l10n.bookTypeStudent;
      case 'travel': return l10n.bookDetailTypeTravel;
      case 'business': return l10n.bookDetailTypeBusiness;
      case 'wedding': return l10n.bookTypeWedding;
      case 'rental': return l10n.bookTypeRental;
      case 'investment': return l10n.bookTypeInvestment;
      case 'pet': return l10n.bookTypePet;
      case 'health': return l10n.bookTypeHealth;
      case 'event': return l10n.bookTypeEvent;
      case 'other': return l10n.bookDetailTypeOther;
      default: return type; // 自定义类型直接显示原始文本
    }
  }
}

class _MenuItemData {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool isDestructive;

  const _MenuItemData(this.icon, this.label, {this.onTap, this.isDestructive = false});
}
