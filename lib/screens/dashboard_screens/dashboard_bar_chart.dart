import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:service_desk/blocs/report_bar_chart_blocs/report_bar_chart_bloc.dart';
import 'package:service_desk/blocs/report_bar_chart_blocs/report_bar_chart_state.dart';
import 'package:service_desk/blocs/report_dashboard_table_blocs/report_dasboard_table_bloc.dart';
import 'package:service_desk/blocs/report_dashboard_table_blocs/report_dasboard_table_state.dart';
import 'package:service_desk/const/const_colors.dart';

import '../../blocs/report_bar_chart_blocs/report_bar_chart_event.dart';
import '../../blocs/report_dashboard_table_blocs/report_dasboard_table_event.dart';
import '../../models/reports_model/report_post_model.dart';
import '../../models/reports_model/report_response_model.dart';
import '../../services/report_service.dart';
import '../../services/user_service.dart';
import '../table_great/dashboard_great_table.dart';

class DashboardBarChart extends StatelessWidget {
  const DashboardBarChart({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => ReportBarChartBloc(reportService: ReportService()),
        ),
        BlocProvider(
          create: (_) =>
              ReportDasboardTableBloc(reportService: ReportService()),
        ),
      ],
      child: DashboardBarChartUI(),
    );
  }
}

class DashboardBarChartUI extends StatefulWidget {
  const DashboardBarChartUI({super.key});

  @override
  State<DashboardBarChartUI> createState() => _DashboardBarChartUIState();
}

class _DashboardBarChartUIState extends State<DashboardBarChartUI> {
  final user = UserService.getUser();
  int touchedGroupIndex = -1;
  DateTime dataStart = DateTime.now().subtract(Duration(days: 190));
  DateTime dataEnd = DateTime.now();

  @override
  void initState() {
    context.read<ReportBarChartBloc>().add(
      ReportGenerateRequested(
        ReportPostModel(
          name: 'DashboardPieChart',
          dateFrom: dataStart,
          dateTo: dataEnd,
          showTotalCount: true,
          filterAuthorId: null,
          filterStatus: null,
          filterCategory: null,
          filterPriority: null,
          filterUserId: user?.userId ?? 0,
          groupBy: '2',
          sortBy: 'date',
          sortDescending: true,
          dateGrouping: ''
        ),
      ),
    );
    context.read<ReportDasboardTableBloc>().add(
      ReportTableGenerateRequested(
        ReportPostModel(
          name: 'DashboardPieChart',
          dateFrom: dataStart,
          dateTo: dataEnd,
          showTotalCount: true,
          filterAuthorId: null,
          filterStatus: null,
          filterCategory: null,
          filterPriority: null,
          filterUserId: user?.userId ?? 0,
          groupBy: '6',
          sortBy: 'date',
          sortDescending: true,
          dateGrouping: ''
        ),
      ),
    );
    super.initState();
  }

  Widget _titleWidget(bool isDesktop) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: EdgeInsets.only(left: 19.w),
          child: Text(
            "SOLICITĂRI",
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w700,
              fontSize: 20.sp.clamp(20, 30),
              color: AppColors.textTitleFl,
            ),
          ),
        ),
        Spacer(),
        Container(
          margin: EdgeInsets.only(right: 19.w),
          width: isDesktop ? 148.w : 148.w * 2,
          height: isDesktop ? 24.h : 24.h + 2,
          decoration: BoxDecoration(
            color: AppColors.backgroundColor,
            borderRadius: BorderRadius.circular(100.r),
            border: Border.all(color: AppColors.borderCardColor, width: 1.w),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "${_formatDate(dataStart)} - ${_formatDate(dataEnd)}",
                style: GoogleFonts.poppins(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w300,
                  color: AppColors.hintTextColor,
                ),
              ),
              SizedBox(width: 8.w),
              SvgPicture.asset(
                "assets/image/calendar.svg",
                width: 14.w,
                height: 14.h,
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveBreakpoints.of(context);
    return Container(
      margin: EdgeInsets.only(top: 14.w, left: 10.h, bottom: 5.w),
      padding: EdgeInsets.only(top: 8.h),
      decoration: BoxDecoration(
        color: AppColors.backgroundColor,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: AppColors.borderCardColor, width: 1.w),
      ),
      child: Column(
        children: [
          _titleWidget(responsive.isDesktop),
          BlocBuilder<ReportBarChartBloc, ReportBarChartState>(
            builder: (context, state) {
              if (state is ReportLoading) {
                return Center(child: CircularProgressIndicator());
              }
              if (state is ReportSuccess) {
                return Container(
                  child: _BarRow(
                    model: state.report.rows,
                    max: state.report.totalCount,
                  ),
                );
              }
              if (state is ReportFailure) {
                return Container(child: Text(state.message));
              }

              return Container(child: Text('Пусто'));
            },
          ),
          SizedBox(height: 15.h),
          BlocBuilder<ReportDasboardTableBloc, ReportDasboardTableState>(
            builder: (context, state) {
              if (state is ReportTableLoading) {
                return Center(child: CircularProgressIndicator());
              }
              if (state is ReportTableSuccess) {
                return Expanded(
                  child: DashboardGreatTable(tickets: state.report.rows),
                );
              }
              if (state is ReportTableFailure) {
                return Container(child: Text(state.message));
              }

              return Container(child: Text('Пусто'));
            },
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}";
  }
}

class _BarRow extends StatefulWidget {
  final List<ReportRowResponse> model;
  final int max;

  const _BarRow({super.key, required this.model, required this.max});

  @override
  State<_BarRow> createState() => _BarRowState();
}

class _BarRowState extends State<_BarRow> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.only(top: 8.h, left: 16.w, right: 16.w),
          child: Stack(
            alignment: Alignment.centerLeft,
            children: [
              Container(
                height: 26.h,
                width: double.maxFinite,
                decoration: BoxDecoration(
                  color: AppColors.backgroundCardColor,
                  borderRadius: BorderRadius.circular(100.r),
                ),
              ),
              Container(
                width: double.maxFinite,
                height: 20.h,
                margin: EdgeInsets.symmetric(horizontal: 3.h),
                decoration: BoxDecoration(
                  gradient: AppColors.gradientColor,
                  borderRadius: BorderRadius.circular(100.r),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Total",
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w700,
                          fontSize: 10.sp.clamp(10, 20),
                          color: AppColors.textTitleFl,
                        ),
                      ),
                      Spacer(),
                      Text(
                        "${widget.max}",
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w700,
                          fontSize: 10.sp.clamp(10, 20),
                          color: AppColors.textTitleFl,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        Column(
          children: widget.model.map((row) {
            final percent = widget.max == 0
                ? 0.0
                : (row.count / widget.max).clamp(0.0, 1.0);
            return LayoutBuilder(
              builder: (context, constant) {
                final barWidth = constant.maxWidth * percent;
                final minWidth = 105.0; // минимум чтобы текст влез
                final isMin = barWidth > (constant.maxWidth - 100.h);
                return Padding(
                  padding: EdgeInsets.only(top: 8.h, left: 16.w, right: 16.w),
                  child: Stack(
                    alignment: Alignment.centerLeft,
                    children: [
                      Container(
                        height: 26.h,
                        width: constant.maxWidth,
                        decoration: BoxDecoration(
                          color: AppColors.backgroundCardColor,
                          borderRadius: BorderRadius.circular(100.r),
                        ),
                        alignment: Alignment.centerRight,
                      ),
                      Container(
                        width: barWidth < minWidth ? minWidth : barWidth,
                        height: 20.h,
                        padding: EdgeInsets.symmetric(horizontal: 8.w),
                        margin: EdgeInsets.symmetric(horizontal: 3.h),
                        decoration: BoxDecoration(
                          gradient: AppColors.gradientColor,
                          borderRadius: BorderRadius.circular(100.r),
                        ),
                        alignment: Alignment.centerLeft,
                      ),
                      Positioned(
                        left: 11.w,
                        child: Text(
                          row.label,
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w700,
                            fontSize: 10.sp.clamp(10, 20),
                            color: AppColors.textTitleFl,
                          ),
                        ),
                      ),
                      // Число — поверх всего, справа
                      Positioned(
                        right: 11.w,
                        child: Text(
                          '${row.count}',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w700,
                            fontSize: 10.sp.clamp(10, 20),
                            color: isMin
                                ? AppColors.textTitleFl
                                : AppColors.hintTextColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          }).toList(),
        ),
      ],
    );
  }
}
