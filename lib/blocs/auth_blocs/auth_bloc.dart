import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';


import '../../data_base/user_repository.dart';
import '../../models/users_models/loghin_request.dart';
import '../../models/users_models/loghin_response.dart';
import '../../services/auth_service.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService authService;
  final UserRepository userRepository;
  AuthBloc({required this.authService, required this.userRepository}) : super(const AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
  //  on<LogoutRequested>(_onLogoutRequested);
    on<CheckAuthStatus>(_onCheckAuthStatus);
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatus event,
    Emitter<AuthState> emit,
  ) async {
    final savedUser = await userRepository.getUser();

    if (savedUser != null &&
        savedUser.autoSavePassword &&
        savedUser.password.isNotEmpty) {
      emit(const AuthLoading());

      try {
        final response = await authService.login(
          LoginRequest(login: savedUser.login, password: savedUser.password),
        );

        emit(AuthAuthenticated(token: response.apikey, user: response.user));
      } catch (e) {
        emit(const AuthUnauthenticated());
      }
    } else {
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    try {
      final savedUser = await userRepository.getUser();

      final String login;
      final String password;

      if (savedUser != null && savedUser.autoSavePassword) {
        // Используем сохранённые данные
        login = savedUser.login;
        password = savedUser.password;
      } else {
        // Используем данные из формы
        login = event.login;
        password = event.password;
      }

      // Авторизация
      final response = await authService.login(
        LoginRequest(login: login, password: password),
      );
      if(response.status == 200){
        await userRepository.deletePermissions();
      }
      // Сохраняем пользователя с учётом флага autoSavePassword
      await userRepository.saveUser(
        loginResponse:  LoginResponse(
          apikey: response.apikey,
          user: response.user,
          status: response.status,
        ),
        autosave: event.savePass,
        password: event.savePass ? password : '',
      );

      emit(AuthAuthenticated(token: response.apikey, user: response.user));
    } catch (e) {
      debugPrint(e.toString());
      emit(const AuthFailure("Неверный логин или пароль"));
    }
  }

//  Future<void> _onLogoutRequested(
//    LogoutRequested event,
//    Emitter<AuthState> emit,
//  ) async {
//    // Сохраняем login, но чистим пароль и apiKey
//    final savedUser = UserRepository.getUser();
//    if (savedUser != null) {
//      await UserRepository.saveUser(
//        UserModel(
//          login: savedUser.login,
//          password: '',
//          autoSavePassword: savedUser.autoSavePassword,
//          apiKey: '',
//          userName: '',
//          userId: 0
//        ),
//      );
//    }
//
//    emit(const AuthUnauthenticated());
//  }
}
