import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:service_desk/models/platform_models/platform_create_model.dart';

import '../../services/platform_service.dart';

part 'platform_event.dart';
part 'platform_state.dart';

class PlatformBloc extends Bloc<PlatformEvent, PlatformState> {
  final PlatformService _service;

  PlatformBloc({PlatformService? service})
      : _service = service ?? PlatformService(),
        super(PlatformInitial()) {
    on<CreatePlatformEvent>(_onCreate);
    on<ClearPlatformEvent>(_onClear);
  }

  Future<void> _onCreate(
      CreatePlatformEvent event, Emitter<PlatformState> emit) async {
    emit(PlatformLoading());
    try {
      final now = DateTime.now();
      final platform = PlatformCreateModel(
        name: event.name,
        companyId: event.companyId,
        dateCreated: now,
        dateModifire: now,
      );
      final created = await _service.createPlatform(
        apiKey: event.apiKey,
        platform: platform,
      );
      emit(PlatformCreated(created));
    } catch (e) {
      emit(PlatformError(e.toString()));
    }
  }

  Future<void> _onClear(
      ClearPlatformEvent event, Emitter<PlatformState> emit) async {
    emit(PlatformInitial());
  }
}
