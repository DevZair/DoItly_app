import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/task_model.dart';
import '../../data/repositories/task_repository.dart';
import 'task_event.dart';
import 'task_state.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  TaskBloc(this._taskRepository) : super(const TaskInitial()) {
    on<LoadTasksEvent>(_onLoadTasks);
    on<RefreshTasksEvent>(_onRefreshTasks);
    on<CreateTaskEvent>(_onCreateTask);
    on<UpdateTaskStatusEvent>(_onUpdateTaskStatus);
  }

  final TaskRepository _taskRepository;

  Future<void> _onLoadTasks(
    LoadTasksEvent event,
    Emitter<TaskState> emit,
  ) async {
    emit(const TaskLoading());
    try {
      final tasks = await _taskRepository.fetchTasks();
      emit(TaskLoaded(tasks));
    } catch (_) {
      emit(const TaskError('Не удалось загрузить задачи.'));
    }
  }

  Future<void> _onRefreshTasks(
    RefreshTasksEvent event,
    Emitter<TaskState> emit,
  ) async {
    try {
      final tasks = await _taskRepository.fetchTasks();
      emit(TaskLoaded(tasks));
    } catch (_) {
      emit(const TaskError('Не получилось обновить список.'));
    }
  }

  Future<void> _onCreateTask(
    CreateTaskEvent event,
    Emitter<TaskState> emit,
  ) async {
    try {
      final newTask = await _taskRepository.createTask(
        title: event.title,
        description: event.description,
        deadline: event.deadline,
        assigneeIds: event.assigneeIds,
        xpReward: event.xpReward,
      );
      final updatedTasks = _currentTasks()
        ..removeWhere((task) => task.id == newTask.id)
        ..insert(0, newTask);

      emit(
        TaskActionSuccess(
          tasks: updatedTasks,
          message: 'Задача создана!',
          actionType: TaskActionType.create,
        ),
      );
    } catch (_) {
      emit(const TaskError('Не удалось создать задачу. Попробуйте позже.'));
    }
  }

  Future<void> _onUpdateTaskStatus(
    UpdateTaskStatusEvent event,
    Emitter<TaskState> emit,
  ) async {
    try {
      final result = await _taskRepository.updateTaskStatus(
        taskId: event.taskId,
        status: event.status,
      );

      final updatedTasks = _currentTasks();
      final index = updatedTasks.indexWhere(
        (task) => task.id == result.task.id,
      );
      if (index == -1) {
        updatedTasks.add(result.task);
      } else {
        updatedTasks[index] = result.task;
      }

      emit(
        TaskActionSuccess(
          tasks: updatedTasks,
          message: 'Статус обновлён!',
          actionType: TaskActionType.update,
          xpReward:
              event.status == TaskStatus.done ? result.xpReward : null,
        ),
      );
    } catch (_) {
      emit(const TaskError('Не удалось изменить статус задачи.'));
    }
  }

  List<TaskModel> _currentTasks() {
    final currentState = state;
    if (currentState is TaskLoaded) {
      return List<TaskModel>.from(currentState.tasks);
    }
    return List<TaskModel>.from([]);
  }
}
