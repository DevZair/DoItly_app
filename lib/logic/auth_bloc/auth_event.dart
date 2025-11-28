import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class LoginRequested extends AuthEvent {
  const LoginRequested({required this.email, required this.password});

  final String email;
  final String password;

  @override
  List<Object?> get props => [email, password];
}

class LogoutRequested extends AuthEvent {
  const LogoutRequested();
}

class RegisterRequested extends AuthEvent {
  const RegisterRequested({
    required this.email,
    required this.password,
    required this.name,
    required this.surname,
    required this.nickname,
  });

  final String email;
  final String password;
  final String name;
  final String surname;
  final String nickname;

  @override
  List<Object?> get props => [email, password, name, surname, nickname];
}

class CheckAuthStatus extends AuthEvent {
  const CheckAuthStatus();
}

class RefreshCurrentUserRequested extends AuthEvent {
  const RefreshCurrentUserRequested();
}
