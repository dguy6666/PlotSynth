import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart';

class DatabaseService {
  // Singleton - מופע יחיד
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('plotsynth.db');
    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    // 1. קבלת תיקיית המסמכים המאובטחת של המכשיר
    final Directory appDocDir = await getApplicationDocumentsDirectory();
    final String path = join(appDocDir.path, fileName);

    // 2. פתיחת מסד הנתונים ישירות דרך מנוע ה-C של SQLite
    final Database db = sqlite3.open(path);

    // 3. חובה ב-SQLite: הפעלת תמיכה במפתחות זרים (Foreign Keys)
    db.execute('PRAGMA foreign_keys = ON;');

    // 4. יצירת הטבלאות בפעם הראשונה שהאפליקציה נפתחת
    if (db.userVersion == 0) {
      _createTables(db);
      db.userVersion = 1; // מעדכן את הגרסה כדי לא ליצור שוב
    }

    return db;
  }

  void _createTables(Database db) {
    // יצירת טבלת Projects
    db.execute('''
      CREATE TABLE IF NOT EXISTS "projects" (
        "id" TEXT PRIMARY KEY,
        "name" TEXT NOT NULL,
        "createdAt" TEXT NOT NULL,
        "updatedAt" TEXT NOT NULL,
        "isFavorite" INTEGER NOT NULL DEFAULT 0
      );
    ''');

    // יצירת טבלת text (תוקן הסוגר הכפול)
    db.execute('''
      CREATE TABLE IF NOT EXISTS "text_snapshots" (
        "id" TEXT PRIMARY KEY,
        "projectId" TEXT NOT NULL,
        "tabType" TEXT NOT NULL,
        "content" TEXT NOT NULL,
        "wordCount" INTEGER NOT NULL,
        "timestamp" TEXT NOT NULL,
        FOREIGN KEY("projectId") REFERENCES "projects"("id") ON DELETE CASCADE
      );
    ''');
  }

  // פונקציית סגירה נקייה לשחרור משאבים
  void close() {
    _database?.close();
    _database = null;
  }
}