import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  final String tableName = 'readings';
  final String colId = 'id';
  final String colSystolic = 'systolic';
  final String colDiastolic = 'diastolic';
  final String colHeartRate = 'heartRate';
  final String colDateTime = 'dateTime';
  final String colNotes = 'notes';

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

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
      version: 1,
      onCreate: _onCreate,
    );
  }

// Add these columns to your table creation
Future<void> _onCreate(Database db, int version) async {
  await db.execute('''
    CREATE TABLE readings (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      systolic INTEGER NOT NULL,
      diastolic INTEGER NOT NULL,
      pulse INTEGER,
      laterality TEXT NOT NULL,
      profile TEXT NOT NULL,
      date TEXT NOT NULL
    )
  ''');

  await db.execute('''
    CREATE TABLE profiles (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL UNIQUE
    )
  ''');
}

// Add profile methods
Future<int> insertProfile(String name) async {
  final db = await database;
  return await db.insert('profiles', {'name': name});
}

Future<List<Map<String, dynamic>>> getAllProfiles() async {
  final db = await database;
  return await db.query('profiles');
}

Future<int> deleteProfile(int id) async {
  final db = await database;
  return await db.delete('profiles', where: 'id = ?', whereArgs: [id]);
}

  // CRUD Operations
  Future<int> insertReading(Map<String, dynamic> reading) async {
    final db = await database;
    return await db.insert(tableName, reading);
  }

  Future<List<Map<String, dynamic>>> getAllReadings() async {
    final db = await database;
    return await db.query(tableName, orderBy: '$colDateTime DESC');
  }

  Future<int> updateReading(Map<String, dynamic> reading) async {
    final db = await database;
    return await db.update(
      tableName,
      reading,
      where: '$colId = ?',
      whereArgs: [reading[colId]],
    );
  }

  Future<int> deleteReading(int id) async {
    final db = await database;
    return await db.delete(
      tableName,
      where: '$colId = ?',
      whereArgs: [id],
    );
  }
}