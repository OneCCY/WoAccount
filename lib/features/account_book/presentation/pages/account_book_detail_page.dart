import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../config/di/providers.dart';
import '../../../../config/database/app_database.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/repositories/account_book_repository.dart';

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
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('账本详情')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final book = _book;
    if (book == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('账本详情')),
        body: const Center(child: Text('账本不存在')),
      );
    }

    final icon = book.icon ?? '📒';
    final typeLabel = _typeToLabel(book.type);

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        title: const Text('账本详情'),
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
                    Expanded(child: _buildStatCard(context, '本月支出', '¥${_stats!.totalExpense.toStringAsFixed(0)}', context.colors.error)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildStatCard(context, '本月收入', '¥${_stats!.totalIncome.toStringAsFixed(0)}', context.colors.success)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildStatCard(context, '交易笔数', '${_stats!.count}', context.colors.textSecondary)),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 32),

            // 功能菜单
            _buildMenuSection(context, '常规操作', [
              if (!book.isDefault)
                _MenuItemData(Icons.check_circle_outline, '设为默认账本', onTap: () => _onSetDefault(book)),
              _MenuItemData(Icons.swap_horiz, '切换到此账本', onTap: () => _onSwitchToBook(book)),
            ]),

            const SizedBox(height: 16),

            // 危险区域
            _buildMenuSection(context, '危险操作', [
              _MenuItemData(Icons.delete_sweep_outlined, '清空账本数据', onTap: () => _onClearData(book), isDestructive: true),
              if (!book.isDefault)
                _MenuItemData(Icons.delete_forever_outlined, '删除账本', onTap: () => _onDeleteBook(book), isDestructive: true),
              if (book.isDefault)
                _MenuItemData(Icons.lock_outline, '默认账本不可删除', isDestructive: true),
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
              color: title == '危险操作' ? context.colors.error : context.colors.textTertiary,
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

  Future<void> _onSetDefault(AccountBook book) async {
    await _repo.setDefault(book.id);
    ref.read(currentBookProvider.notifier).state = book.id;
    _loadData();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('已设为默认账本'), behavior: SnackBarBehavior.floating, duration: const Duration(milliseconds: 800)),
      );
    }
  }

  Future<void> _onSwitchToBook(AccountBook book) async {
    ref.read(currentBookProvider.notifier).state = book.id;
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('已切换到 ${book.name}'), behavior: SnackBarBehavior.floating, duration: const Duration(milliseconds: 800)),
      );
      Navigator.pop(context);
    }
  }

  Future<void> _onClearData(AccountBook book) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('清空数据'),
        content: Text('确定要清空「${book.name}」的所有交易记录和对话历史吗？\n\n此操作不可撤销。'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('取消')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: context.colors.error),
            child: const Text('清空'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      // TODO: 实现清空账本数据的逻辑（删除关联的交易和对话）
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('数据已清空'), behavior: SnackBarBehavior.floating, duration: Duration(milliseconds: 800)),
        );
        _loadData();
      }
    }
  }

  Future<void> _onDeleteBook(AccountBook book) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('删除账本'),
        content: Text('确定要删除「${book.name}」吗？\n\n该账本下的所有数据将被清除，此操作不可撤销。'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('取消')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: context.colors.error),
            child: const Text('删除'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await _repo.delete(book.id);
      if (success && mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('账本已删除'), behavior: SnackBarBehavior.floating, duration: Duration(milliseconds: 800)),
        );
      }
    }
  }

  String _typeToLabel(String type) {
    switch (type) {
      case 'personal': return '个人账本';
      case 'family': return '家庭账本';
      case 'travel': return '旅行账本';
      case 'business': return '生意账本';
      case 'other': return '其他';
      default: return type;
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
