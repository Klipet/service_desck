part of 'company_state_bloc.dart';

@immutable
abstract class CompanyStateState extends Equatable {
  @override
  List<Object?> get props => [];
}

class CompanyStateInitial extends CompanyStateState {}

class CompanyStateLoading extends CompanyStateState {}

class CompanyStateCreated extends CompanyStateState {
  final SimpleDictionaryModel companyState;
  CompanyStateCreated(this.companyState);

  @override
  List<Object?> get props => [companyState];
}

class CompanyStatesLoaded extends CompanyStateState {
  final List<SimpleDictionaryModel> companyStates;
  CompanyStatesLoaded(this.companyStates);

  @override
  List<Object?> get props => [companyStates];
}

class CompanyStateUpdated extends CompanyStateState {
  final SimpleDictionaryModel companyState;
  CompanyStateUpdated(this.companyState);

  @override
  List<Object?> get props => [companyState];
}

class CompanyStateError extends CompanyStateState {
  final String message;
  CompanyStateError(this.message);

  @override
  List<Object?> get props => [message];
}
