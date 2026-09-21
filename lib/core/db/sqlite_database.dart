import 'package:flutter/services.dart' show rootBundle;
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'db_interface.dart';

class SQLiteDatabase implements IDatabase {
  static final SQLiteDatabase _instance = SQLiteDatabase._internal();
  factory SQLiteDatabase() => _instance;
  SQLiteDatabase._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('database.db'); 
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 4,
      onCreate: (Database db, int version) async {
        try {
          String script = await rootBundle.loadString('assets/init_script.sql');
          List<String> commands = script.split(';');

          for (String command in commands) {
            if (command.trim().isNotEmpty) {
              await db.execute(command);
            }
          }
        } catch (e) {
          throw Exception('database initialization script error: $e');
        }
      },
      onUpgrade: (Database db, int oldVersion, int newVersion) async {
        if (oldVersion < 2) {
          await db.execute(
            "ALTER TABLE projects ADD COLUMN category TEXT NOT NULL DEFAULT 'TECNOLOGÍA'",
          );
          await db.execute(
            'ALTER TABLE projects ADD COLUMN filled_spots INTEGER NOT NULL DEFAULT 0',
          );
          await db.execute(
            'ALTER TABLE projects ADD COLUMN total_spots INTEGER NOT NULL DEFAULT 5',
          );
        }
        if (oldVersion < 3) {
          await db.execute(
            'CREATE TABLE IF NOT EXISTS applications ('
            'id INTEGER PRIMARY KEY AUTOINCREMENT,'
            'project_id INTEGER NOT NULL,'
            'motivation TEXT NOT NULL,'
            'skills TEXT NOT NULL,'
            'experience TEXT NOT NULL,'
            'submitted_at TEXT NOT NULL,'
            'FOREIGN KEY (project_id) REFERENCES projects (id)'
            ')',
          );
        }
        if (oldVersion < 4) {
          await db.execute(
            "ALTER TABLE applications ADD COLUMN applicant_name TEXT NOT NULL DEFAULT ''",
          );
          await db.execute(
            "ALTER TABLE applications ADD COLUMN applicant_program TEXT NOT NULL DEFAULT ''",
          );
          await db.execute(
            "ALTER TABLE applications ADD COLUMN applicant_university TEXT NOT NULL DEFAULT ''",
          );
          await db.execute(
            'ALTER TABLE applications ADD COLUMN avatar_url TEXT',
          );
          await db.execute(
            "ALTER TABLE applications ADD COLUMN status TEXT NOT NULL DEFAULT 'pending'",
          );
          await db.execute(
            'ALTER TABLE applications ADD COLUMN attachment_name TEXT',
          );
          await db.execute(
            'ALTER TABLE applications ADD COLUMN attachment_size_label TEXT',
          );
        }
      },
    );
  }

  // --- (db_interface.dart) ---

  @override
  Future<List<Map<String, dynamic>>> queryTable(String table) async {
    final db = await database;
    return await db.query(table);
  }

  @override
  Future<int> insertData(String table, Map<String, dynamic> data) async {
    final db = await database;
    return await db.insert(
      table,
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> updateData(
    String table,
    int id,
    Map<String, dynamic> data,
  ) async {
    final db = await database;
    await db.update(table, data, where: 'id = ?', whereArgs: [id]);
  }
}