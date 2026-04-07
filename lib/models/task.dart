class Task {
  final String id;
  final String title;
  final bool isCompleted;
  final List<String> subtasks;
  final DateTime createdAt;

  Task({
    required this.id,
    required this.title,
    this.isCompleted = false,
    this.subtasks = const [],
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory Task.fromMap(Map<String, dynamic> data, String id) {
    return Task(
      id: id,
      title: data['title'] as String,
      isCompleted: data['isCompleted'] as bool? ?? false,
      subtasks: List<String>.from(data['subtasks'] as List<dynamic>? ?? []),
      createdAt: DateTime.parse(data['createdAt'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'isCompleted': isCompleted,
      'subtasks': subtasks,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  Task copyWith({
    String? id,
    String? title,
    bool? isCompleted,
    List<String>? subtasks,
    DateTime? createdAt,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
      subtasks: subtasks ?? this.subtasks,
      createdAt: createdAt ?? this.createdAt,
    );
  }

}