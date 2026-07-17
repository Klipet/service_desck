import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:service_desk/models/company_model.dart';

import '../../data_base/user_repository.dart';
import '../../services/client_service.dart';
import '../../services/company_service.dart';

part 'company_event.dart';
part 'company_state.dart';

class CompanyBloc extends Bloc<CompanyEvent, CompanyState> {
  final CompanyService _service;

  CompanyBloc({CompanyService? service}): _service = service ?? CompanyService(), super(CompanyInitial()) {
    on<FeatCompanyEvent>(_onFeat);
    on<SearchCompanyEvent>(_onSearch);
    on<ClearCompanyEvent>(_onClear);
  }

  Future<void> _onFeat(
      FeatCompanyEvent event, Emitter<CompanyState> emit) async {
    // При инициализации — не грузим ничего, ждём ввода
    emit(CompanyInitial());
  }

  Future<void> _onSearch(
      SearchCompanyEvent event, Emitter<CompanyState> emit) async {
    if (event.query.trim().isEmpty) {
      emit(CompanyInitial());
      return;
    }
    emit(CompanyLoading());
    try {
      final userRepository = UserRepository();
      final savedUser = await userRepository.getUser();
      final apiKey = savedUser?.apiKey ?? '';
      final result = await _service.searchCompanies(query: event.query, apiKey: apiKey);
      emit(CompanyLoaded(result));
    } catch (e) {
      emit(CompanyError(e.toString()));
    }
  }

  Future<void> _onClear(
      ClearCompanyEvent event, Emitter<CompanyState> emit) async {
    emit(CompanyInitial());
  }
}
