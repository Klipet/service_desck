import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:service_desk/models/tikets_models/tiket_response.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

import '../../const/const_app.dart';
import '../../const/const_colors.dart';
import '../../models/model_data_table_tiket/column_config.dart';
import '../../utils/ticket_grid_widget.dart';
import '../dialogs/column_manager_dialog.dart';

class TiketGreatTable extends StatefulWidget {
  final List<TicketResponse> tickets;

  const TiketGreatTable({super.key, required this.tickets});

  @override
  State<TiketGreatTable> createState() => _TiketGreatTableState();
}

class _TiketGreatTableState extends State<TiketGreatTable> {
   TicketGridWidget? _dataSource;
  late List<ColumnConfig> _columnConfigs = [
    ColumnConfig(columnName: 'id', label: 'ID', width: 50),
    ColumnConfig(columnName: 'title', label: 'Заголовок', width: 350),
    ColumnConfig(columnName: 'phone', label: 'Телефон', width: 150),
    ColumnConfig(columnName: 'bugNumber', label: 'Номер бага', width: 150),
    ColumnConfig(columnName: 'dataCreted', label: 'Дата создания', width: 150),
    ColumnConfig(
      columnName: 'dataModefire',
      label: 'Дата изменения',
      width: 150,
    ),
    ColumnConfig(columnName: 'userName', label: 'Пользователь', width: 150),
    ColumnConfig(columnName: 'workSpaceName', label: 'Воркспейс', width: 150),
    ColumnConfig(columnName: 'stateName', label: 'Статус', width: 120),
    ColumnConfig(columnName: 'typeTiketName', label: 'Тип тикета', width: 130),
    ColumnConfig(columnName: 'preorityName', label: 'Приоритет', width: 120),
    ColumnConfig(columnName: 'modeName', label: 'Режим', width: 110),
    ColumnConfig(columnName: 'subCategoryName', label: 'Подкатегория',width: 140,),
    ColumnConfig(columnName: 'categoryName', label: 'Категория', width: 130),
    ColumnConfig(columnName: 'authorName', label: 'Автор', width: 130),
    ColumnConfig(columnName: 'platformName', label: 'Платформа', width: 120),
    ColumnConfig(columnName: 'companyName', label: 'Компания', width: 130),
    ColumnConfig(columnName: 'dueDate', label: 'Дедлайн', width: 130),
  ];

  @override
  void initState() {
    super.initState();
    _loadColumnSettings().then((_) {
      _dataSource = TicketGridWidget(
        tickets: widget.tickets,
        columnConfigs: _columnConfigs,
      );
      setState(() {});
    });
  }

  // Сохраняем порядок и видимость
  Future<void> _saveColumnSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final data = _columnConfigs.map((c) => {
      'columnName': c.columnName,
      'visible': c.visible,
    }).toList();
    await prefs.setString(prefKey, jsonEncode(data));
  }

// Восстанавливаем порядок и видимость
  Future<void> _loadColumnSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(prefKey);
    if (raw == null) return;

    try {
      final List saved = jsonDecode(raw);

      // Строим map: columnName -> настройки
      final savedMap = {
        for (final item in saved)
          item['columnName'] as String: item,
      };

      // Восстанавливаем порядок по сохранённому списку
      final reordered = <ColumnConfig>[];

      for (final item in saved) {
        final name = item['columnName'] as String;
        final config = _columnConfigs.firstWhere(
              (c) => c.columnName == name,
          orElse: () => ColumnConfig(columnName: '', label: '', width: 0),
        );
        if (config.columnName.isEmpty) continue;
        config.visible = item['visible'] as bool;
        reordered.add(config);
      }

      // Добавляем новые колонки которых не было в сохранении
      for (final c in _columnConfigs) {
        if (!savedMap.containsKey(c.columnName)) {
          reordered.add(c);
        }
      }
      _columnConfigs
        ..clear()
        ..addAll(reordered);
    } catch (_) {
      // Если сохранение повреждено — оставляем дефолт
    }
  }

  @override
  void didUpdateWidget(TiketGreatTable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.tickets != widget.tickets) {
      _dataSource!.updateTickets(widget.tickets);
    }
  }

  void _showColumnManager() {
    showDialog(
      context: context,
      builder: (_) => ColumnManagerDialog(
        configs: _columnConfigs,
        onChanged: () {
          setState(() {
            _dataSource!.updateTickets(widget.tickets);
            _saveColumnSettings(); // ✅
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final visibleConfigs = _columnConfigs.where((c) => c.visible).toList();

    if (visibleConfigs.isEmpty) {
      return const Center(child: Text('Все колонки скрыты'));
    }
    if (_dataSource == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        // Тулбар
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.backgroundColor,
            border: Border(
              bottom: BorderSide(color: Theme.of(context).dividerColor),
            ),
          ),
          child: Row(
            children: [
              TextButton.icon(
                onPressed: _showColumnManager,
                icon: const Icon(Icons.view_column_outlined, size: 18),
                label: const Text('Колонки'),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: SfDataGrid(
            key: ValueKey(_columnConfigs.map((c) => c.columnName).join()),
            source: _dataSource!,
            allowSorting: true,
            columnWidthMode: ColumnWidthMode.fitByColumnName,
            allowMultiColumnSorting: true,
            allowFiltering: true,
            allowColumnsDragging: true,
            allowColumnsResizing: true,
            allowExpandCollapseGroup: true,
            gridLinesVisibility: GridLinesVisibility.both,
            headerGridLinesVisibility: GridLinesVisibility.both,
            onColumnDragging: (details) {
              if (details.action == DataGridColumnDragAction.dropped) {
                final from = details.from;
                final to = details.to;
                if (to == null) return true;

                setState(() {
                  // Работаем только с видимыми
                  final visibleConfigs = _columnConfigs
                      .where((c) => c.visible)
                      .toList();

                  final moved = visibleConfigs.removeAt(from);
                  visibleConfigs.insert(to, moved);

                  // Восстанавливаем полный список с новым порядком видимых
                  final hidden = _columnConfigs.where((c) => !c.visible).toList();
                  _columnConfigs = [...visibleConfigs, ...hidden];

                  _dataSource = TicketGridWidget(
                    tickets: widget.tickets,
                    columnConfigs: visibleConfigs,
                  );
                });

                _saveColumnSettings();
                return true;
              }
              return true;
            },
            columns: _buildColumns(),
          ),
        ),
      ],
    );
  }

  List<GridColumn> _buildColumns() {
    return _columnConfigs
        .where((c) => c.visible)
        .map((c) => GridColumn(
      columnName: c.columnName,
      columnWidthMode: ColumnWidthMode.fitByColumnName,
      minimumWidth: c.columnName == 'title' ? 300 : double.nan, // ✅ только для title
      label: Container(
        padding: const EdgeInsets.all(8),
        alignment: Alignment.centerLeft,
        child: Text(
          c.label,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    ))
        .toList();
  }

  Widget _header(String text) {
    return Container(
      padding: const EdgeInsets.all(8),
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
