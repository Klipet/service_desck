import 'package:equatable/equatable.dart';

import '../../models/reports_model/report_post_model.dart';

abstract class ReportDasboardTableEvent extends Equatable {
  @override
  List<Object?> get props => [];
}
/// Отправить запрос на генерацию отчёта
class ReportTableGenerateRequested extends ReportDasboardTableEvent {
  final ReportPostModel model;
  ReportTableGenerateRequested(this.model);

  @override
  List<Object?> get props => [model];
}

class ReportTableGenerateBarChart extends ReportDasboardTableEvent {
  final ReportPostModel model;
  ReportTableGenerateBarChart(this.model);

  @override
  List<Object?> get props => [model];
}

/// Сбросить результат
class ReportTableReset extends ReportDasboardTableEvent {}