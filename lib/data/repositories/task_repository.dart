import 'dart:async';

import '../../core/network/api_client.dart';
import '../models/task_model.dart';
import '../models/user_model.dart';

class TaskUpdateResult {
  TaskUpdateResult({required this.task, this.xpReward});

  final TaskModel task;
  final int? xpReward;
}

class TaskRepository {
  TaskRepository(this._apiClient, {this.enableRemoteSync = false})
    : _mockUsers = [
        const UserModel(
          id: 'u1',
          name: 'Aisha Karimova',
          email: 'aisha@doitly.uz',
          xp: 420,
          level: 5,
          avatarColor: 0xFF3BA8F8,
        ),
        const UserModel(
          id: 'u2',
          name: 'Marco Silva',
          email: 'marco@doitly.uz',
          xp: 360,
          level: 4,
          avatarColor: 0xFF34D399,
        ),
        const UserModel(
          id: 'u3',
          name: 'Sara Chen',
          email: 'sara@doitly.uz',
          xp: 285,
          level: 3,
          avatarColor: 0xFFFBBF24,
        ),
        const UserModel(
          id: 'u4',
          name: 'Jamshid Ergashev',
          email: 'jamshid@doitly.uz',
          xp: 210,
          level: 3,
          avatarColor: 0xFF818CF8,
        ),
        const UserModel(
          id: 'u5',
          name: 'Leyla Rahim',
          email: 'leyla@doitly.uz',
          xp: 165,
          level: 2,
          avatarColor: 0xFFF472B6,
        ),
      ],
      _mockTasks = [] {
    _seedTasks();
  }

  final ApiClient _apiClient;
  final bool enableRemoteSync;
  final List<UserModel> _mockUsers;
  final List<TaskModel> _mockTasks;
  late int _taskCounter;
  UserModel? _currentUser;

  void _seedTasks() {
    _mockTasks.addAll([
      TaskModel(
        id: '1',
        title: 'Plan sprint backlog',
        description:
            'Outline goals for the upcoming product sprint with the team.',
        deadline: DateTime.now().add(const Duration(days: 1)),
        status: TaskStatus.inProgress,
        xpReward: 20,
        assignees: [_mockUsers[0], _mockUsers[1]],
      ),
      TaskModel(
        id: '2',
        title: 'Share launch post',
        description: 'Schedule a short DoItly teaser across socials.',
        deadline: DateTime.now().add(const Duration(days: 2)),
        status: TaskStatus.newTask,
        xpReward: 15,
        assignees: [_mockUsers[2]],
      ),
      TaskModel(
        id: '3',
        title: 'QA checklist',
        description:
            'Verify iOS + Android release candidates against smoke tests.',
        deadline: DateTime.now().add(const Duration(days: 4)),
        status: TaskStatus.newTask,
        xpReward: 25,
        assignees: [_mockUsers[3], _mockUsers[4]],
      ),
    ]);
    _taskCounter = _mockTasks.length;
  }

  Future<UserModel> login(String email, String password) async {
    if (enableRemoteSync) {
      try {
        final response = await _apiClient.post<Map<String, dynamic>>(
          '/auth/login',
          data: {'email': email, 'password': password},
        );
        final json = response.data;
        if (json != null) {
          final user = UserModel.fromJson(json);
          _currentUser = user;
          _upsertLeaderboardUser(user);
          return user;
        }
      } catch (_) {
        // Fallback to mock auth when backend is unavailable.
      }
    }

    await Future.delayed(const Duration(milliseconds: 500));
    final normalized = email.trim().toLowerCase();
    final existing = _mockUsers
        .where((user) => user.email.toLowerCase() == normalized)
        .toList();

    if (existing.isNotEmpty) {
      _currentUser = existing.first;
      return existing.first;
    }

    final newUser = UserModel(
      id: 'u${_mockUsers.length + 1}',
      name: email.split('@').first,
      email: email,
      xp: 0,
      level: 1,
      avatarColor: 0xFF94A3B8,
    );

    _mockUsers.add(newUser);
    _currentUser = newUser;
    return newUser;
  }

  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _currentUser = null;
  }

  Future<UserModel?> currentUser() async => _currentUser;

  Future<UserModel> refreshCurrentUser() async {
    final user = _currentUser;
    if (user == null) {
      throw StateError('No active session');
    }

    final index = _mockUsers.indexWhere((element) => element.id == user.id);
    if (index == -1) {
      _mockUsers.add(user);
      return user;
    }

    final updated = _mockUsers[index];
    _currentUser = updated;
    return updated;
  }

  Future<List<UserModel>> fetchAssignableUsers() async {
    if (enableRemoteSync) {
      try {
        final response = await _apiClient.get<List<dynamic>>('/users');
        final payload = response.data;
        if (payload != null) {
          return payload
              .whereType<Map<String, dynamic>>()
              .map(UserModel.fromJson)
              .toList();
        }
      } catch (_) {
        // Fall through to mock data if remote call fails.
      }
    }

    await Future.delayed(const Duration(milliseconds: 200));
    return List<UserModel>.from(_mockUsers);
  }

  Future<List<TaskModel>> fetchTasks() async {
    if (enableRemoteSync) {
      try {
        final response = await _apiClient.get<List<dynamic>>('/tasks');
        final data = response.data;
        if (data != null) {
          return data
              .whereType<Map<String, dynamic>>()
              .map(TaskModel.fromJson)
              .toList();
        }
      } catch (_) {
        // Fall back to mock list when offline.
      }
    }

    await Future.delayed(const Duration(milliseconds: 400));
    _mockTasks.sort((a, b) => a.deadline.compareTo(b.deadline));
    return List<TaskModel>.from(_mockTasks);
  }

  Future<TaskModel> createTask({
    required String title,
    required String description,
    required DateTime deadline,
    required List<String> assigneeIds,
  }) async {
    if (enableRemoteSync) {
      try {
        final response = await _apiClient.post<Map<String, dynamic>>(
          '/tasks',
          data: {
            'title': title,
            'description': description,
            'deadline': deadline.toIso8601String(),
            'assignee_ids': assigneeIds,
          },
        );
        final json = response.data;
        if (json != null) {
          final created = TaskModel.fromJson(json);
          _mockTasks.insert(0, created);
          return created;
        }
      } catch (_) {
        // Use mock data in offline mode.
      }
    }

    await Future.delayed(const Duration(milliseconds: 300));
    _taskCounter += 1;
    final assignees = assigneeIds.isEmpty
        ? _fallbackAssignees()
        : _resolveUsersById(assigneeIds);
    final newTask = TaskModel(
      id: _taskCounter.toString(),
      title: title,
      description: description,
      deadline: deadline,
      status: TaskStatus.newTask,
      xpReward: 10 + (_taskCounter % 3) * 5,
      assignees: assignees,
    );
    _mockTasks.insert(0, newTask);
    return newTask;
  }

  Future<TaskUpdateResult> updateTaskStatus({
    required String taskId,
    required TaskStatus status,
  }) async {
    if (enableRemoteSync) {
      try {
        final response = await _apiClient.patch<Map<String, dynamic>>(
          '/tasks/$taskId',
          data: {'status': status.apiValue},
        );
        final json = response.data;
        if (json != null) {
          final updatedTask = TaskModel.fromJson(json);
          final remoteReward = json['xp_reward'] as int?;
          if (remoteReward != null && _currentUser != null) {
            final upgradedXp = _currentUser!.xp + remoteReward;
            final updatedUser = _currentUser!.copyWith(
              xp: upgradedXp,
              level: _levelFromXp(upgradedXp),
            );
            _currentUser = updatedUser;
            _upsertLeaderboardUser(updatedUser);
          }
          return TaskUpdateResult(task: updatedTask, xpReward: remoteReward);
        }
      } catch (_) {
        // Fall back to local mock state.
      }
    }

    await Future.delayed(const Duration(milliseconds: 250));
    final index = _mockTasks.indexWhere((task) => task.id == taskId);
    if (index == -1) {
      throw StateError('Task not found');
    }

    final existing = _mockTasks[index];
    final xpReward =
        status == TaskStatus.done && existing.status != TaskStatus.done
        ? existing.xpReward
        : null;

    final updatedTask = existing.copyWith(status: status);
    _mockTasks[index] = updatedTask;

    if (xpReward != null && _currentUser != null) {
      final upgradedXp = _currentUser!.xp + xpReward;
      final updatedUser = _currentUser!.copyWith(
        xp: upgradedXp,
        level: _levelFromXp(upgradedXp),
      );
      _currentUser = updatedUser;
      _upsertLeaderboardUser(updatedUser);
    }

    return TaskUpdateResult(task: updatedTask, xpReward: xpReward);
  }

  Future<List<UserModel>> fetchLeaderboard() async {
    if (enableRemoteSync) {
      try {
        final response = await _apiClient.get<List<dynamic>>('/leaderboard');
        final data = response.data;
        if (data != null) {
          return data
              .whereType<Map<String, dynamic>>()
              .map(UserModel.fromJson)
              .toList();
        }
      } catch (_) {
        // Fallback to mock leaderboard on failure.
      }
    }

    await Future.delayed(const Duration(milliseconds: 400));
    final sorted = [..._mockUsers]..sort((a, b) => b.xp.compareTo(a.xp));
    return sorted;
  }

  List<UserModel> _resolveUsersById(List<String> assigneeIds) {
    return _mockUsers.where((user) => assigneeIds.contains(user.id)).toList();
  }

  List<UserModel> _fallbackAssignees() {
    if (_currentUser == null) {
      return [];
    }
    final existingIndex = _mockUsers.indexWhere(
      (user) => user.id == _currentUser!.id,
    );
    if (existingIndex == -1) {
      _mockUsers.add(_currentUser!);
      return [_currentUser!];
    }
    return [_mockUsers[existingIndex]];
  }

  void _upsertLeaderboardUser(UserModel user) {
    final leaderboardIndex = _mockUsers.indexWhere(
      (element) => element.id == user.id,
    );
    if (leaderboardIndex == -1) {
      _mockUsers.add(user);
    } else {
      _mockUsers[leaderboardIndex] = user;
    }
  }

  int _levelFromXp(int xp) => (xp ~/ 120) + 1;
}
