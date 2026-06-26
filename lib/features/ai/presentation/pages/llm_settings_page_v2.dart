import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wo_account/l10n/app_localizations.dart';

import 'agent_list_page.dart';
import 'supplier_management_page.dart';
import 'usage_analysis_page.dart';

/// AI 设置主入口页（v2.0）
///
/// 三个卡片入口：供应商管理、功能配置、用量情况
class LlmSettingsPageV2 extends ConsumerStatefulWidget {
  const LlmSettingsPageV2({super.key});

  @override
  ConsumerState<LlmSettingsPageV2> createState() => _LlmSettingsPageV2State();
}

class _LlmSettingsPageV2State extends ConsumerState<LlmSettingsPageV2> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.aiSettingsTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildEntryCard(
            icon: Icons.dns_outlined,
            title: l10n.aiSettingsSuppliers,
            color: Colors.blue,
            onTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const SupplierManagementPageV2()),
            ),
          ),
          const SizedBox(height: 12),
          _buildEntryCard(
            icon: Icons.smart_toy_outlined,
            title: l10n.aiSettingsAgents,
            color: Colors.green,
            onTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const AgentListPage()),
            ),
          ),
          const SizedBox(height: 12),
          _buildEntryCard(
            icon: Icons.bar_chart_outlined,
            title: l10n.aiSettingsUsage,
            color: Colors.orange,
            onTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const UsageAnalysisPage()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEntryCard({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
              ),
              Icon(Icons.chevron_right, color: Theme.of(context).colorScheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}
