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
