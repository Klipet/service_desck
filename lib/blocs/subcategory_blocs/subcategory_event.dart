part of 'subcategory_bloc.dart';

@immutable
abstract class SubCategoryEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class CreateSubCategoryEvent extends SubCategoryEvent {
  final String apiKey;
  final String name;
  final int categoryOid;

  CreateSubCategoryEvent({
    required this.apiKey,
    required this.name,
    required this.categoryOid,
  });

  @override
  List<Object?> get props => [apiKey, name, categoryOid];
}

class LoadAllSubCategoriesEvent extends SubCategoryEvent {
  final String apiKey;
  LoadAllSubCategoriesEvent(this.apiKey);

  @override
  List<Object?> get props => [apiKey];
}

class UpdateSubCategoryEvent extends SubCategoryEvent {
  final String apiKey;
  final SubCategoryCreateModel subCategory;

  UpdateSubCategoryEvent({required this.apiKey, required this.subCategory});

  @override
  List<Object?> get props => [apiKey, subCategory];
}
