import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:service_desk/models/dictionary_models/simple_dictionary_model.dart';

import '../../services/tiket_type_service.dart';

part 'tiket_type_event.dart';
part 'tiket_type_state.dart';

class TiketTypeBloc extends Bloc<TiketTypeEvent, TiketTypeState> {
  final TiketTypeService _service;

  TiketTypeBloc({TiketTypeService? service})
      : _service = service ?? TiketTypeService(),
        super(TiketTypeInitial()) {
    on<CreateTiketTypeEvent>(_onCreate);
    on<LoadAllTiketTypesEvent>(_onLoadAll);
    on<UpdateTiketTypeEvent>(_onUpdate);
  }

  Future<void> _onCreate(
      CreateTiketTypeEvent event, Emitter<TiketTypeState> emit) async {
    emit(TiketTypeLoading());
    try {
      final created = await _service.createTiketType(
        apiKey: event.apiKey,
        name: event.name,
      );
      emit(TiketTypeCreated(created));
    } catch (e) {
      emit(TiketTypeError(e.toString()));
    }
  }

  Future<void> _onLoadAll(
      LoadAllTiketTypesEvent event, Emitter<TiketTypeState> emit) async {
    emit(TiketTypeLoading());
    try {
      final types = await _service.getAllTiketTypes(apiKey: event.apiKey);
      emit(TiketTypesLoaded(types));
    } catch (e) {
      emit(TiketTypeError(e.toString()));
    }
  }

  Future<void> _onUpdate(
      UpdateTiketTypeEvent event, Emitter<TiketTypeState> emit) async {
    emit(TiketTypeLoading());
    try {
      final updated = await _service.updateTiketType(
        apiKey: event.apiKey,
        tiketType: event.tiketType,
      );
      emit(TiketTypeUpdated(updated));
    } catch (e) {
      emit(TiketTypeError(e.toString()));
    }
  }
}
