import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:service_desk/models/user_create_models/user_create_model.dart';
import 'package:service_desk/models/user_create_models/user_list_model.dart';

import '../../services/user_create_service.dart';

part 'user_create_event.dart';
part 'user_create_state.dart';

class UserCreateBloc extends Bloc<UserCreateEvent, UserCreateState> {
  final UserCreateService _service;

  UserCreateBloc({UserCreateService? service})
      : _service = service ?? UserCreateService(),
        super(UserCreateInitial()) {
    on<CreateUserEvent>(_onCreate);
    on<LoadAllUsersEvent>(_onLoadAll);
    on<UpdateUserEvent>(_onUpdate);
  }

  Future<void> _onCreate(
      CreateUserEvent event, Emitter<UserCreateState> emit) async {
    emit(UserCreateLoading());
    try {
      await _service.createUser(apiKey: event.apiKey, user: event.user);
      emit(UserCreated());
    } catch (e) {
      emit(UserCreateError(e.toString()));
    }
  }

  Future<void> _onLoadAll(
      LoadAllUsersEvent event, Emitter<UserCreateState> emit) async {
    emit(UserCreateLoading());
    try {
      final users = await _service.getAllUsers(apiKey: event.apiKey);
      emit(UsersLoaded(users));
    } catch (e) {
      emit(UserCreateError(e.toString()));
    }
  }

  Future<void> _onUpdate(
      UpdateUserEvent event, Emitter<UserCreateState> emit) async {
    emit(UserCreateLoading());
    try {
      await _service.updateUser(
        apiKey: event.apiKey,
        oid: event.oid,
        name: event.name,
        firstName: event.firstName,
        email: event.email,
        loghin: event.loghin,
        isActive: event.isActive,
        dateCreated: event.dateCreated,
        workSpaceId: event.workSpaceId,
        phone: event.phone,
        password: event.password,
      );
      emit(UserUpdated());
    } catch (e) {
      emit(UserCreateError(e.toString()));
    }
  }
}
