import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../ai/data/models/llm_config.dart';

/// LLM API 配置页
/// 选择服务商、输入 API Key、配置模型、高级参数、测试连接
class LlmSettingsPage extends StatefulWidget {
  const LlmSettingsPage({super.key});

  @override
  State<LlmSettingsPage> createState() => _LlmSettingsPageState();
}

class _LlmSettingsPageState extends State<LlmSettingsPage> {
  String _provider = 'deepseek';
  final _apiKeyController = TextEditingController();
  final _baseUrlController = TextEditingController();
  final _modelController = TextEditingController();
  double _temperature = 0.0;
  int _maxTokens = 1000;
  int _timeout = 30;
  bool _isLoading = true;
  bool _isTesting = false;
  bool? _testResult; // null=未测试, true=成功, false=失败
  String? _testError;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _provider = prefs.getString('llm_provider') ?? 'deepseek';
      _apiKeyController.text = prefs.getString('llm_api_key') ?? '';
      _baseUrlController.text = prefs.getString('llm_base_url') ??
          (LlmProviders.getById(_provider)?.defaultBaseUrl ?? '');
      _modelController.text = prefs.getString('llm_model') ??
          (LlmProviders.getById(_provider)?.defaultModel ?? '');
      _temperature = double.tryParse(prefs.getString('llm_temperature') ?? '0') ?? 0.0;
      _maxTokens = int.tryParse(prefs.getString('llm_max_tokens') ?? '1000') ?? 1000;
      _timeout = int.tryParse(prefs.getString('llm_timeout') ?? '30') ?? 30;
      _isLoading = false;
    });
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('llm_provider', _provider);
    await prefs.setString('llm_api_key', _apiKeyController.text.trim());
    await prefs.setString('llm_base_url', _baseUrlController.text.trim());
    await prefs.setString('llm_model', _modelController.text.trim());
    await prefs.setString('llm_temperature', _temperature.toString());
    await prefs.setString('llm_max_tokens', _maxTokens.toString());
    await prefs.setString('llm_timeout', _timeout.toString());

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('设置已保存'), behavior: SnackBarBehavior.floating),
      );
      Navigator.of(context).pop();
    }
  }

  Future<void> _testConnection() async {
    setState(() {
      _isTesting = true;
      _testResult = null;
      _testError = null;
    });

    try {
      // 先保存当前配置
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('llm_provider', _provider);
      await prefs.setString('llm_api_key', _apiKeyController.text.trim());
      await prefs.setString('llm_base_url', _baseUrlController.text.trim());
      await prefs.setString('llm_model', _modelController.text.trim());
      await prefs.setString('llm_temperature', _temperature.toString());
      await prefs.setString('llm_max_tokens', _maxTokens.toString());
      await prefs.setString('llm_timeout', _timeout.toString());

      // 通过 Dio 直接测试
      final dio = _createTestDio();
      final response = await dio.post(
        '${_baseUrlController.text.trim()}/chat/completions',
        options: Options(
          headers: {
            'Authorization': 'Bearer ${_apiKeyController.text.trim()}',
            'Content-Type': 'application/json',
          },
          sendTimeout: Duration(seconds: _timeout),
          receiveTimeout: Duration(seconds: _timeout),
        ),
        data: {
          'model': _modelController.text.trim(),
          'messages': [
            {'role': 'user', 'content': 'Hello'}
          ],
          'max_tokens': 10,
        },
      );

      if (mounted) {
        setState(() {
          _testResult = response.statusCode == 200;
          _isTesting = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _testResult = false;
          _testError = _parseError(e);
          _isTesting = false;
        });
      }
    }
  }

  Dio _createTestDio() => Dio();

  String _parseError(dynamic e) {
    if (e.toString().contains('401')) return 'API Key 无效';
    if (e.toString().contains('403')) return '访问被拒绝';
    if (e.toString().contains('404')) return '请求地址不正确';
    if (e.toString().contains('timeout') || e.toString().contains('Timeout')) {
      return '请求超时';
    }
    if (e.toString().contains('connection') || e.toString().contains('Socket')) {
      return '网络连接失败';
    }
    return '连接失败: ${e.toString().length > 100 ? e.toString().substring(0, 100) : e.toString()}';
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    _baseUrlController.dispose();
    _modelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('AI 服务配置'),
        actions: [
          TextButton(
            onPressed: _save,
            child: Text('保存', style: AppTextStyles.body.copyWith(color: AppColors.primary)),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppDimensions.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 服务商选择
                  Text('服务商', style: AppTextStyles.footnote),
                  const SizedBox(height: 8),
                  _buildProviderSelector(),

                  const SizedBox(height: 24),

                  // API Key
                  Text('API Key', style: AppTextStyles.footnote),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: _apiKeyController,
                    hintText: '输入 API Key',
                    obscureText: true,
                  ),

                  const SizedBox(height: 24),

                  // Base URL
                  Text('请求地址', style: AppTextStyles.footnote),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: _baseUrlController,
                    hintText: 'https://api.example.com/v1',
                  ),

                  const SizedBox(height: 24),

                  // 模型
                  Text('模型名称', style: AppTextStyles.footnote),
                  const SizedBox(height: 8),
                  _buildModelSelector(),

                  const SizedBox(height: 24),

                  // 高级设置
                  _buildAdvancedSection(),

                  const SizedBox(height: 24),

                  // 测试连接
                  _buildTestSection(),

                  const SizedBox(height: 16),

                  // 提示
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primarySurface,
                      borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline, size: 16, color: AppColors.primaryDark),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'API Key 仅存储在本地，不会上传到任何服务器',
                            style: AppTextStyles.caption.copyWith(color: AppColors.primaryDark),
                          ),
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

  /// 提供商选择器
  Widget _buildProviderSelector() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: LlmProviders.all.map((provider) {
          final isSelected = _provider == provider.id;
          return InkWell(
            onTap: () {
              setState(() {
                _provider = provider.id;
                if (provider.id != 'custom') {
                  _baseUrlController.text = provider.defaultBaseUrl;
                  _modelController.text = provider.defaultModel;
                }
                _testResult = null;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: AppColors.separatorOpaque, width: 0.5),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(provider.name, style: AppTextStyles.body),
                        if (provider.id != 'custom')
                          Text(
                            provider.defaultBaseUrl,
                            style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary),
                          ),
                      ],
                    ),
                  ),
                  if (isSelected)
                    const Icon(Icons.check, size: 20, color: AppColors.primary),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  /// 模型选择器（支持下拉选择或手动输入）
  Widget _buildModelSelector() {
    final provider = LlmProviders.getById(_provider);
    final models = provider?.availableModels ?? [];

    if (models.isEmpty) {
      // 自定义提供商：手动输入
      return _buildTextField(
        controller: _modelController,
        hintText: '输入模型名称',
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: models.contains(_modelController.text) ? _modelController.text : null,
          isExpanded: true,
          hint: Text('选择模型', style: AppTextStyles.body.copyWith(color: AppColors.textHint)),
          items: models.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
          onChanged: (v) {
            if (v != null) setState(() => _modelController.text = v);
          },
        ),
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
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('高级设置', style: AppTextStyles.footnote.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),

          // 温度参数
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
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  onChanged: (v) => _maxTokens = int.tryParse(v) ?? 1000,
                ),
              ),
            ],
          ),

          const Divider(height: 16),

          // 超时时间
          Row(
            children: [
              Text('超时时间（秒）', style: AppTextStyles.body),
              const Spacer(),
              SizedBox(
                width: 60,
                child: TextField(
                  controller: TextEditingController(text: _timeout.toString()),
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.right,
                  style: AppTextStyles.body,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  onChanged: (v) => _timeout = int.tryParse(v) ?? 30,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 测试连接区域
  Widget _buildTestSection() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _isTesting ? null : _testConnection,
            icon: _isTesting
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(
                    _testResult == true
                        ? Icons.check_circle
                        : _testResult == false
                            ? Icons.error
                            : Icons.wifi_tethering,
                    size: 18,
                    color: _testResult == true
                        ? AppColors.success
                        : _testResult == false
                            ? AppColors.error
                            : AppColors.primary,
                  ),
            label: Text(
              _isTesting
                  ? '测试中...'
                  : _testResult == true
                      ? '连接成功'
                      : _testResult == false
                          ? '连接失败'
                          : '测试连接',
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              side: BorderSide(
                color: _testResult == true
                    ? AppColors.success
                    : _testResult == false
                        ? AppColors.error
                        : AppColors.primary,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              ),
            ),
          ),
        ),
        if (_testError != null) ...[
          const SizedBox(height: 8),
          Text(
            _testError!,
            style: AppTextStyles.caption.copyWith(color: AppColors.error),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    bool obscureText = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        style: AppTextStyles.body,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: AppTextStyles.body.copyWith(color: AppColors.textHint),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }
}
