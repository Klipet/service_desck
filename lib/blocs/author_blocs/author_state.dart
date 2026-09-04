part of 'author_bloc.dart';

@immutable
abstract class AuthorState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthorInitial extends AuthorState {}

class AuthorLoading extends AuthorState {}

class AuthorCreated extends AuthorState {
  final AuthorCreateModel author;
  AuthorCreated(this.author);

  @override
  List<Object?> get props => [author];
}

class AuthorsLoaded extends AuthorState {
  final List<AuthorCreateModel> authors;
  AuthorsLoaded(this.authors);

  @override
  List<Object?> get props => [authors];
}

class AuthorError extends AuthorState {
  final String message;
  AuthorError(this.message);

  @override
  List<Object?> get props => [message];
}
