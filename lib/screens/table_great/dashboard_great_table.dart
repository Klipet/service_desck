import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:service_desk/models/reports_model/report_response_model.dart';
import 'package:service_desk/utils/deashboard_grid_widget.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

import '../../const/const_colors.dart';
import '../../models/model_data_table_tiket/column_config.dart';
import '../../utils/ticket_grid_widget.dart';

class DashboardGreatTable extends StatefulWidget {
  final List<ReportRowResponse> tickets;
  const DashboardGreatTable({super.key, required this.tickets});

  @override
  State<DashboardGreatTable> createState() => _DashboardGreatTableState();
}

class _DashboardGreatTableState extends State<DashboardGreatTable> {
  DeashboardGridWidget? _gridWidget;

  @override
  void initState() {
    super.initState();
    _gridWidget = DeashboardGridWidget(tickets: widget.tickets);
  }

  @override
  void didUpdateWidget(covariant DashboardGreatTable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.tickets != widget.tickets) {
      _gridWidget = DeashboardGridWidget(tickets: widget.tickets);
    }
  }

  @override
  Widget build(BuildContext context) {
    if(_gridWidget == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return SfDataGrid(
      source: _gridWidget!,
      columnWidthMode: ColumnWidthMode.fill,
      gridLinesVisibility: GridLinesVisibility.none,
      headerGridLinesVisibility: GridLinesVisibility.none,
      headerRowHeight: 24.h,
      rowHeight: 24.h,
      columns: [
        GridColumn(
          columnName: 'index',
          minimumWidth: 24.w,
          maximumWidth: 32.w,
          label: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              border: Border.symmetric(horizontal: BorderSide(
                color: AppColors.borderCardColor,
                width: 1.w
              ))
            ),
            child: Text('Nr.', style: GoogleFonts.poppins(
                fontWeight: FontWeight.w700, fontSize: 10.sp.clamp(10, 20), color: AppColors.hintTextColor)),
          ),
        ),
        GridColumn(
          columnName: 'label',
          label: Container(
            decoration: BoxDecoration(
                border: Border.symmetric(horizontal: BorderSide(
                    color: AppColors.borderCardColor,
                    width: 1.w
                ))
            ),
            alignment: Alignment.center,
            child: Text('Статус',  style: GoogleFonts.poppins(
                fontWeight: FontWeight.w700, fontSize: 10.sp.clamp(10, 20), color: AppColors.hintTextColor)),
          ),
        ),
        GridColumn(
          columnName: 'count',
          label: Container(
            decoration: BoxDecoration(
                border: Border.symmetric(horizontal: BorderSide(
                    color: AppColors.borderCardColor,
                    width: 1.w
                ))
            ),
            alignment: Alignment.center,
            child:  Text('Всего',  style: GoogleFonts.poppins(
                fontWeight: FontWeight.w700, fontSize: 10.sp.clamp(10, 20), color: AppColors.hintTextColor)),
          ),
        ),
        GridColumn(
          columnName: 'closedCount',
          label: Container(
            decoration: BoxDecoration(
                border: Border.symmetric(horizontal: BorderSide(
                    color: AppColors.borderCardColor,
                    width: 1.w
                ))
            ),
            alignment: Alignment.center,
            child:Text('Закрыто',  style: GoogleFonts.poppins(
                fontWeight: FontWeight.w700, fontSize: 10.sp.clamp(10, 20), color: AppColors.hintTextColor)),
          ),
        ),
        GridColumn(
          columnName: 'overdueCount',
          label: Container(
            decoration: BoxDecoration(
                border: Border.symmetric(horizontal: BorderSide(
                    color: AppColors.borderCardColor,
                    width: 1.w
                ))
            ),
            alignment: Alignment.center,
            child:  Text('Просроче',  style: GoogleFonts.poppins(
                fontWeight: FontWeight.w700, fontSize: 10.sp.clamp(10, 20), color: AppColors.hintTextColor)),
          ),
        ),
      ],
    );
  }
}
