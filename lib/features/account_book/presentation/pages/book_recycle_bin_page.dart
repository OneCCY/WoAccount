import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:wo_account/l10n/app_localizations.dart';
import '../../../../config/database/app_database.dart';
import '../../../../config/di/providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/repositories/account_book_repository.dart';

/// 账本回收站
/// 显示已删除的账本，支持恢复和永久删除
class BookRecycleBinPage extends ConsumerStatefulWidget {
  const BookRecycleBinPage({super.key});

  @override
  ConsumerState<BookRecycleBinPage> createState() => _BookRecycleBinPageState();
}

class _BookRecycleBinPageState extends ConsumerState<BookRecycleBinPage> {
  late final AccountBookRepository _repo;
  List<AccountBook> _deletedBooks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _repo = ref.read(accountBookRepositoryProvider);
    _loadData();
  }

  Future<void> _loadData() async {
    final books = await _repo.getDeletedAll();
    setState(() {
      _deletedBooks = books;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(title: Text(l10n.bookRecycleBin)),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _deletedBooks.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.delete_outline, size: 48, color: context.colors.textTertiary),
                      const SizedBox(height: 16),
                      Text(l10n.bookRecycleBinEmpty, style: context.textStyles.callout.copyWith(color: context.colors.textSecondary)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: _deletedBooks.length,
                  itemBuilder: (context, index) => _buildBookItem(_deletedBooks[index]),
                ),
    );
  }

  Widget _buildBookItem(AccountBook book) {
    final l10n = AppLocalizations.of(context)!;
    final icon = book.icon ?? '📒';
    final dateStr = DateFormat('yyyy-MM-dd HH:mm').format(book.updatedAt);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.md, vertical: 4),
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
                color: context.colors.textTertiary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
              ),
              child: Center(child: Text(icon, style: const TextStyle(fontSize: 22))),
            ),
            const SizedBox(width: 12),
            // 名称 + 删除时间
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(book.name, style: context.textStyles.body),
                  const SizedBox(height: 2),
                  Text(dateStr, style: context.textStyles.caption.copyWith(color: context.colors.textTertiary)),
                ],
              ),
            ),
            // 恢复按钮
            TextButton(
              onPressed: () => _onRestore(book),
              child: Text(l10n.bookRestore),
            ),
            // 永久删除按钮
            IconButton(
              onPressed: () => _onPermanentDelete(book),
              icon: Icon(Icons.delete_forever_outlined, color: context.colors.error, size: 20),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _onRestore(AccountBook book) async {
    final success = await _repo.restore(book.id);
    if (success && mounted) {
      _loadData();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.bookRestored), behavior: SnackBarBehavior.floating, duration: const Duration(milliseconds: 800)),
      );
    }
  }

  Future<void> _onPermanentDelete(AccountBook book) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.bookPermanentDelete),
        content: Text(l10n.bookPermanentDeleteConfirm(book.name)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l10n.commonCancel)),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: context.colors.error),
            child: Text(l10n.bookPermanentDelete),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      // 先清空数据，再物理删除账本
      await _repo.clearData(book.id);
      // 物理删除：直接从数据库移除
      final db = ref.read(appDatabaseProvider);
      await (db.delete(db.accountBooks)..where((b) => b.id.equals(book.id))).go();
      if (mounted) {
        _loadData();
      }
    }
  }
}
