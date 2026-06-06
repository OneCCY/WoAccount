import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../ai/data/models/llm_config.dart';
import '../../../ai/data/repositories/llm_repository_impl.dart';

/// LLM 服务配置页
/// 用户自行添加/管理 AI 服务商，无预设
class LlmSettingsPage extends StatefulWidget {
  const LlmSettingsPage({super.key});

  @override
  State<LlmSettingsPage> createState() => _LlmSettingsPageState();
}

class _LlmSettingsPageState extends State<LlmSettingsPage> {
  List<LlmProvider> _providers = [];
  String? _activeId;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final providers = await LlmConfigManager.loadProviders();
    final activeId = await LlmConfigManager.getActiveProviderId();
    if (mounted) {
      setState(() {
        _providers = providers;
        _activeId = activeId;
        _isLoading = false;
      });
    }
  }

  Future<void> _setActive(String id) async {
    await LlmConfigManager.setActiveProviderId(id);
    setState(() => _activeId = id);
  }

  Future<void> _delete(LlmProvider provider) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('删除服务商'),
        content: Text('确定删除「${provider.name}」？'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('取消')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('删除', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await LlmConfigManager.deleteProvider(provider.id);
      await _load();
    }
  }

  void _addProvider() async {
    final result = await Navigator.push<LlmProvider>(
      context,
      MaterialPageRoute(builder: (_) => const _ProviderEditPage()),
    );
    if (result != null) {
      await LlmConfigManager.addProvider(result);
      await _load();
    }
  }

  void _editProvider(LlmProvider provider) async {
    final result = await Navigator.push<LlmProvider>(
      context,
      MaterialPageRoute(builder: (_) => _ProviderEditPage(provider: provider)),
    );
    if (result != null) {
      await LlmConfigManager.updateProvider(result);
      await _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('AI 服务配置'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addProvider,
            tooltip: '添加服务商',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _providers.isEmpty
              ? _buildEmptyState()
              : _buildProviderList(),
    );
  }

  /// 空状态：提示用户添加服务商
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off_outlined, size: 64, color: AppColors.textTertiary),
            const SizedBox(height: 16),
            Text('尚未配置 AI 服务', style: AppTextStyles.h3),
            const SizedBox(height: 8),
            Text(
              '添加一个 AI 服务商即可使用智能记账功能\n支持所有 OpenAI 兼容的 API 接口',
              style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _addProvider,
              icon: const Icon(Icons.add),
              label: const Text('添加服务商'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.textOnPrimary,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 服务商列表
  Widget _buildProviderList() {
    return ListView.builder(
      padding: const EdgeInsets.all(AppDimensions.md),
      itemCount: _providers.length,
      itemBuilder: (context, index) {
        final p = _providers[index];
        final isActive = p.id == _activeId;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            border: isActive ? Border.all(color: AppColors.primary, width: 2) : null,
          ),
          child: InkWell(
            onTap: () => _setActive(p.id),
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 名称 + 状态
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          p.name.isEmpty ? '未命名服务商' : p.name,
                          style: AppTextStyles.h3.copyWith(fontSize: 16),
                        ),
                      ),
                      if (isActive)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primarySurface,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text('使用中', style: AppTextStyles.caption.copyWith(color: AppColors.primary)),
                        ),
                      if (!p.isComplete)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.warning.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text('未完成', style: AppTextStyles.caption.copyWith(color: AppColors.warning)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // 信息行
                  if (p.baseUrl.isNotEmpty)
                    _infoRow('地址', p.baseUrl),
                  if (p.model.isNotEmpty)
                    _infoRow('模型', p.model),

                  const SizedBox(height: 12),

                  // 操作按钮
                  Row(
                    children: [
                      _actionButton(
                        icon: Icons.wifi_tethering,
                        label: '测试',
                        onTap: () => _testProvider(p),
                      ),
                      const SizedBox(width: 8),
                      _actionButton(
                        icon: Icons.edit_outlined,
                        label: '编辑',
                        onTap: () => _editProvider(p),
                      ),
                      const SizedBox(width: 8),
                      _actionButton(
                        icon: Icons.delete_outline,
                        label: '删除',
                        color: AppColors.error,
                        onTap: () => _delete(p),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: Text(label, style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary)),
          ),
          Expanded(
            child: Text(value, style: AppTextStyles.footnote, overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }

  Widget _actionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? color,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color ?? AppColors.textSecondary),
            const SizedBox(width: 4),
            Text(label, style: AppTextStyles.caption.copyWith(color: color ?? AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }

  Future<void> _testProvider(LlmProvider provider) async {
    if (!provider.isComplete) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请先完善配置'), behavior: SnackBarBehavior.floating),
      );
      return;
    }

    // 显示测试中
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    final repo = LlmRepositoryImpl(Dio());
    final success = await repo.testConnection(provider);

    if (mounted) {
      Navigator.pop(context); // 关闭 loading
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? '✅ 连接成功' : '❌ 连接失败，请检查配置'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: success ? AppColors.success : AppColors.error,
        ),
      );
    }
  }
}

/// 服务商编辑页（添加/编辑）
class _ProviderEditPage extends StatefulWidget {
  final LlmProvider? provider;
  const _ProviderEditPage({this.provider});

  @override
  State<_ProviderEditPage> createState() => _ProviderEditPageState();
}

class _ProviderEditPageState extends State<_ProviderEditPage> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _apiKeyCtrl;
  late final TextEditingController _baseUrlCtrl;
  late final TextEditingController _modelCtrl;
  double _temperature = 0.0;
  int _maxTokens = 1000;
  int _timeout = 30;

  bool get _isEditing => widget.provider != null;

  @override
  void initState() {
    super.initState();
    final p = widget.provider;
    _nameCtrl = TextEditingController(text: p?.name ?? '');
    _apiKeyCtrl = TextEditingController(text: p?.apiKey ?? '');
    _baseUrlCtrl = TextEditingController(text: p?.baseUrl ?? '');
    _modelCtrl = TextEditingController(text: p?.model ?? '');
    if (p != null) {
      _temperature = p.temperature;
      _maxTokens = p.maxTokens;
      _timeout = p.timeoutSeconds;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _apiKeyCtrl.dispose();
    _baseUrlCtrl.dispose();
    _modelCtrl.dispose();
    super.dispose();
  }

  void _save() {
    final name = _nameCtrl.text.trim();
    final apiKey = _apiKeyCtrl.text.trim();
    final baseUrl = _baseUrlCtrl.text.trim();
    final model = _modelCtrl.text.trim();

    if (name.isEmpty || apiKey.isEmpty || baseUrl.isEmpty || model.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请填写所有必填项'), behavior: SnackBarBehavior.floating),
      );
      return;
    }

    // 确保 baseUrl 不以 / 结尾
    final cleanUrl = baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl;

    final provider = LlmProvider(
      id: widget.provider?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      apiKey: apiKey,
      baseUrl: cleanUrl,
      model: model,
      temperature: _temperature,
      maxTokens: _maxTokens,
      timeoutSeconds: _timeout,
    );

    Navigator.pop(context, provider);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(_isEditing ? '编辑服务商' : '添加服务商'),
        actions: [
          TextButton(
            onPressed: _save,
            child: Text('保存', style: AppTextStyles.body.copyWith(color: AppColors.primary)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _label('服务商名称'),
            _field(_nameCtrl, '如：DeepSeek、通义千问、本地 Ollama'),
            const SizedBox(height: 20),

            _label('API Key'),
            _field(_apiKeyCtrl, '输入 API Key', obscure: true),
            const SizedBox(height: 20),

            _label('请求地址'),
            _field(_baseUrlCtrl, '如：https://api.deepseek.com/v1'),
            const SizedBox(height: 8),
            _hint('所有 OpenAI 兼容接口均可使用（OpenAI、DeepSeek、通义千问、Ollama 等）'),
            const SizedBox(height: 20),

            _label('模型名称'),
            _field(_modelCtrl, '如：deepseek-chat、qwen-turbo'),
            const SizedBox(height: 20),

            // 高级设置
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('高级设置', style: AppTextStyles.footnote.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 16),

                  // 温度
                  Row(
                    children: [
                      Text('温度参数', style: AppTextStyles.body),
                      const Spacer(),
                      Text(_temperature.toStringAsFixed(1),
                          style: AppTextStyles.body.copyWith(color: AppColors.textSecondary)),
                    ],
                  ),
                  Slider(
                    value: _temperature,
                    min: 0.0,
                    max: 1.0,
                    divisions: 10,
                    activeColor: AppColors.primary,
                    onChanged: (v) => setState(() => _temperature = v),
                  ),

                  // 最大 Token
                  Row(
                    children: [
                      Text('最大 Token', style: AppTextStyles.body),
                      const Spacer(),
                      SizedBox(
                        width: 80,
                        child: TextField(
                          controller: TextEditingController(text: _maxTokens.toString()),
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.right,
                          style: AppTextStyles.body,
                          decoration: const InputDecoration(border: InputBorder.none, isDense: true),
                          onChanged: (v) => _maxTokens = int.tryParse(v) ?? 1000,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 16),

                  // 超时
                  Row(
                    children: [
                      Text('超时（秒）', style: AppTextStyles.body),
                      const Spacer(),
                      SizedBox(
                        width: 60,
                        child: TextField(
                          controller: TextEditingController(text: _timeout.toString()),
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.right,
                          style: AppTextStyles.body,
                          decoration: const InputDecoration(border: InputBorder.none, isDense: true),
                          onChanged: (v) => _timeout = int.tryParse(v) ?? 30,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text, style: AppTextStyles.footnote),
    );
  }

  Widget _field(TextEditingController controller, String hint, {bool obscure = false}) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        style: AppTextStyles.body,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: AppTextStyles.body.copyWith(color: AppColors.textHint),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  Widget _hint(String text) {
    return Text(text, style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary));
  }
}
