import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:service_desk/models/dictionary_models/simple_dictionary_model.dart';

import '../../services/workspace_service.dart';

part 'workspace_event.dart';
part 'workspace_state.dart';

class WorkSpaceBloc extends Bloc<WorkSpaceEvent, WorkSpaceState> {
  final WorkSpaceService _service;

  WorkSpaceBloc({WorkSpaceService? service})
      : _service = service ?? WorkSpaceService(),
        super(WorkSpaceInitial()) {
    on<CreateWorkSpaceEvent>(_onCreate);
    on<LoadAllWorkSpacesEvent>(_onLoadAll);
    on<UpdateWorkSpaceEvent>(_onUpdate);
  }

  Future<void> _onUpdate(
      UpdateWorkSpaceEvent event, Emitter<WorkSpaceState> emit) async {
    emit(WorkSpaceLoading());
    try {
      final updated = await _service.updateWorkSpace(
        apiKey: event.apiKey,
        workSpace: event.workSpace,
      );
      emit(WorkSpaceUpdated(updated));
    } catch (e) {
      emit(WorkSpaceError(e.toString()));
    }
  }

  Future<void> _onLoadAll(
      LoadAllWorkSpacesEvent event, Emitter<WorkSpaceState> emit) async {
    emit(WorkSpaceLoading());
    try {
      final workSpaces = await _service.getAllWorkSpaces(apiKey: event.apiKey);
      emit(WorkSpacesLoaded(workSpaces));
    } catch (e) {
      emit(WorkSpaceError(e.toString()));
    }
  }

  Future<void> _onCreate(
      CreateWorkSpaceEvent event, Emitter<WorkSpaceState> emit) async {
    emit(WorkSpaceLoading());
    try {
      final created = await _service.createWorkSpace(
        apiKey: event.apiKey,
        name: event.name,
      );
      emit(WorkSpaceCreated(created));
    } catch (e) {
      emit(WorkSpaceError(e.toString()));
    }
  }
}
