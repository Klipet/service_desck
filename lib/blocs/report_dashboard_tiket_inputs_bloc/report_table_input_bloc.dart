import 'package:bloc/bloc.dart';
import 'package:service_desk/blocs/report_dashboard_tiket_inputs_bloc/report_table_input_event.dart';
import 'package:service_desk/blocs/report_dashboard_tiket_inputs_bloc/report_table_input_state.dart';

import '../../services/report_service.dart';
import '../../services/user_service.dart';

class ReportTableInputBloc extends Bloc<ReportTableInputEvent, ReportTableInputState>{
  final ReportService reportService;

  ReportTableInputBloc({required this.reportService}) : super(ReportInputInitial()){
    on<ReportTableInputRequested>(_generateReport);
  }
  Future<void> _generateReport(ReportTableInputRequested event, Emitter<ReportTableInputState> emit) async{
    emit(ReportInputLoading());
    final user = UserService.getUser();
    final String apiKeyUser = user?.apiKey ?? '';
    final report = await reportService.generate(model: event.model, apiKey: apiKeyUser, );
    emit(ReportInputSuccess(report));
  }
}