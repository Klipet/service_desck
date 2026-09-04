part of 'mode_bloc.dart';

@immutable
abstract class ModeEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class CreateModeEvent extends ModeEvent {
  final String apiKey;
  final String name;

  CreateModeEvent({required this.apiKey, required this.name});

  @override
  List<Object?> get props => [apiKey, name];
}

class LoadAllModesEvent extends ModeEvent {
  final String apiKey;
  LoadAllModesEvent(this.apiKey);

  @override
  List<Object?> get props => [apiKey];
}

class UpdateModeEvent extends ModeEvent {
  final String apiKey;
  final SimpleDictionaryModel mode;

  UpdateModeEvent({required this.apiKey, required this.mode});

  @override
  List<Object?> get props => [apiKey, mode];
}
