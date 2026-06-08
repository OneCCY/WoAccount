import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../../../../config/database/app_database.dart';
import '../../../../config/di/providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';

/// 个人资料编辑页
class ProfileEditPage extends ConsumerStatefulWidget {
  const ProfileEditPage({super.key});

  @override
  ConsumerState<ProfileEditPage> createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends ConsumerState<ProfileEditPage> {
  UserProfile? _profile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final db = ref.read(appDatabaseProvider);
    final profiles = await db.select(db.userProfiles).get();
    if (mounted) {
      setState(() {
        _profile = profiles.isNotEmpty ? profiles.first : null;
        _isLoading = false;
      });
    }
  }

  Future<void> _updateProfile(UserProfilesCompanion companion) async {
    final db = ref.read(appDatabaseProvider);
    await (db.update(db.userProfiles)..where((t) => t.id.equals(_profile!.id)))
        .write(companion);
    await _loadProfile();
  }

  Future<void> _pickAvatar() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, maxWidth: 512, maxHeight: 512);
    if (picked == null) return;

    // 复制到应用目录
    final appDir = await getApplicationDocumentsDirectory();
    final fileName = 'avatar_${DateTime.now().millisecondsSinceEpoch}${p.extension(picked.path)}';
    final savedPath = p.join(appDir.path, 'avatars', fileName);
    await Directory(p.dirname(savedPath)).create(recursive: true);
    await File(picked.path).copy(savedPath);

    await _updateProfile(UserProfilesCompanion(avatarPath: Value(savedPath)));
  }

  void _editField(String title, String? currentValue, ValueChanged<String> onSave, {TextInputType? keyboardType, int maxLines = 1}) {
    final controller = TextEditingController(text: currentValue ?? '');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: keyboardType,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: '请输入$title',
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
          TextButton(
            onPressed: () {
              onSave(controller.text.trim());
              Navigator.pop(ctx);
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }

  void _pickGender() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(title: const Text('男'), onTap: () { _updateProfile(const UserProfilesCompanion(gender: Value('男'))); Navigator.pop(ctx); }),
            ListTile(title: const Text('女'), onTap: () { _updateProfile(const UserProfilesCompanion(gender: Value('女'))); Navigator.pop(ctx); }),
            ListTile(title: const Text('保密'), onTap: () { _updateProfile(const UserProfilesCompanion(gender: Value('保密'))); Navigator.pop(ctx); }),
          ],
        ),
      ),
    );
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('退出登录'),
        content: const Text('确定要退出登录吗？'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('取消')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text('退出', style: TextStyle(color: context.colors.expense))),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      // TODO: 实际退出逻辑（清除 token、跳转登录页）
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('退出登录功能即将完善'), behavior: SnackBarBehavior.floating),
      );
    }
  }

  Future<void> _deleteAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('申请注销账号'),
        content: const Text('注销账号后数据将无法恢复，确定要申请注销吗？'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('取消')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text('申请注销', style: TextStyle(color: context.colors.expense))),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('注销申请已提交'), behavior: SnackBarBehavior.floating),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('个人资料')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final profile = _profile;
    if (profile == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('个人资料')),
        body: const Center(child: Text('未找到用户资料')),
      );
    }

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(title: const Text('个人资料')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 16),
            // 头像
            _buildAvatarSection(profile),
            const SizedBox(height: 16),
            // 信息列表
            _buildInfoCard(profile),
            const SizedBox(height: 16),
            // 危险操作
            _buildDangerCard(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarSection(UserProfile profile) {
    return Center(
      child: GestureDetector(
        onTap: _pickAvatar,
        child: Stack(
          children: [
            CircleAvatar(
              radius: 48,
              backgroundColor: context.colors.primarySurface,
              backgroundImage: profile.avatarPath != null ? FileImage(File(profile.avatarPath!)) : null,
              child: profile.avatarPath == null
                  ? Icon(Icons.person_outline, size: 40, color: context.colors.primaryDark)
                  : null,
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: context.colors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.camera_alt, size: 16, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(UserProfile profile) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppDimensions.md),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          _buildRow('昵称', profile.nickname, () {
            _editField('昵称', profile.nickname, (v) {
              if (v.isNotEmpty) _updateProfile(UserProfilesCompanion(nickname: Value(v)));
            });
          }),
          _buildRow('ID', profile.uid, null, readOnly: true),
          _buildRow('性别', profile.gender ?? '未设置', _pickGender),
          _buildRow('邮箱', profile.email ?? '未设置', () {
            _editField('邮箱', profile.email, (v) {
              _updateProfile(UserProfilesCompanion(email: Value(v.isEmpty ? null : v)));
            }, keyboardType: TextInputType.emailAddress);
          }),
          _buildRow('手机', profile.phone ?? '未设置', () {
            _editField('手机', profile.phone, (v) {
              _updateProfile(UserProfilesCompanion(phone: Value(v.isEmpty ? null : v)));
            }, keyboardType: TextInputType.phone);
          }, showDivider: false),
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value, VoidCallback? onTap, {bool readOnly = false, bool showDivider = true}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: showDivider
            ? BoxDecoration(border: Border(bottom: BorderSide(color: context.colors.separatorOpaque, width: 0.5)))
            : null,
        child: Row(
          children: [
            SizedBox(width: 70, child: Text(label, style: context.textStyles.body)),
            Expanded(child: Text(value, style: context.textStyles.footnote.copyWith(color: context.colors.textSecondary), textAlign: TextAlign.right)),
            if (!readOnly) ...[
              const SizedBox(width: 4),
              Icon(Icons.chevron_right, size: 18, color: context.colors.textTertiary),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDangerCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppDimensions.md),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          InkWell(
            onTap: _logout,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Icon(Icons.logout, size: 20, color: context.colors.expense),
                  const SizedBox(width: 12),
                  Text('退出登录', style: context.textStyles.body.copyWith(color: context.colors.expense)),
                ],
              ),
            ),
          ),
          InkWell(
            onTap: _deleteAccount,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(border: Border(top: BorderSide(color: context.colors.separatorOpaque, width: 0.5))),
              child: Row(
                children: [
                  Icon(Icons.delete_forever_outlined, size: 20, color: context.colors.expense),
                  const SizedBox(width: 12),
                  Text('申请注销账号', style: context.textStyles.body.copyWith(color: context.colors.expense)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
