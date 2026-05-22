import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import '../../../const/const_colors.dart';
import '../../../models/model_data_table_tiket/column_config.dart';
import '../../../utils/ticket_grid_widget.dart';

class TicketDataGrid extends StatefulWidget {
  final TicketGridWidget dataSource;
  final List<ColumnConfig> columnConfigs;
  final Map<String, double> columnWidths;
  final Function(List<int>)? onSelectionChanged;
  final Function(String name, double width) onColumnResized;
  final Function(int from, int to) onColumnMoved;

  const TicketDataGrid({
    super.key,
    required this.dataSource,
    required this.columnConfigs,
    required this.columnWidths,
    required this.onColumnResized,
    required this.onColumnMoved,
    this.onSelectionChanged,
  });

  @override
  State<TicketDataGrid> createState() => _TicketDataGridState();
}

class _TicketDataGridState extends State<TicketDataGrid> {
  List<GridColumn> _buildColumns() {
    final pinned = ['checkbox', 'newMessage'];
    final sorted = [
      ...pinned.map((name) => widget.columnConfigs.firstWhere((c) => c.columnName == name)),
      ...widget.columnConfigs.where((c) => !pinned.contains(c.columnName) && c.visible),
    ];
    return sorted.map((c) => GridColumn(
            columnName: c.columnName,
            allowEditing: false,
      minimumWidth: (c.columnName == 'checkbox' || c.columnName == 'newMessage') ? 40.w : 30.w,
      maximumWidth: (c.columnName == 'checkbox' || c.columnName == 'newMessage') ? 40.w : double.infinity,
            columnWidthMode: (c.columnName == 'checkbox' || c.columnName == 'newMessage')
                ? ColumnWidthMode.none  // 👈 фиксированная ширина
                : ColumnWidthMode.fitByColumnName,
            width: c.columnName == 'title'
                ? 350.w
                : (widget.columnWidths[c.columnName] ?? c.width),
            label: _buildColumnsLable(c),
          ),
        ).toList();
  }

  Widget _buildColumnsLable(ColumnConfig cc) {
    if (cc.columnName == 'checkbox') {
      return _CheckboxHeader(dataSource: widget.dataSource);
    } else if (cc.columnName == 'newMessage') {
      return Container(
        alignment: Alignment.center,
        //  padding: EdgeInsets.only(left: 8.w),
        decoration: BoxDecoration(
          border: Border.symmetric(
            vertical: BorderSide(color: AppColors.borderCardColor),
          ),
        ),
        child: SvgPicture.asset(
          'assets/image/tool_bar_ticket/inbox.svg',
          color: AppColors.backgroundColor,
          width: 16.w,
          height: 16.h,
        ),
      );
    } else {
      return Container(
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.only(left: 8.w),
        decoration: BoxDecoration(
          border: Border.symmetric(
            vertical: BorderSide(color: AppColors.borderCardColor),
          ),
        ),
        child: Text(
          cc.label,
          style: GoogleFonts.poppins(
            color: AppColors.backgroundColor,
            fontSize: 10.sp,
            fontWeight: FontWeight.w500,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SfDataGridTheme(
      data: SfDataGridThemeData(headerColor: AppColors.dataGreadColorTitle),
      child: SfDataGrid(
        key: ValueKey(widget.columnConfigs.map((c) => c.columnName).join()),
        source: widget.dataSource,
        headerRowHeight: 24.h,
        rowHeight: 24.h,
        allowSorting: false,
        columnWidthMode: ColumnWidthMode.none,
        allowColumnsResizing: true,
        allowColumnsDragging: true,
        gridLinesVisibility: GridLinesVisibility.none,
        headerGridLinesVisibility: GridLinesVisibility.none,
        onColumnResizeUpdate: (details) {
          widget.onColumnResized(details.column.columnName, details.width);
          return true;
        },
        onColumnDragging: (details) {
          if (details.action == DataGridColumnDragAction.dropped &&
              details.to != null) {
            widget.onColumnMoved(details.from, details.to!);
          }
          return true;
        },
        columns: _buildColumns(),
      ),
    );
  }
}


class _CheckboxHeader extends StatefulWidget {
  final TicketGridWidget dataSource;

  const _CheckboxHeader({required this.dataSource});

  @override
  State<_CheckboxHeader> createState() => _CheckboxHeaderState();
}

class _CheckboxHeaderState extends State<_CheckboxHeader> {
  @override
  void initState() {
    super.initState();
    widget.dataSource.addListener(_onChanged); // 👈 слушаем изменения
  }

  @override
  void dispose() {
    widget.dataSource.removeListener(_onChanged);
    super.dispose();
  }

  void _onChanged() => setState(() {}); // 👈 перестраиваемся при toggleAll/toggleRow

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => widget.dataSource.toggleAll(),
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border.symmetric(
            vertical: BorderSide(color: AppColors.borderCardColor),
          ),
        ),
        child: SvgPicture.asset(
          widget.dataSource.allSelected
              ? 'assets/image/tool_bar_ticket/checkbox.svg'
              : 'assets/image/tool_bar_ticket/checkbox_false.svg',
          color: AppColors.backgroundColor,
          width: 16.w,
          height: 16.h,
        ),
      ),
    );
  }
}