import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:service_desk/models/company_model.dart';

import '../../data_base/user_repository.dart';
import '../../services/company_service.dart';

part 'company_event.dart';
part 'company_state.dart';

class CompanyBloc extends Bloc<CompanyEvent, CompanyState> {
  final CompanyService _service;

  CompanyBloc({CompanyService? service}): _service = service ?? CompanyService(), super(CompanyInitial()) {
    on<FeatCompanyEvent>(_onFeat);
    on<SearchCompanyEvent>(_onSearch);
    on<ClearCompanyEvent>(_onClear);
    on<LoadAllCompaniesEvent>(_onLoadAll);
    on<LoadCompanyStatesEvent>(_onLoadStates);
    on<CreateCompanyEvent>(_onCreate);
    on<UpdateCompanyEvent>(_onUpdate);
  }

  Future<void> _onLoadAll(
      LoadAllCompaniesEvent event, Emitter<CompanyState> emit) async {
    emit(CompanyLoading());
    try {
      final companies = await _service.getAllCompanies(apiKey: event.apiKey);
      emit(CompanyLoaded(companies));
    } catch (e) {
      emit(CompanyError(e.toString()));
    }
  }

  Future<void> _onLoadStates(
      LoadCompanyStatesEvent event, Emitter<CompanyState> emit) async {
    try {
      final states = await _service.getCompanyStates(apiKey: event.apiKey);
      emit(CompanyStatesLoaded(states));
    } catch (e) {
      emit(CompanyError(e.toString()));
    }
  }

  Future<void> _onCreate(
      CreateCompanyEvent event, Emitter<CompanyState> emit) async {
    emit(CompanyLoading());
    try {
      final company = await _service.createCompany(
        apiKey: event.apiKey,
        name: event.name,
        companyStateOid: event.companyStateOid,
        idnp: event.idnp,
      );
      emit(CompanyCreated(company));
    } catch (e) {
      emit(CompanyError(e.toString()));
    }
  }

  Future<void> _onUpdate(
      UpdateCompanyEvent event, Emitter<CompanyState> emit) async {
    emit(CompanyLoading());
    try {
      final company = await _service.updateCompany(
        apiKey: event.apiKey,
        company: event.company,
      );
      emit(CompanyUpdated(company));
    } catch (e) {
      emit(CompanyError(e.toString()));
    }
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
