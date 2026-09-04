part of 'holiday_bloc.dart';

@immutable
abstract class HolidayEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class CreateHolidayEvent extends HolidayEvent {
  final String apiKey;
  final String name;
  final DateTime date;
  final bool isRecurringYearly;

  CreateHolidayEvent({
    required this.apiKey,
    required this.name,
    required this.date,
    this.isRecurringYearly = false,
  });

  @override
  List<Object?> get props => [apiKey, name, date, isRecurringYearly];
}

class LoadAllHolidaysEvent extends HolidayEvent {
  final String apiKey;
  LoadAllHolidaysEvent(this.apiKey);

  @override
  List<Object?> get props => [apiKey];
}
