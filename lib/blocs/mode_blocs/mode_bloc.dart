import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:service_desk/models/dictionary_models/simple_dictionary_model.dart';

import '../../services/mode_service.dart';

part 'mode_event.dart';
part 'mode_state.dart';

class ModeBloc extends Bloc<ModeEvent, ModeState> {
  final ModeService _service;

  ModeBloc({ModeService? service})
      : _service = service ?? ModeService(),
        super(ModeInitial()) {
    on<CreateModeEvent>(_onCreate);
    on<LoadAllModesEvent>(_onLoadAll);
    on<UpdateModeEvent>(_onUpdate);
  }

  Future<void> _onCreate(CreateModeEvent event, Emitter<ModeState> emit) async {
    emit(ModeLoading());
    try {
      final created = await _service.createMode(
        apiKey: event.apiKey,
        name: event.name,
      );
      emit(ModeCreated(created));
    } catch (e) {
      emit(ModeError(e.toString()));
    }
  }

  Future<void> _onLoadAll(LoadAllModesEvent event, Emitter<ModeState> emit) async {
    emit(ModeLoading());
    try {
      final modes = await _service.getAllModes(apiKey: event.apiKey);
      emit(ModesLoaded(modes));
    } catch (e) {
      emit(ModeError(e.toString()));
    }
  }

  Future<void> _onUpdate(UpdateModeEvent event, Emitter<ModeState> emit) async {
    emit(ModeLoading());
    try {
      final updated = await _service.updateMode(
        apiKey: event.apiKey,
        mode: event.mode,
      );
      emit(ModeUpdated(updated));
    } catch (e) {
      emit(ModeError(e.toString()));
    }
  }
}
