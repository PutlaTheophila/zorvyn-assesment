import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}

class AuthSignUpRequested extends AuthEvent {
  final String name;
  final String email;
  final String password;

  const AuthSignUpRequested({
    required this.name,
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [name, email, password];
}

class AuthSignInRequested extends AuthEvent {
  final String email;
  final String password;

  const AuthSignInRequested({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];
}

class AuthSignOutRequested extends AuthEvent {
  const AuthSignOutRequested();
}

class AuthUpdateProfileRequested extends AuthEvent {
  final String? name;
  final String? email;
  final String? avatarUrl;
  final String? currentPassword;

  const AuthUpdateProfileRequested({
    this.name,
    this.email,
    this.avatarUrl,
    this.currentPassword,
  });

  @override
  List<Object?> get props => [name, email, avatarUrl, currentPassword];
}
