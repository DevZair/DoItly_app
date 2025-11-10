import 'package:equatable/equatable.dart';

import 'user_model.dart';

enum TaskStatus { newTask, inProgress, done }

extension TaskStatusX on TaskStatus {
  String get label {
    switch (this) {
      case TaskStatus.newTask:
        return 'Новая';
      case TaskStatus.inProgress:
        return 'В работе';
      case TaskStatus.done:
        return 'Готово';
    }
  }

  String get apiValue {
    switch (this) {
      case TaskStatus.newTask:
        return 'new';
      case TaskStatus.inProgress:
        return 'in_progress';
      case TaskStatus.done:
        return 'done';
    }
  }
}

TaskStatus taskStatusFromApiValue(String value) {
  switch (value) {
    case 'in_progress':
      return TaskStatus.inProgress;
    case 'done':
      return TaskStatus.done;
    case 'new':
    default:
      return TaskStatus.newTask;
  }
}

class TaskModel extends Equatable {
  const TaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.deadline,
    required this.status,
    required this.xpReward,
    required this.assignees,
  });

  final String id;
  final String title;
  final String description;
  final DateTime deadline;
  final TaskStatus status;
  final int xpReward;
  final List<UserModel> assignees;

  TaskModel copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? deadline,
    TaskStatus? status,
    int? xpReward,
    List<UserModel>? assignees,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      deadline: deadline ?? this.deadline,
      status: status ?? this.status,
      xpReward: xpReward ?? this.xpReward,
      assignees: assignees ?? this.assignees,
    );
  }

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'].toString(),
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      deadline: DateTime.parse(json['deadline'] as String),
      status: taskStatusFromApiValue(json['status'] as String? ?? 'new'),
      xpReward: json['xp_reward'] as int? ?? 10,
      assignees: (json['assignees'] as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>()
          .map(UserModel.fromJson)
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'deadline': deadline.toIso8601String(),
      'status': status.apiValue,
      'xp_reward': xpReward,
      'assignees': assignees.map((user) => user.toJson()).toList(),
    };
  }

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    deadline,
    status,
    xpReward,
    assignees,
  ];
}
