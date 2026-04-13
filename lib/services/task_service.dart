import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/task.dart';


// ── Firestore version (Phase D) ───────────────────────────────
Future<void> addTaskToFirestore(String title) async {
  if (title.trim().isEmpty) return;  // Same validation rule

  await FirebaseFirestore.instance.collection('tasks').add({
    'title': title.trim(),
    'isCompleted': false,
    'subtasks': [],
    'createdAt': DateTime.now().toIso8601String(),
  });
  // No setState() needed here — the stream will push the new doc
}

// Toggle isCompleted in Firestore
Future<void> toggleTask(Task task) async {
  await FirebaseFirestore.instance
    .collection('tasks')
    .doc(task.id)
    .update({'isCompleted': !task.isCompleted});
}

// Permanently delete a task
Future<void> deleteTask(String taskId) async {
  await FirebaseFirestore.instance
    .collection('tasks')
    .doc(taskId)
    .delete();
}

Future<void> updateTask(String taskId, String newTitle) async {
  if (newTitle.trim().isEmpty) return;

  await FirebaseFirestore.instance
    .collection('tasks')
    .doc(taskId)
    .update({'title': newTitle.trim()});
}

Future<void> addSubtaskToFirestore(String taskId, String subtaskTitle) async {
  if (subtaskTitle.trim().isEmpty) return;

  final taskRef = FirebaseFirestore.instance.collection('tasks').doc(taskId);
  await taskRef.update({
    'subtasks': FieldValue.arrayUnion([{
      'title': subtaskTitle.trim(),
      'isCompleted': false,
    }])
  });
}