import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:service_desk/models/subcategory_models/subcategory_create_model.dart';

import '../../services/subcategory_service.dart';

part 'subcategory_event.dart';
part 'subcategory_state.dart';

class SubCategoryBloc extends Bloc<SubCategoryEvent, SubCategoryState> {
  final SubCategoryService _service;

  SubCategoryBloc({SubCategoryService? service})
      : _service = service ?? SubCategoryService(),
        super(SubCategoryInitial()) {
    on<CreateSubCategoryEvent>(_onCreate);
    on<LoadAllSubCategoriesEvent>(_onLoadAll);
    on<UpdateSubCategoryEvent>(_onUpdate);
  }

  Future<void> _onCreate(
      CreateSubCategoryEvent event, Emitter<SubCategoryState> emit) async {
    emit(SubCategoryLoading());
    try {
      final created = await _service.createSubCategory(
        apiKey: event.apiKey,
        name: event.name,
        categoryOid: event.categoryOid,
      );
      emit(SubCategoryCreated(created));
    } catch (e) {
      emit(SubCategoryError(e.toString()));
    }
  }

  Future<void> _onLoadAll(
      LoadAllSubCategoriesEvent event, Emitter<SubCategoryState> emit) async {
    emit(SubCategoryLoading());
    try {
      final items = await _service.getAllSubCategories(apiKey: event.apiKey);
      emit(SubCategoriesLoaded(items));
    } catch (e) {
      emit(SubCategoryError(e.toString()));
    }
  }

  Future<void> _onUpdate(
      UpdateSubCategoryEvent event, Emitter<SubCategoryState> emit) async {
    emit(SubCategoryLoading());
    try {
      final updated = await _service.updateSubCategory(
        apiKey: event.apiKey,
        subCategory: event.subCategory,
      );
      emit(SubCategoryUpdated(updated));
    } catch (e) {
      emit(SubCategoryError(e.toString()));
    }
  }
}
