import 'package:flutter/foundation.dart';
import '../models/task.dart';
import '../services/database_helper.dart';

class TaskProvider with ChangeNotifier {
  List<Task> _tasks = [];
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  String _selectedCategory = 'All';
  String _selectedTag = '';

  List<Task> get tasks => _tasks;
  String get selectedCategory => _selectedCategory;
  String get selectedTag => _selectedTag;

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

  Future<void> setCategory(String category) async {
    _selectedCategory = category;
    if (category == 'All') {
      _tasks = await _dbHelper.getAllTasks();
    } else {
      _tasks = await _dbHelper.getTasksByCategory(category);
    }
    notifyListeners();
  }

  Future<void> setTag(String tag) async {
    _selectedTag = tag;
    if (tag.isEmpty) {
      _tasks = await _dbHelper.getAllTasks();
    } else {
      _tasks = await _dbHelper.getTasksByTag(tag);
    }
    notifyListeners();
  }

  Future<List<String>> getAllCategories() async {
    return await _dbHelper.getAllCategories();
  }

  Future<List<String>> getAllTags() async {
    return await _dbHelper.getAllTags();
  }
}
