import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:service_desk/const/const_colors.dart';
import 'package:service_desk/data_base/user_repository.dart';
import 'package:service_desk/models/dictionary_models/simple_dictionary_model.dart';
import 'package:service_desk/models/subcategory_models/subcategory_create_model.dart';
import 'package:service_desk/screens/widgets/bordered_form_field.dart';
import 'package:service_desk/screens/widgets/custom_dictionary_dropdown_widget.dart';

import '../../../blocs/category_blocs/category_bloc.dart';
import '../../../blocs/subcategory_blocs/subcategory_bloc.dart';
import 'widgets/simple_create_form.dart';
import 'widgets/simple_editable_list.dart';

/// Категории и подкатегории объединены на одной вкладке в едином стиле —
/// подкатегория без категории не имеет смысла, поэтому им проще жить рядом.
class CategoryCreateTab extends StatelessWidget {
  const CategoryCreateTab({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => CategoryBloc()),
        BlocProvider(create: (_) => SubCategoryBloc()),
      ],
      child: const _CategorySubCategoryTabBody(),
    );
  }
}

class _CategorySubCategoryTabBody extends StatefulWidget {
  const _CategorySubCategoryTabBody();

  @override
  State<_CategorySubCategoryTabBody> createState() =>
      _CategorySubCategoryTabBodyState();
}

class _CategorySubCategoryTabBodyState
    extends State<_CategorySubCategoryTabBody> {
  final _userRepo = UserRepository();
  String _apiKey = '';

  final _categoryFormKey = GlobalKey<FormState>();
  final _categoryNameController = TextEditingController();
  bool _categorySaving = false;
  bool _categoriesLoading = true;
  List<SimpleDictionaryModel> _categories = [];

  final _subCategoryFormKey = GlobalKey<FormState>();
  final _subCategoryNameController = TextEditingController();
  bool _subCategorySaving = false;
  bool _subCategoriesLoading = true;
  List<SubCategoryCreateModel> _subCategories = [];
  int? _selectedCategoryOid;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final apiKey = await _userRepo.getUserApikey();
    if (!mounted) return;
    setState(() => _apiKey = apiKey ?? '');
    _loadCategories();
    _loadSubCategories();
  }

  void _loadCategories() {
    setState(() => _categoriesLoading = true);
    context.read<CategoryBloc>().add(LoadAllCategoriesEvent(_apiKey));
  }

  void _loadSubCategories() {
    setState(() => _subCategoriesLoading = true);
    context.read<SubCategoryBloc>().add(LoadAllSubCategoriesEvent(_apiKey));
  }

  @override
  void dispose() {
    _categoryNameController.dispose();
    _subCategoryNameController.dispose();
    super.dispose();
  }

  void _submitCategory() {
    if (!_categoryFormKey.currentState!.validate()) return;
    setState(() => _categorySaving = true);
    context.read<CategoryBloc>().add(
      CreateCategoryEvent(apiKey: _apiKey, name: _categoryNameController.text.trim()),
    );
  }

  Future<void> _editCategory(SimpleDictionaryModel item) async {
    final newName = await showRenameDialog(
      context,
      title: 'Редактирование категории',
      initialName: item.name,
    );
    if (newName == null || !mounted) return;
    context.read<CategoryBloc>().add(
      UpdateCategoryEvent(
        apiKey: _apiKey,
        category: SimpleDictionaryModel(
          oid: item.oid,
          name: newName,
          active: item.active,
          dateCreated: item.dateCreated,
          dateModifire: DateTime.now(),
        ),
      ),
    );
  }

  void _submitSubCategory() {
    if (!_subCategoryFormKey.currentState!.validate()) return;
    if (_selectedCategoryOid == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Выберите категорию')));
      return;
    }
    setState(() => _subCategorySaving = true);
    context.read<SubCategoryBloc>().add(
      CreateSubCategoryEvent(
        apiKey: _apiKey,
        name: _subCategoryNameController.text.trim(),
        categoryOid: _selectedCategoryOid!,
      ),
    );
  }

  String _categoryNameFor(int categoryOid) {
    final match = _categories.where((c) => c.oid == categoryOid);
    return match.isEmpty ? '—' : match.first.name;
  }

  Future<void> _editSubCategory(SubCategoryCreateModel item) async {
    final nameController = TextEditingController(text: item.name);
    var selectedOid = item.categoryOid;

    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
          title: Text('Редактирование подкатегории',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
          content: SizedBox(
            width: 340.w,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                BorderedFieldLabel('Название'),
                BorderedFormField(
                  controller: nameController,
                  hint: 'Название',
                  autofocus: true,
                ),
                SizedBox(height: 12.h),
                BorderedFieldLabel('Категория'),
                CustomDictionaryDropdown(
                  hintText: 'Категория',
                  icon: Icons.folder_outlined,
                  items: _categories.map((c) => c.toDictionaryItem()).toList(),
                  initialValue: _categories
                      .where((c) => c.oid == selectedOid)
                      .map((c) => c.toDictionaryItem())
                      .firstOrNull,
                  onSelected: (item) => setDialogState(() => selectedOid = item.oid),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Отмена')),
            TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Сохранить')),
          ],
        ),
      ),
    );

    if (saved != true || !mounted) return;
    final newName = nameController.text.trim();
    if (newName.isEmpty) return;

    context.read<SubCategoryBloc>().add(
      UpdateSubCategoryEvent(
        apiKey: _apiKey,
        subCategory: SubCategoryCreateModel(
          oid: item.oid,
          name: newName,
          active: item.active,
          categoryOid: selectedOid,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<CategoryBloc, CategoryState>(
          listener: (context, state) {
            if (state is CategoryCreated) {
              setState(() => _categorySaving = false);
              _categoryNameController.clear();
              ScaffoldMessenger.of(context)
                  .showSnackBar(const SnackBar(content: Text('Категория создана')));
              _loadCategories();
            } else if (state is CategoryUpdated) {
              ScaffoldMessenger.of(context)
                  .showSnackBar(const SnackBar(content: Text('Изменения сохранены')));
              _loadCategories();
            } else if (state is CategoriesLoaded) {
              setState(() {
                _categories = state.categories;
                _categoriesLoading = false;
                _selectedCategoryOid ??=
                    state.categories.isNotEmpty ? state.categories.first.oid : null;
              });
            } else if (state is CategoryError) {
              setState(() {
                _categorySaving = false;
                _categoriesLoading = false;
              });
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text('Ошибка: ${state.message}')));
            }
          },
        ),
        BlocListener<SubCategoryBloc, SubCategoryState>(
          listener: (context, state) {
            if (state is SubCategoryCreated) {
              setState(() => _subCategorySaving = false);
              _subCategoryNameController.clear();
              ScaffoldMessenger.of(context)
                  .showSnackBar(const SnackBar(content: Text('Подкатегория создана')));
              _loadSubCategories();
            } else if (state is SubCategoryUpdated) {
              ScaffoldMessenger.of(context)
                  .showSnackBar(const SnackBar(content: Text('Изменения сохранены')));
              _loadSubCategories();
            } else if (state is SubCategoriesLoaded) {
              setState(() {
                _subCategories = state.subCategories;
                _subCategoriesLoading = false;
              });
            } else if (state is SubCategoryError) {
              setState(() {
                _subCategorySaving = false;
                _subCategoriesLoading = false;
              });
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text('Ошибка: ${state.message}')));
            }
          },
        ),
      ],
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SimpleCreateForm(
                  title: 'Новая категория',
                  fieldLabel: 'Название',
                  formKey: _categoryFormKey,
                  controller: _categoryNameController,
                  saving: _categorySaving,
                  onSubmit: _submitCategory,
                ),
                SizedBox(height: 16.h),
                Expanded(
                  child: SimpleEditableList(
                    items: _categories,
                    loading: _categoriesLoading,
                    onRefresh: _loadCategories,
                    onEdit: _editCategory,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SimpleCreateForm(
                  title: 'Новая подкатегория',
                  fieldLabel: 'Название',
                  formKey: _subCategoryFormKey,
                  controller: _subCategoryNameController,
                  saving: _subCategorySaving,
                  onSubmit: _submitSubCategory,
                  extraFields: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        BorderedFieldLabel('Категория'),
                        CustomDictionaryDropdown(
                          hintText: 'Категория',
                          icon: Icons.folder_outlined,
                          items: _categories.map((c) => c.toDictionaryItem()).toList(),
                          initialValue: _categories
                              .where((c) => c.oid == _selectedCategoryOid)
                              .map((c) => c.toDictionaryItem())
                              .firstOrNull,
                          onSelected: (item) =>
                              setState(() => _selectedCategoryOid = item.oid),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: AppColors.backgroundColor,
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(color: AppColors.borderCardColor, width: 1.w),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Существующие записи',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                                fontSize: 13.sp,
                                color: AppColors.textColorOne,
                              ),
                            ),
                            const Spacer(),
                            IconButton(
                              onPressed: _subCategoriesLoading ? null : _loadSubCategories,
                              icon: const Icon(Icons.refresh, size: 18),
                            ),
                          ],
                        ),
                        SizedBox(height: 8.h),
                        Expanded(
                          child: _subCategoriesLoading
                              ? const Center(child: CircularProgressIndicator())
                              : _subCategories.isEmpty
                                  ? const Center(child: Text('Список пуст'))
                                  : ListView.separated(
                                      itemCount: _subCategories.length,
                                      separatorBuilder: (_, __) =>
                                          Divider(height: 1, color: AppColors.borderCardColor),
                                      itemBuilder: (_, i) {
                                        final item = _subCategories[i];
                                        return ListTile(
                                          dense: true,
                                          title: Text(item.name,
                                              style: GoogleFonts.poppins(fontSize: 13.sp)),
                                          subtitle: Text(
                                            _categoryNameFor(item.categoryOid),
                                            style: GoogleFonts.poppins(
                                                fontSize: 11.sp, color: AppColors.hintTextColor),
                                          ),
                                          trailing: IconButton(
                                            icon: const Icon(Icons.edit_outlined, size: 18),
                                            onPressed: () => _editSubCategory(item),
                                          ),
                                        );
                                      },
                                    ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
