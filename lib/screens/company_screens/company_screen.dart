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

import '../../blocs/company_blocs/company_bloc.dart';

/// Список компаний (GET /Company) с возможностью редактирования
/// (PUT /Company/UpdateCompanyById). Использует свой CompanyBloc/CompanyService.
class CompanyScreen extends StatelessWidget {
  const CompanyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CompanyBloc(),
      child: const _CompanyScreenBody(),
    );
  }
}

class _CompanyScreenBody extends StatefulWidget {
  const _CompanyScreenBody();

  @override
  State<_CompanyScreenBody> createState() => _CompanyScreenBodyState();
}

class _CompanyScreenBodyState extends State<_CompanyScreenBody> {
  final _userRepo = UserRepository();
  String _apiKey = '';

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final apiKey = await _userRepo.getUserApikey();
    if (!mounted) return;
    setState(() => _apiKey = apiKey ?? '');
    _load();
  }

  void _load() {
    context.read<CompanyBloc>().add(LoadAllCompaniesEvent(_apiKey));
  }

  Future<void> _openEditDialog(CompanyModel company) async {
    final nameController = TextEditingController(text: company.name);
    final idnpController = TextEditingController(text: company.idnp ?? '');

    context.read<CompanyBloc>().add(LoadCompanyStatesEvent(_apiKey));
    var selectedStateOid = company.companyStateOid;
    var selectedStateName = company.companyStateName;
    var states = <CompanyStateModel>[];

    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          return BlocListener<CompanyBloc, CompanyState>(
            listener: (ctx, state) {
              if (state is CompanyStatesLoaded) {
                setDialogState(() {
                  states = state.states;
                  if (states.every((s) => s.oid != selectedStateOid) &&
                      states.isNotEmpty) {
                    selectedStateOid = states.first.oid;
                    selectedStateName = states.first.name;
                  }
                });
              }
            },
            child: AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
              title: Text(
                'Редактирование компании',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
              ),
              content: SizedBox(
                width: 360.w,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    BorderedFieldLabel('Название компании'),
                    BorderedFormField(
                      controller: nameController,
                      hint: 'Название компании',
                    ),
                    SizedBox(height: 12.h),
                    BorderedFieldLabel('IDNP'),
                    BorderedFormField(
                      controller: idnpController,
                      hint: 'IDNP',
                    ),
                    SizedBox(height: 12.h),
                    BorderedFieldLabel('Статус компании'),
                    CustomDictionaryDropdown(
                      hintText: 'Статус компании',
                      icon: Icons.flag_outlined,
                      items: states.map((s) => s.toDictionaryItem()).toList(),
                      initialValue: states
                          .where((s) => s.oid == selectedStateOid)
                          .map((s) => s.toDictionaryItem())
                          .firstOrNull,
                      onSelected: (item) {
                        setDialogState(() {
                          selectedStateOid = item.oid;
                          selectedStateName = item.name;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('Отмена'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: const Text('Сохранить'),
                ),
              ],
            ),
          );
        },
      ),
    );

    if (saved != true) return;
    if (!mounted) return;

    context.read<CompanyBloc>().add(
      UpdateCompanyEvent(
        apiKey: _apiKey,
        company: CompanyModel(
          oid: company.oid,
          name: nameController.text.trim(),
          idnp: idnpController.text.trim().isEmpty ? null : idnpController.text.trim(),
          companyStateOid: selectedStateOid,
          companyStateName: selectedStateName,
          active: company.active,
          dateModifire: DateTime.now(),
          dateCreated: company.dateCreated,
          platforms: company.platforms,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CompanyBloc, CompanyState>(
      listener: (context, state) {
        if (state is CompanyUpdated) {
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text('Компания обновлена')));
          _load();
        } else if (state is CompanyError) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('Ошибка: ${state.message}')));
        }
      },
      builder: (context, state) {
        return Container(
          margin: EdgeInsets.all(14.w),
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
                    'Компании',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w700,
                      fontSize: 18.sp,
                      color: AppColors.textColorOne,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: state is CompanyLoading ? null : _load,
                    icon: const Icon(Icons.refresh),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              Expanded(child: _buildBody(state)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBody(CompanyState state) {
    if (state is CompanyLoading) return const Center(child: CircularProgressIndicator());
    if (state is CompanyError) return Center(child: Text(state.message));
    if (state is! CompanyLoaded) return const SizedBox.shrink();
    if (state.companies.isEmpty) return const Center(child: Text('Список пуст'));

    return ListView.separated(
      itemCount: state.companies.length,
      separatorBuilder: (_, __) => Divider(height: 1, color: AppColors.borderCardColor),
      itemBuilder: (_, i) {
        final company = state.companies[i];
        return ListTile(
          dense: true,
          title: Text(company.name, style: GoogleFonts.poppins(fontSize: 13.sp)),
          subtitle: Text(
            company.companyStateName,
            style: GoogleFonts.poppins(fontSize: 11.sp, color: AppColors.hintTextColor),
          ),
          trailing: IconButton(
            icon: const Icon(Icons.edit_outlined, size: 18),
            onPressed: () => _openEditDialog(company),
          ),
        );
      },
    );
  }
}
