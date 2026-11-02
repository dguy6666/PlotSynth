import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

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

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    // create Projects table
    await db.execute('''
      CREATE TABLE "Projects" (
      "ID"	TEXT,
      "name"	TEXT NOT NULL,
      "createdAt"	TEXT NOT NULL,
      "updatedAt"	TEXT NOT NULL,
      "isFavorite"	INTEGER NOT NULL DEFAULT 0,
      PRIMARY KEY("ID")
    )''');

    // creates TextSnapshots table
    await db.execute('''
      CREATE TABLE "TextSnapshots" (
      "ID"	TEXT,
      "projectID"	TEXT NOT NULL,
      "tabType"	TEXT NOT NULL,
      "content"	TEXT NOT NULL,
      "wordCount"	INTEGER NOT NULL,
      "timestamp"	TEXT NOT NULL,
      PRIMARY KEY("ID"),
      FOREIGN KEY("projectID") REFERENCES "Projects"("ID") ON DELETE CASCADE
    )
    )''');
  }

}