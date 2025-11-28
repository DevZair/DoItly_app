import 'package:equatable/equatable.dart';

import 'user_model.dart';

enum TaskStatus { newTask, inProgress, done }

extension TaskStatusX on TaskStatus {
  String get label {
    switch (this) {
      case TaskStatus.newTask:
        return 'Не начата';
      case TaskStatus.inProgress:
        return 'В работе';
      case TaskStatus.done:
        return 'Готово';
    }
  }

  String get apiValue {
    switch (this) {
      case TaskStatus.newTask:
        return 'not_started';
      case TaskStatus.inProgress:
        return 'in_progress';
      case TaskStatus.done:
        return 'completed';
    }
  }
}

TaskStatus taskStatusFromApiValue(String value) {
  switch (value) {
    case 'not_started':
      return TaskStatus.newTask;
    case 'in_progress':
      return TaskStatus.inProgress;
    case 'completed':
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
    int _parseXp(dynamic value) {
      if (value is int) return value;
      if (value is double) return value.toInt();
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    final xpFromApi = _parseXp(json['xp_reward']);
    final xpFromPoint = _parseXp(json['point']);
    final xpReward = xpFromApi != 0 ? xpFromApi : xpFromPoint;

    return TaskModel(
      id: json['id'].toString(),
      title: json['title'] as String? ?? '',
      description:
          json['description'] as String? ??
          json['task_desc'] as String? ??
          '',
      deadline: DateTime.tryParse(json['deadline']?.toString() ?? '') ??
          DateTime.now(),
      status: taskStatusFromApiValue(
        json['status']?.toString() ?? 'not_started',
      ),
      xpReward: xpReward,
      assignees: (json['assignees'] as List<dynamic>? ??
              json['users'] as List<dynamic>? ??
              [])
          .whereType<Map<String, dynamic>>()
          .map(UserModel.fromJson)
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'task_desc': description,
      'deadline': deadline.toIso8601String(),
      'status': status.apiValue,
      'point': xpReward,
      'user_ids': assignees
          .map((user) => int.tryParse(user.id))
          .whereType<int>()
          .toList(),
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
