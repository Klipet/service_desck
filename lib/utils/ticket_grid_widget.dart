
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:service_desk/models/model_data_table_tiket/employee_ticket.dart';
import 'package:service_desk/models/tikets_models/tiket_response.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

import '../const/const_colors.dart';
import '../models/model_data_table_tiket/column_config.dart';

class TicketGridWidget extends DataGridSource{
  final List<ColumnConfig> columnConfigs;
  final Function(List<int>)? onSelectionChanged;
  List<DataGridRow> _rows = [];
  final Set<int> _selectedIds = {}; // 👈
  List<TicketResponse> _tickets = [];

  TicketGridWidget({this.onSelectionChanged, required List<TicketResponse> tickets,  required this.columnConfigs}) {
    _tickets = tickets;
    _buildRows(tickets: tickets);
  }

  bool get allSelected => // 👈
  _tickets.isNotEmpty && _selectedIds.length == _tickets.length;

  void toggleAll() { // 👈
    if (allSelected) {
      _selectedIds.clear();
    } else {
      _selectedIds.addAll(_tickets.map((t) => t.id));
    }
    onSelectionChanged?.call(_selectedIds.toList());
    notifyListeners();
  }

  void toggleRow(int id) { // 👈
    if (_selectedIds.contains(id)) {
      _selectedIds.remove(id);
    } else {
      _selectedIds.add(id);
    }
    onSelectionChanged?.call(_selectedIds.toList());
    notifyListeners();
  }

  void _buildRows ({required List<TicketResponse> tickets,}) {
    _rows = tickets.map((t) {
      final allCells = <String, dynamic>{
        'checkbox':   false,
        'newMessage': false,
        'id':              t.id,
        'title':           t.title ?? '—',
        'phone':           t.phone ?? '—',
        'bugNumber':       t.bugNumber ?? '—',
        'dataCreted':      t.dataCreted,
        'dataModefire':    t.dataModefire,
        'userName':        t.userName ?? '—',
        'workSpaceName':   t.workSpaceName ?? '—',
        'stateName':       t.stateName ?? '—',
        'typeTiketName':   t.typeTiketName ?? '—',
        'preorityName':    t.preorityName ?? '—',
        'modeName':        t.modeName ?? '—',
        'subCategoryName': t.subCategoryName ?? '—',
        'categoryName':    t.categoryName ?? '—',
        'authorName':      t.authorName ?? '—',
        'platformName':    t.platformName ?? '—',
        'companyName':     t.companyName ?? '—',
        'dueDate':         t.dueDate,
      };
      final visibleColumns = columnConfigs.where((c) => c.visible).toList();
      final cells = visibleColumns.map((c) => DataGridCell(
        columnName: c.columnName,
        value: allCells[c.columnName],
      )).toList();
      return DataGridRow(cells: cells);
    }).toList();
  }


  void updateTickets(List<TicketResponse> tickets) {
    _tickets = tickets;
    _selectedIds.clear();
    tickets.sort((a, b) => b.id.compareTo(a.id)); // 🔥 от большего к меньшему
    _buildRows(tickets: tickets);
    notifyListeners();
  }

  @override
  List<DataGridRow> get rows => _rows;


  @override
  DataGridRowAdapter? buildRow(DataGridRow row) {
    final id = row.getCells().firstWhere((c) => c.columnName == 'id').value as int;
    final isSelected = _selectedIds.contains(id);

    return DataGridRowAdapter(
        color: isSelected
            ? AppColors.backgroundCardColor // 👈 цвет выбранной строки
            : null,
      cells: row.getCells()
      .map((cell) {
        // Булевые поля — иконка
        if (cell.columnName == 'checkbox') {
          return GestureDetector(
            onTap: () => toggleRow(id), // 👈
            child: Container(
              alignment: Alignment.center,
              child: SvgPicture.asset(
                isSelected
                    ? 'assets/image/tool_bar_ticket/checkbox.svg'  // 👈
                    : 'assets/image/tool_bar_ticket/checkbox_false.svg',
                width: 16.w,
                height: 16.h,
              //  color: isSelected ? AppColors.dataGreadColorTitle : Colors.grey,
              ),
            ),
          );
        }

        if (cell.columnName == 'newMessage') {
          final hasNew = cell.value as bool? ?? false;
          return Container(
            alignment: Alignment.center,
            child: SvgPicture.asset(
              'assets/image/tool_bar_ticket/inbox.svg', // 👈 замени на свою иконку
              width: 16.w,
              height: 16.h,
              color: hasNew ? Colors.green : Colors.grey,
            ),
          );
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          alignment: Alignment.centerLeft,
          child: Text(
            cell.value?.toString() ?? '—',
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 13),
          ),
        );
      }).toList()

    );
  }
}

