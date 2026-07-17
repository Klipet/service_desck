import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:service_desk/models/users_models/user_model.dart';

import '../../const/const_colors.dart';
import '../../data_base/repository/dictionaries_repository.dart';
import '../../models/company_model.dart';
import '../../models/dictionary_item_model.dart';
import '../../models/tikets_models/tiket_response.dart';
import '../widgets/custom_dictionary_dropdown_widget.dart';
import '../widgets/rich_description_editor_widget.dart';

class TicketFormDetail extends StatefulWidget {
  final CompanyModel? searchCompany;
  final DictionariesRepository dictionariesRepo;
  final TicketResponse? ticketResponse;

  // Списки для дропдаунов, для которых нет DictionaryItem "из коробки"
  final List<PlatformModel> platforms;
  final List<UserModel> technicians;

  // Начальные значения (режим редактирования тикета)
  final PlatformModel? platform;
  final UserModel? userModel;
  final AuthorModel? authorModel;
  final DictionaryItem? category; // ASSUMPTION: класса "Category" нигде не было — использую DictionaryItem
  final SubCategory? subCategory;
//  final Role? role;

  // Левая колонка
  final ValueChanged<PlatformModel> onPlatformSelected;
  final ValueChanged<DictionaryItem> onGroupSelected;
  final ValueChanged<UserModel> onUserResponsable;
  final ValueChanged<String> onPhoneChanged;
  final ValueChanged<bool> onResultPhoneChanged;
  final ValueChanged<DateTime> onDataPhoneChanged;
  final ValueChanged<DateTime> onDateSecondPhoneChanged;
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
    required this.technicians,
    required this.onPlatformSelected,
    required this.onGroupSelected,
    required this.onUserResponsable,
    required this.onPhoneChanged,
    required this.onResultPhoneChanged,
    required this.onDataPhoneChanged,
    required this.onDateSecondPhoneChanged,
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
  List<Phone> _availablePhones = [];
  AuthorModel? _selectedAuthor;
  Phone? _selectedPhone;



  @override
  void initState() {
    super.initState();
    _loadTicket();

    // Сообщаем родителю "значения по умолчанию" из тикета —
    // после первого кадра, чтобы не словить setState-during-build.
    WidgetsBinding.instance.addPostFrameCallback((_) => _notifyInitialValues());
  }

  @override
  void didUpdateWidget(covariant TicketFormDetail oldWidget) {
    final ticket = widget.ticketResponse;
    if (ticket == null) return;
    super.didUpdateWidget(oldWidget);

    if (oldWidget.platforms != widget.platforms) {
      // ---- Platforma + Autor ----
      final platform = widget.platforms.firstWhereOrNull((p) => p.oid == ticket.platformId);
      if (platform != null) {
        _platformaDict = _platformToDict(platform);
        _availableAuthors = platform.autor;
        _selectedAuthor = _availableAuthors.firstWhereOrNull((a) => a.oid == ticket.authorId);
        if(_selectedAuthor != null){
          _selectedPhone = _selectedAuthor!.phone?.first;
        }

      }

    }
  }


  void _loadTicket() {
    final ticket = widget.ticketResponse;
    if (ticket == null) return;
    debugPrint('platforms count at initState: ${widget.platforms.length}');
    debugPrint('Company count at initState: ${widget.searchCompany}');

    // ---- Platforma + Autor ----
    final platform = widget.platforms.firstWhereOrNull((p) => p.oid == ticket.platformId);
    if (platform != null) {
      _platformaDict = _platformToDict(platform);
      _availableAuthors = platform.autor;
      _selectedAuthor = _availableAuthors.firstWhereOrNull((a) => a.oid == ticket.authorId);

      if (_selectedAuthor != null &&
          _selectedAuthor!.phone != null &&
          _selectedAuthor!.phone!.isNotEmpty) {
        print("Ном ${_selectedAuthor!.phone!.first}");
        _selectedPhone = _selectedAuthor!.phone!.first;
      }
    }

    // ---- Tehnician ----
    final user = widget.technicians.firstWhereOrNull((u) => u.id == ticket.userId);
    if (user != null) {
      _tehnicianDict = _userToDict(user);
    }

    // ---- Categorie + Subcategorie ----
    final category = widget.dictionariesRepo.tiketCategory
        .firstWhereOrNull((c) => c.oid == ticket.categoryId);
    if (category != null) {
      _categorie = category;
      _availableSubCategories =
          (category.subCetegory ?? []).whereType<SubCategory>().toList();
      final subCategory =
      _availableSubCategories.firstWhereOrNull((s) => s.oid == ticket.subCategoryId);
      if (subCategory != null) {
        _subcategorieDict = _subCategoryToDict(subCategory);
      }
    }

    // ---- Grupa ----
    _grupa = widget.dictionariesRepo.tiketWorkSpace
        .firstWhereOrNull((g) => g.oid == ticket.workSpaceId);

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

    final platform = widget.platforms.firstWhereOrNull((p) => p.oid == ticket.platformId);
    if (platform != null) widget.onPlatformSelected(platform);

    final user = widget.technicians.firstWhereOrNull((u) => u.id == ticket.userId);
    if (user != null) widget.onUserResponsable(user);

    if (_categorie != null) widget.onCategorySelected(_categorie!);

    final subCategory =
    _availableSubCategories.firstWhereOrNull((s) => s.oid == ticket.subCategoryId);
    if (subCategory != null) widget.onSubCategorySelected(subCategory);

    if (_grupa != null) widget.onGroupSelected(_grupa!);

    if (_selectedAuthor != null) {
      widget.onAuthorChanged?.call(_selectedAuthor!);
    }

    if (ticket.phone != null && ticket.phone!.isNotEmpty) {
      widget.onPhoneChanged(ticket.phone!);
    }
    widget.onResultPhoneChanged(ticket.resaultPhone);
    widget.onDataPhoneChanged(ticket.dataPhone);
    widget.onDateSecondPhoneChanged(ticket.dateSecondPhone);
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

  DictionaryItem _userToDict(UserModel u) => DictionaryItem(
    oid: u.id,
    name: u.name,
    active: true,
  );

   DictionaryItem _phoneToDict(Phone u) => DictionaryItem(
     oid: u.oid ?? 0,
     name: u.number?? '',
     active: true,
   );

  DictionaryItem _subCategoryToDict(SubCategory s) => DictionaryItem(
    oid: s.oid,
    name: s.name,
    active: s.active,
    dateCreated: s.dateCreated,
    dateModifire: s.dateModifire,
  );
  DictionaryItem _authorToDict(AuthorModel a) => DictionaryItem(
    oid: a.oid,
    name: a.name,
    active: a.active,
    dateCreated: a.dateCreated,
    dateModifire: a.dateModifire,
  );

   /// Применяет выбранного автора и заполняет поле телефона
   void _applySelectedAuthor(AuthorModel author) {
     setState(() {
       _selectedAuthor = author;
       _availablePhones = author.phone ?? [];
       // Автоматически выбираем первый телефон
       if (_availablePhones.isNotEmpty) {
         _selectedPhone = _availablePhones.first;
         _phoneController.text = _selectedPhone!.number ?? '';
       }
     });

     if (_selectedPhone?.number != null && _selectedPhone!.number!.isNotEmpty) {
       widget.onPhoneChanged(_selectedPhone!.number!);
     }

     widget.onAuthorChanged?.call(author);
   }


  @override
  Widget build(BuildContext context) {
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
        // ---- Platforma ----
        CustomDictionaryDropdown(
          hintText: 'Platforma',
          icon: Icons.dns_outlined,
          items: widget.platforms.map(_platformToDict).toList(),
          initialValue: _platformaDict,
          onSelected: (item) {
            final platform =
            widget.platforms.firstWhereOrNull((p) => p.oid == item.oid);
            setState(() {
              _platformaDict = item;
              _availableAuthors = platform?.autor ?? [];
              _selectedAuthor = null;
            });
            if (platform != null) widget.onPlatformSelected(platform);

            // Сбрасываем предыдущего автора явно — иначе снаружи останется
            // "прилипший" authorId от прошлой платформы (баг, если у новой
            // платформы 0 или несколько контактов и юзер ничего не выбрал).
          //  widget.onAuthorChanged?.call(null);

            // Если у платформы ровно один контакт — берём его автоматически.
            if (_availableAuthors.length == 1) {
              _applySelectedAuthor(_availableAuthors.first);
            }
          },
        ),
        SizedBox(height: 10.h),

          CustomDictionaryDropdown(
            key: ValueKey('autor_${_platformaDict?.oid}'),
            hintText: 'Contact / Autor',
            icon: Icons.person_pin_circle_outlined,
            items: _availableAuthors.map(_authorToDict).toList(),
            initialValue:
            _selectedAuthor != null ? _authorToDict(_selectedAuthor!) : null,
            onSelected: (item) {
              final author =
              _availableAuthors.firstWhereOrNull((a) => a.oid == item.oid);
              if (author != null) _applySelectedAuthor(author);
            },
          ),
        SizedBox(height: 10.h),
        // ---- Grupa ----
        CustomDictionaryDropdown(
          hintText: 'Grupa',
          icon: Icons.groups_outlined,
          items: widget.dictionariesRepo.tiketWorkSpace,
          initialValue: _grupa,
          onSelected: (item) {
            setState(() => _grupa = item);
            widget.onGroupSelected(item);
          },
        ),
        SizedBox(height: 10.h),

        // ---- Tehnician responsabil ----
        CustomDictionaryDropdown(
          hintText: 'Tehnician responsabil',
          icon: Icons.person_outline,
          items: widget.technicians.map(_userToDict).toList(),
          initialValue: _tehnicianDict,
          onSelected: (item) {
            final user =
            widget.technicians.firstWhereOrNull((u) => u.id == item.oid);
            setState(() => _tehnicianDict = item);
            if (user != null) widget.onUserResponsable(user);
          },
        ),
        SizedBox(height: 6.h),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: CustomDictionaryDropdown(
                hintText: 'Phone selected',
                icon: Icons.phone,
                items: (_selectedAuthor?.phone ?? []).map(_phoneToDict).toList(),
                initialValue:
                _selectedPhone != null ? _phoneToDict(_selectedPhone!) : null,
                onSelected: (item) {
                  final phone =
                  _availablePhones.firstWhereOrNull((a) => a.oid == item.oid);
                  if (phone != null) {
                    setState(() => _selectedPhone = phone);
                    _phoneController.text = phone.number ?? '';
                    widget.onPhoneChanged(phone.number ?? '');
                  }
                },
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: _YesNoField(
                hintText: 'Rezultatul contactării',
                value: _resultPhone,
                onChanged: (v) {
                  setState(() => _resultPhone = v);
                  widget.onResultPhoneChanged(v);
                },
              ),
            ),
          ],
        ),
        SizedBox(height: 10.h),

        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _DateField(
                hintText: 'Data și ora contactării',
                value: _dataContactarii,
                onPick: (date) {
                  setState(() => _dataContactarii = date);
                  widget.onDataPhoneChanged(date);
                },
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: _DateField(
                hintText: 'Recontactare programată',
                value: _recontactareProgramata,
                onPick: (date) {
                  setState(() => _recontactareProgramata = date);
                  widget.onDateSecondPhoneChanged(date);
                },
              ),
            ),
          ],
        ),
        SizedBox(height: 10.h),

        // ---- Categorie solicitare ----
        CustomDictionaryDropdown(
          hintText: 'Categorie solicitare',
          icon: Icons.category_outlined,
          items: widget.dictionariesRepo.tiketCategory,
          initialValue: _categorie,
          onSelected: (item) {
            setState(() {
              _categorie = item;
              _availableSubCategories =
                  (item.subCetegory ?? []).whereType<SubCategory>().toList();
              _subcategorieDict = null; // сброс подкатегории при смене категории
            });
            widget.onCategorySelected(item);
          },
        ),
        SizedBox(height: 10.h),

        // ---- Subcategorie solicitare ----
        // key меняется вместе с категорией — гарантированно пересобирает
        // внутреннее состояние дропдауна (иначе старый текст может остаться).
        CustomDictionaryDropdown(
          key: ValueKey('subcategorie_${_categorie?.oid}'),
          hintText: _availableSubCategories.isEmpty
              ? 'Alegeți mai întâi categoria'
              : 'Subcategorie solicitare',
          icon: Icons.list_alt_outlined,
          items: _availableSubCategories.map(_subCategoryToDict).toList(),
          initialValue: _subcategorieDict,
          onSelected: (item) {
            final subCategory = _availableSubCategories
                .firstWhereOrNull((s) => s.oid == item.oid);
            setState(() => _subcategorieDict = item);
            if (subCategory != null) widget.onSubCategorySelected(subCategory);
          },
        ),
        SizedBox(height: 10.h),

        _YesNoField(
          hintText: 'Înregistrat în bug-tracker',
          value: _bugTransfer,
          onChanged: (v) {
            setState(() => _bugTransfer = v);
            widget.onBugTransferChanged(v);
          },
        ),
        SizedBox(height: 14.h),

        _FieldLabel('ID/numărul bug-ului din bug-tracker'),
        SizedBox(height: 6.h),
        _BorderedTextField(
          controller: _bugIdController,
          onChanged: widget.onBugNumberChanged,
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
          initialDeltaJson: _descriptionController.text, // если редактируете существующую запись
          onDeltaChanged: widget.onDescriptionChanged,       // сохраняйте эту JSON-строку в БД
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
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: AppColors.backgroundCardColor,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: AppColors.textTitleFl, width: 1),
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
              color: Colors.grey.shade500,
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
                  color: value == null ? AppColors.textColorOne : Colors.black87,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(Icons.expand_more, size: 20.sp, color: AppColors.hintTextColor),
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

        onPick(DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime?.hour ?? 0,
          pickedTime?.minute ?? 0,
        ));
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
                  color: value != null ? Colors.black87 : AppColors.textColorOne,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(Icons.calendar_today_outlined, size: 18.sp, color: AppColors.hintTextColor),
          ],
        ),
      ),
    );
  }
}