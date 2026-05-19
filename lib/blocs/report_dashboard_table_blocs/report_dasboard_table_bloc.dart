import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data_base/user_repository.dart';
import '../../services/report_service.dart';
import 'report_dasboard_table_event.dart';
import 'report_dasboard_table_state.dart';

class ReportDasboardTableBloc extends Bloc<ReportDasboardTableEvent, ReportDasboardTableState>{
  final ReportService reportService;
  final UserRepository userRepository;
  ReportDasboardTableBloc({ required this.userRepository, required this.reportService}) : super(ReportTableInitial()) {
    on<ReportTableGenerateRequested>(_onGenerateRequested);
  }
  Future<void> _onGenerateRequested(ReportTableGenerateRequested event, Emitter<ReportDasboardTableState> emit,) async {
    emit(ReportTableLoading());
    try {

      final user = await userRepository.getUser();
      final String apiKeyUser = user?.apiKey ?? '';
      final report = await reportService.generate(model: event.model, apiKey: apiKeyUser, );
      emit(ReportTableSuccess(report));
    } catch (e) {
      emit(ReportTableFailure(e.toString()));
    }
  }
}