import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:service_desk/const/const_colors.dart';
import 'package:service_desk/data_base/user_repository.dart';
import 'package:service_desk/models/dictionary_models/simple_dictionary_model.dart';
import 'package:service_desk/models/user_create_models/user_create_model.dart';
import 'package:service_desk/models/user_create_models/user_list_model.dart';
import 'package:service_desk/screens/widgets/bordered_form_field.dart';
import 'package:service_desk/screens/widgets/custom_dictionary_dropdown_widget.dart';

import '../../../blocs/user_create_blocs/user_create_bloc.dart';
import '../../../blocs/workspace_blocs/workspace_bloc.dart';

class UserCreateTab extends StatelessWidget {
  const UserCreateTab({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => WorkSpaceBloc()),
        BlocProvider(create: (_) => UserCreateBloc()),
      ],
      child: const _UserCreateTabBody(),
    );
  }
}

class _UserCreateTabBody extends StatefulWidget {
  const _UserCreateTabBody();

  @override
  State<_UserCreateTabBody> createState() => _UserCreateTabBodyState();
}

class _UserCreateTabBodyState extends State<_UserCreateTabBody> {
  final _userRepo = UserRepository();
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _loghinController = TextEditingController();

  String _apiKey = '';
  bool _saving = false;
  bool _obscurePassword = true;
  bool _isActive = true;
  bool _loadingList = true;
  List<SimpleDictionaryModel> _workSpaces = [];
  List<UserListModel> _users = [];
  int? _selectedWorkSpaceOid;

  static final _emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final apiKey = await _userRepo.getUserApikey();
    if (!mounted) return;
    setState(() => _apiKey = apiKey ?? '');
    context.read<WorkSpaceBloc>().add(LoadAllWorkSpacesEvent(_apiKey));
    _load();
  }

  void _load() {
    setState(() => _loadingList = true);
    context.read<UserCreateBloc>().add(LoadAllUsersEvent(_apiKey));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _firstNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _loghinController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedWorkSpaceOid == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Выберите рабочее пространство')));
      return;
    }
    setState(() => _saving = true);
    context.read<UserCreateBloc>().add(
      CreateUserEvent(
        apiKey: _apiKey,
        user: UserCreateModel(
          name: _nameController.text.trim(),
          firstName: _firstNameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
          loghin: _loghinController.text.trim(),
          phone: _phoneController.text.trim().isEmpty
              ? null
              : _phoneController.text.trim(),
          isActive: _isActive,
          dateCreated: DateTime.now(),
          workSpaceId: _selectedWorkSpaceOid!,
        ),
      ),
    );
  }

  String? _requiredValidator(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Обязательное поле' : null;

  Future<void> _editUser(UserListModel item) async {
    final nameController = TextEditingController(text: item.name);
    final firstNameController = TextEditingController(text: item.firstName);
    final emailController = TextEditingController(text: item.email);
    final phoneController = TextEditingController(text: item.phone ?? '');
    final loghinController = TextEditingController(text: item.loghin);
    final passwordController = TextEditingController();
    var selectedWorkSpaceOid = item.workSpaceId;
    var isActive = item.isActive;
    var obscure = true;
    final dialogFormKey = GlobalKey<FormState>();

    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
          title: Text('Редактирование пользователя',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
          content: SizedBox(
            width: 380.w,
            child: Form(
              key: dialogFormKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    BorderedFieldLabel('Фамилия'),
                    BorderedFormField(
                      controller: nameController,
                      hint: 'Фамилия',
                      validator: _requiredValidator,
                    ),
                    SizedBox(height: 12.h),
                    BorderedFieldLabel('Имя'),
                    BorderedFormField(
                      controller: firstNameController,
                      hint: 'Имя',
                      validator: _requiredValidator,
                    ),
                    SizedBox(height: 12.h),
                    BorderedFieldLabel('Email'),
                    BorderedFormField(
                      controller: emailController,
                      hint: 'Email',
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Обязательное поле';
                        return _emailRegex.hasMatch(v.trim()) ? null : 'Некорректный email';
                      },
                    ),
                    SizedBox(height: 12.h),
                    BorderedFieldLabel('Телефон (необязательно)'),
                    BorderedFormField(
                      controller: phoneController,
                      hint: 'Телефон (необязательно)',
                    ),
                    SizedBox(height: 12.h),
                    BorderedFieldLabel('Логин'),
                    BorderedFormField(
                      controller: loghinController,
                      hint: 'Логин',
                      validator: _requiredValidator,
                    ),
                    SizedBox(height: 12.h),
                    BorderedFieldLabel('Новый пароль (оставь пустым, чтобы не менять)'),
                    BorderedFormField(
                      controller: passwordController,
                      hint: 'Новый пароль',
                      obscureText: obscure,
                      suffixIcon: IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        iconSize: 18.r,
                        icon: Icon(obscure
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined),
                        onPressed: () => setDialogState(() => obscure = !obscure),
                      ),
                      validator: (v) =>
                          (v != null && v.isNotEmpty && v.length < 6) ? 'Минимум 6 символов' : null,
                    ),
                    SizedBox(height: 12.h),
                    BorderedFieldLabel('Рабочее пространство'),
                    CustomDictionaryDropdown(
                      hintText: 'Рабочее пространство',
                      icon: Icons.workspaces_outlined,
                      items: _workSpaces.map((w) => w.toDictionaryItem()).toList(),
                      initialValue: _workSpaces
                          .where((w) => w.oid == selectedWorkSpaceOid)
                          .map((w) => w.toDictionaryItem())
                          .firstOrNull,
                      onSelected: (item) =>
                          setDialogState(() => selectedWorkSpaceOid = item.oid),
                    ),
                    SizedBox(height: 4.h),
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      controlAffinity: ListTileControlAffinity.leading,
                      title: const Text('Активен'),
                      value: isActive,
                      onChanged: (v) => setDialogState(() => isActive = v ?? true),
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Отмена')),
            TextButton(
              onPressed: () {
                if (!dialogFormKey.currentState!.validate()) return;
                Navigator.pop(ctx, true);
              },
              child: const Text('Сохранить'),
            ),
          ],
        ),
      ),
    );

    if (saved != true || !mounted) return;

    context.read<UserCreateBloc>().add(
      UpdateUserEvent(
        apiKey: _apiKey,
        oid: item.oid,
        name: nameController.text.trim(),
        firstName: firstNameController.text.trim(),
        email: emailController.text.trim(),
        loghin: loghinController.text.trim(),
        isActive: isActive,
        dateCreated: item.dateCreated,
        workSpaceId: selectedWorkSpaceOid,
        phone: phoneController.text.trim().isEmpty ? null : phoneController.text.trim(),
        password: passwordController.text.isEmpty ? null : passwordController.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<WorkSpaceBloc, WorkSpaceState>(
          listener: (context, state) {
            if (state is WorkSpacesLoaded) {
              setState(() {
                _workSpaces = state.workSpaces;
                _selectedWorkSpaceOid ??=
                    state.workSpaces.isNotEmpty ? state.workSpaces.first.oid : null;
              });
            }
          },
        ),
        BlocListener<UserCreateBloc, UserCreateState>(
          listener: (context, state) {
            if (state is UserCreated) {
              setState(() => _saving = false);
              _nameController.clear();
              _firstNameController.clear();
              _emailController.clear();
              _passwordController.clear();
              _phoneController.clear();
              _loghinController.clear();
              setState(() => _isActive = true);
              ScaffoldMessenger.of(context)
                  .showSnackBar(const SnackBar(content: Text('Пользователь создан')));
              _load();
            } else if (state is UserUpdated) {
              ScaffoldMessenger.of(context)
                  .showSnackBar(const SnackBar(content: Text('Изменения сохранены')));
              _load();
            } else if (state is UsersLoaded) {
              setState(() {
                _users = state.users;
                _loadingList = false;
              });
            } else if (state is UserCreateError) {
              setState(() {
                _saving = false;
                _loadingList = false;
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
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Новый пользователь',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w700,
                      fontSize: 18.sp,
                      color: AppColors.textColorOne,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: AppColors.backgroundColor,
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(color: AppColors.borderCardColor, width: 1.w),
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          BorderedFieldLabel('Фамилия'),
                          BorderedFormField(
                            controller: _nameController,
                            hint: 'Фамилия',
                            validator: _requiredValidator,
                          ),
                          SizedBox(height: 12.h),
                          BorderedFieldLabel('Имя'),
                          BorderedFormField(
                            controller: _firstNameController,
                            hint: 'Имя',
                            validator: _requiredValidator,
                          ),
                          SizedBox(height: 12.h),
                          BorderedFieldLabel('Email'),
                          BorderedFormField(
                            controller: _emailController,
                            hint: 'Email',
                            keyboardType: TextInputType.emailAddress,
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) return 'Обязательное поле';
                              return _emailRegex.hasMatch(v.trim())
                                  ? null
                                  : 'Некорректный email';
                            },
                          ),
                          SizedBox(height: 12.h),
                          BorderedFieldLabel('Телефон (необязательно)'),
                          BorderedFormField(
                            controller: _phoneController,
                            hint: 'Телефон (необязательно)',
                            keyboardType: TextInputType.phone,
                          ),
                          SizedBox(height: 12.h),
                          BorderedFieldLabel('Логин'),
                          BorderedFormField(
                            controller: _loghinController,
                            hint: 'Логин',
                            validator: _requiredValidator,
                          ),
                          SizedBox(height: 12.h),
                          BorderedFieldLabel('Пароль'),
                          BorderedFormField(
                            controller: _passwordController,
                            hint: 'Пароль',
                            obscureText: _obscurePassword,
                            suffixIcon: IconButton(
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              iconSize: 18.r,
                              icon: Icon(_obscurePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined),
                              onPressed: () =>
                                  setState(() => _obscurePassword = !_obscurePassword),
                            ),
                            validator: (v) {
                              if (v == null || v.isEmpty) return 'Обязательное поле';
                              return v.length < 6 ? 'Минимум 6 символов' : null;
                            },
                          ),
                          SizedBox(height: 12.h),
                          BorderedFieldLabel('Рабочее пространство'),
                          CustomDictionaryDropdown(
                            hintText: 'Рабочее пространство',
                            icon: Icons.workspaces_outlined,
                            items: _workSpaces.map((w) => w.toDictionaryItem()).toList(),
                            initialValue: _workSpaces
                                .where((w) => w.oid == _selectedWorkSpaceOid)
                                .map((w) => w.toDictionaryItem())
                                .firstOrNull,
                            onSelected: (item) =>
                                setState(() => _selectedWorkSpaceOid = item.oid),
                          ),
                          SizedBox(height: 4.h),
                          Material(
                            type: MaterialType.transparency,
                            child: CheckboxListTile(
                              contentPadding: EdgeInsets.zero,
                              controlAffinity: ListTileControlAffinity.leading,
                              title: const Text('Активен'),
                              value: _isActive,
                              onChanged: (v) =>
                                  setState(() => _isActive = v ?? true),
                            ),
                          ),
                          SizedBox(height: 16.h),
                          ElevatedButton.icon(
                            onPressed: _saving ? null : _submit,
                            icon: _saving
                                ? SizedBox(
                                    width: 16.w,
                                    height: 16.w,
                                    child: const CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Icon(Icons.add, size: 18),
                            label: const Text('Создать'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.textTitleFl,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: 16.w),
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
                        'Существующие пользователи',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 13.sp,
                          color: AppColors.textColorOne,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: _loadingList ? null : _load,
                        icon: const Icon(Icons.refresh, size: 18),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Expanded(
                    child: _loadingList
                        ? const Center(child: CircularProgressIndicator())
                        : _users.isEmpty
                            ? const Center(child: Text('Список пуст'))
                            : ListView.separated(
                                itemCount: _users.length,
                                separatorBuilder: (_, __) =>
                                    Divider(height: 1, color: AppColors.borderCardColor),
                                itemBuilder: (_, i) {
                                  final u = _users[i];
                                  final canEdit = u.oid > 0;
                                  return ListTile(
                                    dense: true,
                                    title: Text('${u.firstName} ${u.name}'.trim(),
                                        style: GoogleFonts.poppins(fontSize: 13.sp)),
                                    subtitle: Text(
                                      '${u.loghin} · ${u.email}',
                                      style: GoogleFonts.poppins(
                                          fontSize: 11.sp, color: AppColors.hintTextColor),
                                    ),
                                    trailing: IconButton(
                                      icon: const Icon(Icons.edit_outlined, size: 18),
                                      onPressed: canEdit ? () => _editUser(u) : null,
                                      tooltip: canEdit
                                          ? null
                                          : 'API не возвращает id пользователя — правка недоступна',
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
    );
  }
}
