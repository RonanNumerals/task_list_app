import 'package:flutter/material.dart';
import '../models/task.dart';
import '../services/task_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final TextEditingController _taskController = TextEditingController();
  final TextEditingController _editController = TextEditingController();
  //List<Task> _tasks = [];

  @override
  void dispose() {
    _taskController.dispose(); // IMPORTANT: always dispose controllers
    _editController.dispose();
    super.dispose();
  }

  /*
  // ── Local state version (Phase C) ─────────────────────────────
  void _addTask() {
    final title = _taskController.text.trim();
    if (title.isEmpty) return;  // Block empty submissions

    setState(() {
      _tasks.add(Task(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        createdAt: DateTime.now(),
      ));
      _taskController.clear();
    });
  }

  Future<void> _updateTask(Task task) async {
    setState(() {
      final index = _tasks.indexWhere((t) => t.id == task.id);
      if (index != -1) {
        _tasks[index] = task.copyWith(isCompleted: !task.isCompleted);
      }
    });
  }
  */

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Task Manager')),
      body: Column(
        children: [
          // ── Input row ──────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(children: [
              Expanded(child: TextField(controller: _taskController,
                decoration: const InputDecoration(hintText: 'New task name...'),
              )),
              const SizedBox(width: 8),
              ElevatedButton(onPressed: () => addTaskToFirestore(_taskController.text.trim()), child: const Text('Add')),
            ]),
          ),
          // ── Task list ──────────────────────────────────────────
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                .collection('tasks')
                .orderBy('createdAt')
                .snapshots(),
              builder: (context, snapshot) {
                // State 1: Still connecting to Firestore
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                // State 2: Stream returned an error
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                // State 3: Data arrived
                final docs = snapshot.data?.docs ?? [];
                // State 4: Collection is empty
                if (docs.isEmpty) {
                  return const Center(child: Text('No tasks yet. Add one above!'));
                }
                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final task = Task.fromMap(
                      docs[index].id,
                      docs[index].data() as Map<String, dynamic>,
                    );
                    return ListTile(
                      title: Text(
                        task.title,
                        style: TextStyle(
                          decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                        ),
                      ),
                      leading: Checkbox(
                        value: task.isCompleted,
                        onChanged: (_) => toggleTask(task),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit_outlined),
                            onPressed: () {
                              // Show a dialog to edit the task title
                              showDialog(
                                context: context,
                                builder: (context) {
                                  _editController.text = task.title;
                                  return AlertDialog(
                                    title: const Text('Edit Task'),
                                    content: TextField(controller: _editController),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text('Cancel'),
                                      ),
                                      ElevatedButton(
                                        onPressed: () {
                                          updateTask(task.id, _editController.text.trim());
                                          Navigator.pop(context);
                                        },
                                        child: const Text('Save'),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () => deleteTask(task.id),
                          ),
                        ]
                      )
                    );
                  },
                );
              },
            )
          )
        ],
      ),
    );
  }
}