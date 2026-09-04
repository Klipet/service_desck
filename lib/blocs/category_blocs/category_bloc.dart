import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:service_desk/models/dictionary_models/simple_dictionary_model.dart';

import '../../services/category_service.dart';

part 'category_event.dart';
part 'category_state.dart';

class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  final CategoryService _service;

  CategoryBloc({CategoryService? service})
      : _service = service ?? CategoryService(),
        super(CategoryInitial()) {
    on<CreateCategoryEvent>(_onCreate);
    on<LoadAllCategoriesEvent>(_onLoadAll);
    on<UpdateCategoryEvent>(_onUpdate);
  }

  Future<void> _onUpdate(
      UpdateCategoryEvent event, Emitter<CategoryState> emit) async {
    emit(CategoryLoading());
    try {
      final updated = await _service.updateCategory(
        apiKey: event.apiKey,
        category: event.category,
      );
      emit(CategoryUpdated(updated));
    } catch (e) {
      emit(CategoryError(e.toString()));
    }
  }

  Future<void> _onCreate(
      CreateCategoryEvent event, Emitter<CategoryState> emit) async {
    emit(CategoryLoading());
    try {
      final created = await _service.createCategory(
        apiKey: event.apiKey,
        name: event.name,
      );
      emit(CategoryCreated(created));
    } catch (e) {
      emit(CategoryError(e.toString()));
    }
  }

  Future<void> _onLoadAll(
      LoadAllCategoriesEvent event, Emitter<CategoryState> emit) async {
    emit(CategoryLoading());
    try {
      final categories = await _service.getAllCategories(apiKey: event.apiKey);
      emit(CategoriesLoaded(categories));
    } catch (e) {
      emit(CategoryError(e.toString()));
    }
  }
}
