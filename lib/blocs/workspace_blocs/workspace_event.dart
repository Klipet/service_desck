part of 'workspace_bloc.dart';

@immutable
abstract class WorkSpaceEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class CreateWorkSpaceEvent extends WorkSpaceEvent {
  final String apiKey;
  final String name;

  CreateWorkSpaceEvent({required this.apiKey, required this.name});

  @override
  List<Object?> get props => [apiKey, name];
}

class LoadAllWorkSpacesEvent extends WorkSpaceEvent {
  final String apiKey;
  LoadAllWorkSpacesEvent(this.apiKey);

  @override
  List<Object?> get props => [apiKey];
}

class UpdateWorkSpaceEvent extends WorkSpaceEvent {
  final String apiKey;
  final SimpleDictionaryModel workSpace;

  UpdateWorkSpaceEvent({required this.apiKey, required this.workSpace});

  @override
  List<Object?> get props => [apiKey, workSpace];
}
