part of 'category_bloc.dart';

@immutable
abstract class CategoryEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class CreateCategoryEvent extends CategoryEvent {
  final String apiKey;
  final String name;

  CreateCategoryEvent({required this.apiKey, required this.name});

  @override
  List<Object?> get props => [apiKey, name];
}

class LoadAllCategoriesEvent extends CategoryEvent {
  final String apiKey;
  LoadAllCategoriesEvent(this.apiKey);

  @override
  List<Object?> get props => [apiKey];
}

class UpdateCategoryEvent extends CategoryEvent {
  final String apiKey;
  final SimpleDictionaryModel category;

  UpdateCategoryEvent({required this.apiKey, required this.category});

  @override
  List<Object?> get props => [apiKey, category];
}
