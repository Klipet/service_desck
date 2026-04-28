import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:service_desk/blocs/report_bar_chart_blocs/report_bar_chart_event.dart';

import '../../models/reports_model/chart_item.dart';
import '../../services/report_service.dart';
import '../../services/user_service.dart';
import 'report_bar_chart_state.dart';


class ReportBarChartBloc extends Bloc<ReportBarChartEvent, ReportBarChartState> {
  final ReportService reportService;

  ReportBarChartBloc({required this.reportService}) : super(ReportInitial()) {
    on<ReportGenerateRequested>(_onGenerateRequested);
  }

  Future<void> _onGenerateRequested(ReportGenerateRequested event, Emitter<ReportBarChartState> emit,) async {
    emit(ReportLoading());
    try {

      final user = UserService.getUser();
      final String apiKeyUser = user?.apiKey ?? '';
      final report = await reportService.generate(model: event.model, apiKey: apiKeyUser, );
      emit(ReportSuccess(report));
    } catch (e) {
      emit(ReportFailure(e.toString()));
    }
  }


}