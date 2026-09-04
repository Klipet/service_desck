part of 'category_bloc.dart';

@immutable
abstract class CategoryState extends Equatable {
  @override
  List<Object?> get props => [];
}

class CategoryInitial extends CategoryState {}

class CategoryLoading extends CategoryState {}

class CategoryCreated extends CategoryState {
  final SimpleDictionaryModel category;
  CategoryCreated(this.category);

  @override
  List<Object?> get props => [category];
}

class CategoriesLoaded extends CategoryState {
  final List<SimpleDictionaryModel> categories;
  CategoriesLoaded(this.categories);

  @override
  List<Object?> get props => [categories];
}

class CategoryUpdated extends CategoryState {
  final SimpleDictionaryModel category;
  CategoryUpdated(this.category);

  @override
  List<Object?> get props => [category];
}

class CategoryError extends CategoryState {
  final String message;
  CategoryError(this.message);

  @override
  List<Object?> get props => [message];
}
