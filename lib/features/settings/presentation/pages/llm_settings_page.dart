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
                  if (p.baseUrl.isNotEmpty) _infoRow('地址', p.baseUrl),
                  if (p.model.isNotEmpty) _infoRow('模型', p.model),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _actionButton(icon: Icons.wifi_tethering, label: '测试', onTap: () => _testProvider(p)),
                      const SizedBox(width: 8),
                      _actionButton(icon: Icons.edit_outlined, label: '编辑', onTap: () => _editProvider(p)),
                      const SizedBox(width: 8),
                      _actionButton(icon: Icons.delete_outline, label: '删除', color: AppColors.error, onTap: () => _delete(p)),
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
          SizedBox(width: 40, child: Text(label, style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary))),
          Expanded(child: Text(value, style: AppTextStyles.footnote, overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }

  Widget _actionButton({required IconData icon, required String label, required VoidCallback onTap, Color? color}) {
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

    showDialog(context: context, barrierDismissible: false, builder: (_) => const Center(child: CircularProgressIndicator()));

    final repo = LlmRepositoryImpl(Dio());
    final success = await repo.testConnection(provider);

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? '✅ 连接成功' : '❌ 连接失败，请检查地址、Key 和模型名称'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: success ? AppColors.success : AppColors.error,
        ),
      );
    }
  }
}

// ============================================================
// 服务商编辑页
// ============================================================

/// 各大模型服务商配置参考
const _providerExamples = [
  _ProviderExample(
    name: 'DeepSeek',
    baseUrl: 'https://api.deepseek.com',
    model: 'deepseek-v3',
    note: '不要加 /v1 后缀，官方已自动处理',
  ),
  _ProviderExample(
    name: '通义千问 (阿里)',
    baseUrl: 'https://dashscope.aliyuncs.com/compatible-mode/v1',
    model: 'qwen-plus',
    note: '使用兼容模式地址，模型可选 qwen-turbo / qwen-plus / qwen-max',
  ),
  _ProviderExample(
    name: 'OpenAI',
    baseUrl: 'https://api.openai.com/v1',
    model: 'gpt-4o-mini',
    note: '需要海外网络访问',
  ),
  _ProviderExample(
    name: '豆包 (字节)',
    baseUrl: 'https://ark.cn-beijing.volces.com/api/v3',
    model: 'doubao-pro-32k',
    note: '需要在火山方舟创建推理接入点，模型名使用接入点 ID',
  ),
  _ProviderExample(
    name: '智谱AI',
    baseUrl: 'https://open.bigmodel.cn/api/paas/v4',
    model: 'glm-4-flash',
    note: 'glm-4-flash 免费额度',
  ),
  _ProviderExample(
    name: '月之暗面 (Kimi)',
    baseUrl: 'https://api.moonshot.cn/v1',
    model: 'moonshot-v1-8k',
    note: '',
  ),
  _ProviderExample(
    name: 'Ollama (本地)',
    baseUrl: 'http://localhost:11434/v1',
    model: 'qwen2.5:7b',
    note: '需要本地运行 Ollama 服务',
  ),
];

class _ProviderExample {
  final String name;
  final String baseUrl;
  final String model;
  final String note;
  const _ProviderExample({required this.name, required this.baseUrl, required this.model, required this.note});
}

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
  bool _showAdvanced = false;

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
      _showAdvanced = true;
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

  /// 从配置参考快速填充
  void _applyExample(_ProviderExample ex) {
    setState(() {
      _nameCtrl.text = ex.name;
      _baseUrlCtrl.text = ex.baseUrl;
      _modelCtrl.text = ex.model;
    });
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
            // 配置参考卡片
            _buildReferenceSection(),
            const SizedBox(height: 24),

            // 基本配置
            Text('基本配置', style: AppTextStyles.footnote.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),

            _label('服务商名称'),
            _field(_nameCtrl, '如：DeepSeek、通义千问'),
            const SizedBox(height: 16),

            _label('API Key'),
            _field(_apiKeyCtrl, '输入 API Key', obscure: true),
            const SizedBox(height: 16),

            _label('请求地址'),
            _field(_baseUrlCtrl, '如：https://api.deepseek.com'),
            const SizedBox(height: 4),
            _hint('填入 API 的 base_url，不需要手动拼接 /chat/completions'),
            const SizedBox(height: 16),

            _label('模型名称'),
            _field(_modelCtrl, '如：deepseek-v3、qwen-plus'),
            const SizedBox(height: 4),
            _hint('填写服务商提供的模型 ID'),
            const SizedBox(height: 24),

            // 高级设置（折叠）
            _buildAdvancedSection(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  /// 配置参考区域
  Widget _buildReferenceSection() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          title: Row(
            children: [
              Icon(Icons.menu_book, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Text('配置参考', style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600)),
            ],
          ),
          children: _providerExamples.map((ex) => _buildExampleCard(ex)).toList(),
        ),
      ),
    );
  }

  Widget _buildExampleCard(_ProviderExample ex) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
        border: Border.all(color: AppColors.separator),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(ex.name, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600))),
              InkWell(
                onTap: () => _applyExample(ex),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.primarySurface,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text('使用', style: AppTextStyles.caption.copyWith(color: AppColors.primary)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          _exampleRow('地址', ex.baseUrl),
          _exampleRow('模型', ex.model),
          if (ex.note.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(ex.note, style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary)),
          ],
        ],
      ),
    );
  }

  Widget _exampleRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 36,
            child: Text(label, style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary)),
          ),
          Expanded(
            child: Text(value, style: AppTextStyles.caption.copyWith(fontFamily: 'monospace')),
          ),
        ],
      ),
    );
  }

  /// 高级设置区域
  Widget _buildAdvancedSection() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          initiallyExpanded: _showAdvanced,
          title: Text('高级设置', style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600)),
          children: [
            // 温度
            Row(
              children: [
                Text('温度参数', style: AppTextStyles.body),
                const Spacer(),
                Text(_temperature.toStringAsFixed(1), style: AppTextStyles.body.copyWith(color: AppColors.textSecondary)),
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
            const SizedBox(height: 8),

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
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
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
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(text, style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary)),
    );
  }
}
