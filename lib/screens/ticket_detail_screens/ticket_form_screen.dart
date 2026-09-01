import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:service_desk/const/const_colors.dart';
import 'package:service_desk/models/company_model.dart';
import 'package:service_desk/models/dictionaries_items/work_space_item.dart';
import 'package:service_desk/models/new_ticket_models/new_ticket_model_ui.dart';
import 'package:service_desk/screens/ticket_detail_screens/tiket_form_detail.dart';

import '../../data_base/repository/dictionaries_repository.dart';
import '../../models/dictionaries_items/dictionary_item_model.dart';
import '../../models/tikets_models/tiket_phone_model.dart';
import '../../models/tikets_models/tiket_post_model.dart';
import '../../models/tikets_models/tiket_response.dart';
import '../../models/users_models/user_model.dart';
import '../widgets/autocomplete_basic_company.dart';
import 'ticket_title_screen.dart';

class TicketFormScreen extends StatefulWidget {
  final TicketResponse? ticket; // null = пустая форма
  final void Function(TicketPostModel data)? onSubmit;
  final VoidCallback? onCancel;
  final List<TicketPhoneModel> phones;

  final DictionariesRepository dictionariesRepo;

//  final void Function(String name) searchCompany;

  const TicketFormScreen({
    super.key,
    this.ticket,
    this.onSubmit,
    this.onCancel,
//    required this.searchCompany,
    required this.dictionariesRepo,
    required this.phones,
  });

  @override
  State<TicketFormScreen> createState() => _TicketFormScreenState();
}

class _TicketFormScreenState extends State<TicketFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _data = NewTicketModelUI();
  final _dataPost = TicketPostModel();

  CompanyModel? _selectedCompany;
  bool get _isEditing => widget.ticket != null;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }


  void _handleSubmit() {
    final formValid = _formKey.currentState?.validate() ?? true;
    if (!formValid) return;

    // Минимальная проверка обязательных полей — дополните под свои правила.
    if (_selectedCompany == null) {
      _showValidationError('Selectați compania');
      return;
    }

    // Компания подтягивается сюда явно, так как AutocompleteBasicCompany
    // не сообщает своё значение напрямую в TicketFormDetail.
    _dataPost.companyId = _selectedCompany!.oid; // ПРОВЕРЬТЕ: поле companyId в CompanyModel
    _dataPost.id = widget.ticket?.id ?? 0;
    _dataPost.dataModefire = DateTime.now();
    if (!_isEditing) {
      _dataPost.dataCreted = DateTime.now();
    }

    widget.onSubmit?.call(_dataPost);
  }

  void _showValidationError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundCardColor,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.only(top: 14.h, left: 8.w),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(
                  child: Text(
                    'SOLICITARE NOUĂ',
                    style: GoogleFonts.poppins(
                      color: AppColors.hintTextColor,
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                      child: Center(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: 400.w),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // ── Autocomplete компании ──────────────────
                                AutocompleteBasicCompany(
                                  // Если редактирование — подставляем начальное значение
                                  initialValue: widget.ticket?.companyName, // раскомментировать когда будет поле
                                  onSelected: (company) {
                                    setState(() => _selectedCompany = company);
                                    // Дублируем в старый колбэк для обратной совместимости
                                  //  widget.searchCompany(company.name);
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                ),

              ],
            ),
          ),
          SizedBox(height: 5.h,),
          TicketTitleScreen(
            ticketResponse: widget.ticket,
            ticketType: widget.dictionariesRepo.tiketType,
            ticketState: widget.dictionariesRepo.tiketState,
            ticketPreority: widget.dictionariesRepo.tiketPreority,
            ticketMode: widget.dictionariesRepo.tiketMode, // передайте DictionariesResponse сюда
            onTypeSelected: (item) => setState(() => _dataPost.typeTiketId = item.oid),
            onStateSelected: (item) => setState(() => _dataPost.stateId = item.oid),
            onPriorSelected: (item) => setState(() => _dataPost.preorityId = item.oid),
            onModeSelected: (item) => setState(() => _dataPost.modeId = item.oid),
          ),
          Container(height: 5.h, color: AppColors.backgroundColor,),
          Expanded(
            child: Container(
              width: double.maxFinite,
              color: AppColors.backgroundColor,
              padding: EdgeInsets.only(left: 16.w, right: 16.w,),
              child:
             // SingleChildScrollView(
               // child:
                TicketFormDetail(
                  // Получаем из Widget
                  onPlatformSelected: (item) => _dataPost.platformId = item.oid,
                  onGroupSelected: (item) => _dataPost.workSpaceId = item.oid, // допущение: Grupa = workSpaceId
                  onCategorySelected: (item) => _dataPost.categoryId = item.oid,
                  onSubCategorySelected: (item) => _dataPost.subCategoryId = item.oid,
                  onBugTransferChanged: (v) => _dataPost.bugTransfer = v ?? false,
                  onBugNumberChanged: (v) => _dataPost.bugNumber = v,
                  onTitleChanged: (v) => _dataPost.title = v,
                  onDescriptionChanged: (v) => _dataPost.description = v,
                  onUserResponsable: (UserItem value) {  },
                  onPhonesChanged: (List<TicketPhoneModel> value) {  },

                  // Передаем в widget!!!!!!
                  ticketResponse: widget.ticket,
                  phones: widget.phones,
                  searchCompany: _selectedCompany,
                  dictionariesRepo:  widget.dictionariesRepo,
                  platforms: _selectedCompany?.platforms ?? [],
                  onAuthorChanged: (author) => _dataPost.authorId = author.oid,
                //  technicians: widget.ticket?.userId,

              ),
            ),
          ),
          // ---- Кнопки Anulează / Înregistrează ----
          Container(
            color:
            AppColors.backgroundColor,
            child: Padding(
              padding: EdgeInsets.only(right: 16.w,bottom: 10.h, ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: widget.onCancel,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.backgroundColor,
                      side: BorderSide(color: AppColors.textTitleFl),
                      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 14.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                    ),
                    child: Text('Anulează', style: GoogleFonts.poppins(
                      color: AppColors.textTitleFl,
                      fontWeight: FontWeight.w500,
                      fontSize: 15.sp,
                    ),),
                  ),
                  SizedBox(width: 12.w),
                  ElevatedButton(
                    onPressed: _handleSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.textTitleFl,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 14.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      elevation: 0,
                    ),
                    child: Text('Înregistrează', style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w500,
                      fontSize: 15.sp,
                    ),),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
