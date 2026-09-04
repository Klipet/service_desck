part of 'email_template_bloc.dart';

@immutable
abstract class EmailTemplateEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class CreateEmailTemplateEvent extends EmailTemplateEvent {
  final String apiKey;
  final EmailTemplateCreateModel template;

  CreateEmailTemplateEvent({required this.apiKey, required this.template});

  @override
  List<Object?> get props => [apiKey, template];
}

class UpdateEmailTemplateEvent extends EmailTemplateEvent {
  final String apiKey;
  final EmailTemplateCreateModel template;

  UpdateEmailTemplateEvent({required this.apiKey, required this.template});

  @override
  List<Object?> get props => [apiKey, template];
}

class LoadAllEmailTemplatesEvent extends EmailTemplateEvent {
  final String apiKey;
  LoadAllEmailTemplatesEvent(this.apiKey);

  @override
  List<Object?> get props => [apiKey];
}

class DeleteEmailTemplateEvent extends EmailTemplateEvent {
  final String apiKey;
  final int oid;
  DeleteEmailTemplateEvent({required this.apiKey, required this.oid});

  @override
  List<Object?> get props => [apiKey, oid];
}
