import 'package:flutter/material.dart';

/// 对话管理页 — 查看所有历史会话
class DialogManagePage extends StatefulWidget {
  const DialogManagePage({super.key});

  @override
  State<DialogManagePage> createState() => _DialogManagePageState();
}

class _DialogManagePageState extends State<DialogManagePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('对话管理')),
      body: const Center(
        child: Text('对话管理功能开发中...'),
      ),
    );
  }
}