import 'package:uuid/uuid.dart';

/// AI 角色定义
class AiPersona {
  final String id;
  final String name;
  final String avatar; // emoji 头像
  final String? avatarPath; // 🆕 自定义头像文件路径
  final String description;
  final List<DialogueExample> examples;
  final String greeting;
  final bool isDefault;
  final int sortOrder;

  const AiPersona({
    required this.id,
    required this.name,
    this.avatar = '🤖',
    this.avatarPath,
    this.description = '',
    this.examples = const [],
    this.greeting = '',
    this.isDefault = false,
    this.sortOrder = 0,
  });

  AiPersona copyWith({
    String? id,
    String? name,
    String? avatar,
    String? avatarPath,
    String? description,
    List<DialogueExample>? examples,
    String? greeting,
    bool? isDefault,
    int? sortOrder,
  }) {
    return AiPersona(
      id: id ?? this.id,
      name: name ?? this.name,
      avatar: avatar ?? this.avatar,
      avatarPath: avatarPath ?? this.avatarPath,
      description: description ?? this.description,
      examples: examples ?? this.examples,
      greeting: greeting ?? this.greeting,
      isDefault: isDefault ?? this.isDefault,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  static AiPersona generate({
    required String name,
    String avatar = '🤖',
    String? avatarPath,
    String description = '',
    List<DialogueExample> examples = const [],
    String greeting = '',
    bool isDefault = false,
    int sortOrder = 0,
  }) {
    return AiPersona(
      id: const Uuid().v4(),
      name: name,
      avatar: avatar,
      avatarPath: avatarPath,
      description: description,
      examples: examples,
      greeting: greeting,
      isDefault: isDefault,
      sortOrder: sortOrder,
    );
  }

  String get systemPrompt => buildPersonaPrompt(name, description, examples);

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'avatar': avatar,
    if (avatarPath != null) 'avatarPath': avatarPath,
    'description': description,
    'examples': examples.map((e) => e.toJson()).toList(),
    'greeting': greeting,
    'isDefault': isDefault,
    'sortOrder': sortOrder,
  };

  factory AiPersona.fromJson(Map<String, dynamic> json) => AiPersona(
    id: json['id'] as String,
    name: json['name'] as String,
    avatar: json['avatar'] as String? ?? '🤖',
    avatarPath: json['avatarPath'] as String?,
    description: json['description'] as String? ?? '',
    examples: (json['examples'] as List<dynamic>?)
        ?.map((e) => DialogueExample.fromJson(e as Map<String, dynamic>))
        .toList() ?? [],
    greeting: json['greeting'] as String? ?? '',
    isDefault: json['isDefault'] as bool? ?? false,
    sortOrder: json['sortOrder'] as int? ?? 0,
  );

  static String buildPersonaPrompt(
    String name, String desc, List<DialogueExample> examples,
  ) {
    final buffer = StringBuffer('''你正在进行角色扮演，请始终以设定的角色身份回应用户。

角色名称：$name

角色性格：$desc

## 规则
1. 完全以该角色的身份语气说话，保持一致
2. 回复简洁自然，像日常对话
3. 不要提及你是一个 AI 或语言模型
4. 使用与用户相同的语言回复
5. 即使收到与记账相关的描述，也要以角色身份回应，不要输出 JSON''');

    if (examples.isNotEmpty) {
      buffer.writeln('\n## 对话示例');
      buffer.writeln('以下示例展示了角色的典型回应方式：');
      for (final ex in examples) {
        buffer.writeln('User: ${ex.user}');
        buffer.writeln('Assistant: ${ex.assistant}');
      }
    }

    return buffer.toString();
  }
}

/// 对话示例
class DialogueExample {
  final String user;
  final String assistant;

  const DialogueExample({required this.user, required this.assistant});

  Map<String, dynamic> toJson() => {'user': user, 'assistant': assistant};

  factory DialogueExample.fromJson(Map<String, dynamic> json) => DialogueExample(
    user: json['user'] as String,
    assistant: json['assistant'] as String,
  );
}