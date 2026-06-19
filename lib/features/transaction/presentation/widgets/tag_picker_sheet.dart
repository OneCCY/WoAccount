import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:wo_account/l10n/app_localizations.dart';
import '../../../../config/database/app_database.dart';
import '../../../../config/di/providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';

/// 标签选择器底部弹窗
/// 支持多选，返回选中的标签 ID 列表
class TagPickerSheet extends ConsumerStatefulWidget {
  final List<int> selectedTagIds;

  const TagPickerSheet({super.key, required this.selectedTagIds});

  /// 显示标签选择器，返回选中的标签 ID 列表，null 表示取消
  static Future<List<int>?> show(BuildContext context, {List<int> selectedTagIds = const []}) {
    return showModalBottomSheet<List<int>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => TagPickerSheet(selectedTagIds: selectedTagIds),
    );
  }

  @override
  ConsumerState<TagPickerSheet> createState() => _TagPickerSheetState();
}

class _TagPickerSheetState extends ConsumerState<TagPickerSheet> {
  List<Tag> _tags = [];
  late Set<int> _selected;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _selected = Set.from(widget.selectedTagIds);
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

  Future<void> _createTag() async {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController();
    String selectedColor = '#4CAF50';

    final result = await showDialog<(String, String)>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(l10n.tagPickerCreate),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                autofocus: true,
                maxLength: 20,
                decoration: InputDecoration(
                  hintText: l10n.tagPickerCreate,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // 颜色选择
              SizedBox(
                height: 36,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _quickColors.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 6),
                  itemBuilder: (_, index) {
                    final colorHex = _quickColors[index];
                    final color = Color(int.parse('FF${colorHex.replaceFirst('#', '')}', radix: 16));
                    final isSelected = selectedColor == colorHex;
                    return GestureDetector(
                      onTap: () => setDialogState(() => selectedColor = colorHex),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                          border: isSelected ? Border.all(color: color, width: 2) : null,
                        ),
                        child: Center(
                          child: Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(l10n.commonCancel),
            ),
            TextButton(
              onPressed: () {
                final name = controller.text.trim();
                if (name.isNotEmpty) Navigator.pop(ctx, (name, selectedColor));
              },
              child: Text(l10n.commonConfirm),
            ),
          ],
        ),
      ),
    );

    if (result != null && mounted) {
      final tagRepo = ref.read(tagRepositoryProvider);
      final bookId = ref.read(currentBookProvider);
      final newId = await tagRepo.create(TagsCompanion.insert(
        name: result.$1,
        accountBookId: bookId,
        color: Value(result.$2),
      ));
      setState(() => _selected.add(newId));
      await _loadTags();
    }
  }

  static const _quickColors = [
    '#F44336', '#E91E63', '#9C27B0', '#3F51B5', '#2196F3',
    '#00BCD4', '#4CAF50', '#8BC34A', '#FF9800', '#795548',
    '#607D8B',
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      height: screenHeight * 0.55,
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.fromLTRB(16, 0, 16, 16 + bottomInset),
      child: Column(
        children: [
          // 拖拽条
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 12, bottom: 12),
            decoration: BoxDecoration(
              color: context.colors.textTertiary.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // 标题 + 完成按钮
          Row(
            children: [
              Text(l10n.tagPickerTitle, style: context.textStyles.h3),
              const Spacer(),
              TextButton(
                onPressed: () => Navigator.pop(context, _selected.toList()),
                child: Text(
                  l10n.commonSave,
                  style: context.textStyles.body.copyWith(
                    color: context.colors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // 标签网格
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator(color: context.colors.primary))
                : SingleChildScrollView(
                    child: Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        ..._tags.map((tag) => _buildTagOption(tag)),
                        // 新建标签按钮
                        _buildCreateButton(),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTagOption(Tag tag) {
    final color = _parseColor(tag.color);
    final isSelected = _selected.contains(tag.id);

    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            _selected.remove(tag.id);
          } else {
            _selected.add(tag.id);
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.2) : color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(AppDimensions.radiusRound),
          border: Border.all(
            color: isSelected ? color : color.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
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
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
            if (isSelected) ...[
              const SizedBox(width: 4),
              Icon(Icons.check, size: 16, color: color),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCreateButton() {
    return GestureDetector(
      onTap: _createTag,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: context.colors.surfaceSecondary,
          borderRadius: BorderRadius.circular(AppDimensions.radiusRound),
          border: Border.all(color: context.colors.separator, width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add, size: 16, color: context.colors.textSecondary),
            const SizedBox(width: 4),
            Text(
              AppLocalizations.of(context)!.tagPickerCreate,
              style: context.textStyles.body.copyWith(color: context.colors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
