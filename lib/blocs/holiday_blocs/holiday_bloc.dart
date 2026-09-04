import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:service_desk/models/holiday_models/holiday_create_model.dart';

import '../../services/holiday_service.dart';

part 'holiday_event.dart';
part 'holiday_state.dart';

class HolidayBloc extends Bloc<HolidayEvent, HolidayState> {
  final HolidayService _service;

  HolidayBloc({HolidayService? service})
      : _service = service ?? HolidayService(),
        super(HolidayInitial()) {
    on<CreateHolidayEvent>(_onCreate);
    on<LoadAllHolidaysEvent>(_onLoadAll);
  }

  Future<void> _onLoadAll(
      LoadAllHolidaysEvent event, Emitter<HolidayState> emit) async {
    emit(HolidayLoading());
    try {
      final holidays = await _service.getAllHolidays(apiKey: event.apiKey);
      emit(HolidaysLoaded(holidays));
    } catch (e) {
      emit(HolidayError(e.toString()));
    }
  }

  Future<void> _onCreate(
      CreateHolidayEvent event, Emitter<HolidayState> emit) async {
    emit(HolidayLoading());
    try {
      final created = await _service.createHoliday(
        apiKey: event.apiKey,
        holiday: HolidayCreateModel(
          name: event.name,
          date: event.date,
          isRecurringYearly: event.isRecurringYearly,
        ),
      );
      emit(HolidayCreated(created));
    } catch (e) {
      emit(HolidayError(e.toString()));
    }
  }
}
