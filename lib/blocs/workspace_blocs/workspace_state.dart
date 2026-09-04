part of 'workspace_bloc.dart';

@immutable
abstract class WorkSpaceState extends Equatable {
  @override
  List<Object?> get props => [];
}

class WorkSpaceInitial extends WorkSpaceState {}

class WorkSpaceLoading extends WorkSpaceState {}

class WorkSpaceCreated extends WorkSpaceState {
  final SimpleDictionaryModel workSpace;
  WorkSpaceCreated(this.workSpace);

  @override
  List<Object?> get props => [workSpace];
}

class WorkSpacesLoaded extends WorkSpaceState {
  final List<SimpleDictionaryModel> workSpaces;
  WorkSpacesLoaded(this.workSpaces);

  @override
  List<Object?> get props => [workSpaces];
}

class WorkSpaceUpdated extends WorkSpaceState {
  final SimpleDictionaryModel workSpace;
  WorkSpaceUpdated(this.workSpace);

  @override
  List<Object?> get props => [workSpace];
}

class WorkSpaceError extends WorkSpaceState {
  final String message;
  WorkSpaceError(this.message);

  @override
  List<Object?> get props => [message];
}
