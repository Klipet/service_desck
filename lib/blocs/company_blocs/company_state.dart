part of 'company_bloc.dart';

@immutable
abstract class CompanyState extends Equatable {
  @override
  List<Object?> get props => [];
}

class CompanyInitial extends CompanyState {}

class CompanyLoading extends CompanyState {}

class CompanyLoaded extends CompanyState {
  final List<CompanyModel> companies;
   CompanyLoaded(this.companies);

  @override
  List<Object?> get props => [companies];
}

class CompanyError extends CompanyState {
  final String message;
  CompanyError(this.message);

  @override
  List<Object?> get props => [message];
}

class CompanyStatesLoaded extends CompanyState {
  final List<CompanyStateModel> states;
  CompanyStatesLoaded(this.states);

  @override
  List<Object?> get props => [states];
}

class CompanyCreated extends CompanyState {
  final CompanyModel company;
  CompanyCreated(this.company);

  @override
  List<Object?> get props => [company];
}

class CompanyUpdated extends CompanyState {
  final CompanyModel company;
  CompanyUpdated(this.company);

  @override
  List<Object?> get props => [company];
}
