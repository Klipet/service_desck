part of 'tiket_type_bloc.dart';

@immutable
abstract class TiketTypeState extends Equatable {
  @override
  List<Object?> get props => [];
}

class TiketTypeInitial extends TiketTypeState {}

class TiketTypeLoading extends TiketTypeState {}

class TiketTypeCreated extends TiketTypeState {
  final SimpleDictionaryModel tiketType;
  TiketTypeCreated(this.tiketType);

  @override
  List<Object?> get props => [tiketType];
}

class TiketTypesLoaded extends TiketTypeState {
  final List<SimpleDictionaryModel> tiketTypes;
  TiketTypesLoaded(this.tiketTypes);

  @override
  List<Object?> get props => [tiketTypes];
}

class TiketTypeUpdated extends TiketTypeState {
  final SimpleDictionaryModel tiketType;
  TiketTypeUpdated(this.tiketType);

  @override
  List<Object?> get props => [tiketType];
}

class TiketTypeError extends TiketTypeState {
  final String message;
  TiketTypeError(this.message);

  @override
  List<Object?> get props => [message];
}
