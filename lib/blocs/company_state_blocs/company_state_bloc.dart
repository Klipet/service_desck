import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:service_desk/models/dictionary_models/simple_dictionary_model.dart';

import '../../services/company_state_service.dart';

part 'company_state_event.dart';
part 'company_state_state.dart';

class CompanyStateBloc extends Bloc<CompanyStateEvent, CompanyStateState> {
  final CompanyStateService _service;

  CompanyStateBloc({CompanyStateService? service})
      : _service = service ?? CompanyStateService(),
        super(CompanyStateInitial()) {
    on<CreateCompanyStateEvent>(_onCreate);
    on<LoadAllCompanyStatesEvent>(_onLoadAll);
    on<UpdateCompanyStateEvent>(_onUpdate);
  }

  Future<void> _onCreate(
      CreateCompanyStateEvent event, Emitter<CompanyStateState> emit) async {
    emit(CompanyStateLoading());
    try {
      final created = await _service.createCompanyState(
        apiKey: event.apiKey,
        name: event.name,
      );
      emit(CompanyStateCreated(created));
    } catch (e) {
      emit(CompanyStateError(e.toString()));
    }
  }

  Future<void> _onLoadAll(
      LoadAllCompanyStatesEvent event, Emitter<CompanyStateState> emit) async {
    emit(CompanyStateLoading());
    try {
      final states = await _service.getAllCompanyStates(apiKey: event.apiKey);
      emit(CompanyStatesLoaded(states));
    } catch (e) {
      emit(CompanyStateError(e.toString()));
    }
  }

  Future<void> _onUpdate(
      UpdateCompanyStateEvent event, Emitter<CompanyStateState> emit) async {
    emit(CompanyStateLoading());
    try {
      final updated = await _service.updateCompanyState(
        apiKey: event.apiKey,
        companyState: event.companyState,
      );
      emit(CompanyStateUpdated(updated));
    } catch (e) {
      emit(CompanyStateError(e.toString()));
    }
  }
}
