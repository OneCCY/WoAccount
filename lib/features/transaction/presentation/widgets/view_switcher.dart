import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// 视图类型枚举
enum ViewType { day, week, month }

/// 日/周/月 视图切换器
class ViewSwitcher extends StatelessWidget {
  final ViewType currentView;
  final ValueChanged<ViewType> onViewChanged;

  const ViewSwitcher({
    super.key,
    required this.currentView,
    required this.onViewChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.colors.background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildTab(context, '日', ViewType.day),
          _buildTab(context, '周', ViewType.week),
          _buildTab(context, '月', ViewType.month),
        ],
      ),
    );
  }

  Widget _buildTab(BuildContext context, String label, ViewType type) {
    final isActive = currentView == type;
    return GestureDetector(
      onTap: () => onViewChanged(type),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? context.colors.success : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: isActive ? context.colors.textOnPrimary : context.colors.textSecondary,
          ),
        ),
      ),
    );
  }
}
