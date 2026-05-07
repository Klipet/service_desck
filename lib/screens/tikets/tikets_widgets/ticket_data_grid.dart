import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import '../../../const/const_colors.dart';
import '../../../models/model_data_table_tiket/column_config.dart';
import '../../../utils/ticket_grid_widget.dart';


class TicketDataGrid extends StatelessWidget {
  final TicketGridWidget dataSource;
  final List<ColumnConfig> columnConfigs;
  final Map<String, double> columnWidths;
  final Function(String name, double width) onColumnResized;
  final Function(int from, int to) onColumnMoved;

  const TicketDataGrid({
    super.key,
    required this.dataSource,
    required this.columnConfigs,
    required this.columnWidths,
    required this.onColumnResized,
    required this.onColumnMoved,
  });

  List<GridColumn> _buildColumns() {
    return columnConfigs
        .where((c) => c.visible)
        .map((c) => GridColumn(
      columnName: c.columnName,
      columnWidthMode: ColumnWidthMode.fitByColumnName,
      width: c.columnName == 'title'
          ? 350.w
          : (columnWidths[c.columnName] ?? double.nan),
      label: Container(
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.only(left: 8.w),
        decoration: BoxDecoration(
          border: Border.symmetric(
            vertical: BorderSide(color: AppColors.borderCardColor),
          ),
        ),
        child: Text(
          c.label,
          style: GoogleFonts.poppins(
            color: AppColors.backgroundColor,
            fontSize: 10.sp,
            fontWeight: FontWeight.w700,
            fontStyle: FontStyle.italic,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    ))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SfDataGridTheme(
        data: SfDataGridThemeData(
          headerColor: AppColors.dataGreadColorTitle,
        ),
        child: SfDataGrid(
          key: ValueKey(columnConfigs.map((c) => c.columnName).join()),
          source: dataSource,
          headerRowHeight: 24.h,
          rowHeight: 24.h,
          allowSorting: false,
          columnWidthMode: ColumnWidthMode.none,
          allowColumnsResizing: true,
          allowColumnsDragging: true,
          gridLinesVisibility: GridLinesVisibility.none,
          headerGridLinesVisibility: GridLinesVisibility.none,
          onColumnResizeUpdate: (details) {
            onColumnResized(details.column.columnName, details.width);
            return true;
          },
          onColumnDragging: (details) {
            if (details.action == DataGridColumnDragAction.dropped &&
                details.to != null) {
              onColumnMoved(details.from, details.to!);
            }
            return true;
          },
          columns: _buildColumns(),
        ),
      ),
    );
  }
}