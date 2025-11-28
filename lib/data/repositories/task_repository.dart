import '../../core/services/api_service.dart';
import '../../core/services/db_service.dart';
import '../models/task_model.dart';
import '../models/user_model.dart';

class TaskUpdateResult {
  TaskUpdateResult({required this.task, this.xpReward});

  final TaskModel task;
  final int? xpReward;
}

class TaskRepository {
  TaskRepository();

  UserModel? _currentUser;

  Future<UserModel> login(String email, String password) async {
    final response = await ApiService.request<Map<String, dynamic>>(
      '/api/auth/login',
      data: {'email': email, 'password': password},
    );

    final tokens = _parseTokens(response);
    if (tokens.accessToken == null || tokens.accessToken!.isEmpty) {
      throw StateError('Access token is missing');
    }

    _persistSession(tokens);

    final profile = await _fetchCurrentUserRemote();
    if (profile == null) {
      throw StateError('Не удалось получить профиль пользователя');
    }

    _currentUser = profile;
    return profile;
  }

  Future<UserModel> register({
    required String email,
    required String password,
    required String name,
    required String surname,
    required String nickname,
  }) async {
    final response = await ApiService.request<Map<String, dynamic>>(
      '/api/auth/register',
      data: {
        'email': email,
        'password': password,
        'name': name,
        'surname': surname,
        'nickname': nickname,
        'points': 0,
      },
    );

    final tokens = _parseTokens(response);
    if (tokens.accessToken == null || tokens.accessToken!.isEmpty) {
      throw StateError('Access token is missing');
    }

    _persistSession(tokens);

    final profile = await _fetchCurrentUserRemote();
    if (profile == null) {
      throw StateError('Не удалось получить профиль после регистрации');
    }

    _currentUser = profile;
    return profile;
  }

  Future<void> logout() async {
    _currentUser = null;
    _clearStoredSession();
  }

  Future<UserModel?> currentUser() async {
    if (_currentUser != null) return _currentUser;

    if (DBService.token.isEmpty) {
      return null;
    }

    try {
      final profile = await _fetchCurrentUserRemote();
      _currentUser = profile;
      return profile;
    } catch (_) {
      _clearStoredSession();
      return null;
    }
  }

  Future<UserModel> refreshCurrentUser() async {
    final updated = await _fetchCurrentUserRemote();
    if (updated == null) {
      throw StateError('Сессия недействительна');
    }
    _currentUser = updated;
    return updated;
  }

  Future<List<UserModel>> fetchAssignableUsers() async {
    final response = await ApiService.request<List<dynamic>>(
      '/api/usersapi/',
      method: Method.get,
    );
    return response
        .whereType<Map<String, dynamic>>()
        .map(UserModel.fromJson)
        .toList();
  }

  Future<List<TaskModel>> fetchTasks() async {
    final response = await ApiService.request<List<dynamic>>(
      '/api/tasks/',
      method: Method.get,
    );
    return response
        .whereType<Map<String, dynamic>>()
        .map(TaskModel.fromJson)
        .toList();
  }

  Future<TaskModel> createTask({
    required String title,
    required String description,
    required DateTime deadline,
    required List<String> assigneeIds,
    required int xpReward,
  }) async {
    final response = await ApiService.request<Map<String, dynamic>>(
      '/api/tasks/',
      data: {
        'title': title,
        'task_desc': description,
        'deadline': deadline.toUtc().toIso8601String(),
        'point': xpReward,
        'user_ids': assigneeIds
            .map((id) => int.tryParse(id))
            .whereType<int>()
            .toList(),
      },
    );
    final created = TaskModel.fromJson(response);
    return created;
  }

  Future<TaskUpdateResult> updateTaskStatus({
    required String taskId,
    required TaskStatus status,
  }) async {
    final response = await ApiService.request<Map<String, dynamic>>(
      '/api/tasks/$taskId',
      method: Method.put,
      data: {'task_status': status.apiValue},
    );

    final updatedTask = TaskModel.fromJson(response);
    final remoteReward = _parseXpReward(response['xp_reward']) ??
        _parseXpReward(response['point']);

    if (remoteReward != null && _currentUser != null) {
      final upgradedXp = _currentUser!.xp + remoteReward;
      final updatedUser = _currentUser!.copyWith(
        xp: upgradedXp,
        level: _levelFromXp(upgradedXp),
      );
      _currentUser = updatedUser;
    }

    return TaskUpdateResult(task: updatedTask, xpReward: remoteReward);
  }

  Future<List<UserModel>> fetchLeaderboard() async {
    final users = await fetchAssignableUsers();
    users.sort((a, b) => b.xp.compareTo(a.xp));
    return users;
  }

  Future<UserModel?> _fetchCurrentUserRemote() async {
    final response = await ApiService.request<Map<String, dynamic>>(
      '/api/users/me',
      method: Method.get,
    );
    if (response.isEmpty) return null;
    return UserModel.fromJson(response);
  }

  void _persistSession(_AuthTokens tokens) {
    DBService.token = tokens.accessToken ?? '';
    if (tokens.refreshToken != null) {
      DBService.resfreshToken = tokens.refreshToken!;
    }
  }

  void _clearStoredSession() {
    DBService.token = '';
    DBService.resfreshToken = '';
  }

  int _levelFromXp(int xp) => (xp ~/ 120) + 1;

  int? _parseXpReward(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  _AuthTokens _parseTokens(Map<String, dynamic> json) {
    final payload = json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : json;
    final access = payload['access_token'] ??
        payload['accessToken'] ??
        payload['token'];
    final refresh = payload['refresh_token'] ?? payload['refreshToken'];
    return _AuthTokens(
      accessToken: access?.toString(),
      refreshToken: refresh?.toString(),
    );
  }
}

class _AuthTokens {
  _AuthTokens({this.accessToken, this.refreshToken});

  final String? accessToken;
  final String? refreshToken;
}
