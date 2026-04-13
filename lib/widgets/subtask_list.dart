import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/task.dart';
import '../services/task_service.dart';

class SubtaskDialog extends StatelessWidget {
  final Task task;
  final TaskService taskService;

  const SubtaskDialog({
    super.key,
    required this.task,
    required this.taskService,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Subtasks for "${task.title}"'),
      content: SizedBox(
        width: double.maxFinite,
        child: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('tasks')
              .doc(task.id)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            final data =
                snapshot.data!.data() as Map<String, dynamic>;

            final subtasks = List<Map<String, dynamic>>.from(
              data['subtasks'] ?? [],
            );

            if (subtasks.isEmpty) {
              return const Text('No subtasks yet!');
            }

            return ListView(
              shrinkWrap: true,
              children: subtasks.map((sub) {
                return ListTile(
                  title: Text(
                    sub['title'] ?? '',
                    style: TextStyle(
                      decoration: sub['isCompleted'] == true
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                  leading: Checkbox(
                    value: sub['isCompleted'] ?? false,
                    onChanged: (_) {
                      taskService.toggleSubtask(task, sub);
                    },
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () {
                          final TextEditingController editController =
                              TextEditingController(text: sub['title'] ?? '');

                          showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: const Text('Edit Subtask'),
                              content: TextField(
                                controller: editController,
                                decoration: const InputDecoration(
                                  hintText: 'Update subtask title...',
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Cancel'),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    final newTitle = editController.text.trim();

                                    if (newTitle.isNotEmpty) {
                                      taskService.updateSubtask(
                                        task,
                                        sub,
                                        newTitle,
                                      );
                                    }

                                    Navigator.pop(context);
                                  },
                                  child: const Text('Save'),
                                ),
                              ],
                            ),
                          );
                        },
                        icon: const Icon(Icons.edit_outlined),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () {
                          taskService.deleteSubtask(task, sub);
                        },
                      ),
                    ],
                  ),
                );
              }).toList(),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }
}