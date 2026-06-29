import 'package:drift/drift.dart';
import '../../../../config/database/app_database.dart';

/// 语义记忆仓库
/// 管理 PersonaMemory 的 CRUD、评分更新、Top-N 查询
class MemoryRepository {
  final AppDatabase _db;

  MemoryRepository(this._db);

  /// 获取某角色的 Top-N 语义记忆（按 score 降序）
  Future<List<PersonaMemory>> getTopMemories({
    required String personaId,
    int limit = 8,
  }) async {
    return (_db.select(_db.personaMemories)
      ..where((t) => t.personaId.equals(personaId))
      ..orderBy([(t) => OrderingTerm.desc(t.score)])
      ..limit(limit))
      .get();
  }

  /// 按类型获取记忆
  Future<List<PersonaMemory>> getMemoriesByType({
    required String personaId,
    required String type,
  }) async {
    return (_db.select(_db.personaMemories)
      ..where((t) => t.personaId.equals(personaId) & t.type.equals(type))
      ..orderBy([(t) => OrderingTerm.desc(t.score)]))
      .get();
  }

  /// 获取所有类型的分组记忆
  Future<Map<String, List<PersonaMemory>>> getAllGrouped({
    required String personaId,
  }) async {
    final all = await (_db.select(_db.personaMemories)
      ..where((t) => t.personaId.equals(personaId))
      ..orderBy([(t) => OrderingTerm.desc(t.score)]))
      .get();
    final grouped = <String, List<PersonaMemory>>{};
    for (final m in all) {
      grouped.putIfAbsent(m.type, () => []).add(m);
    }
    return grouped;
  }

  /// 写入或更新记忆（去重合并）
  Future<void> upsertMemory(PersonaMemory memory) async {
    // 查重：同 personaId + 同 type + 同 content
    final existing = await (_db.select(_db.personaMemories)
      ..where((t) =>
          t.personaId.equals(memory.personaId) &
          t.type.equals(memory.type) &
          t.content.equals(memory.content)))
      .getSingleOrNull();

    if (existing != null) {
      // 更新 score（取较高值 + 命中奖励）
      final newScore = (existing.score + memory.score) / 2 + 0.1;
      await (_db.update(_db.personaMemories)
        ..where((t) => t.id.equals(existing.id)))
        .write(PersonaMemoriesCompanion(
          score: Value(newScore.clamp(0.0, 1.0)),
          updatedAt: Value(DateTime.now()),
        ));
    } else {
      // 新增
      final companion = memory.toCompanion(true);
      await _db.into(_db.personaMemories).insert(companion);
    }
  }

  /// 批量写入记忆
  Future<void> upsertMemories(List<PersonaMemory> memories) async {
    for (final m in memories) {
      await upsertMemory(m);
    }
  }

  /// 删除单条记忆
  Future<void> deleteMemory(int id) async {
    await (_db.delete(_db.personaMemories)..where((t) => t.id.equals(id))).go();
  }

  /// 删除角色关联的所有记忆
  Future<void> clearMemories(String personaId) async {
    await (_db.delete(_db.personaMemories)
      ..where((t) => t.personaId.equals(personaId))).go();
  }

  /// 清理低分/过期记忆
  Future<void> decayAndPrune({
    double decayRate = 0.05,
    int daysThreshold = 30,
    double minScore = 0.1,
  }) async {
    final cutoff = DateTime.now().subtract(Duration(days: daysThreshold));
    final all = await (_db.select(_db.personaMemories)).get();
    for (final m in all) {
      if (m.updatedAt.isBefore(cutoff)) {
        final newScore = m.score - decayRate;
        if (newScore <= minScore) {
          await (_db.delete(_db.personaMemories)
            ..where((t) => t.id.equals(m.id))).go();
        } else {
          await (_db.update(_db.personaMemories)
            ..where((t) => t.id.equals(m.id)))
          .write(PersonaMemoriesCompanion(score: Value(newScore)));
        }
      }
    }
  }
}