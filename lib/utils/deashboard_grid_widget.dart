import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:service_desk/const/const_colors.dart';
import 'package:service_desk/models/reports_model/report_response_model.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class DeashboardGridWidget extends DataGridSource{
  List<DataGridRow> _rows = [];

  DeashboardGridWidget({required List<ReportRowResponse> tickets}){
  _buildRows(tickets: tickets);
  }
  void _buildRows({required List<ReportRowResponse> tickets}) {
    _rows = tickets.asMap().entries.map((entry) {
      final index = entry.key + 1; // нумерация с 1
      final report = entry.value;
      return DataGridRow(cells: [
        DataGridCell<int>(columnName: 'index', value: index),
        DataGridCell<String>(columnName: 'label', value: report.label),
        DataGridCell<int>(columnName: 'count', value: report.count),
        DataGridCell<int>(columnName: 'closedCount', value: report.closedCount),
        DataGridCell<int>(columnName: 'overdueCount', value: report.overdueCount),
      ]);
    }).toList();
  }
  @override
  List<DataGridRow> get rows => _rows;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    return DataGridRowAdapter(
      cells: row.getCells().map((cell) {
        return Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: AppColors.borderCardColor,
                width: 1.w
              ),

              right:  cell.columnName == 'overdueCount' ? BorderSide.none :  BorderSide(
                  color: AppColors.borderCardColor,
                  width: 1.w
              ),
            )
          ),
          child: _formatCell(cell)
        );
      }).toList(),
    );
  }


  Text _formatCell(DataGridCell cell) {
    if (cell.columnName == 'overdueCount') {
      if(cell.value > 0){
      return  Text(
       cell.value.toString(),
       style: GoogleFonts.poppins(
         color: AppColors.dorderError,
         fontSize: 10.sp.clamp(10, 20),
         fontWeight: FontWeight.w500
       ),
      );
      }else {
        return  Text(
          cell.value.toString(),
          style: GoogleFonts.poppins(
              color: AppColors.hintTextColor,
              fontSize: 10.sp.clamp(10, 20),
              fontWeight: FontWeight.w500
          ),
        );
      }
    }else if(cell.columnName == 'label'){
      return  Text(
        cell.value.toString(),
        style: GoogleFonts.poppins(
            color: AppColors.textColorOne,
            fontSize: 10.sp.clamp(10, 20),
            fontWeight: FontWeight.w700
        ),
      );
    }
    else{
      if(cell.value > 0){
       return Text(
          cell.value.toString(),
          style: GoogleFonts.poppins(
              color: AppColors.textColorOne,
              fontSize: 10.sp.clamp(10, 20),
              fontWeight: FontWeight.w500
          ),
        );
      }else{
       return Text(
          cell.value.toString(),
          style: GoogleFonts.poppins(
              color: AppColors.hintTextColor,
              fontSize: 10.sp.clamp(10, 20),
              fontWeight: FontWeight.w500
          ),
        );
      }
    }
  }



}