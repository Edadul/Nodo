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
      version: 2,
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
  Future<void> insertData(String table, Map<String, dynamic> data) async {
    final db = await database;
    await db.insert(
      table,
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}