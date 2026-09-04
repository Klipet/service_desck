part of 'platform_bloc.dart';

@immutable
abstract class PlatformState extends Equatable {
  @override
  List<Object?> get props => [];
}

class PlatformInitial extends PlatformState {}

class PlatformLoading extends PlatformState {}

class PlatformCreated extends PlatformState {
  final PlatformCreateModel platform;
  PlatformCreated(this.platform);

  @override
  List<Object?> get props => [platform];
}

class PlatformError extends PlatformState {
  final String message;
  PlatformError(this.message);

  @override
  List<Object?> get props => [message];
}
