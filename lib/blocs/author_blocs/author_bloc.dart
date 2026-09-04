import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:service_desk/models/author_models/author_create_model.dart';

import '../../services/author_service.dart';

part 'author_event.dart';
part 'author_state.dart';

class AuthorBloc extends Bloc<AuthorEvent, AuthorState> {
  final AuthorService _service;

  AuthorBloc({AuthorService? service})
      : _service = service ?? AuthorService(),
        super(AuthorInitial()) {
    on<CreateAuthorEvent>(_onCreate);
    on<LoadAllAuthorsEvent>(_onLoadAll);
    on<ClearAuthorEvent>(_onClear);
  }

  Future<void> _onLoadAll(
      LoadAllAuthorsEvent event, Emitter<AuthorState> emit) async {
    emit(AuthorLoading());
    try {
      final authors = await _service.getAllAuthors(apiKey: event.apiKey);
      emit(AuthorsLoaded(authors));
    } catch (e) {
      emit(AuthorError(e.toString()));
    }
  }

  Future<void> _onCreate(
      CreateAuthorEvent event, Emitter<AuthorState> emit) async {
    emit(AuthorLoading());
    try {
      final now = DateTime.now();
      final author = AuthorCreateModel(
        name: event.name,
        email: event.email,
        platformId: event.platformId,
        dateCreated: now,
        dateModifire: now,
        phone: event.phoneNumber == null || event.phoneNumber!.isEmpty
            ? const []
            : [AuthorPhoneModel(number: event.phoneNumber, dataCreated: now)],
      );
      final created = await _service.createAuthor(
        apiKey: event.apiKey,
        author: author,
      );
      emit(AuthorCreated(created));
    } catch (e) {
      emit(AuthorError(e.toString()));
    }
  }

  Future<void> _onClear(
      ClearAuthorEvent event, Emitter<AuthorState> emit) async {
    emit(AuthorInitial());
  }
}
