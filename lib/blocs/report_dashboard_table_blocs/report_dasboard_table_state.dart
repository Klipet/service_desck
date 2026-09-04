import 'package:equatable/equatable.dart';

import '../../models/reports_model/report_response_model.dart';

abstract class ReportDasboardTableState extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Начальное состояние
class ReportTableInitial extends ReportDasboardTableState {}

/// Загрузка
class ReportTableLoading extends ReportDasboardTableState {}

/// Успех — данные получены
class ReportTableSuccess extends ReportDasboardTableState {
  final ReportResponseModel report;
  ReportTableSuccess(this.report);

  @override
  List<Object?> get props => [report];
}

/// Ошибка
class ReportTableFailure extends ReportDasboardTableState {
  final String message;
  ReportTableFailure(this.message);

  @override
  List<Object?> get props => [message];
}