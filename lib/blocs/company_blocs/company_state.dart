part of 'company_bloc.dart';

@immutable
sealed class CompanyState {}

final class CompanyInitial extends CompanyState {}

final class CompanyLoaded extends CompanyState {
  final List<CompanyModel> company;
  CompanyLoaded(this.company);
}
final class CompanyLoading extends CompanyState{}

final class CompanyError extends CompanyState{
  final String message;
  CompanyError(this.message);
}

