// import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:wellness_tracker/models/study_models.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('study_activity.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 2, // version add goal feature
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    print("Update databse with version $oldVersion");
    if (oldVersion < 2) {
      // For simplicity in this sandbox, we'll drop and recreate to ensure userId is everywhere
      // In a real app, you'd use ALTER TABLE
      await db.execute('DROP TABLE IF EXISTS focus_sessions');
      await db.execute('DROP TABLE IF EXISTS goal_steps');
      await db.execute('DROP TABLE IF EXISTS goals');
      await db.execute('DROP TABLE IF EXISTS tasks');
      await db.execute('DROP TABLE IF EXISTS subjects');
      await db.execute('DROP TABLE IF EXISTS users');
      await _createDB(db, newVersion);
    }
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        username TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE subjects (
        id TEXT PRIMARY KEY,
        userId TEXT NOT NULL,
        name TEXT NOT NULL,
        color INTEGER NOT NULL,
        icon INTEGER NOT NULL,
        FOREIGN KEY (userId) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE tasks (
        id TEXT PRIMARY KEY,
        userId TEXT NOT NULL,
        title TEXT NOT NULL,
        description TEXT,
        subjectId TEXT NOT NULL,
        dueDate TEXT NOT NULL,
        status INTEGER NOT NULL,
        priority INTEGER NOT NULL,
        FOREIGN KEY (userId) REFERENCES users (id) ON DELETE CASCADE,
        FOREIGN KEY (subjectId) REFERENCES subjects (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE goals (
        id TEXT PRIMARY KEY,
        userId TEXT NOT NULL,
        title TEXT NOT NULL,
        description TEXT,
        deadline TEXT NOT NULL,
        FOREIGN KEY (userId) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE goal_steps (
        id TEXT PRIMARY KEY,
        goalId TEXT NOT NULL,
        title TEXT NOT NULL,
        isCompleted INTEGER NOT NULL,
        FOREIGN KEY (goalId) REFERENCES goals (id) ON DELETE CASCADE
      )
    ''');
    await db.execute('''
      CREATE TABLE focus_sessions (
        id TEXT PRIMARY KEY,
        userId TEXT NOT NULL,
        subjectId TEXT,
        durationMinutes INTEGER NOT NULL,
        startTime TEXT NOT NULL,
        FOREIGN KEY (userId) REFERENCES users (id) ON DELETE CASCADE,
        FOREIGN KEY (subjectId) REFERENCES subject (id) ON DELETE CASCADE 
      )
    ''');
  }

  // User CRUD
  Future<void> insertUser(User user) async {
    final db = await instance.database;
    await db.insert(
      'users',
      user.toMap(),
      conflictAlgorithm: ConflictAlgorithm.fail,
    );
  }

  Future<User?> getUser(String email, String password) async {
    final db = await instance.database;
    final result = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );
    if (result.isNotEmpty) {
      return User.fromMap(result.first);
    }
    return null;
  }

  Future<User?> getUserById(String id) async {
    final db = await instance.database;
    final result = await db.query('users', where: 'id = ?', whereArgs: [id]);
    if (result.isNotEmpty) {
      return User.fromMap(result.first);
    }
    return null;
  }

  // Subject CRUD
  Future<void> insertSubject(Subject subject) async {
    final db = await instance.database;
    await db.insert(
      'subjects',
      subject.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Subject>> getAllSubjects() async {
    final db = await instance.database;
    final result = await db.query('subjects');
    return result.map((json) => Subject.fromMap(json)).toList();
  }

  Future<List<Subject>> getSubjectsByUser(String userId) async {
    final db = await instance.database;
    final result =
        await db.query('subjects', where: 'userId = ?', whereArgs: [userId]);
    return result.map((json) => Subject.fromMap(json)).toList();
  }

  Future<void> deleteSubject(String id) async {
    final db = await instance.database;
    await db.delete('subjects', where: 'id = ?', whereArgs: [id]);
  }

  // Task CRUD
  Future<void> insertTask(StudyTask task) async {
    final db = await instance.database;
    await db.insert(
      'tasks',
      task.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Future<List<StudyTask>> getAllTasks() async {
  //   final db = await instance.database;
  //   final result = await db.query('tasks');
  //   return result.map((json) => StudyTask.fromMap(json)).toList();
  // }

  Future<List<StudyTask>> getTasksByUser(String userId) async {
    final db = await instance.database;
    final result =
        await db.query('tasks', where: 'userId = ?', whereArgs: [userId]);
    return result.map((json) => StudyTask.fromMap(json)).toList();
  }

  Future<void> updateTask(StudyTask task) async {
    final db = await instance.database;
    await db.update(
      'tasks',
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  Future<void> deleteTask(String id) async {
    final db = await instance.database;
    await db.delete(
      'tasks',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Goal CRUD
  Future<void> insertGoal(StudyGoal goal) async {
    final db = await instance.database;
    await db.transaction((txn) async {
      await txn.insert(
        'goals',
        goal.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      for (var step in goal.steps) {
        await txn.insert(
          'goal_steps',
          step.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  Future<List<StudyGoal>> getGoalsByUser(String userId) async {
    final db = await instance.database;
    final goalsResult =
        await db.query('goals', where: 'userId = ?', whereArgs: [userId]);

    List<StudyGoal> goals = [];
    for (var goalMap in goalsResult) {
      final stepsResult = await db
          .query('goal_steps', where: 'goalId = ?', whereArgs: [goalMap['id']]);
      final steps = stepsResult.map((s) => GoalStep.fromMap(s)).toList();
      goals.add(StudyGoal.fromMap(goalMap, steps: steps));
    }
    return goals;
  }

  // Future<List<StudyGoal>> getAllGoal() async {
  //   final db = await instance.database;
  //   final goalResult = await db.query('goals');

  //   List<StudyGoal> goals = [];
  //   for (var goalMap in goalResult) {
  //     final stepResult = await db
  //         .query('goal_steps', where: 'goalId = ?', whereArgs: [goalMap['id']]);
  //     final steps = stepResult.map((s) => GoalStep.fromMap(s)).toList();
  //     goals.add(StudyGoal.fromMap(goalMap, steps: steps));
  //   }

  //   return goals;
  // }

  Future<void> updateGoalStep(GoalStep step) async {
    final db = await instance.database;
    await db.update('goal_steps', step.toMap(),
        where: 'id = ?', whereArgs: [step.id]);
  }

  Future<void> deleteGoal(String id) async {
    final db = await instance.database;
    await db.delete('goals', where: 'id = ?', whereArgs: [id]);
    // casecade delete should handle steps
    await db.delete('goal_steps', where: 'goalId = ?', whereArgs: [id]);
  }

  // Focus Session CRUD
  Future<void> insertFocusSession(FocusSession session) async {
    final db = await instance.database;
    await db.insert(
      'focus_sessions',
      session.toMap(),
    );
  }

  Future<List<FocusSession>> getFocusSessionsByUser(String userId) async {
    final db = await instance.database;
    final result = await db.query('focus_sessions',
        where: 'userId = ?', whereArgs: [userId], orderBy: 'startTime DESC');
    return result.map((json) => FocusSession.fromMap(json)).toList();
  }

  // Future<List<FocusSession>> getAllFocusSessions() async {
  //   final db = await instance.database;
  //   final result = await db.query(
  //     'focus_sessions',
  //     orderBy: 'startTime DESC',
  //   );
  //   return result.map((json) => FocusSession.fromMap(json)).toList();
  // }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}
