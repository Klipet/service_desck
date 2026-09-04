part of 'company_bloc.dart';

@immutable
abstract class CompanyEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FeatCompanyEvent extends CompanyEvent {}

class SearchCompanyEvent extends CompanyEvent {
  final String query;
  SearchCompanyEvent(this.query);

  @override
  List<Object?> get props => [query];
}

class ClearCompanyEvent extends CompanyEvent {}

class LoadAllCompaniesEvent extends CompanyEvent {
  final String apiKey;
  LoadAllCompaniesEvent(this.apiKey);

  @override
  List<Object?> get props => [apiKey];
}

class LoadCompanyStatesEvent extends CompanyEvent {
  final String apiKey;
  LoadCompanyStatesEvent(this.apiKey);

  @override
  List<Object?> get props => [apiKey];
}

class CreateCompanyEvent extends CompanyEvent {
  final String apiKey;
  final String name;
  final String? idnp;
  final int companyStateOid;

  CreateCompanyEvent({
    required this.apiKey,
    required this.name,
    required this.companyStateOid,
    this.idnp,
  });

  @override
  List<Object?> get props => [apiKey, name, idnp, companyStateOid];
}

class UpdateCompanyEvent extends CompanyEvent {
  final String apiKey;
  final CompanyModel company;

  UpdateCompanyEvent({required this.apiKey, required this.company});

  @override
  List<Object?> get props => [apiKey, company];
}
