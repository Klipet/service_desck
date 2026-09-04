part of 'tiket_type_bloc.dart';

@immutable
abstract class TiketTypeEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class CreateTiketTypeEvent extends TiketTypeEvent {
  final String apiKey;
  final String name;

  CreateTiketTypeEvent({required this.apiKey, required this.name});

  @override
  List<Object?> get props => [apiKey, name];
}

class LoadAllTiketTypesEvent extends TiketTypeEvent {
  final String apiKey;
  LoadAllTiketTypesEvent(this.apiKey);

  @override
  List<Object?> get props => [apiKey];
}

class UpdateTiketTypeEvent extends TiketTypeEvent {
  final String apiKey;
  final SimpleDictionaryModel tiketType;

  UpdateTiketTypeEvent({required this.apiKey, required this.tiketType});

  @override
  List<Object?> get props => [apiKey, tiketType];
}
