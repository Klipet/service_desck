part of 'platform_bloc.dart';

@immutable
abstract class PlatformEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class CreatePlatformEvent extends PlatformEvent {
  final String apiKey;
  final String name;
  final int companyId;

  CreatePlatformEvent({
    required this.apiKey,
    required this.name,
    required this.companyId,
  });

  @override
  List<Object?> get props => [apiKey, name, companyId];
}

class ClearPlatformEvent extends PlatformEvent {}
