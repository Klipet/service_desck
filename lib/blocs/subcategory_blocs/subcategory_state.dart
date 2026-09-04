part of 'subcategory_bloc.dart';

@immutable
abstract class SubCategoryState extends Equatable {
  @override
  List<Object?> get props => [];
}

class SubCategoryInitial extends SubCategoryState {}

class SubCategoryLoading extends SubCategoryState {}

class SubCategoryCreated extends SubCategoryState {
  final SubCategoryCreateModel subCategory;
  SubCategoryCreated(this.subCategory);

  @override
  List<Object?> get props => [subCategory];
}

class SubCategoriesLoaded extends SubCategoryState {
  final List<SubCategoryCreateModel> subCategories;
  SubCategoriesLoaded(this.subCategories);

  @override
  List<Object?> get props => [subCategories];
}

class SubCategoryUpdated extends SubCategoryState {
  final SubCategoryCreateModel subCategory;
  SubCategoryUpdated(this.subCategory);

  @override
  List<Object?> get props => [subCategory];
}

class SubCategoryError extends SubCategoryState {
  final String message;
  SubCategoryError(this.message);

  @override
  List<Object?> get props => [message];
}
