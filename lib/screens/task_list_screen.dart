import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/task.dart';
import '../services/task_service.dart';
import '../widgets/task_tile.dart';
import '../widgets/subtask_list.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final TextEditingController _taskController = TextEditingController();
  final TextEditingController _editController = TextEditingController();
  final TextEditingController _subTaskController = TextEditingController();

  final TaskService taskService = TaskService();

  bool isDarkMode = false;

  void _toggleTheme() {
    setState(() {
      isDarkMode = !isDarkMode;
    });
  }

  @override
  void dispose() {
    _taskController.dispose();
    _editController.dispose();
    _subTaskController.dispose();
    super.dispose();
  }

  void _showSubtasks(Task task) {
    showDialog(
      context: context,
      builder: (_) => SubtaskDialog(
        task: task,
        taskService: taskService,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: isDarkMode ? ThemeData.dark() : ThemeData.light(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Task Manager'),
          actions: [
            IconButton(
              onPressed: _toggleTheme,
              icon: Icon(
                isDarkMode ? Icons.light_mode : Icons.dark_mode,
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _taskController,
                      decoration: const InputDecoration(
                        hintText: 'New task name...',
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      taskService.addTaskToFirestore(
                        _taskController.text.trim(),
                      );
                      _taskController.clear();
                    },
                    child: const Text('Add'),
                  ),
                ],
              ),
            ),

            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('tasks')
                    .orderBy('createdAt')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text('Error: ${snapshot.error}'),
                    );
                  }

                  final docs = snapshot.data?.docs ?? [];

                  if (docs.isEmpty) {
                    return const Center(
                      child: Text('No tasks yet. Add one above!'),
                    );
                  }

                  final tasks = docs.map((doc) {
                    return Task.fromMap(
                      doc.id,
                      doc.data() as Map<String, dynamic>,
                    );
                  }).toList();

                  return ListView.builder(
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      final task = tasks[index];

                      return TaskTile(
                        task: task,
                        taskService: taskService,
                        editController: _editController,
                        subTaskController: _subTaskController,
                        onShowSubtasks: () => _showSubtasks(task),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}