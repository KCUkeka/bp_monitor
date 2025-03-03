import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  // Singleton pattern
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;
  final String _readingsTable = 'readings';
  final String _profilesTable = 'profiles';

  // Column names
  final String colId = 'id';
  final String colSystolic = 'systolic';
  final String colDiastolic = 'diastolic';
  final String colHeartRate = 'heartRate';
  final String colArmSide = 'armSide';
  final String colDateTime = 'dateTime';
  final String colProfileId = 'profileId';
  final String colProfileName = 'name';

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, 'bp_readings.db');

    return await openDatabase(
      path,
      version: 2, // Incremented version for schema changes
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Create profiles table first
    await db.execute('''
      CREATE TABLE $_profilesTable (
        $colId INTEGER PRIMARY KEY AUTOINCREMENT,
        $colProfileName TEXT NOT NULL UNIQUE
      )
    ''');

    // Create readings table with foreign key
    await db.execute('''
      CREATE TABLE $_readingsTable (
        $colId INTEGER PRIMARY KEY AUTOINCREMENT,
        $colSystolic INTEGER NOT NULL,
        $colDiastolic INTEGER NOT NULL,
        $colHeartRate INTEGER,
        $colArmSide TEXT NOT NULL,
        $colDateTime TEXT NOT NULL,
        $colProfileId INTEGER,
        FOREIGN KEY ($colProfileId) REFERENCES $_profilesTable($colId)
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Migration for version 2
      await db.execute('''
        ALTER TABLE $_readingsTable 
        ADD COLUMN $colProfileId INTEGER
      ''');
    }
  }

  // ================== Profile Operations ==================
  Future<int> insertProfile(String name) async {
    final db = await database;
    return await db.insert(
      _profilesTable,
      {colProfileName: name},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getProfiles() async {
    final db = await database;
    return await db.query(_profilesTable);
  }

  Future<int> deleteProfile(int id) async {
    final db = await database;
    return await db.delete(
      _profilesTable,
      where: '$colId = ?',
      whereArgs: [id],
    );
  }

  // ================== Reading Operations ==================
  Future<int> insertReading(Map<String, dynamic> reading) async {
    final db = await database;
    return await db.insert(
      _readingsTable,
      reading,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getAllReadings() async {
    final db = await database;
    return await db.query(
      _readingsTable,
      orderBy: '$colDateTime DESC',
    );
  }

  Future<List<Map<String, dynamic>>> getReadingsByProfile(int profileId) async {
    final db = await database;
    return await db.query(
      _readingsTable,
      where: '$colProfileId = ?',
      whereArgs: [profileId],
      orderBy: '$colDateTime DESC',
    );
  }

  Future<List<Map<String, dynamic>>> getReadingsWithProfile() async {
    final db = await database;
    return await db.rawQuery('''
      SELECT r.*, p.$colProfileName 
      FROM $_readingsTable r 
      LEFT JOIN $_profilesTable p 
      ON r.$colProfileId = p.$colId
      ORDER BY r.$colDateTime DESC
    ''');
  }

  Future<int> updateReading(Map<String, dynamic> reading) async {
    final db = await database;
    return await db.update(
      _readingsTable,
      reading,
      where: '$colId = ?',
      whereArgs: [reading[colId]],
    );
  }

  Future<int> deleteReading(int id) async {
    final db = await database;
    return await db.delete(
      _readingsTable,
      where: '$colId = ?',
      whereArgs: [id],
    );
  }

  // ================== Helper Methods ==================
  Future<void> close() async {
    final db = await database;
    db.close();
  }

  Future<void> clearDatabase() async {
    final db = await database;
    await db.delete(_readingsTable);
    await db.delete(_profilesTable);
  }
}