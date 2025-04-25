import 'package:uuid/uuid.dart';

class Task {
  final String id;
  String title;
  String description;
  DateTime dueDate;
  bool isCompleted;
  Priority priority;
  String category;
  List<String> tags;

  Task({
    String? id,
    required this.title,
    this.description = '',
    required this.dueDate,
    this.isCompleted = false,
    this.priority = Priority.medium,
    this.category = 'General',
    List<String>? tags,
  }) : id = id ?? const Uuid().v4(),
       tags = tags ?? [];

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'dueDate': dueDate.toIso8601String(),
      'isCompleted': isCompleted ? 1 : 0,
      'priority': priority.index,
      'category': category,
      'tags': tags.join(','),
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      dueDate: DateTime.parse(map['dueDate']),
      isCompleted: map['isCompleted'] == 1,
      priority: Priority.values[map['priority']],
      category: map['category'] ?? 'General',
      tags: (map['tags'] as String?)?.split(',') ?? [],
    );
  }
}

enum Priority { low, medium, high }

// Predefined categories for tasks
class TaskCategories {
  static const List<String> categories = [
    'General',
    'Work',
    'Personal',
    'Shopping',
    'Health',
    'Education',
    'Finance',
    'Other',
  ];
}
