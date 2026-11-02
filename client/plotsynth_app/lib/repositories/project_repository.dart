import 'package:plotsynth_app/models/project.dart';
import 'package:plotsynth_app/models/text_snapshot.dart';
import 'package:plotsynth_app/services/database_service.dart';
import 'package:sqlite3/sqlite3.dart';

class ProjectRepository {
  final DatabaseService _dbService = DatabaseService.instance;

/// הוספה או החלפה של פרויקט קיים
  Future<void> insertProject(Project project) async {
    final db = await _dbService.database;

    db.execute(
      '''
      INSERT OR REPLACE INTO projects (id, name, createdAt, updatedAt, isFavorite)
      VALUES (?, ?, ?, ?, ?)
      ''',
      [
        project.id,
        project.name, 
        project.createdAt.toIso8601String(),
        project.updatedAt.toIso8601String(),
        project.isFavorite ? 1 : 0,
      ],
    );
  }

  /// שליפת כל הפרויקטים ממוינים לפי תאריך עדכון אחרון
  Future<List<Project>> getAllProjects() async {
    final db = await _dbService.database;

    final ResultSet results = db.select(
      'SELECT * FROM projects ORDER BY updatedAt DESC',
    );

    final List<Project> projects = [];
    for (final Row row in results) {
      // ממירים כל Row ל-Project
      projects.add(
        Project(
          id: row['id'] as String,
          name: row['name'] as String,
          createdAt: DateTime.parse(row['createdAt'] as String),
          updatedAt: DateTime.parse(row['updatedAt'] as String),
          isFavorite: (row['isFavorite'] as int? ?? 0) == 1,
          outlineHistory: [],
          writeHistory: [],
        ),
      );
    }

    return projects;
  }

  /// עדכון פרויקט קיים (למשל שינוי שם או סימון מועדף)
  Future<void> updateProject(Project project) async {
    final db = await _dbService.database;

    db.execute(
      '''
      UPDATE projects 
      SET name = ?, updatedAt = ?, isFavorite = ?
      WHERE id = ?
      ''',
      [
        project.name,
        project.updatedAt.toIso8601String(),
        project.isFavorite ? 1 : 0,
        project.id,
      ],
    );
  }

  Future<void> deleteProject(String projectId) async {
    final db = await _dbService.database;
    db.execute('DELETE FROM projects WHERE id = ?', [projectId]);
  }
  // ==================== TEXT SNAPSHOTS ====================

  /// שמירת סנאפשוט של טקסט (Outline או Write)
  Future<void> saveSnapshot({
    required String projectId,
    required String tabType,
    required TextSnapshot snapshot,
  }) async {
    final db = await _dbService.database;

    db.execute(
      '''
      INSERT OR REPLACE INTO text_snapshots (id, projectId, tabType, content, wordCount, timestamp)
      VALUES (?, ?, ?, ?, ?, ?)
      ''',
      [
        snapshot.id,
        projectId,
        tabType,
        snapshot.content,
        snapshot.wordCount,
        snapshot.timestamp.toIso8601String(),
      ],
    );
  }

  /// שליפת הסנאפשוט העדכני ביותר עבור טאב מסוים בפרויקט
  Future<TextSnapshot?> getLatestSnapshot(String projectId, String tabType) async {
    final db = await _dbService.database;

    final ResultSet results = db.select(
      '''
      SELECT * FROM text_snapshots 
      WHERE projectId = ? AND tabType = ? 
      ORDER BY timestamp DESC 
      LIMIT 1
      ''',
      [projectId, tabType],
    );

    if (results.isEmpty) {
      return null;
    }

    final Row row = results.first;
    return TextSnapshot(
      id: row['id'] as String,
      content: row['content'] as String,
      wordCount: row['wordCount'] as int,
      timestamp: DateTime.parse(row['timestamp'] as String),
    );
  }


  // 3. שליפת כל היסטוריית הסנאפשוטים (עבור רשימת הגרסאות בטאב!)
  Future<List<TextSnapshot>> getAllSnapshots(String projectId, String tabType) async {
    final db = await _dbService.database;

    final ResultSet results = db.select(
      '''
      SELECT * FROM "text_snapshots"
      WHERE "projectId" = ? AND "tabType" = ?
      ORDER BY "timestamp" DESC
      ''',
      [projectId, tabType],
    );

    return results.map((row) => TextSnapshot.fromRow(row)).toList();
  }
}