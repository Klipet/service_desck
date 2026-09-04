part of 'mode_bloc.dart';

@immutable
abstract class ModeState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ModeInitial extends ModeState {}

class ModeLoading extends ModeState {}

class ModeCreated extends ModeState {
  final SimpleDictionaryModel mode;
  ModeCreated(this.mode);

  @override
  List<Object?> get props => [mode];
}

class ModesLoaded extends ModeState {
  final List<SimpleDictionaryModel> modes;
  ModesLoaded(this.modes);

  @override
  List<Object?> get props => [modes];
}

class ModeUpdated extends ModeState {
  final SimpleDictionaryModel mode;
  ModeUpdated(this.mode);

  @override
  List<Object?> get props => [mode];
}

class ModeError extends ModeState {
  final String message;
  ModeError(this.message);

  @override
  List<Object?> get props => [message];
}
