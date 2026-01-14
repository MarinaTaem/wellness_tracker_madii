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
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE subjects (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        color INTEGER NOT NULL,
        icon INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE tasks (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT,
        subjectId TEXT NOT NULL,
        dueDate TEXT NOT NULL,
        status INTEGER NOT NULL,
        priority INTEGER NOT NULL,
        FOREIGN KEY (subjectId) REFERENCES subjects (id) on DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE goals (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        progress REAL NOT NULL,
        deadline TEXT NOT NULL
      )
    ''');
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

  Future<List<StudyTask>> getAllTasks() async {
    final db = await instance.database;
    final result = await db.query('tasks');
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
    await db.insert(
      'goals',
      goal.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<StudyGoal>> getAllGoal() async {
    final db = await instance.database;
    final result = await db.query('goals');
    return result.map((json) => StudyGoal.fromMap(json)).toList();
  }
}
