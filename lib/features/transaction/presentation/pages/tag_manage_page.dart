import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:wo_account/l10n/app_localizations.dart';
import '../../../../config/database/app_database.dart';
import '../../../../config/di/providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/toast.dart';

/// 预设颜色选项
const _colorOptions = [
  '#F44336', '#E91E63', '#9C27B0', '#673AB7', '#3F51B5',
  '#2196F3', '#00BCD4', '#009688', '#4CAF50', '#8BC34A',
  '#FF9800', '#FF5722', '#795548', '#607D8B', '#9E9E9E',
];

/// 标签管理页
class TagManagePage extends ConsumerStatefulWidget {
  const TagManagePage({super.key});

  @override
  ConsumerState<TagManagePage> createState() => _TagManagePageState();
}

class _TagManagePageState extends ConsumerState<TagManagePage> {
  List<Tag> _tags = [];
  bool _isLoading = true;
  bool _editMode = false;

  @override
  void initState() {
    super.initState();
    _loadTags();
  }

  Future<void> _loadTags() async {
    final tagRepo = ref.read(tagRepositoryProvider);
    final bookId = ref.read(currentBookProvider);
    final tags = await tagRepo.getAll(bookId);
    if (mounted) {
      setState(() {
        _tags = tags;
        _isLoading = false;
      });
    }
  }

  Color _parseColor(String hex) {
    final clean = hex.replaceFirst('#', '');
    return Color(int.parse('FF$clean', radix: 16));
  }

  Future<void> _showAddSheet() async {
    final result = await _TagEditSheet.show(context);
    if (result != null && mounted) {
      final tagRepo = ref.read(tagRepositoryProvider);
      final bookId = ref.read(currentBookProvider);
      await tagRepo.create(TagsCompanion.insert(
        name: result.$1,
        accountBookId: bookId,
        color: Value(result.$2),
      ));
      AppToast.show(context, AppLocalizations.of(context)!.tagCreated);
      await _loadTags();
    }
  }

  Future<void> _showEditSheet(Tag tag) async {
    final result = await _TagEditSheet.show(context, initialName: tag.name, initialColor: tag.color);
    if (result != null && mounted) {
      final tagRepo = ref.read(tagRepositoryProvider);
      await tagRepo.update(TagsCompanion(
        id: Value(tag.id),
        name: Value(result.$1),
        color: Value(result.$2),
        accountBookId: Value(tag.accountBookId),
      ));
      AppToast.show(context, AppLocalizations.of(context)!.tagUpdated);
      await _loadTags();
    }
  }

  Future<void> _deleteTag(Tag tag) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.tagDelete),
        content: Text(l10n.tagDeleteConfirm(tag.name)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l10n.commonCancel)),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.commonDelete, style: TextStyle(color: context.colors.expense)),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      final tagRepo = ref.read(tagRepositoryProvider);
      await tagRepo.delete(tag.id);
      AppToast.show(context, l10n.tagDeleted);
      await _loadTags();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        title: Text(l10n.tagManage),
        backgroundColor: context.colors.surface,
        actions: [
          if (_tags.isNotEmpty)
            IconButton(
              icon: Icon(_editMode ? Icons.check : Icons.edit_outlined),
              onPressed: () => setState(() => _editMode = !_editMode),
            ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddSheet,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: context.colors.primary))
          : _tags.isEmpty
              ? _buildEmptyState(l10n)
              : _buildTagGrid(l10n),
    );
  }

  Widget _buildEmptyState(AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.label_outline, size: 48, color: context.colors.textTertiary),
          const SizedBox(height: 16),
          Text(
            l10n.tagManageEmpty,
            style: context.textStyles.callout.copyWith(color: context.colors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTagGrid(AppLocalizations l10n) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.md),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: _tags.map((tag) => _buildTagChip(tag)).toList(),
      ),
    );
  }

  Widget _buildTagChip(Tag tag) {
    final color = _parseColor(tag.color);
    return GestureDetector(
      onTap: _editMode ? null : () => _showEditSheet(tag),
      onLongPress: _editMode ? null : () => _showEditSheet(tag),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(AppDimensions.radiusRound),
          border: Border.all(color: color.withValues(alpha: 0.4), width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
            Text(
              tag.name,
              style: context.textStyles.body.copyWith(
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (_editMode) ...[
              const SizedBox(width: 4),
              GestureDetector(
                onTap: () => _deleteTag(tag),
                child: Icon(Icons.close, size: 16, color: color.withValues(alpha: 0.6)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// 标签新建/编辑底部弹窗
class _TagEditSheet extends StatefulWidget {
  final String? initialName;
  final String? initialColor;

  const _TagEditSheet({this.initialName, this.initialColor});

  /// 显示弹窗，返回 (name, color) 或 null
  static Future<(String, String)?> show(
    BuildContext context, {
    String? initialName,
    String? initialColor,
  }) {
    return showModalBottomSheet<(String, String)>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _TagEditSheet(initialName: initialName, initialColor: initialColor),
    );
  }

  @override
  State<_TagEditSheet> createState() => _TagEditSheetState();
}

class _TagEditSheetState extends State<_TagEditSheet> {
  late final TextEditingController _nameController;
  late String _selectedColor;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName ?? '');
    _selectedColor = widget.initialColor ?? _colorOptions[DateTime.now().millisecond % _colorOptions.length];
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final isEdit = widget.initialName != null;

    return Container(
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      padding: EdgeInsets.fromLTRB(
        AppDimensions.md,
        8,
        AppDimensions.md,
        bottomInset + AppDimensions.md,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 拖拽条
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: context.colors.textTertiary.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          // 标题
          Text(
            isEdit ? l10n.tagEdit : l10n.tagAdd,
            style: AppTextStyles.h3.copyWith(fontSize: 16),
          ),
          const SizedBox(height: 20),
          // 名称输入
          TextField(
            controller: _nameController,
            autofocus: true,
            maxLength: 20,
            decoration: InputDecoration(
              hintText: l10n.tagAdd,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
          ),
          const SizedBox(height: 16),
          // 颜色选择标签
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              l10n.txnDetailTags,
              style: context.textStyles.footnote.copyWith(color: context.colors.textTertiary),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _colorOptions.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final color = Color(int.parse('FF${_colorOptions[index].replaceFirst('#', '')}', radix: 16));
                final isSelected = _selectedColor == _colorOptions[index];
                return GestureDetector(
                  onTap: () => setState(() => _selectedColor = _colorOptions[index]),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: isSelected
                          ? Border.all(color: color, width: 2.5)
                          : null,
                    ),
                    child: Center(
                      child: Container(
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          // 确认按钮
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                final name = _nameController.text.trim();
                if (name.isEmpty) return;
                Navigator.pop(context, (name, _selectedColor));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: context.colors.primary,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                ),
              ),
              child: Text(
                l10n.commonSave,
                style: AppTextStyles.body.copyWith(
                  color: context.colors.textOnPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
