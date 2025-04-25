import 'package:uuid/uuid.dart';

class Task {
  final String id;
  String title;
  String description;
  DateTime dueDate;
  bool isCompleted;
  Priority priority;

  Task({
    String? id,
    required this.title,
    this.description = '',
    required this.dueDate,
    this.isCompleted = false,
    this.priority = Priority.medium,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'dueDate': dueDate.toIso8601String(),
      'isCompleted': isCompleted ? 1 : 0,
      'priority': priority.index,
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
    );
  }
}

enum Priority { low, medium, high }
