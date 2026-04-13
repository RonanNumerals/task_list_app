import 'package:flutter/material.dart';
import '../models/task.dart';
import '../services/task_service.dart';

class TaskTile extends StatelessWidget {
  final Task task;
  final TextEditingController editController;
  final TextEditingController subTaskController;
  final TaskService taskService;
  final VoidCallback onShowSubtasks;

  const TaskTile({
    super.key,
    required this.task,
    required this.editController,
    required this.subTaskController,
    required this.taskService,
    required this.onShowSubtasks,
  });

  void _showEditTaskDialog(BuildContext context) {
    editController.text = task.title;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Edit Task'),
        content: TextField(controller: editController),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              taskService.updateTask(
                task.id,
                editController.text.trim(),
              );
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showAddSubtaskDialog(BuildContext context) {
    subTaskController.clear();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add Subtask'),
        content: TextField(
          controller: subTaskController,
          decoration: const InputDecoration(
            hintText: 'Subtask title...',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              taskService.addSubtaskToFirestore(
                task.id,
                subTaskController.text.trim(),
              );
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onShowSubtasks,
      title: Text(
        task.title,
        style: TextStyle(
          decoration:
              task.isCompleted ? TextDecoration.lineThrough : null,
        ),
      ),
      leading: Checkbox(
        value: task.isCompleted,
        onChanged: (_) => taskService.toggleTask(task),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddSubtaskDialog(context),
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => _showEditTaskDialog(context),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => taskService.deleteTask(task.id),
          ),
        ],
      ),
    );
  }
}