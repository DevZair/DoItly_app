import 'package:equatable/equatable.dart';

import '../../data/models/task_model.dart';

enum TaskActionType { create, update }

abstract class TaskState extends Equatable {
  const TaskState();

  @override
  List<Object?> get props => [];
}

class TaskInitial extends TaskState {
  const TaskInitial();
}

class TaskLoading extends TaskState {
  const TaskLoading();
}

class TaskLoaded extends TaskState {
  const TaskLoaded(this.tasks);

  final List<TaskModel> tasks;

  @override
  List<Object?> get props => [tasks];
}

class TaskActionSuccess extends TaskLoaded {
  const TaskActionSuccess({
    required List<TaskModel> tasks,
    required this.message,
    required this.actionType,
    this.xpReward,
  }) : super(tasks);

  final String message;
  final TaskActionType actionType;
  final int? xpReward;

  @override
  List<Object?> get props => [tasks, message, actionType, xpReward];
}

class TaskError extends TaskState {
  const TaskError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
