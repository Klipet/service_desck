part of 'user_create_bloc.dart';

@immutable
abstract class UserCreateState extends Equatable {
  @override
  List<Object?> get props => [];
}

class UserCreateInitial extends UserCreateState {}

class UserCreateLoading extends UserCreateState {}

class UserCreated extends UserCreateState {}

class UsersLoaded extends UserCreateState {
  final List<UserListModel> users;
  UsersLoaded(this.users);

  @override
  List<Object?> get props => [users];
}

class UserUpdated extends UserCreateState {}

class UserCreateError extends UserCreateState {
  final String message;
  UserCreateError(this.message);

  @override
  List<Object?> get props => [message];
}
