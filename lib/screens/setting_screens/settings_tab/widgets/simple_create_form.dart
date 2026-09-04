import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:service_desk/const/const_colors.dart';
import 'package:service_desk/screens/widgets/bordered_form_field.dart';

/// Переиспользуемая форма "создать запись справочника по имени".
/// Сам виджет ничего не знает про bloc/service — только рендер + колбэк.
class SimpleCreateForm extends StatelessWidget {
  final String title;
  final String fieldLabel;
  final GlobalKey<FormState> formKey;
  final TextEditingController controller;
  final bool saving;
  final VoidCallback onSubmit;
  final List<Widget> extraFields;

  const SimpleCreateForm({
    super.key,
    required this.title,
    required this.fieldLabel,
    required this.formKey,
    required this.controller,
    required this.saving,
    required this.onSubmit,
    this.extraFields = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
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
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BorderedFieldLabel(fieldLabel),
                BorderedFormField(
                  controller: controller,
                  hint: fieldLabel,
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Введите название' : null,
                ),
                ...extraFields.expand((w) => [SizedBox(height: 12.h), w]),
                SizedBox(height: 16.h),
                ElevatedButton.icon(
                  onPressed: saving ? null : onSubmit,
                  icon: saving
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
    );
  }
}
