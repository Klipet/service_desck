import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:service_desk/models/dictionary_models/simple_dictionary_model.dart';

import '../../services/ticket_state_service.dart';

part 'ticket_state_event.dart';
part 'ticket_state_state.dart';

class TicketStateBloc extends Bloc<TicketStateEvent, TicketStateState> {
  final TicketStateService _service;

  TicketStateBloc({TicketStateService? service})
      : _service = service ?? TicketStateService(),
        super(TicketStateInitial()) {
    on<CreateTicketStateEvent>(_onCreate);
    on<LoadAllTicketStatesEvent>(_onLoadAll);
    on<UpdateTicketStateEvent>(_onUpdate);
  }

  Future<void> _onUpdate(
      UpdateTicketStateEvent event, Emitter<TicketStateState> emit) async {
    emit(TicketStateLoading());
    try {
      final updated = await _service.updateState(
        apiKey: event.apiKey,
        state: event.state,
      );
      emit(TicketStateUpdated(updated));
    } catch (e) {
      emit(TicketStateError(e.toString()));
    }
  }

  Future<void> _onCreate(
      CreateTicketStateEvent event, Emitter<TicketStateState> emit) async {
    emit(TicketStateLoading());
    try {
      final created = await _service.createState(
        apiKey: event.apiKey,
        name: event.name,
      );
      emit(TicketStateCreated(created));
    } catch (e) {
      emit(TicketStateError(e.toString()));
    }
  }

  Future<void> _onLoadAll(
      LoadAllTicketStatesEvent event, Emitter<TicketStateState> emit) async {
    emit(TicketStateLoading());
    try {
      final states = await _service.getAllStates(apiKey: event.apiKey);
      emit(TicketStatesLoaded(states));
    } catch (e) {
      emit(TicketStateError(e.toString()));
    }
  }
}
