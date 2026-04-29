
import 'package:flutter/material.dart';
import 'package:service_desk/models/model_data_table_tiket/employee_ticket.dart';
import 'package:service_desk/models/tikets_models/tiket_response.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

import '../models/model_data_table_tiket/column_config.dart';

class TicketGridWidget extends DataGridSource{
  final List<ColumnConfig> columnConfigs;
  List<DataGridRow> _rows = [];

  TicketGridWidget({required List<TicketResponse> tickets,  required this.columnConfigs}) {
    _buildRows(tickets: tickets);
  }


  void _buildRows ({required List<TicketResponse> tickets,}) {
    _rows = tickets.map((t) {
      final allCells = <String, dynamic>{
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

      final cells = columnConfigs
          .where((c) => c.visible)
          .map((c) => DataGridCell(
        columnName: c.columnName,
        value: allCells[c.columnName],
      )).toList();

      return DataGridRow(cells: cells);
    }).toList();
  }


  void updateTickets(List<TicketResponse> tickets) {
    tickets.sort((a, b) => b.id.compareTo(a.id)); // 🔥 от большего к меньшему
    _buildRows(tickets: tickets);
    notifyListeners();
  }

  @override
  List<DataGridRow> get rows => _rows;


  @override
  DataGridRowAdapter? buildRow(DataGridRow row) {
    return DataGridRowAdapter(
      cells: row.getCells()
      .map((cell) {
        // Булевые поля — иконка
        if (cell.value is bool) {
          return Container(
            alignment: Alignment.center,
            child: Icon(
              cell.value as bool ? Icons.check_circle_outline : Icons.radio_button_unchecked,
              size: 18,
              color: cell.value as bool ? Colors.green : Colors.grey,
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

