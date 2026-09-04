import 'package:equatable/equatable.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:service_desk/models/reports_model/chart_item.dart';

import '../../models/reports_model/report_response_model.dart';

abstract class ReportBarChartState extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Начальное состояние
class ReportInitial extends ReportBarChartState {}

/// Загрузка
class ReportLoading extends ReportBarChartState {}

/// Успех — данные получены
class ReportSuccess extends ReportBarChartState {
  final ReportResponseModel report;
  ReportSuccess(this.report);

  @override
  List<Object?> get props => [report];
}

/// Ошибка
class ReportFailure extends ReportBarChartState {
  final String message;
  ReportFailure(this.message);

  @override
  List<Object?> get props => [message];
}
