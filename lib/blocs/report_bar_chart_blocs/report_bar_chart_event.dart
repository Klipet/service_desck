import 'package:equatable/equatable.dart';

import '../../models/reports_model/report_post_model.dart';

abstract class ReportBarChartEvent extends Equatable {
  @override
  List<Object?> get props => [];
}
/// Отправить запрос на генерацию отчёта
class ReportGenerateRequested extends ReportBarChartEvent {
  final ReportPostModel model;
  ReportGenerateRequested(this.model);

  @override
  List<Object?> get props => [model];
}

class ReportGenerateBarChart extends ReportBarChartEvent {
  final ReportPostModel model;
  ReportGenerateBarChart(this.model);

  @override
  List<Object?> get props => [model];
}

/// Сбросить результат
class ReportReset extends ReportBarChartEvent {}