part of 'holiday_bloc.dart';

@immutable
abstract class HolidayState extends Equatable {
  @override
  List<Object?> get props => [];
}

class HolidayInitial extends HolidayState {}

class HolidayLoading extends HolidayState {}

class HolidayCreated extends HolidayState {
  final HolidayCreateModel holiday;
  HolidayCreated(this.holiday);

  @override
  List<Object?> get props => [holiday];
}

class HolidaysLoaded extends HolidayState {
  final List<HolidayCreateModel> holidays;
  HolidaysLoaded(this.holidays);

  @override
  List<Object?> get props => [holidays];
}

class HolidayError extends HolidayState {
  final String message;
  HolidayError(this.message);

  @override
  List<Object?> get props => [message];
}
