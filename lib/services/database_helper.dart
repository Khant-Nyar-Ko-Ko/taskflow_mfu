import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/task.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('taskflow.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 2, // Increment version for schema update
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE tasks(
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT,
        dueDate TEXT NOT NULL,
        isCompleted INTEGER NOT NULL,
        priority INTEGER NOT NULL,
        category TEXT NOT NULL,
        tags TEXT
      )
    ''');
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add new columns for version 2
      await db.execute(
        'ALTER TABLE tasks ADD COLUMN category TEXT NOT NULL DEFAULT "General"',
      );
      await db.execute('ALTER TABLE tasks ADD COLUMN tags TEXT');
    }
  }

  Future<String> insertTask(Task task) async {
    final db = await instance.database;
    await db.insert('tasks', task.toMap());
    return task.id;
  }

  Future<List<Task>> getAllTasks() async {
    final db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query('tasks');
    return List.generate(maps.length, (i) => Task.fromMap(maps[i]));
  }

  Future<List<Task>> getTasksByCategory(String category) async {
    final db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'tasks',
      where: 'category = ?',
      whereArgs: [category],
    );
    return List.generate(maps.length, (i) => Task.fromMap(maps[i]));
  }

  Future<List<Task>> getTasksByTag(String tag) async {
    final db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query('tasks');
    return List.generate(maps.length, (i) {
      final task = Task.fromMap(maps[i]);
      return task.tags.contains(tag) ? task : null;
    }).whereType<Task>().toList();
  }

  Future<int> updateTask(Task task) async {
    final db = await instance.database;
    return db.update(
      'tasks',
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  Future<int> deleteTask(String id) async {
    final db = await instance.database;
    return await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<String>> getAllCategories() async {
    final db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'tasks',
      distinct: true,
      columns: ['category'],
    );
    return maps.map((map) => map['category'] as String).toList();
  }

  Future<List<String>> getAllTags() async {
    final db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query('tasks');
    final Set<String> tags = {};
    for (var map in maps) {
      final task = Task.fromMap(map);
      tags.addAll(task.tags);
    }
    return tags.toList();
  }
}
