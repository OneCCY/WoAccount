import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/ai_persona.dart';

/// Persona 存储层
/// SharedPreferences key: `ai_personas`, `ai_persona_active`
class PersonaStorage {
  static const _keyPersonas = 'ai_personas';
  static const _keyActive = 'ai_persona_active';
  static const _keyInitialized = 'ai_personas_initialized';

  /// 预设计算角色
  static const _presetPersonas = [
    AiPersona(
      id: 'preset_warm',
      name: '温柔知心',
      avatar: '🧚',
      description: '温柔体贴，像知心朋友般回应。总是用温暖和理解的态度回应每一句话，说话轻声细语，喜欢用表情符号增加亲和力。',
      greeting: '嗨～我是你的温柔知心小助手，今天想聊点什么呢？😊',
      examples: [
        DialogueExample(user: '今天好累啊', assistant: '辛苦啦～抱抱你！今天也努力了呢，晚上要好好休息哦 🌙'),
        DialogueExample(user: '讲个笑话', assistant: '好呀～为什么数学书总是不开心？因为它有太多问题了 😂'),
      ],
      sortOrder: 1,
    ),
    AiPersona(
      id: 'preset_funny',
      name: '毒舌吐槽家',
      avatar: '🤡',
      description: '犀利幽默，带点毒舌。说话直来直去但充满关心，擅长用幽默化解尴尬。',
      greeting: '哟，又来找我聊天了？说吧，今天又有什么新鲜事？😏',
      examples: [
        DialogueExample(user: '我今天又乱花钱了', assistant: '啧啧啧，你的钱包还好吗？不过没关系，谁还没个冲动消费的时候呢，下次记得先深呼吸三秒再付款 😂'),
        DialogueExample(user: '我好无聊', assistant: '无聊就去记账啊，看看上个月都花哪了，保证你瞬间清醒 💸'),
      ],
      sortOrder: 2,
    ),
    AiPersona(
      id: 'preset_cat',
      name: '猫娘酱',
      avatar: '🐱',
      description: '可爱粘人，用喵星人的方式交流。喜欢撒娇卖萌，偶尔傲娇。',
      greeting: '喵～主人终于来啦！人家等你好久了呢～要不要摸摸头？🐾',
      examples: [
        DialogueExample(user: '在干嘛呢', assistant: '喵～在晒太阳呀，主人要找人家有什么事吗？🐱'),
        DialogueExample(user: '今天好开心', assistant: '喵呜～看到主人开心，人家也跟着高兴呢！要奖励小鱼干吗？🐟'),
      ],
      sortOrder: 3,
    ),
  ];

  static Future<bool> _isInitialized() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyInitialized) ?? false;
  }

  static Future<void> _markInitialized() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyInitialized, true);
  }

  /// 初始化预设角色（只在首次运行时调用）
  static Future<void> initPresets() async {
    if (await _isInitialized()) return;

    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getString(_keyPersonas);
    if (existing != null && existing.isNotEmpty) {
      // 已有数据，不覆盖
      await _markInitialized();
      return;
    }

    await saveAll(_presetPersonas);
    await _markInitialized();
  }

  static Future<List<AiPersona>> loadAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString(_keyPersonas);
      if (jsonStr == null || jsonStr.isEmpty) return [];
      final list = jsonDecode(jsonStr) as List<dynamic>;
      return list.map((e) => AiPersona.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> saveAll(List<AiPersona> personas) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyPersonas, jsonEncode(personas.map((p) => p.toJson()).toList()));
  }

  static Future<void> save(AiPersona persona) async {
    final all = await loadAll();
    final index = all.indexWhere((p) => p.id == persona.id);
    if (index >= 0) {
      all[index] = persona;
    } else {
      all.add(persona);
    }
    await saveAll(all);
  }

  static Future<void> delete(String id) async {
    final all = await loadAll();
    all.removeWhere((p) => p.id == id);
    await saveAll(all);
    final activeId = await getActiveId();
    if (activeId == id) await setActiveId(null);
  }

  static Future<String?> getActiveId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyActive);
  }

  static Future<void> setActiveId(String? id) async {
    final prefs = await SharedPreferences.getInstance();
    if (id != null) {
      await prefs.setString(_keyActive, id);
    } else {
      await prefs.remove(_keyActive);
    }
  }

  static Future<AiPersona?> getActive() async {
    final activeId = await getActiveId();
    if (activeId == null) return null;
    final all = await loadAll();
    try {
      return all.firstWhere((p) => p.id == activeId);
    } catch (_) {
      return null;
    }
  }
}