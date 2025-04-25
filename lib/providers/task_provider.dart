import 'package:flutter/foundation.dart';
import '../models/task.dart';
import '../services/database_helper.dart';

class TaskProvider with ChangeNotifier {
  List<Task> _tasks = [];
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  List<Task> get tasks => _tasks;

  Future<void> loadTasks() async {
    _tasks = await _dbHelper.getAllTasks();
    notifyListeners();
  }

  Future<void> addTask(Task task) async {
    await _dbHelper.insertTask(task);
    _tasks.add(task);
    notifyListeners();
  }

  Future<void> updateTask(Task task) async {
    await _dbHelper.updateTask(task);
    final index = _tasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      _tasks[index] = task;
      notifyListeners();
    }
  }

  Future<void> deleteTask(String id) async {
    await _dbHelper.deleteTask(id);
    _tasks.removeWhere((task) => task.id == id);
    notifyListeners();
  }

  Future<void> toggleTaskCompletion(String id) async {
    final task = _tasks.firstWhere((t) => t.id == id);
    task.isCompleted = !task.isCompleted;
    await updateTask(task);
  }
}
