import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/task_provider.dart';
import '../models/task.dart';
import 'add_task_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  TaskSortOption _sortOption = TaskSortOption.dueDate;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_handleTabChange);
    Future.microtask(() => context.read<TaskProvider>().loadTasks());
  }

  void _handleTabChange() {
    if (_tabController.indexIsChanging) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }

  List<Task> _getFilteredTasks(List<Task> tasks) {
    return tasks.where((task) {
      final matchesSearch =
          task.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          task.description.toLowerCase().contains(_searchQuery.toLowerCase());

      switch (_tabController.index) {
        case 0: // All tasks
          return matchesSearch;
        case 1: // Active tasks
          return matchesSearch && !task.isCompleted;
        case 2: // Completed tasks
          return matchesSearch && task.isCompleted;
        default:
          return matchesSearch;
      }
    }).toList();
  }

  List<Task> _getSortedTasks(List<Task> tasks) {
    final sortedTasks = List<Task>.from(tasks);
    switch (_sortOption) {
      case TaskSortOption.dueDate:
        sortedTasks.sort((a, b) => a.dueDate.compareTo(b.dueDate));
        break;
      case TaskSortOption.priority:
        sortedTasks.sort(
          (a, b) => b.priority.index.compareTo(a.priority.index),
        );
        break;
      case TaskSortOption.title:
        sortedTasks.sort((a, b) => a.title.compareTo(b.title));
        break;
    }
    return sortedTasks;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TaskFlow'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Active'),
            Tab(text: 'Completed'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder:
                    (context) => Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(
                          title: const Text('Sort by Due Date'),
                          leading: const Icon(Icons.calendar_today),
                          onTap: () {
                            setState(
                              () => _sortOption = TaskSortOption.dueDate,
                            );
                            Navigator.pop(context);
                          },
                        ),
                        ListTile(
                          title: const Text('Sort by Priority'),
                          leading: const Icon(Icons.flag),
                          onTap: () {
                            setState(
                              () => _sortOption = TaskSortOption.priority,
                            );
                            Navigator.pop(context);
                          },
                        ),
                        ListTile(
                          title: const Text('Sort by Title'),
                          leading: const Icon(Icons.sort_by_alpha),
                          onTap: () {
                            setState(() => _sortOption = TaskSortOption.title);
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search tasks...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                setState(() => _searchQuery = value);
              },
            ),
          ),
          Expanded(
            child: Consumer<TaskProvider>(
              builder: (context, taskProvider, child) {
                final tasks = _getSortedTasks(
                  _getFilteredTasks(taskProvider.tasks),
                );
                if (tasks.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.task_alt,
                          size: 64,
                          color: Theme.of(
                            context,
                          ).colorScheme.primary.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No tasks found',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Add a new task to get started',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    return TaskCard(task: task);
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddTaskScreen()),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Task'),
      ),
    );
  }
}

class TaskCard extends StatelessWidget {
  final Task task;

  const TaskCard({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('MMM d, yyyy');

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: () {
          // TODO: Implement task editing
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      task.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        decoration:
                            task.isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                      ),
                    ),
                  ),
                  Checkbox(
                    value: task.isCompleted,
                    onChanged: (bool? value) {
                      context.read<TaskProvider>().toggleTaskCompletion(
                        task.id,
                      );
                    },
                  ),
                ],
              ),
              if (task.description.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  task.description,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    dateFormat.format(task.dueDate),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  _buildPriorityChip(context, task.priority),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPriorityChip(BuildContext context, Priority priority) {
    final theme = Theme.of(context);
    Color color;
    String label;

    switch (priority) {
      case Priority.high:
        color = Colors.red;
        label = 'High';
        break;
      case Priority.medium:
        color = Colors.orange;
        label = 'Medium';
        break;
      case Priority.low:
        color = Colors.green;
        label = 'Low';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        label,
        style: theme.textTheme.bodySmall?.copyWith(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

enum TaskSortOption { dueDate, priority, title }
