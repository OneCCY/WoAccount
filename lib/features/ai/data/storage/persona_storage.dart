import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/ai_persona.dart';

/// Persona 存储层
/// SharedPreferences key: `ai_personas`, `ai_persona_active`
class PersonaStorage {
  static const _keyPersonas = 'ai_personas';
  static const _keyActive = 'ai_persona_active';

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