import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:service_desk/models/dictionary_models/simple_dictionary_model.dart';

import '../../services/phone_resault_service.dart';

part 'phone_resault_event.dart';
part 'phone_resault_state.dart';

class PhoneResaultBloc extends Bloc<PhoneResaultEvent, PhoneResaultState> {
  final PhoneResaultService _service;

  PhoneResaultBloc({PhoneResaultService? service})
      : _service = service ?? PhoneResaultService(),
        super(PhoneResaultInitial()) {
    on<CreatePhoneResaultEvent>(_onCreate);
    on<LoadAllPhoneResaultsEvent>(_onLoadAll);
    on<UpdatePhoneResaultEvent>(_onUpdate);
  }

  Future<void> _onCreate(
      CreatePhoneResaultEvent event, Emitter<PhoneResaultState> emit) async {
    emit(PhoneResaultLoading());
    try {
      final created = await _service.createPhoneResault(
        apiKey: event.apiKey,
        name: event.name,
      );
      emit(PhoneResaultCreated(created));
    } catch (e) {
      emit(PhoneResaultError(e.toString()));
    }
  }

  Future<void> _onLoadAll(
      LoadAllPhoneResaultsEvent event, Emitter<PhoneResaultState> emit) async {
    emit(PhoneResaultLoading());
    try {
      final results = await _service.getAllPhoneResaults(apiKey: event.apiKey);
      emit(PhoneResaultsLoaded(results));
    } catch (e) {
      emit(PhoneResaultError(e.toString()));
    }
  }

  Future<void> _onUpdate(
      UpdatePhoneResaultEvent event, Emitter<PhoneResaultState> emit) async {
    emit(PhoneResaultLoading());
    try {
      final updated = await _service.updatePhoneResault(
        apiKey: event.apiKey,
        phoneResault: event.phoneResault,
      );
      emit(PhoneResaultUpdated(updated));
    } catch (e) {
      emit(PhoneResaultError(e.toString()));
    }
  }
}
