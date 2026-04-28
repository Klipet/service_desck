import '../../models/reports_model/report_post_model.dart';

abstract class ReportDasboardTableEvent {}
/// Отправить запрос на генерацию отчёта
class ReportTableGenerateRequested extends ReportDasboardTableEvent {
  final ReportPostModel model;
  ReportTableGenerateRequested(this.model);
}

class ReportTableGenerateBarChart extends ReportDasboardTableEvent {
  final ReportPostModel model;
  ReportTableGenerateBarChart(this.model);
}

/// Сбросить результат
class ReportTableReset extends ReportDasboardTableEvent {}