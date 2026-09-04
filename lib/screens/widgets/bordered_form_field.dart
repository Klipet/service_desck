import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:service_desk/const/const_colors.dart';

/// Единый стиль текстового поля для всех форм настроек — пилюля с рамкой,
/// как _BorderedTextField в tiket_form_detail.dart. В отличие от него,
/// это TextFormField — поддерживает validator для форм создания/редактирования.
class BorderedFormField extends StatelessWidget {
  final TextEditingController? controller;
  final String? initialValue;
  final String hint;
  final TextInputType? keyboardType;
  final bool obscureText;
  final int maxLines;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final bool autofocus;

  const BorderedFormField({
    super.key,
    this.controller,
    this.initialValue,
    required this.hint,
    this.keyboardType,
    this.obscureText = false,
    this.maxLines = 1,
    this.suffixIcon,
    this.validator,
    this.onChanged,
    this.autofocus = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: maxLines == 1 ? 32.h : null,
      constraints: BoxConstraints(minHeight: 32.h),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: AppColors.backgroundCardColor,
        borderRadius: BorderRadius.circular(100.r),
        border: Border.all(color: AppColors.textTitleFl, width: 1.w),
      ),
      child: TextFormField(
        controller: controller,
        initialValue: initialValue,
        autofocus: autofocus,
        keyboardType: keyboardType,
        obscureText: obscureText,
        maxLines: obscureText ? 1 : maxLines,
        textAlignVertical: TextAlignVertical.center,
        onChanged: onChanged,
        validator: validator,
        style: GoogleFonts.poppins(fontSize: 14.sp, color: Colors.black87),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.poppins(fontSize: 13.sp, color: AppColors.textColorOne),
          suffixIcon: suffixIcon,
          suffixIconConstraints: BoxConstraints(maxHeight: 20.h, minWidth: 0),
          isCollapsed: true,
          border: InputBorder.none,
        ),
      ),
    );
  }
}

/// Подпись над полем — как _FieldLabel в tiket_form_detail.dart.
class BorderedFieldLabel extends StatelessWidget {
  final String text;

  const BorderedFieldLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6.h),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 12.sp,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
      ),
    );
  }
}
