import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:service_desk/const/const_colors.dart';

import '../../models/model_data_table_tiket/column_config.dart';

class ColumnManagerDialog extends StatefulWidget {
  final List<ColumnConfig> configs;
  final VoidCallback onChanged;

  const ColumnManagerDialog({required this.configs, required this.onChanged});

  @override
  State<ColumnManagerDialog> createState() => ColumnManagerDialogState();
}

class ColumnManagerDialogState extends State<ColumnManagerDialog> {
  @override
  Widget build(BuildContext context) {
    final visibleCount = widget.configs.where((c) => c.visible).length;

    return AlertDialog(
      backgroundColor: AppColors.backgroundColor,

      title: Row(
        children: [
          Container(
            decoration: BoxDecoration(color: AppColors.backgroundColor),
            child: Text('Управление колонками', style: GoogleFonts.poppins(
              color: AppColors.textColorOne,
              fontWeight: FontWeight.w700,
              fontSize: 20.sp
            ),),
          ),
          Spacer(),
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Icon(Icons.close_rounded, color: Colors.black, size: 20.r),
          ),
        ],
      ),
      contentPadding: EdgeInsets.only(left: 12.w, right: 12.w, bottom: 10.h),
      content: Container(
        decoration: BoxDecoration(
          color: AppColors.backgroundColor,
          borderRadius: BorderRadius.circular(10.r),
        ),
        width: 320.w,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        for (final c in widget.configs) {
                          if (c.columnName == 'id' || c.columnName == 'checkbox' || c.columnName == 'newMessage' ) continue; // <- защита
                          c.visible = true;
                        }
                      });
                      widget.onChanged();
                    },
                    child: Container(
                      width: 70.w,
                      height: 15.h,
                      alignment: Alignment.center,
                    //  margin: EdgeInsets.only(right: 8.w, bottom: 5.h),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: AppColors.gradientColorTop),
                        borderRadius: BorderRadiusGeometry.circular(100.r),

                      ),
                      child: Text('Все', style: GoogleFonts.poppins(
                        color: AppColors.backgroundColor,
                        fontWeight: FontWeight.w500,
                        fontSize: 10.sp
                      ),),
                    ),
                  ),
                  SizedBox(width: 10.w,),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        // Оставляем хотя бы одну
                        for (int i = 1; i < widget.configs.length; i++) {
                          if (widget.configs[i].columnName == 'id' ||
                              widget.configs[i].columnName == 'checkbox' ||
                              widget.configs[i].columnName == 'newMessage') continue;
                          widget.configs[i].visible = false;
                        }
                      });
                      widget.onChanged();
                    },
                    child: Container(
                      width: 70.w,
                      height: 15.h,
                    //  margin: EdgeInsets.only(right: 8.w, bottom: 5.h),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: AppColors.gradientColorTop),
                        borderRadius: BorderRadiusGeometry.circular(100.r),

                      ),
                      child: Text('Снять все', style: GoogleFonts.poppins(
                          color: AppColors.backgroundColor,
                          fontWeight: FontWeight.w500,
                          fontSize: 10.sp
                      ),),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '$visibleCount / ${widget.configs.length}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: 400.h),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: widget.configs.length,
                itemBuilder: (_, i) {
                  final config = widget.configs[i];
                  return CheckboxListTile(
                    dense: true,
                    checkColor: AppColors.dataGreadColorTitle,
                    hoverColor: AppColors.backgroundColor,
                    activeColor: AppColors.backgroundColor,
                    checkboxScaleFactor: 1.4,
                    // 🔥 ВАЖНО
                    fillColor: WidgetStateProperty.resolveWith((states) {
                      if (states.contains(WidgetState.disabled)) {
                        return Colors.transparent; // фон отключенного
                      }
                      return AppColors.backgroundColor;
                    }),

                    side: BorderSide(
                      color: config.visible
                          ? AppColors.dataGreadColorTitle
                          : AppColors.textColorOne, // цвет рамки когда false
                      width: 2,
                    ),

                    title: Text(
                      config.label,
                      style: GoogleFonts.poppins(
                          fontSize: 10.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textTitleFl
                      ),
                    ),
                    subtitle: Text(
                      config.columnName,
                      style: GoogleFonts.poppins(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textTitleFl
                      ),
                    ),
                    value: config.visible,
                    onChanged: config.columnName == 'id' || config.columnName == 'checkbox' || config.columnName == 'newMessage'

                        ? null
                        : (val) {
                            if (val == false && visibleCount <= 1) return;
                            setState(() => config.visible = val ?? true);
                            widget.onChanged();
                          },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
