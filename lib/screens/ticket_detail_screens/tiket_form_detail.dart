import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:service_desk/models/dictionaries_items/work_space_item.dart';
import 'package:service_desk/models/users_models/user_model.dart';
import 'package:service_desk/screens/ticket_detail_screens/phone_records_section.dart';

import '../../const/const_colors.dart';
import '../../data_base/repository/dictionaries_repository.dart';
import '../../models/company_model.dart';
import '../../models/dictionaries_items/catigory_item.dart';
import '../../models/dictionaries_items/dictionary_item_model.dart';
import '../../models/tikets_models/tiket_phone_model.dart';
import '../../models/tikets_models/tiket_response.dart';
import '../widgets/custom_dictionary_dropdown_widget.dart';
import '../widgets/rich_description_editor_widget.dart';
import '../widgets/yes_no_field.dart';

class TicketFormDetail extends StatefulWidget {
  final CompanyModel? searchCompany;
  final DictionariesRepository dictionariesRepo;
  final TicketResponse? ticketResponse;
  final List<TicketPhoneModel> phones;

  // Списки для дропдаунов, для которых нет DictionaryItem "из коробки"
  final List<PlatformModel> platforms;

  //  final UserModel technicians;

  // Начальные значения (режим редактирования тикета)
  final PlatformModel? platform;
  final UserModel? userModel;
  final AuthorModel? authorModel;
  final DictionaryItem?
  category; // ASSUMPTION: класса "Category" нигде не было — использую DictionaryItem
  final SubCategory? subCategory;

  //  final Role? role;

  // Левая колонка
  final ValueChanged<PlatformModel> onPlatformSelected;
  final ValueChanged<DictionaryItem> onGroupSelected;
  final ValueChanged<UserItem> onUserResponsable;
  final ValueChanged<List<TicketPhoneModel>> onPhonesChanged;
  final ValueChanged<DictionaryItem> onCategorySelected;
  final ValueChanged<SubCategory> onSubCategorySelected;
  final ValueChanged<bool> onBugTransferChanged;
  final ValueChanged<String> onBugNumberChanged;
  final ValueChanged<AuthorModel>? onAuthorChanged;

  // Правая колонка
  final ValueChanged<String> onTitleChanged;
  final ValueChanged<String> onDescriptionChanged;

  const TicketFormDetail({
    super.key,
    required this.searchCompany,
    required this.dictionariesRepo,
    required this.platforms,
    //  required this.technicians,
    required this.onPlatformSelected,
    required this.onGroupSelected,
    required this.onUserResponsable,
    required this.onCategorySelected,
    required this.onSubCategorySelected,
    required this.onBugTransferChanged,
    required this.onBugNumberChanged,
    required this.onTitleChanged,
    required this.onDescriptionChanged,
    this.platform,
    this.userModel,
    this.authorModel,
    this.category,
    this.subCategory,
    this.onAuthorChanged,
    this.ticketResponse,
    required this.phones,
    required this.onPhonesChanged,
    //  this.role,
  });

  @override
  State<TicketFormDetail> createState() => _TicketFormState();
}

class _TicketFormState extends State<TicketFormDetail> {
  late TextEditingController _phoneController = TextEditingController();
  final _bugIdController = TextEditingController();
  final _subjectController = TextEditingController();
  final _descriptionController = TextEditingController();

  // Только для подсветки выбранного значения в дропдаунах (в виде DictionaryItem-обёртки).
  DictionaryItem? _platformaDict;
  DictionaryItem? _grupa;
  DictionaryItem? _tehnicianDict;
  DictionaryItem? _categorie;
  DictionaryItem? _subcategorieDict;

  bool? _resultPhone;
  bool? _bugTransfer;
  DateTime? _dataContactarii;
  DateTime? _recontactareProgramata;

  // Реальный список подкатегорий текущей выбранной категории.
  List<SubCategory> _availableSubCategories = [];
  List<AuthorModel> _availableAuthors = [];
  List<UserItem> _availableUsers = [];
  List<WorkSpaceItem> _availableGrupa = [];
  AuthorModel? _selectedAuthor;
  late List<TicketPhoneModel> _phoneRecords;

  @override
  void initState() {
    super.initState();
    _loadTicket();
    _phoneRecords = List.of(widget.phones);
    // Сообщаем родителю "значения по умолчанию" из тикета —
    // после первого кадра, чтобы не словить setState-during-build.
    WidgetsBinding.instance.addPostFrameCallback((_) => _notifyInitialValues());
  }

  @override
  void didUpdateWidget(covariant TicketFormDetail oldWidget) {
    super.didUpdateWidget(oldWidget);

    final ticket = widget.ticketResponse;
    if (ticket == null) return;

    final ticketChanged = oldWidget.ticketResponse != widget.ticketResponse;
    final platformsChanged = oldWidget.platforms != widget.platforms;
    //     final dictionariesJustLoaded =
    //         oldWidget.dictionariesRepo.tiketWorkSpace.isEmpty &&
    //             widget.dictionariesRepo.tiketWorkSpace.isNotEmpty;
    final categoriesJustLoaded =
        oldWidget.dictionariesRepo.tiketCategory.isEmpty &&
        widget.dictionariesRepo.tiketCategory.isNotEmpty;
    final typeJustLoaded =
        oldWidget.dictionariesRepo.tiketType.isEmpty &&
        widget.dictionariesRepo.tiketType.isNotEmpty;
    final stateJustLoaded =
        oldWidget.dictionariesRepo.tiketState.isEmpty &&
        widget.dictionariesRepo.tiketState.isNotEmpty;
    final preorityJustLoaded =
        oldWidget.dictionariesRepo.tiketPreority.isEmpty &&
        widget.dictionariesRepo.tiketPreority.isNotEmpty;
    final workPlaceJustLoaded =
        oldWidget.dictionariesRepo.tiketWorkSpace.isEmpty &&
        widget.dictionariesRepo.tiketWorkSpace.isNotEmpty;

    if (ticketChanged ||
        platformsChanged ||
        categoriesJustLoaded ||
        typeJustLoaded ||
        stateJustLoaded ||
        preorityJustLoaded ||
        workPlaceJustLoaded) {
      setState(() {
        _loadTicket();
      });
      // сообщаем родителю обновлённые значения ещё раз, раз данные подъехали позже
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _notifyInitialValues(),
      );
    }

    if (!listEquals(oldWidget.phones, widget.phones)) {
      _phoneRecords = List.of(widget.phones);
    }
  }

  void _notifyPhonesChanged() {
    widget.onPhonesChanged(List.unmodifiable(_phoneRecords));
  }

  void _addPhoneRecord() {
    final usedNumbers = _phoneRecords.map((e) => e.phone).toSet();
    final suggestedPhone = (_selectedAuthor?.phone ?? [])
        .map((p) => p.number)
        .firstWhereOrNull((n) => n != null && !usedNumbers.contains(n));

    setState(() {
      _phoneRecords = [
        ..._phoneRecords,
        TicketPhoneModel(
          ticketId: widget.ticketResponse?.id,
          phone: suggestedPhone,
          dataCreated: DateTime.now(),
          isActive: true,
        ),
      ];
    });
    _notifyPhonesChanged();
  }

  void _updatePhoneRecord(int index, TicketPhoneModel updated) {
    setState(() {
      _phoneRecords = List.of(_phoneRecords)..[index] = updated;
    });
    _notifyPhonesChanged();
  }

  void _removePhoneRecord(int index) {
    setState(() {
      _phoneRecords = List.of(_phoneRecords)..removeAt(index);
    });
    _notifyPhonesChanged();
  }

  void _loadTicket() {
    final ticket = widget.ticketResponse;
    if (ticket == null) return;

    // ---- Platforma + Autor ----
    final platform = widget.platforms.firstWhereOrNull(
      (p) => p.oid == ticket.platformId,
    );
    if (platform != null) {
      _platformaDict = _platformToDict(platform);
      _availableAuthors = platform.autor;
      _selectedAuthor = _availableAuthors.firstWhereOrNull(
        (a) => a.oid == ticket.authorId,
      );

      if (_selectedAuthor != null &&
          _selectedAuthor!.phone != null &&
          _selectedAuthor!.phone!.isNotEmpty) {}
    }

    // ---- Grupa (WorkSpace) + Tehnician ----
    final workSpace = widget.dictionariesRepo.tiketWorkSpace.firstWhereOrNull(
      (c) => c.oid == ticket.workSpaceId,
    );
    if (workSpace != null) {
      _grupa = _workSpaceToDict(workSpace);
      _availableUsers = (workSpace.users ?? []).whereType<UserItem>().toList();
      final selectedUser = _availableUsers.firstWhereOrNull(
        (u) => u.oid == ticket.userId,
      );
      if (selectedUser != null) {
        _tehnicianDict = _userToDict(selectedUser);
      }
    }

    // ---- Categorie + Subcategorie ----
    final category = widget.dictionariesRepo.tiketCategory.firstWhereOrNull(
      (c) => c.oid == ticket.categoryId,
    );
    if (category != null) {
      _categorie = _categoryToDict(category);
      _availableSubCategories = (category.subCategory ?? [])
          .whereType<SubCategory>()
          .toList();
      final subCategory = _availableSubCategories.firstWhereOrNull(
        (s) => s.oid == ticket.subCategoryId,
      );
      if (subCategory != null) {
        _subcategorieDict = _subCategoryToDict(subCategory);
      }
    }

    // ---- Простые поля ----
    _resultPhone = ticket.resaultPhone;
    _dataContactarii = ticket.dataPhone;
    _recontactareProgramata = ticket.dateSecondPhone;
    _bugTransfer = ticket.bugTransfer;
    _bugIdController.text = ticket.bugNumber ?? '';
    _subjectController.text = ticket.title ?? '';
    _descriptionController.text = ticket.description ?? '';
  }

  void _notifyInitialValues() {
    final ticket = widget.ticketResponse;
    if (ticket == null) return;

    final platform = widget.platforms.firstWhereOrNull(
      (p) => p.oid == ticket.platformId,
    );
    if (platform != null) widget.onPlatformSelected(platform);

    if (_categorie != null) widget.onCategorySelected(_categorie!);

    final subCategory = _availableSubCategories.firstWhereOrNull(
      (s) => s.oid == ticket.subCategoryId,
    );
    if (subCategory != null) widget.onSubCategorySelected(subCategory);

    if (_grupa != null) widget.onGroupSelected(_grupa!);

    // Раньше техник вообще не сообщался родителю при загрузке тикета — добавлено:
    if (_tehnicianDict != null) {
      final tech = _availableUsers.firstWhereOrNull(
        (u) => u.oid == _tehnicianDict!.oid,
      );
      if (tech != null) widget.onUserResponsable(tech);
    }

    if (_selectedAuthor != null) {
      widget.onAuthorChanged?.call(_selectedAuthor!);
    }

    widget.onBugTransferChanged(ticket.bugTransfer);
    if (ticket.bugNumber != null && ticket.bugNumber!.isNotEmpty) {
      widget.onBugNumberChanged(ticket.bugNumber!);
    }
    if (ticket.title != null && ticket.title!.isNotEmpty) {
      widget.onTitleChanged(ticket.title!);
    }
    if (ticket.description != null && ticket.description!.isNotEmpty) {
      widget.onDescriptionChanged(ticket.description!);
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _bugIdController.dispose();
    _subjectController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  DictionaryItem _platformToDict(PlatformModel p) => DictionaryItem(
    oid: p.oid,
    name: p.name,
    active: p.active,
    dateCreated: p.dateCreated,
    dateModifire: p.dateModifire,
  );

  DictionaryItem _userToDict(UserItem u) =>
      DictionaryItem(oid: u.oid, name: u.name, active: true);

  DictionaryItem _phoneToDict(Phone u) =>
      DictionaryItem(oid: u.oid ?? 0, name: u.number ?? '', active: true);

  DictionaryItem _subCategoryToDict(SubCategory s) => DictionaryItem(
    oid: s.oid,
    name: s.name,
    active: s.active,
    dateCreated: s.dateCreated,
    dateModifire: s.dateModifire,
  );

  DictionaryItem _categoryToDict(CategoryItem s) => DictionaryItem(
    oid: s.oid,
    name: s.name,
    active: s.active,
    dateCreated: s.dateCreated,
    //  dateModifire: s.dateModifire,
  );

  DictionaryItem _authorToDict(AuthorModel a) => DictionaryItem(
    oid: a.oid,
    name: a.name,
    active: a.active,
    dateCreated: a.dateCreated,
    dateModifire: a.dateModifire,
  );

  DictionaryItem _workSpaceToDict(WorkSpaceItem w) => DictionaryItem(
    oid: w.oid,
    name: w.name,
    active: w.active,
    dateCreated: w.dateCreated,
    dateModifire: DateTime.now(),
  );

  /// Применяет выбранного автора и заполняет поле телефона
  void _applySelectedAuthor(AuthorModel author) {
    setState(() {
      _selectedAuthor = author;
    });
    widget.onAuthorChanged?.call(author);
  }

  @override
  Widget build(BuildContext context) {
    print('${_availableSubCategories.length}');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: _buildLeftColumn()),
              SizedBox(width: 12.w),
              Expanded(child: _buildRightColumn()),
            ],
          ),
        ),
      ],
    );
  }

  // =========================== ЛЕВАЯ КОЛОНКА ===========================
  Widget _buildLeftColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 6.h),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ---- Левая под-колонка ----
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ---- Platforma ----
                  CustomDictionaryDropdown(
                    key: const ValueKey('platforma'),
                    hintText: 'Platforma',
                    icon: Icons.dns_outlined,
                    items: widget.platforms.map(_platformToDict).toList(),
                    initialValue: _platformaDict,
                    onSelected: (item) {
                      final platform = widget.platforms.firstWhereOrNull(
                        (p) => p.oid == item.oid,
                      );
                      setState(() {
                        _platformaDict = item;
                        _availableAuthors = platform?.autor ?? [];
                        _selectedAuthor = null;
                      });
                      if (platform != null) widget.onPlatformSelected(platform);
                      if (_availableAuthors.length == 1) {
                        _applySelectedAuthor(_availableAuthors.first);
                      }
                    },
                  ),
                  SizedBox(height: 10.h),

                  // ---- Contact / Autor ----
                  CustomDictionaryDropdown(
                    key: ValueKey('autor_${_platformaDict?.oid}'),
                    hintText: 'Contact / Autor',
                    icon: Icons.person_pin_circle_outlined,
                    items: _availableAuthors.map(_authorToDict).toList(),
                    initialValue: _selectedAuthor != null
                        ? _authorToDict(_selectedAuthor!)
                        : null,
                    onSelected: (item) {
                      final author = _availableAuthors.firstWhereOrNull(
                        (a) => a.oid == item.oid,
                      );
                      if (author != null) _applySelectedAuthor(author);
                    },
                  ),
                  SizedBox(height: 10.h),

                  // ---- Grupa ----
                  CustomDictionaryDropdown(
                    key: const ValueKey('grupa'),
                    hintText: 'Grupa',
                    icon: Icons.groups_outlined,
                    items: widget.dictionariesRepo.tiketWorkSpace
                        .map(_workSpaceToDict)
                        .toList(),
                    initialValue: _grupa,
                    onSelected: (item) {
                      final workSpace = widget.dictionariesRepo.tiketWorkSpace
                          .firstWhereOrNull((w) => w.oid == item.oid);
                      setState(() {
                        _grupa = item;
                        _availableUsers = (workSpace?.users ?? [])
                            .whereType<UserItem>()
                            .toList();
                        _tehnicianDict = null;
                      });
                      widget.onGroupSelected(item);
                    },
                  ),
                  SizedBox(height: 10.h),

                  // ---- Tehnician responsabil ----
                  CustomDictionaryDropdown(
                    key: ValueKey('user_${_grupa?.oid}'),
                    hintText: _availableUsers.isEmpty
                        ? 'Alegeți mai întâi Grupa'
                        : 'Tehnician responsabil',
                    icon: Icons.person_outline,
                    items: _availableUsers.map(_userToDict).toList(),
                    initialValue: _tehnicianDict,
                    onSelected: (item) {
                      final user = _availableUsers.firstWhereOrNull(
                        (u) => u.oid == item.oid,
                      );
                      setState(() => _tehnicianDict = item);
                      if (user != null) widget.onUserResponsable(user);
                    },
                  ),
                ],
              ),
            ),

            SizedBox(width: 12.w),

            // ---- Правая под-колонка ----
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ---- Categorie solicitare ----
                  CustomDictionaryDropdown(
                    key: const ValueKey('categorie'),
                    hintText: 'Categorie solicitare',
                    icon: Icons.category_outlined,
                    items: widget.dictionariesRepo.tiketCategory
                        .map(_categoryToDict)
                        .toList(),
                    initialValue: _categorie,
                    onSelected: (item) {
                      final categoryModel = widget
                          .dictionariesRepo
                          .tiketCategory
                          .firstWhereOrNull((cat) => cat.oid == item.oid);
                      setState(() {
                        _categorie = item;
                        _availableSubCategories =
                            (categoryModel?.subCategory ?? [])
                                .whereType<SubCategory>()
                                .toList();
                        _subcategorieDict = null;
                      });
                      if (categoryModel != null) {
                        widget.onCategorySelected(
                          _categoryToDict(categoryModel),
                        );
                      }
                    },
                  ),
                  SizedBox(height: 10.h),

                  // ---- Subcategorie solicitare ----
                  CustomDictionaryDropdown(
                    key: ValueKey('subcategorie_${_categorie?.oid}'),
                    hintText: _availableSubCategories.isEmpty
                        ? 'Alegeți mai întâi categoria'
                        : 'Subcategorie solicitare',
                    icon: Icons.list_alt_outlined,
                    items: _availableSubCategories
                        .map(_subCategoryToDict)
                        .toList(),
                    initialValue: _subcategorieDict,
                    onSelected: (item) {
                      final subCategory = _availableSubCategories
                          .firstWhereOrNull((s) => s.oid == item.oid);
                      setState(() => _subcategorieDict = item);
                      if (subCategory != null) {
                        widget.onSubCategorySelected(subCategory);
                      }
                    },
                  ),
                  SizedBox(height: 10.h),

                  YesNoField(
                    hintText: 'Înregistrat în bug-tracker',
                    value: _bugTransfer,
                    onChanged: (v) {
                      setState(() => _bugTransfer = v);
                      widget.onBugTransferChanged(v);
                    },
                  ),
                  SizedBox(height: 10.h),

                //  _FieldLabel('ID/numărul bug-ului din bug-tracker'),
                //  SizedBox(height: 6.h),
                  _BorderedTextField(
                    controller: _bugIdController,
                    onChanged: widget.onBugNumberChanged,
                    hint: 'ID/numărul bug-ului din bug-tracker',
                  ),
                ],
              ),
            ),
          ],
        ),

        SizedBox(height: 10.h),

        // ---- Телефоны — на всю ширину левой колонки ----
        PhoneRecordsSection(
          results: widget.dictionariesRepo.phoneResault,
          records: _phoneRecords,
          authorPhones: _selectedAuthor?.phone ?? [],
          onAdd: _addPhoneRecord,
          onChanged: _updatePhoneRecord,
          onRemove: _removePhoneRecord,
        ),
      ],
    );
  }

  // =========================== ПРАВАЯ КОЛОНКА ===========================

  Widget _buildRightColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        //  _FieldLabel('Subiectul solicitării'),
        SizedBox(height: 6.h),
        _BorderedTextField(
          hint: 'Subiectul solicitării',
          controller: _subjectController,
          onChanged: widget.onTitleChanged,
        ),
        SizedBox(height: 5.h),
        //  _FieldLabel('Descriere'),
        SizedBox(height: 6.h),
        RichDescriptionEditor(
          initialDeltaJson: _descriptionController.text,
          // если редактируете существующую запись
          onDeltaChanged:
              widget.onDescriptionChanged, // сохраняйте эту JSON-строку в БД
          //  onFilesChanged: (files) {
          // files — List<PlatformFile>, здесь грузите их на ваш S3Service
          //  },
        ),
        SizedBox(height: 6.h),
      ],
    );
  }
}

// =============================== ХЕЛПЕРЫ ===============================

class _FieldLabel extends StatelessWidget {
  final String text;

  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.poppins(
        fontSize: 12.sp,
        fontWeight: FontWeight.w500,
        color: Colors.black87,
      ),
    );
  }
}

class _BorderedTextField extends StatelessWidget {
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final int? maxLines;
  final bool expands;
  final String? hint;
  final TextAlignVertical? textAlignVertical;
  final ValueChanged<String>? onChanged;

  const _BorderedTextField({
    required this.controller,
    this.keyboardType,
    this.maxLines = 1,
    this.expands = false,
    this.textAlignVertical,
    this.hint,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(minHeight: 32.h),
      height: 32.h,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: AppColors.backgroundCardColor,
        borderRadius: BorderRadius.circular(100.r),
        border: Border.all(color: AppColors.textTitleFl, width: 1.w),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        expands: expands,
        textAlignVertical: textAlignVertical,
        onChanged: onChanged,
        style: GoogleFonts.poppins(fontSize: 14.sp, color: Colors.black87),
        decoration: InputDecoration(
          hint: Text(
            hint ?? '',
            style: GoogleFonts.poppins(
              fontSize: 13.sp,
              color: AppColors.textColorOne,
            ),
          ),
          isCollapsed: true,
          border: InputBorder.none,
        ),
      ),
    );
  }
}

class _YesNoField extends StatelessWidget {
  final String hintText;
  final bool? value;
  final ValueChanged<bool> onChanged;

  const _YesNoField({
    required this.hintText,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<bool>(
      onSelected: onChanged,
      offset: Offset(0, 36.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
      itemBuilder: (context) => [
        PopupMenuItem(
          value: true,
          child: Text('Da', style: GoogleFonts.poppins(fontSize: 13.sp)),
        ),
        PopupMenuItem(
          value: false,
          child: Text('Nu', style: GoogleFonts.poppins(fontSize: 13.sp)),
        ),
      ],
      child: Container(
        height: 32.h,
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        decoration: BoxDecoration(
          color: AppColors.backgroundCardColor,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: AppColors.textTitleFl, width: 1),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                value == null ? hintText : (value! ? 'Da' : 'Nu'),
                style: GoogleFonts.poppins(
                  fontSize: 13.sp,
                  color: value == null
                      ? AppColors.textColorOne
                      : Colors.black87,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(
              Icons.expand_more,
              size: 20.sp,
              color: AppColors.hintTextColor,
            ),
          ],
        ),
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  final String hintText;
  final DateTime? value;
  final ValueChanged<DateTime> onPick;

  const _DateField({
    required this.hintText,
    required this.value,
    required this.onPick,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final pickedDate = await showDatePicker(
          context: context,
          initialDate: value ?? DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime(2100),
        );
        if (pickedDate == null) return;

        final pickedTime = await showTimePicker(
          context: context,
          initialTime: value != null
              ? TimeOfDay(hour: value!.hour, minute: value!.minute)
              : TimeOfDay.now(),
        );

        onPick(
          DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime?.hour ?? 0,
            pickedTime?.minute ?? 0,
          ),
        );
      },
      child: Container(
        height: 32.h,
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        decoration: BoxDecoration(
          color: AppColors.backgroundCardColor,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: AppColors.textTitleFl, width: 1),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                value != null
                    ? DateFormat('dd.MM.yyyy HH:mm').format(value!)
                    : hintText,
                style: GoogleFonts.poppins(
                  fontSize: 13.sp,
                  color: value != null
                      ? Colors.black87
                      : AppColors.textColorOne,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(
              Icons.calendar_today_outlined,
              size: 18.sp,
              color: AppColors.hintTextColor,
            ),
          ],
        ),
      ),
    );
  }
}
