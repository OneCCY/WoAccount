import 'package:flutter/material.dart';
import '../../../../core/theme/app_dimensions.dart';

/// AI 助手入口卡片
/// 绿色渐变背景，显示 AI 助手入口
class AiAssistantEntry extends StatelessWidget {
  final VoidCallback? onTap;

  const AiAssistantEntry({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.md,
        16,
        AppDimensions.md,
        12,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFE8F5E9),
                  Color(0xFFF1F8E9),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Text('🤖', style: TextStyle(fontSize: 40)),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'AI 助手',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF2E7D32),
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '智能记账 · 消费分析 · 问答查询',
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF66BB6A),
                        ),
                      ),
                    ],
                  ),
                ),
                const Text(
                  '›',
                  style: TextStyle(
                    fontSize: 22,
                    color: Color(0xFF66BB6A),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
