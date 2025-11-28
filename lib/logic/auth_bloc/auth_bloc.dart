import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repositories/task_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(this._taskRepository) : super(const AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
    on<RegisterRequested>(_onRegisterRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<CheckAuthStatus>(_onCheckAuthStatus);
    on<RefreshCurrentUserRequested>(_onRefreshCurrentUser);
  }

  final TaskRepository _taskRepository;

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final user = await _taskRepository.login(event.email, event.password);
      emit(AuthAuthenticated(user));
    } catch (error) {
      emit(AuthError('Не удалось войти. Попробуйте ещё раз.'));
    }
  }

  Future<void> _onRegisterRequested(
    RegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final user =
          await _taskRepository.register(
        email: event.email,
        password: event.password,
        name: event.name,
        surname: event.surname,
        nickname: event.nickname,
      );
      emit(AuthAuthenticated(user));
    } catch (error) {
      emit(
        AuthError(_friendlyRegisterError(error)),
      );
    }
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _taskRepository.logout();
    emit(const AuthInitial());
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatus event,
    Emitter<AuthState> emit,
  ) async {
    final user = await _taskRepository.currentUser();
    if (user != null) {
      emit(AuthAuthenticated(user));
    } else {
      emit(const AuthInitial());
    }
  }

  Future<void> _onRefreshCurrentUser(
    RefreshCurrentUserRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      final updated = await _taskRepository.refreshCurrentUser();
      emit(AuthAuthenticated(updated));
    } catch (_) {
      // If the session is missing we silently fall back to initial state.
      emit(const AuthInitial());
    }
  }

  String _friendlyRegisterError(Object error) {
    String? message;
    try {
      final decoded = jsonDecode(error.toString());
      if (decoded is Map<String, dynamic>) {
        final desc = decoded['description']?.toString();
        final data = decoded['data']?.toString();
        final status = decoded['status']?.toString();
        message = desc?.isNotEmpty == true
            ? desc
            : (data?.isNotEmpty == true ? data : status);
      }
    } catch (_) {
      // ignore JSON parsing issues
    }

    final lower = (message ?? error.toString()).toLowerCase();
    if (lower.contains('nickname') ||
        lower.contains('nick') && lower.contains('exist') ||
        lower.contains('ник')) {
      return 'Такой никнейм уже занят';
    }

    if (message != null && message!.isNotEmpty) {
      return message!;
    }

    return 'Не удалось зарегистрироваться. Попробуйте ещё раз.';
  }
}
