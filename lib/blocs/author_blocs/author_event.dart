part of 'author_bloc.dart';

@immutable
abstract class AuthorEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class CreateAuthorEvent extends AuthorEvent {
  final String apiKey;
  final String name;
  final String? email;
  final String? phoneNumber;
  final int platformId;

  CreateAuthorEvent({
    required this.apiKey,
    required this.name,
    required this.platformId,
    this.email,
    this.phoneNumber,
  });

  @override
  List<Object?> get props => [apiKey, name, email, phoneNumber, platformId];
}

class LoadAllAuthorsEvent extends AuthorEvent {
  final String apiKey;
  LoadAllAuthorsEvent(this.apiKey);

  @override
  List<Object?> get props => [apiKey];
}

class ClearAuthorEvent extends AuthorEvent {}
