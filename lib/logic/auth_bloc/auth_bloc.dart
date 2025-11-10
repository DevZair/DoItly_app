import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repositories/task_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(this._taskRepository) : super(const AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
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
}
