import '../../models/reports_model/report_post_model.dart';

abstract class ReportTableInputEvent{}

/// Отправить запрос на генерацию отчёта
class ReportTableInputRequested extends ReportTableInputEvent {
  final ReportPostModel model;
  ReportTableInputRequested(this.model);
}