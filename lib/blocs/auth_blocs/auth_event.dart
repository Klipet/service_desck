import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class LoginRequested extends AuthEvent {
  final String login;
  final String password;
  final bool savePass;

  const LoginRequested({
    required this.savePass,
    required this.login,
    required this.password,
  });

  @override
  List<Object?> get props => [login, password];
}

class LogoutRequested extends AuthEvent {
  const LogoutRequested();
}
class CheckAuthStatus extends AuthEvent{

}