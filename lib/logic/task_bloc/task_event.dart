import 'package:equatable/equatable.dart';

import '../../data/models/task_model.dart';

abstract class TaskEvent extends Equatable {
  const TaskEvent();

  @override
  List<Object?> get props => [];
}

class LoadTasksEvent extends TaskEvent {
  const LoadTasksEvent();
}

class RefreshTasksEvent extends TaskEvent {
  const RefreshTasksEvent();
}

class CreateTaskEvent extends TaskEvent {
  const CreateTaskEvent({
    required this.title,
    required this.description,
    required this.deadline,
    required this.assigneeIds,
  });

  final String title;
  final String description;
  final DateTime deadline;
  final List<String> assigneeIds;

  @override
  List<Object?> get props => [title, description, deadline, assigneeIds];
}

class UpdateTaskStatusEvent extends TaskEvent {
  const UpdateTaskStatusEvent({required this.taskId, required this.status});

  final String taskId;
  final TaskStatus status;

  @override
  List<Object?> get props => [taskId, status];
}
