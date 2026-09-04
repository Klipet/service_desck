import 'package:equatable/equatable.dart';

import '../../models/reports_model/report_post_model.dart';

abstract class ReportTableInputEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Отправить запрос на генерацию отчёта
class ReportTableInputRequested extends ReportTableInputEvent {
  final ReportPostModel model;
  ReportTableInputRequested(this.model);

  @override
  List<Object?> get props => [model];
}