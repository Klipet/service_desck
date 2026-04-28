import '../../models/reports_model/report_response_model.dart';

abstract class ReportDasboardTableState{}

/// Начальное состояние
class ReportTableInitial extends ReportDasboardTableState {}

/// Загрузка
class ReportTableLoading extends ReportDasboardTableState {}

/// Успех — данные получены
class ReportTableSuccess extends ReportDasboardTableState {
  final ReportResponseModel report;
  ReportTableSuccess(this.report);
}

/// Ошибка
class ReportTableFailure extends ReportDasboardTableState {
  final String message;
  ReportTableFailure(this.message);
}