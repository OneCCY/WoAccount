import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';

/// LLM API 配置页
/// 选择服务商、输入 API Key、配置模型
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
  bool _isLoading = true;

  static const _providers = {
    'deepseek': {
      'name': 'DeepSeek',
      'defaultBaseUrl': 'https://api.deepseek.com/v1',
      'defaultModel': 'deepseek-chat',
    },
    'openai': {
      'name': 'OpenAI',
      'defaultBaseUrl': 'https://api.openai.com/v1',
      'defaultModel': 'gpt-4o-mini',
    },
    'custom': {
      'name': '自定义',
      'defaultBaseUrl': '',
      'defaultModel': '',
    },
  };

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _provider = prefs.getString('llmProvider') ?? 'deepseek';
      _apiKeyController.text = prefs.getString('llmApiKey') ?? '';
      _baseUrlController.text = prefs.getString('llmBaseUrl') ?? _providers[_provider]!['defaultBaseUrl']!;
      _modelController.text = prefs.getString('llmModel') ?? _providers[_provider]!['defaultModel']!;
      _isLoading = false;
    });
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('llmProvider', _provider);
    await prefs.setString('llmApiKey', _apiKeyController.text.trim());
    await prefs.setString('llmBaseUrl', _baseUrlController.text.trim());
    await prefs.setString('llmModel', _modelController.text.trim());

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('设置已保存'), behavior: SnackBarBehavior.floating),
      );
      Navigator.of(context).pop();
    }
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
                  Text('Base URL', style: AppTextStyles.footnote),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: _baseUrlController,
                    hintText: 'https://api.example.com/v1',
                  ),

                  const SizedBox(height: 24),

                  // 模型
                  Text('模型名称', style: AppTextStyles.footnote),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: _modelController,
                    hintText: 'deepseek-chat',
                  ),

                  const SizedBox(height: 32),

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
                ],
              ),
            ),
    );
  }

  Widget _buildProviderSelector() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: _providers.entries.map((entry) {
          final isSelected = _provider == entry.key;
          return InkWell(
            onTap: () {
              setState(() {
                _provider = entry.key;
                if (entry.key != 'custom') {
                  _baseUrlController.text = entry.value['defaultBaseUrl']!;
                  _modelController.text = entry.value['defaultModel']!;
                }
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: AppColors.separatorOpaque, width: 0.5),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(entry.value['name']!, style: AppTextStyles.body),
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
