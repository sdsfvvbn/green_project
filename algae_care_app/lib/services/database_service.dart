import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/algae_log.dart';
import 'package:flutter/foundation.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('algae_logs.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE algae_logs(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        waterColor TEXT NOT NULL,
        temperature REAL NOT NULL,
        pH REAL NOT NULL,
        lightHours INTEGER NOT NULL,
        photoPath TEXT,
        notes TEXT,
        type TEXT,
        isWaterChanged INTEGER DEFAULT 0,
        nextWaterChangeDate TEXT
      )
    ''');
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add nextWaterChangeDate column
      await db.execute('ALTER TABLE algae_logs ADD COLUMN nextWaterChangeDate TEXT');
    }
  }

  Future<int> createLog(AlgaeLog log) async {
    final db = await database;
    return await db.insert('algae_logs', log.toMap());
  }

  Future<List<AlgaeLog>> getAllLogs() async {
    if (kIsWeb) {
      // Web 端回傳空資料或假資料
      return [];
    }
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('algae_logs');
    return List.generate(maps.length, (i) => AlgaeLog.fromMap(maps[i]));
  }

  Future<AlgaeLog?> getLog(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'algae_logs',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return AlgaeLog.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateLog(AlgaeLog log) async {
    final db = await database;
    return await db.update(
      'algae_logs',
      log.toMap(),
      where: 'id = ?',
      whereArgs: [log.id],
    );
  }

  Future<int> deleteLog(int id) async {
    final db = await database;
    return await db.delete(
      'algae_logs',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<AlgaeLog?> getLogByDate(DateTime date) async {
    final db = await database;
    final dateStr = date.toIso8601String().split('T')[0];
    final List<Map<String, dynamic>> maps = await db.query(
      'algae_logs',
      where: "date LIKE ?",
      whereArgs: ["$dateStr%"],
    );
    if (maps.isNotEmpty) {
      return AlgaeLog.fromMap(maps.first);
    }
    return null;
  }

  Future<int> getLogDays() async {
    if (kIsWeb) {
      return 0;
    }
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(DISTINCT date(date)) as cnt FROM algae_logs');
    return result.isNotEmpty ? (result.first['cnt'] as int) : 0;
  }

  Future<List<AlgaeLog>> getDueWaterChanges() async {
    final db = await database;
    final today = DateTime.now();
    final todayStr = today.toIso8601String().split('T')[0];
    
    final List<Map<String, dynamic>> maps = await db.query(
      'algae_logs',
      where: 'nextWaterChangeDate IS NOT NULL AND nextWaterChangeDate <= ?',
      whereArgs: [todayStr],
    );
    return List.generate(maps.length, (i) => AlgaeLog.fromMap(maps[i]));
  }
} 