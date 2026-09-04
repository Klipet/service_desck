import 'package:equatable/equatable.dart';

import '../../models/reports_model/report_response_model.dart';

abstract class ReportTableInputState extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Начальное состояние
class ReportInputInitial extends ReportTableInputState {}

/// Загрузка
class ReportInputLoading extends ReportTableInputState {}

/// Успех — данные получены
class ReportInputSuccess extends ReportTableInputState {
  final ReportResponseModel report;
  ReportInputSuccess(this.report);

  @override
  List<Object?> get props => [report];
}

/// Ошибка
class ReportInputFailure extends ReportTableInputState {
  final String message;
  ReportInputFailure(this.message);

  @override
  List<Object?> get props => [message];
}