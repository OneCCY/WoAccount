import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wo_account/l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// 消息媒体类型
enum MessageMediaType { text, voice, image }

/// 聊天气泡组件
class ChatBubble extends StatelessWidget {
  final bool isUser;
  final String content;
  final DateTime time;
  final MessageMediaType mediaType;
  final String? mediaFilePath;

  const ChatBubble({
    super.key,
    required this.isUser,
    required this.content,
    required this.time,
    this.mediaType = MessageMediaType.text,
    this.mediaFilePath,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) _buildAvatar(context),
          if (!isUser) const SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment: isUser
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                _buildBubbleContent(context),
                const SizedBox(height: 4),
                Text(
                  DateFormat('HH:mm').format(time),
                  style: context.textStyles.caption.copyWith(
                    color: context.colors.textTertiary,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          if (isUser) const SizedBox(width: 8),
          if (isUser) _buildUserAvatar(context),
        ],
      ),
    );
  }

  Widget _buildBubbleContent(BuildContext context) {
    switch (mediaType) {
      case MessageMediaType.voice:
        return _buildVoiceBubble(context);
      case MessageMediaType.image:
        return _buildImageBubble(context);
      case MessageMediaType.text:
        return _buildTextBubble(context);
    }
  }

  Widget _buildTextBubble(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isUser ? context.colors.primary : context.colors.surface,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(16),
          topRight: const Radius.circular(16),
          bottomLeft: Radius.circular(isUser ? 16 : 4),
          bottomRight: Radius.circular(isUser ? 4 : 16),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Text(
        content,
        style: context.textStyles.body.copyWith(
          color: isUser
              ? context.colors.textOnPrimary
              : context.colors.textPrimary,
          height: 1.5,
        ),
      ),
    );
  }

  Widget _buildVoiceBubble(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      constraints: const BoxConstraints(minWidth: 120),
      decoration: BoxDecoration(
        color: isUser ? context.colors.primary : context.colors.surface,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(16),
          topRight: const Radius.circular(16),
          bottomLeft: Radius.circular(isUser ? 16 : 4),
          bottomRight: Radius.circular(isUser ? 4 : 16),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.mic,
            size: 18,
            color: isUser
                ? context.colors.textOnPrimary
                : context.colors.primary,
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              content,
              style: context.textStyles.body.copyWith(
                color: isUser
                    ? context.colors.textOnPrimary
                    : context.colors.textPrimary,
                height: 1.5,
                fontSize: 14,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageBubble(BuildContext context) {
    return Column(
      crossAxisAlignment: isUser
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        if (mediaFilePath != null && File(mediaFilePath!).existsSync())
          GestureDetector(
            onTap: () => _showFullImage(context),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 200, maxHeight: 200),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: Image.file(
                File(mediaFilePath!),
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(
                  width: 120,
                  height: 80,
                  color: context.colors.surfaceSecondary,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.broken_image,
                        color: context.colors.textTertiary,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        AppLocalizations.of(context)!.chatBubbleImageFailed,
                        style: context.textStyles.caption.copyWith(
                          color: context.colors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: isUser
                ? context.colors.primary.withValues(alpha: 0.85)
                : context.colors.surface,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(16),
              topRight: const Radius.circular(16),
              bottomLeft: Radius.circular(isUser ? 16 : 4),
              bottomRight: Radius.circular(isUser ? 4 : 16),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.camera_alt,
                size: 14,
                color: isUser
                    ? context.colors.textOnPrimary.withValues(alpha: 0.8)
                    : context.colors.textTertiary,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  content,
                  style: context.textStyles.body.copyWith(
                    color: isUser
                        ? context.colors.textOnPrimary
                        : context.colors.textPrimary,
                    height: 1.5,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showFullImage(BuildContext context) {
    if (mediaFilePath == null || !File(mediaFilePath!).existsSync()) return;
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: const EdgeInsets.all(16),
        child: GestureDetector(
          onTap: () => Navigator.pop(ctx),
          child: InteractiveViewer(
            child: Image.file(File(mediaFilePath!), fit: BoxFit.contain),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: context.colors.primarySurface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Center(child: Text('🤖', style: TextStyle(fontSize: 16))),
    );
  }

  Widget _buildUserAvatar(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: context.colors.surfaceSecondary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Icon(
          Icons.person,
          size: 18,
          color: context.colors.textSecondary,
        ),
      ),
    );
  }
}
