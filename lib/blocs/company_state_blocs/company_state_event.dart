part of 'company_state_bloc.dart';

@immutable
abstract class CompanyStateEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class CreateCompanyStateEvent extends CompanyStateEvent {
  final String apiKey;
  final String name;

  CreateCompanyStateEvent({required this.apiKey, required this.name});

  @override
  List<Object?> get props => [apiKey, name];
}

class LoadAllCompanyStatesEvent extends CompanyStateEvent {
  final String apiKey;
  LoadAllCompanyStatesEvent(this.apiKey);

  @override
  List<Object?> get props => [apiKey];
}

class UpdateCompanyStateEvent extends CompanyStateEvent {
  final String apiKey;
  final SimpleDictionaryModel companyState;

  UpdateCompanyStateEvent({required this.apiKey, required this.companyState});

  @override
  List<Object?> get props => [apiKey, companyState];
}
