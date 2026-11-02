import 'package:plotsynth_app/models/text_snapshot.dart';
import 'package:plotsynth_app/services/database_service.dart';
import 'package:sqflite/sqflite.dart';


class ProjectRepository {
  // גישה לשירות מסד הנתונים
  final DatabaseService _dbService = DatabaseService.instance;

  // 1. שמירת סנאפשוט חדש
  Future<void> saveSnapshot({
    required String projectId,
    required String tabType,
    required TextSnapshot snapshot,
  }) async {
    // קבלת החיבור ל-DB מתוך ה-Service
    final db = await _dbService.database;

    await db.insert(
      'text_snapshots',
      {
        'id': snapshot.id,
        'projectId': projectId,
        'tabType': tabType, // למשל: 'outline'
        'content': snapshot.content,
        'wordCount': snapshot.wordCount,
        'timestamp': snapshot.timestamp.toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // 2. שליפת הסנאפשוט האחרון למסך
  Future<TextSnapshot?> getLatestSnapshot(String projectId, String tabType) async {
    final db = await _dbService.database;

    final List results = await db.query(
      'text_snapshots',
      where: 'projectId = ? AND tabType = ?',
      whereArgs: [projectId, tabType],
      orderBy: 'timestamp DESC',
      limit: 1,
    );

    if (results.isNotEmpty) {
      return TextSnapshot.fromMap(results.first);
    }
    return null;
  }
}