import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:service_desk/models/email_template_models/email_template_create_model.dart';
import 'package:service_desk/models/email_template_models/email_template_list_model.dart';

import '../../services/email_template_service.dart';

part 'email_template_event.dart';
part 'email_template_state.dart';

class EmailTemplateBloc extends Bloc<EmailTemplateEvent, EmailTemplateState> {
  final EmailTemplateService _service;

  EmailTemplateBloc({EmailTemplateService? service})
      : _service = service ?? EmailTemplateService(),
        super(EmailTemplateInitial()) {
    on<CreateEmailTemplateEvent>(_onCreate);
    on<UpdateEmailTemplateEvent>(_onUpdate);
    on<LoadAllEmailTemplatesEvent>(_onLoadAll);
    on<DeleteEmailTemplateEvent>(_onDelete);
  }

  Future<void> _onCreate(
      CreateEmailTemplateEvent event, Emitter<EmailTemplateState> emit) async {
    emit(EmailTemplateLoading());
    try {
      await _service.createEmailTemplate(
        apiKey: event.apiKey,
        template: event.template,
      );
      emit(EmailTemplateCreated());
    } catch (e) {
      emit(EmailTemplateError(e.toString()));
    }
  }

  Future<void> _onUpdate(
      UpdateEmailTemplateEvent event, Emitter<EmailTemplateState> emit) async {
    emit(EmailTemplateLoading());
    try {
      await _service.updateTemplate(
        apiKey: event.apiKey,
        template: event.template,
      );
      emit(EmailTemplateUpdated());
    } catch (e) {
      emit(EmailTemplateError(e.toString()));
    }
  }

  Future<void> _onLoadAll(LoadAllEmailTemplatesEvent event,
      Emitter<EmailTemplateState> emit) async {
    emit(EmailTemplateLoading());
    try {
      final templates = await _service.getAllTemplates(apiKey: event.apiKey);
      emit(EmailTemplatesLoaded(templates));
    } catch (e) {
      emit(EmailTemplateError(e.toString()));
    }
  }

  Future<void> _onDelete(DeleteEmailTemplateEvent event,
      Emitter<EmailTemplateState> emit) async {
    try {
      await _service.deleteTemplate(apiKey: event.apiKey, oid: event.oid);
      emit(EmailTemplateDeleted());
    } catch (e) {
      emit(EmailTemplateError(e.toString()));
    }
  }
}
