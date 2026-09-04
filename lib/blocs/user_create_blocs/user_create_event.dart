part of 'user_create_bloc.dart';

@immutable
abstract class UserCreateEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class CreateUserEvent extends UserCreateEvent {
  final String apiKey;
  final UserCreateModel user;

  CreateUserEvent({required this.apiKey, required this.user});

  @override
  List<Object?> get props => [apiKey, user];
}

class LoadAllUsersEvent extends UserCreateEvent {
  final String apiKey;
  LoadAllUsersEvent(this.apiKey);

  @override
  List<Object?> get props => [apiKey];
}

class UpdateUserEvent extends UserCreateEvent {
  final String apiKey;
  final int oid;
  final String name;
  final String firstName;
  final String email;
  final String loghin;
  final bool isActive;
  final DateTime dateCreated;
  final int workSpaceId;
  final String? phone;
  final String? password;

  UpdateUserEvent({
    required this.apiKey,
    required this.oid,
    required this.name,
    required this.firstName,
    required this.email,
    required this.loghin,
    required this.isActive,
    required this.dateCreated,
    required this.workSpaceId,
    this.phone,
    this.password,
  });

  @override
  List<Object?> get props => [
        apiKey,
        oid,
        name,
        firstName,
        email,
        loghin,
        isActive,
        dateCreated,
        workSpaceId,
        phone,
        password,
      ];
}
