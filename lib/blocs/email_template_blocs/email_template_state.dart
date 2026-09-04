part of 'email_template_bloc.dart';

@immutable
abstract class EmailTemplateState extends Equatable {
  @override
  List<Object?> get props => [];
}

class EmailTemplateInitial extends EmailTemplateState {}

class EmailTemplateLoading extends EmailTemplateState {}

class EmailTemplateCreated extends EmailTemplateState {}

class EmailTemplateUpdated extends EmailTemplateState {}

class EmailTemplatesLoaded extends EmailTemplateState {
  final List<EmailTemplateListModel> templates;
  EmailTemplatesLoaded(this.templates);

  @override
  List<Object?> get props => [templates];
}

class EmailTemplateDeleted extends EmailTemplateState {}

class EmailTemplateError extends EmailTemplateState {
  final String message;
  EmailTemplateError(this.message);

  @override
  List<Object?> get props => [message];
}
