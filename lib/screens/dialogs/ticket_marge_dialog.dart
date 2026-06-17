import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:reorderables/reorderables.dart';

import '../../const/const_colors.dart';



class TicketMargeDialog extends StatefulWidget {
  final List<int> select;
  final void Function(int primaryId, List<int> secondaryIds) onMerge;

  const TicketMargeDialog({
    super.key,
    required this.select,
    required this.onMerge,
  });

  @override
  State<TicketMargeDialog> createState() => _TicketMargeDialogState();
}

class _TicketMargeDialogState extends State<TicketMargeDialog> {
  late List<int> _items;

  @override
  void initState() {
    super.initState();
    _items = List.from(widget.select);
  }

  @override
  Widget build(BuildContext context) {
    final primaryId = _items.first;
    final secondaryIds = _items.skip(1).toList();
    return AlertDialog(
      backgroundColor: AppColors.backgroundCardColor,
      title: Row(
        children: [
          Text(
            'Объединение заявок',
            style: GoogleFonts.poppins(
              color: AppColors.textColorOne,
              fontWeight: FontWeight.w700,
              fontSize: 20.sp,
            ),
          ),
          Spacer(),
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Icon(Icons.close_rounded, color: Colors.black, size: 20.r),
          ),
        ],
      ),
      content: SizedBox(
        width: 250.w,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Основная заявка',
              style: GoogleFonts.poppins(
                color: AppColors.textTitleFl,
                fontSize: 10.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 6.h),
            // Dropdown для выбора основной заявки
            Container(
              height: 42.h,
              padding: EdgeInsets.symmetric(horizontal: 10.w),
              decoration: BoxDecoration(
                color: AppColors.backgroundColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  isExpanded: true,
                  value: primaryId,
                  icon: Icon(Icons.keyboard_arrow_down, color: AppColors.textTitleFl),
                  dropdownColor: AppColors.backgroundColor,
                  items: _items.map((id) {
                    return DropdownMenuItem<int>(
                      value: id,
                      child: Text("Заявка ${id.toString()}",
                        style: GoogleFonts.poppins(
                          color: AppColors.textTitleFl,
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (newPrimary) {
                    if (newPrimary == null) return;
                    setState(() {
                      _items.remove(newPrimary);
                      _items.insert(0, newPrimary);
                    });
                  },
                ),
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              'Будут объединены:',
              style: GoogleFonts.poppins(
                color: AppColors.textTitleFl,
                fontSize: 10.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 6.h),
            ...secondaryIds.map((id) {
              return Padding(
                padding: EdgeInsets.only(bottom: 6.h),
                child: Row(
                  children: [
                    Text(
                      '• Заявка',
                      style: GoogleFonts.poppins(
                        color: AppColors.textTitleFl,
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      id.toString(),
                      style: GoogleFonts.poppins(
                        color: AppColors.textTitleFl,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
      actions: [
        GestureDetector(
          onTap: () {
            widget.onMerge(primaryId, secondaryIds);
          },
          child: Container(
            height: 30.h,
            width: 150.w,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: AppColors.gradientColorTop),
              borderRadius: BorderRadius.circular(100.r),
            ),
            alignment: Alignment.center,
            child: Text(
              "Объединить",
              style: GoogleFonts.poppins(
                color: AppColors.backgroundColor,
                fontWeight: FontWeight.w500,
                fontSize: 15.sp,
              ),
            ),
          ),
        ),
      ],
    );
  }


  Widget textIndex(int? value, int? index) {
    switch (index) {
      case 0:
        return Row(
          children: [
            Text(
              'В заявку',
              style: GoogleFonts.poppins(
                color: AppColors.textTitleFl,
                fontSize: 10.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(width: 5.w),
            Text(
              value.toString(),
              style: GoogleFonts.poppins(
                color: AppColors.textTitleFl,
                fontSize: 20.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        );
      case 1:
        return Row(
          children: [
            Text(
              'Из заявки',
              style: GoogleFonts.poppins(
                color: AppColors.textTitleFl,
                fontSize: 10.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(width: 5.w),
            Text(
              value.toString(),
              style: GoogleFonts.poppins(
                color: AppColors.textTitleFl,
                fontSize: 20.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        );

      default:
        return Row(
          children: [
            Text(
              'Из заявки',
              style: GoogleFonts.poppins(
                color: AppColors.textTitleFl,
                fontSize: 10.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(width: 5.w),
            Text(
              value.toString(),
              style: GoogleFonts.poppins(
                color: AppColors.textTitleFl,
                fontSize: 20.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        );
    }
  }
}
