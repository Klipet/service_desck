import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'const_colors.dart';

class AppBorder{
  static final borderTextInput = OutlineInputBorder(
    borderRadius: BorderRadius.circular(100.r),
    borderSide: BorderSide(
      color: AppColors.borderCardColor,
      width: 1.w,
    ),
  );
  static final borderErrorInput = OutlineInputBorder(
    borderRadius: BorderRadius.circular(100.r),
    borderSide: BorderSide(
      color: AppColors.dorderError,
      width: 2.w,
    ),
  );
}