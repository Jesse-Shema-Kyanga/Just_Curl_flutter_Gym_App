import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'fitness_tracker.db');
    return await openDatabase(
      path,
      version: 2, // Increment version to apply schema changes
      onCreate: (db, version) async {
        await db.execute(
          'CREATE TABLE users(id INTEGER PRIMARY KEY AUTOINCREMENT, email TEXT UNIQUE, password TEXT)',
        );
        await db.execute(
          'CREATE TABLE steps(id INTEGER PRIMARY KEY AUTOINCREMENT, date TEXT, steps INTEGER)',
        );
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute(
            'CREATE TABLE steps(id INTEGER PRIMARY KEY AUTOINCREMENT, date TEXT, steps INTEGER)',
          );
        }
      },
    );
  }

  // User management methods
  Future<void> insertUser(Map<String, dynamic> user) async {
    final db = await database;
    try {
      await db.insert('users', user, conflictAlgorithm: ConflictAlgorithm.replace);
    } catch (e) {
      print('Error inserting user: $e');
    }
  }

  Future<bool> userExists(String email) async {
    final db = await database;
    final List<Map<String, dynamic>> results = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );
    return results.isNotEmpty;
  }

  Future<Map<String, dynamic>?> getUser(String email, String password) async {
    final db = await database;
    final List<Map<String, dynamic>> results = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );
    return results.isNotEmpty ? results.first : null;
  }

  // Step data management methods
  Future<void> insertStepData(String date, int steps) async {
    final db = await database;
    try {
      await db.insert(
        'steps',
        {'date': date, 'steps': steps},
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      print('Error inserting step data: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getStepData() async {
    final db = await database;
    return await db.query('steps', orderBy: 'date ASC');
  }

  Future<int> getStepsForDate(String date) async {
    final db = await database;
    final List<Map<String, dynamic>> results = await db.query(
      'steps',
      where: 'date = ?',
      whereArgs: [date],
    );
    return results.isNotEmpty ? results.first['steps'] as int : 0;
  }
}
