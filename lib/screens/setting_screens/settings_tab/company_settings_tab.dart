import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:service_desk/const/const_colors.dart';
import 'package:service_desk/data_base/user_repository.dart';
import 'package:service_desk/models/company_model.dart';
import 'package:service_desk/screens/widgets/bordered_form_field.dart';
import 'package:service_desk/screens/widgets/custom_dictionary_dropdown_widget.dart';

import '../../../blocs/author_blocs/author_bloc.dart';
import '../../../blocs/company_blocs/company_bloc.dart';
import '../../../blocs/platform_blocs/platform_bloc.dart';

/// Мастер создания компании: Компания → Платформа → Авторы.
/// Каждый шаг — свой bloc и свой service:
/// CompanyBloc (POST /Company), PlatformBloc (POST /Platform/NewPlatform),
/// AuthorBloc (GET /Author/GetAllAuthor, POST /Author/CreateAuthor).
class CompanySettingsTab extends StatelessWidget {
  const CompanySettingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => CompanyBloc()),
        BlocProvider(create: (_) => PlatformBloc()),
        BlocProvider(create: (_) => AuthorBloc()),
      ],
      child: const _CompanySettingsTabBody(),
    );
  }
}

class _CompanySettingsTabBody extends StatefulWidget {
  const _CompanySettingsTabBody();

  @override
  State<_CompanySettingsTabBody> createState() =>
      _CompanySettingsTabBodyState();
}

class _CompanySettingsTabBodyState extends State<_CompanySettingsTabBody> {
  final _userRepo = UserRepository();
  String _apiKey = '';

  final _companyFormKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _idnpController = TextEditingController();
  List<CompanyStateModel> _states = [];
  int? _selectedStateOid;
  bool _companySaving = false;

  final _platformNameController = TextEditingController();
  bool _platformSaving = false;
  CompanyModel? _createdCompany;

  final _authorFormKey = GlobalKey<FormState>();
  final _authorNameController = TextEditingController();
  final _authorEmailController = TextEditingController();
  final _authorPhoneController = TextEditingController();
  bool _authorSaving = false;
  int? _createdPlatformId;

  static final _emailRegex =
      RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
  static final _phoneRegex =
      RegExp(r'^\+?[0-9\s\-()]{6,20}$');

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    return _emailRegex.hasMatch(value.trim()) ? null : 'Некорректный email';
  }

  String? _validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    return _phoneRegex.hasMatch(value.trim()) ? null : 'Некорректный телефон';
  }

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final apiKey = await _userRepo.getUserApikey();
    if (!mounted) return;
    setState(() => _apiKey = apiKey ?? '');
    context.read<CompanyBloc>().add(LoadCompanyStatesEvent(_apiKey));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _idnpController.dispose();
    _platformNameController.dispose();
    _authorNameController.dispose();
    _authorEmailController.dispose();
    _authorPhoneController.dispose();
    super.dispose();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void _createCompany() {
    if (!_companyFormKey.currentState!.validate()) return;
    if (_selectedStateOid == null) {
      _showError('Нет доступных статусов компании');
      return;
    }
    setState(() => _companySaving = true);
    context.read<CompanyBloc>().add(
      CreateCompanyEvent(
        apiKey: _apiKey,
        name: _nameController.text.trim(),
        companyStateOid: _selectedStateOid!,
        idnp: _idnpController.text.trim().isEmpty
            ? null
            : _idnpController.text.trim(),
      ),
    );
  }

  void _createPlatform() {
    if (_platformNameController.text.trim().isEmpty) {
      _showError('Введите название платформы');
      return;
    }
    setState(() => _platformSaving = true);
    context.read<PlatformBloc>().add(
      CreatePlatformEvent(
        apiKey: _apiKey,
        name: _platformNameController.text.trim(),
        companyId: _createdCompany!.oid,
      ),
    );
  }

  void _createAuthor() {
    if (!_authorFormKey.currentState!.validate()) return;
    setState(() => _authorSaving = true);
    context.read<AuthorBloc>().add(
      CreateAuthorEvent(
        apiKey: _apiKey,
        name: _authorNameController.text.trim(),
        platformId: _createdPlatformId!,
        email: _authorEmailController.text.trim().isEmpty
            ? null
            : _authorEmailController.text.trim(),
        phoneNumber: _authorPhoneController.text.trim().isEmpty
            ? null
            : _authorPhoneController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<CompanyBloc, CompanyState>(
          listener: (context, state) {
            if (state is CompanyStatesLoaded) {
              setState(() {
                _states = state.states;
                _selectedStateOid ??=
                    state.states.isNotEmpty ? state.states.first.oid : null;
              });
            } else if (state is CompanyCreated) {
              setState(() {
                _companySaving = false;
                _createdCompany = state.company;
              });
            } else if (state is CompanyError) {
              setState(() => _companySaving = false);
              _showError('Ошибка: ${state.message}');
            }
          },
        ),
        BlocListener<PlatformBloc, PlatformState>(
          listener: (context, state) {
            if (state is PlatformCreated) {
              setState(() {
                _platformSaving = false;
                _createdPlatformId = state.platform.oid;
              });
            } else if (state is PlatformError) {
              setState(() => _platformSaving = false);
              _showError('Ошибка: ${state.message}');
            }
          },
        ),
        BlocListener<AuthorBloc, AuthorState>(
          listener: (context, state) {
            if (state is AuthorCreated) {
              setState(() {
                _authorSaving = false;
                _authorNameController.clear();
                _authorEmailController.clear();
                _authorPhoneController.clear();
              });
              ScaffoldMessenger.of(context)
                  .showSnackBar(const SnackBar(content: Text('Автор добавлен')));
            } else if (state is AuthorError) {
              setState(() => _authorSaving = false);
              _showError('Ошибка: ${state.message}');
            }
          },
        ),
      ],
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Новая компания',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w700,
                fontSize: 18.sp,
                color: AppColors.textColorOne,
              ),
            ),
            SizedBox(height: 16.h),
            _buildCompanyStep(),
            SizedBox(height: 16.h),
            _buildPlatformStep(),
            SizedBox(height: 16.h),
            _buildAuthorStep(),
          ],
        ),
      ),
    );
  }

  Widget _stepCard({
    required int number,
    required String title,
    required bool enabled,
    required Widget child,
  }) {
    return Opacity(
      opacity: enabled ? 1 : 0.5,
      child: IgnorePointer(
        ignoring: !enabled,
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
                  CircleAvatar(
                    radius: 12.r,
                    backgroundColor: AppColors.textTitleFl,
                    child: Text(
                      '$number',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 14.sp,
                      color: AppColors.textColorOne,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              child,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompanyStep() {
    return _stepCard(
      number: 1,
      title: 'Компания',
      enabled: _createdCompany == null,
      child: _createdCompany != null
          ? Text(
              'Создана: ${_createdCompany!.name}',
              style: GoogleFonts.poppins(fontSize: 13.sp, color: AppColors.textColorOne),
            )
          : Form(
              key: _companyFormKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BorderedFieldLabel('Название компании'),
                  BorderedFormField(
                    controller: _nameController,
                    hint: 'Название компании',
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Введите название' : null,
                  ),
                  SizedBox(height: 12.h),
                  BorderedFieldLabel('IDNP (необязательно)'),
                  BorderedFormField(
                    controller: _idnpController,
                    hint: 'IDNP (необязательно)',
                  ),
                  SizedBox(height: 12.h),
                  BorderedFieldLabel('Статус компании'),
                  CustomDictionaryDropdown(
                    hintText: 'Статус компании',
                    icon: Icons.flag_outlined,
                    items: _states.map((s) => s.toDictionaryItem()).toList(),
                    initialValue: _states
                        .where((s) => s.oid == _selectedStateOid)
                        .map((s) => s.toDictionaryItem())
                        .firstOrNull,
                    onSelected: (item) => setState(() => _selectedStateOid = item.oid),
                  ),
                  SizedBox(height: 16.h),
                  _submitButton(
                    label: 'Создать компанию',
                    saving: _companySaving,
                    onPressed: _createCompany,
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildPlatformStep() {
    return _stepCard(
      number: 2,
      title: 'Платформа',
      enabled: _createdCompany != null && _createdPlatformId == null,
      child: _createdPlatformId != null
          ? Text(
              'Платформа создана для компании "${_createdCompany?.name ?? ''}"',
              style: GoogleFonts.poppins(fontSize: 13.sp, color: AppColors.textColorOne),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BorderedFieldLabel('Название платформы'),
                BorderedFormField(
                  controller: _platformNameController,
                  hint: 'Название платформы',
                ),
                SizedBox(height: 16.h),
                _submitButton(
                  label: 'Создать платформу',
                  saving: _platformSaving,
                  onPressed: _createPlatform,
                ),
              ],
            ),
    );
  }

  Widget _buildAuthorStep() {
    return _stepCard(
      number: 3,
      title: 'Авторы',
      enabled: _createdPlatformId != null,
      child: Form(
        key: _authorFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Новый автор для этой платформы',
              style: GoogleFonts.poppins(fontSize: 12.sp, color: AppColors.hintTextColor),
            ),
            SizedBox(height: 8.h),
            BorderedFieldLabel('Имя автора'),
            BorderedFormField(
              controller: _authorNameController,
              hint: 'Имя автора',
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Введите имя автора' : null,
            ),
            SizedBox(height: 12.h),
            BorderedFieldLabel('Email (необязательно)'),
            BorderedFormField(
              controller: _authorEmailController,
              hint: 'Email (необязательно)',
              keyboardType: TextInputType.emailAddress,
              validator: _validateEmail,
            ),
            SizedBox(height: 12.h),
            BorderedFieldLabel('Телефон (необязательно)'),
            BorderedFormField(
              controller: _authorPhoneController,
              hint: 'Телефон (необязательно)',
              keyboardType: TextInputType.phone,
              validator: _validatePhone,
            ),
            SizedBox(height: 16.h),
            _submitButton(
              label: 'Добавить автора',
              saving: _authorSaving,
              onPressed: _createAuthor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _submitButton({
    required String label,
    required bool saving,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: saving ? null : onPressed,
      icon: saving
          ? SizedBox(
              width: 16.w,
              height: 16.w,
              child: const CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.add, size: 18),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.textTitleFl,
        foregroundColor: Colors.white,
      ),
    );
  }
}
