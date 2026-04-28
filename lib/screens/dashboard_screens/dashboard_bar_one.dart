import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:service_desk/const/const_colors.dart';
import 'package:service_desk/screens/dashboard_screens/dashboard_one_tiket_int.dart';
import 'package:service_desk/screens/dashboard_screens/dashboard_one_tiket_out.dart';
import 'package:service_desk/utils/period_type_dashboard_one.dart';

import '../../utils/date_range_dashboard_one.dart';

class DashboardBarOne extends StatefulWidget {
  const DashboardBarOne({super.key});

  @override
  State<DashboardBarOne> createState() => _DashboardBarOneState();
}

class _DashboardBarOneState extends State<DashboardBarOne> {
  PeriodTypeDashboardOne selectedPeriod = PeriodTypeDashboardOne.week;

  late DateRangeDashboardOne data;

  @override
  void initState() {
    data = getDateRange(selectedPeriod);
    super.initState();
  }

  final border = OutlineInputBorder(
    borderRadius: BorderRadius.circular(100.r),
    borderSide: BorderSide(color: AppColors.borderCardColor, width: 1.w),
  );

  final textStyle = GoogleFonts.poppins(
    fontWeight: FontWeight.w300,
    fontSize: 10.sp.clamp(10, 20),
    color: AppColors.hintTextColor,
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      height: double.maxFinite,

      decoration: BoxDecoration(
        color: AppColors.backgroundColor,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: AppColors.borderCardColor, width: 1.w),
      ),
      child: Stack(
        children: [
          // Основное содержимое (фильтры + два Expanded)
          Positioned.fill(
            child: Column(
              children: [
                // Верхняя строка с выбором компании и периода
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      width: 208.w,
                      height: 24.h,
                      margin: EdgeInsets.only(top: 8.h, right: 8.w),
                      decoration: BoxDecoration(
                        color: AppColors.backgroundColor,
                        border: Border.all(
                          color: AppColors.borderCardColor,
                          width: 1.w,
                        ),
                        borderRadius: BorderRadius.circular(100.r),
                      ),
                      alignment: Alignment.centerLeft,
                      padding: EdgeInsets.symmetric(horizontal: 8.w),
                      child: Row(
                        children: [
                          Text("Company", style: textStyle),
                          Spacer(),
                          SvgPicture.asset(
                            "assets/image/icon_drop_dawn/company_drop_dawn.svg",
                            width: 14.w,
                            height: 14.h,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 208.w,
                      height: 24.h,
                      margin: EdgeInsets.only(top: 8.h, right: 16.w),
                      child: DropdownButtonFormField<PeriodTypeDashboardOne>(
                        value: selectedPeriod,
                        icon: SvgPicture.asset(
                          "assets/image/icon_drop_dawn/drop_dawn.svg",
                        ),
                        alignment: Alignment.center,
                        iconSize: 14.sp,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.only(left: 8.w),
                          filled: true,
                          hint: Text("Выбери период", style: textStyle),
                          fillColor: AppColors.backgroundColor,
                          focusColor: AppColors.backgroundColor,
                          hoverColor: AppColors.backgroundColor,
                          border: border,
                          enabledBorder: border,
                          focusedBorder: border,
                          disabledBorder: border,
                          errorBorder: border,
                          focusedErrorBorder: border,
                        ),
                        dropdownColor: AppColors.backgroundColor,
                        borderRadius: BorderRadius.circular(10.r),
                        items: [
                          DropdownMenuItem(
                            value: PeriodTypeDashboardOne.week,
                            child: Text('Неделя', style: textStyle),
                          ),
                          DropdownMenuItem(
                            value: PeriodTypeDashboardOne.month,
                            child: Text('Месяц', style: textStyle),
                          ),
                          DropdownMenuItem(
                            value: PeriodTypeDashboardOne.year,
                            child: Text('Год', style: textStyle),
                          ),
                          DropdownMenuItem(
                            value: PeriodTypeDashboardOne.spring,
                            child: Text('Весна', style: textStyle),
                          ),
                          DropdownMenuItem(
                            value: PeriodTypeDashboardOne.summer,
                            child: Text('Лето', style: textStyle),
                          ),
                          DropdownMenuItem(
                            value: PeriodTypeDashboardOne.autumn,
                            child: Text('Осень', style: textStyle),
                          ),
                          DropdownMenuItem(
                            value: PeriodTypeDashboardOne.winter,
                            child: Text('Зима', style: textStyle),
                          ),
                        ],
                        onChanged: (PeriodTypeDashboardOne? value) {
                          setState(() {
                            selectedPeriod = value!;
                            data = getDateRange(value);
                            print('Start: ${data.start}');
                            print('End: ${data.end}');
                          });
                        },
                      ),
                    ),
                  ],
                ),
                // Первый расширяемый виджет
                Expanded(
                  child:
                  Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: 8.h,
                      horizontal: 16.w,
                    ),

                    child: Container(
                      constraints: BoxConstraints(
                        maxHeight: 460.h,
                        minHeight: 460.h
                      ),
                      alignment: Alignment.center,
                      padding: EdgeInsets.only(top: 8.h, right: 8.w),
                      decoration: BoxDecoration(
                        color: AppColors.backgroundCardColor,
                        borderRadius: BorderRadius.circular(10.r)
                      ),
                      child: DashboardOneTiketInt(
                        startData: data.start,
                        endData: data.end,
                        company: null,
                        period: selectedPeriod,
                      ),
                    ),
                  ),
                ),
                // Второй расширяемый виджет
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      bottom: 5.w,
                      left: 16.h,
                      right: 16.h,
                    ),
                    child: Container(
                      constraints: BoxConstraints(
                          maxHeight: 460.h,
                          minHeight: 460.h
                      ),
                      alignment: Alignment.center,
                      padding: EdgeInsets.only(top: 8.h, right: 8.w),
                      decoration: BoxDecoration(
                          color: AppColors.backgroundCardColor,
                          borderRadius: BorderRadius.circular(10.r)
                      ),
                      child: DashboardOneTiketOut(
                        startData: data.start,
                        endData: data.end,
                        company: null,
                        period: selectedPeriod,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Кнопка поверх и по центру
          Container(
            alignment: Alignment.centerRight,
            padding: EdgeInsets.only(top: 25.w, right: 20.h),
            child: FloatingActionButton.small(
              onPressed: () {
                // Действие кнопки
              },
              child: Icon(Icons.sync), // или любая другая иконка
            ),
          ),
        ],
      ),
    );
  }

}
