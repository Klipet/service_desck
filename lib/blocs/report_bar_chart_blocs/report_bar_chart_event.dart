
import '../../models/reports_model/report_post_model.dart';

abstract class ReportBarChartEvent {}
/// Отправить запрос на генерацию отчёта
class ReportGenerateRequested extends ReportBarChartEvent {
  final ReportPostModel model;
  ReportGenerateRequested(this.model);
}

class ReportGenerateBarChart extends ReportBarChartEvent {
  final ReportPostModel model;
  ReportGenerateBarChart(this.model);
}

/// Сбросить результат
class ReportReset extends ReportBarChartEvent {}