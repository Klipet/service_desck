import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:service_desk/const/const_colors.dart';
import 'package:service_desk/data_base/user_repository.dart';
import 'package:service_desk/models/holiday_models/holiday_create_model.dart';
import 'package:service_desk/screens/widgets/bordered_form_field.dart';

import '../../../blocs/holiday_blocs/holiday_bloc.dart';
import 'widgets/simple_create_form.dart';

class HolidayCreateTab extends StatelessWidget {
  const HolidayCreateTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => HolidayBloc(),
      child: const _HolidayCreateTabBody(),
    );
  }
}

class _HolidayCreateTabBody extends StatefulWidget {
  const _HolidayCreateTabBody();

  @override
  State<_HolidayCreateTabBody> createState() => _HolidayCreateTabBodyState();
}

class _HolidayCreateTabBodyState extends State<_HolidayCreateTabBody> {
  final _userRepo = UserRepository();
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  String _apiKey = '';
  bool _saving = false;
  bool _loadingList = true;
  DateTime _date = DateTime.now();
  bool _isRecurringYearly = false;
  List<HolidayCreateModel> _items = [];

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
    setState(() => _loadingList = true);
    context.read<HolidayBloc>().add(LoadAllHolidaysEvent(_apiKey));
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(DateTime.now().year - 5),
      lastDate: DateTime(DateTime.now().year + 10),
    );
    if (picked != null) setState(() => _date = picked);
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    context.read<HolidayBloc>().add(
      CreateHolidayEvent(
        apiKey: _apiKey,
        name: _nameController.text.trim(),
        date: _date,
        isRecurringYearly: _isRecurringYearly,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<HolidayBloc, HolidayState>(
      listener: (context, state) {
        if (state is HolidayCreated) {
          setState(() => _saving = false);
          _nameController.clear();
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text('Праздник создан')));
          _load();
        } else if (state is HolidaysLoaded) {
          setState(() {
            _items = state.holidays;
            _loadingList = false;
          });
        } else if (state is HolidayError) {
          setState(() {
            _saving = false;
            _loadingList = false;
          });
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('Ошибка: ${state.message}')));
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SimpleCreateForm(
            title: 'Новый праздник',
            fieldLabel: 'Название',
            formKey: _formKey,
            controller: _nameController,
            saving: _saving,
            onSubmit: _submit,
            extraFields: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BorderedFieldLabel('Дата'),
                  InkWell(
                    onTap: _pickDate,
                    borderRadius: BorderRadius.circular(100.r),
                    child: Container(
                      constraints: BoxConstraints(minHeight: 32.h),
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                      decoration: BoxDecoration(
                        color: AppColors.backgroundCardColor,
                        borderRadius: BorderRadius.circular(100.r),
                        border: Border.all(color: AppColors.textTitleFl, width: 1.w),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.calendar_today_outlined,
                              size: 16.r, color: AppColors.textTitleFl),
                          SizedBox(width: 8.w),
                          Text(
                            DateFormat('dd.MM.yyyy').format(_date),
                            style: GoogleFonts.poppins(fontSize: 14.sp, color: Colors.black87),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                title: const Text('Повторяется каждый год'),
                value: _isRecurringYearly,
                onChanged: (v) => setState(() => _isRecurringYearly = v ?? false),
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
                        'Существующие праздники',
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
                        : _items.isEmpty
                            ? const Center(child: Text('Список пуст'))
                            : ListView.separated(
                                itemCount: _items.length,
                                separatorBuilder: (_, __) =>
                                    Divider(height: 1, color: AppColors.borderCardColor),
                                itemBuilder: (_, i) {
                                  final item = _items[i];
                                  return ListTile(
                                    dense: true,
                                    title: Text(item.name,
                                        style: GoogleFonts.poppins(fontSize: 13.sp)),
                                    subtitle: Text(
                                      DateFormat('dd.MM.yyyy').format(item.date) +
                                          (item.isRecurringYearly ? ' · каждый год' : ''),
                                      style: GoogleFonts.poppins(
                                          fontSize: 11.sp, color: AppColors.hintTextColor),
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
