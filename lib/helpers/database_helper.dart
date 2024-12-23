import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;
  // In database_helper.dart
  final String createWeightEntriesTable = '''
  CREATE TABLE weight_entries(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_email TEXT,
    weight REAL,
    date TEXT,
    FOREIGN KEY(user_email) REFERENCES users(email)
  )
''';
  final String createExerciseLogsTable = '''
  CREATE TABLE exercise_logs(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_email TEXT,
    exercise_name TEXT,
    weight REAL,
    reps INTEGER,
    sets INTEGER,
    date TEXT,
    FOREIGN KEY(user_email) REFERENCES users(email)
  )
''';

  Future<void> createRunningTable() async {
    final db = await database;
    await db.execute('''
    CREATE TABLE IF NOT EXISTS running_sessions(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      user_email TEXT,
      duration TEXT,
      distance REAL,
      calories INTEGER,
      average_pace TEXT,
      date TEXT
    )
  ''');
  }




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
      version: 5, // Updated to version 5
      onCreate: (db, version) async {
        await db.execute('''
        CREATE TABLE users(
          id INTEGER PRIMARY KEY AUTOINCREMENT, 
          email TEXT UNIQUE, 
          password TEXT,
          name TEXT,
          weight_goal REAL,
          current_weight REAL,
          workout_goal TEXT
        )
      ''');
        await db.execute('''
        CREATE TABLE steps(
          id INTEGER PRIMARY KEY AUTOINCREMENT, 
          date TEXT, 
          steps INTEGER
        )
      ''');
        await db.execute(createWeightEntriesTable);
        await db.execute(createExerciseLogsTable); // Add this line
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 4) {
          await db.execute('ALTER TABLE users ADD COLUMN name TEXT');
          await db.execute('ALTER TABLE users ADD COLUMN weight_goal REAL');
          await db.execute('ALTER TABLE users ADD COLUMN current_weight REAL');
          await db.execute('ALTER TABLE users ADD COLUMN workout_goal TEXT');
          await db.execute(createWeightEntriesTable);
        }
        if (oldVersion < 5) {
          await db.execute(createExerciseLogsTable);
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
// Add to DatabaseHelper class
  Future<void> insertRunningSession(Map<String, dynamic> session) async {
    final db = await database;
    await db.insert(
      'running_sessions',
      session,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getRunningHistory(String userEmail) async {
    final db = await database;
    return await db.query(
      'running_sessions',
      where: 'user_email = ?',
      whereArgs: [userEmail],
      orderBy: 'date DESC',
    );
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

  Future<void> updateUserProfile(String email, {
    String? name,
    double? weightGoal,
    double? currentWeight,
    String? workoutGoal,
  }) async {
    final db = await database;
    try {
      await db.update(
        'users',
        {
          if (name != null) 'name': name,
          if (weightGoal != null) 'weight_goal': weightGoal,
          if (currentWeight != null) 'current_weight': currentWeight,
          if (workoutGoal != null) 'workout_goal': workoutGoal,
        },
        where: 'email = ?',
        whereArgs: [email],
      );
    } catch (e) {
      print('Error updating user profile: $e');
    }
  }

  Future<Map<String, dynamic>?> getUserProfile(String email) async {
    final db = await database;
    final results = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );
    print('DEBUG: Database query results: $results');
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
  Future<void> insertUserProfile(Map<String, dynamic> profile) async {
    final db = await database;
    await db.insert(
      'user_profiles',
      profile,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
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

  // Weight entry management methods
  Future<void> insertWeightEntry(String userEmail, double weight) async {
    final db = await database;
    final date = DateTime.now().toIso8601String();
    await db.insert(
      'weight_entries',
      {
        'user_email': userEmail,
        'weight': weight,
        'date': date,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> insertExerciseLog(Map<String, dynamic> log) async {
    final db = await database;
    await db.insert(
      'exercise_logs',
      log,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getExerciseLogs(String userEmail) async {
    final db = await database;
    return await db.query(
      'exercise_logs',
      where: 'user_email = ?',
      whereArgs: [userEmail],
      orderBy: 'date DESC',
    );
  }

  Future<List<Map<String, dynamic>>> getWeightEntries(String userEmail, String period) async {
    final db = await database;
    final now = DateTime.now();
    final DateTime startDate;

    switch (period) {
      case 'week':
        startDate = now.subtract(const Duration(days: 7));
        break;
      case 'month':
        startDate = now.subtract(const Duration(days: 30));
        break;
      case 'year':
        startDate = now.subtract(const Duration(days: 365));
        break;
      default:
        startDate = now.subtract(const Duration(days: 7));
    }

    return await db.query(
      'weight_entries',
      where: 'user_email = ? AND date >= ?',
      whereArgs: [userEmail, startDate.toIso8601String()],
      orderBy: 'date ASC',
    );
  }

}
