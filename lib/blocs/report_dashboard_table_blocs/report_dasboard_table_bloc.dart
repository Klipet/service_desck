import 'package:flutter_bloc/flutter_bloc.dart';

import '../../services/report_service.dart';
import '../../services/user_service.dart';
import 'report_dasboard_table_event.dart';
import 'report_dasboard_table_state.dart';

class ReportDasboardTableBloc extends Bloc<ReportDasboardTableEvent, ReportDasboardTableState>{
  final ReportService reportService;

  ReportDasboardTableBloc({required this.reportService}) : super(ReportTableInitial()) {
    on<ReportTableGenerateRequested>(_onGenerateRequested);
  }
  Future<void> _onGenerateRequested(ReportTableGenerateRequested event, Emitter<ReportDasboardTableState> emit,) async {
    emit(ReportTableLoading());
    try {

      final user = UserService.getUser();
      final String apiKeyUser = user?.apiKey ?? '';
      final report = await reportService.generate(model: event.model, apiKey: apiKeyUser, );
      emit(ReportTableSuccess(report));
    } catch (e) {
      emit(ReportTableFailure(e.toString()));
    }
  }
}