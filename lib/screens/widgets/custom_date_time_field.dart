import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../const/const_colors.dart';

class CustomDateTimeField extends StatelessWidget {
  final DateTime? value;
  final ValueChanged<DateTime> onPick;
  final String dateFormat;

  const CustomDateTimeField({
    super.key,
    required this.value,
    required this.onPick,
    this.dateFormat = 'dd.MM HH:mm',
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final picked = await showCustomDateTimePicker(
          context: context,
          initialValue: value,
        );
        if (picked != null) onPick(picked);
      },
      child: Text(
        value != null ? DateFormat(dateFormat).format(value!) : '—',
        style: GoogleFonts.poppins(
          fontSize: 12.sp,
          color: value != null ? Colors.black87 : Colors.grey.shade400,
        ),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

/// Удобная функция-обёртка, чтобы вызывать диалог откуда угодно
/// без прямого создания виджета:
///
/// ```dart
/// final picked = await showCustomDateTimePicker(
///   context: context,
///   initialValue: someDate,
/// );
/// ```
Future<DateTime?> showCustomDateTimePicker({
  required BuildContext context,
  DateTime? initialValue,
  DateTime? firstDate,
  DateTime? lastDate,
}) {
  return showDialog<DateTime>(
    context: context,
    builder: (context) => CustomDateTimePickerDialog(
      initialValue: initialValue,
      firstDate: firstDate,
      lastDate: lastDate,
    ),
  );
}

/// Сам диалог: календарь (квадратные крупные даты) + колёса времени.
/// Публичный класс — можно переиспользовать где угодно в проекте.
class CustomDateTimePickerDialog extends StatefulWidget {
  final DateTime? initialValue;
  final DateTime? firstDate;
  final DateTime? lastDate;

  const CustomDateTimePickerDialog({
    super.key,
    this.initialValue,
    this.firstDate,
    this.lastDate,
  });

  @override
  State<CustomDateTimePickerDialog> createState() =>
      _CustomDateTimePickerDialogState();
}

class _CustomDateTimePickerDialogState
    extends State<CustomDateTimePickerDialog> {
  late List<DateTime?> _selectedDates;
  late int _selectedHour;
  late int _selectedMinute;

  late final FixedExtentScrollController _hourController;
  late final FixedExtentScrollController _minuteController;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialValue ?? DateTime.now();
    _selectedDates = [DateTime(initial.year, initial.month, initial.day)];
    _selectedHour = initial.hour;
    _selectedMinute = initial.minute;

    _hourController = FixedExtentScrollController(initialItem: _selectedHour);
    _minuteController =
        FixedExtentScrollController(initialItem: _selectedMinute);
  }

  @override
  void dispose() {
    _hourController.dispose();
    _minuteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14.r),
        side: BorderSide(color: AppColors.textTitleFl, width: 1.w),
      ),
      insetPadding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
      child: SizedBox(
        width: 340.w,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CalendarDatePicker2(
              config: CalendarDatePicker2Config(
                calendarType: CalendarDatePicker2Type.single,
                firstDate: widget.firstDate ?? DateTime(2020),
                lastDate: widget.lastDate ?? DateTime(2100),
                dayTextStyle: GoogleFonts.poppins(fontSize: 16.sp),
                selectedDayTextStyle: GoogleFonts.poppins(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
                selectedDayHighlightColor: AppColors.textTitleFl,
                todayTextStyle: GoogleFonts.poppins(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textTitleFl,
                ),
                controlsTextStyle: GoogleFonts.poppins(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                ),
                dayBuilder: ({
                  required date,
                  textStyle,
                  decoration,
                  isSelected,
                  isDisabled,
                  isToday,
                }) {
                  final selected = isSelected ?? false;
                  final today = isToday ?? false;
                  return Container(
                    margin: EdgeInsets.all(2.w),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: selected
                          ? AppColors.textTitleFl
                          : (today
                          ? AppColors.textTitleFl.withOpacity(0.12)
                          : null),
                      borderRadius: BorderRadius.circular(6.r),
                      border: (today && !selected)
                          ? Border.all(color: AppColors.textTitleFl, width: 1.w)
                          : null,
                    ),
                    child: Text(
                      date.day.toString(),
                      style: GoogleFonts.poppins(
                        fontSize: 16.sp,
                        fontWeight:
                        (selected || today) ? FontWeight.w600 : FontWeight.w400,
                        color: selected ? Colors.white : Colors.black87,
                      ),
                    ),
                  );
                },
              ),
              value: _selectedDates,
              onValueChanged: (dates) => setState(() => _selectedDates = dates),
            ),
            Divider(height: 1, color: Colors.grey.shade200),
            SizedBox(
              height: 140.h,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _WheelColumn(
                    controller: _hourController,
                    itemCount: 24,
                    onChanged: (v) => setState(() => _selectedHour = v),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4.w),
                    child: Text(
                      ':',
                      style: GoogleFonts.poppins(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  _WheelColumn(
                    controller: _minuteController,
                    itemCount: 60,
                    onChanged: (v) => setState(() => _selectedMinute = v),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: Colors.grey.shade200),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Anulează', style: GoogleFonts.poppins(fontSize: 13.sp)),
                  ),
                  SizedBox(width: 8.w),
                  TextButton(
                    onPressed: () {
                      final selected = _selectedDates.first;
                      if (selected == null) return;
                      Navigator.pop(
                        context,
                        DateTime(
                          selected.year,
                          selected.month,
                          selected.day,
                          _selectedHour,
                          _selectedMinute,
                        ),
                      );
                    },
                    child: Text(
                      'OK',
                      style: GoogleFonts.poppins(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WheelColumn extends StatelessWidget {
  final FixedExtentScrollController controller;
  final int itemCount;
  final ValueChanged<int> onChanged;

  const _WheelColumn({
    required this.controller,
    required this.itemCount,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 60.w,
      child: ListWheelScrollView.useDelegate(
        controller: controller,
        itemExtent: 36.h,
        physics: const FixedExtentScrollPhysics(),
        onSelectedItemChanged: onChanged,
        childDelegate: ListWheelChildBuilderDelegate(
          childCount: itemCount,
          builder: (context, index) {
            return Center(
              child: Text(
                index.toString().padLeft(2, '0'),
                style: GoogleFonts.poppins(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}