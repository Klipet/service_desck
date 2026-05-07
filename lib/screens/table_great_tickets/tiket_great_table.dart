import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:service_desk/models/tikets_models/tiket_response.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_core/theme.dart';
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
  late List<TicketResponse> _filteredTickets;
  String? _selectedStatus;
  Map<String, double> _columnWidths = {};

  late List<ColumnConfig> _columnConfigs = [
    ColumnConfig(columnName: 'id', label: 'ID', width: 20.w),
    ColumnConfig(columnName: 'title', label: 'Заголовок', width: 315.w),
    ColumnConfig(columnName: 'phone', label: 'Телефон', width: 150.w),
    ColumnConfig(columnName: 'bugNumber', label: 'Номер бага', width: 150.w),
    ColumnConfig(
      columnName: 'dataCreted',
      label: 'Дата создания',
      width: 134.w,
    ),
    ColumnConfig(
      columnName: 'dataModefire',
      label: 'Дата изменения',
      width: 122.w,
    ),
    ColumnConfig(columnName: 'userName', label: 'Пользователь', width: 150.w,),
    ColumnConfig(columnName: 'workSpaceName', label: 'Воркспейс', width: 150.w),
    ColumnConfig(columnName: 'stateName', label: 'Статус', width: 106.w),
    ColumnConfig(
      columnName: 'typeTiketName',
      label: 'Тип тикета',
      width: 110.w,
    ),
    ColumnConfig(columnName: 'preorityName', label: 'Приоритет', width: 120.w),
    ColumnConfig(columnName: 'modeName', label: 'Режим', width: 110.w),
    ColumnConfig(
      columnName: 'subCategoryName',
      label: 'Подкатегория',
      width: 140.w,
    ),
    ColumnConfig(columnName: 'categoryName', label: 'Категория', width: 130.w),
    ColumnConfig(columnName: 'authorName', label: 'Автор', width: 114.w),
    ColumnConfig(columnName: 'platformName', label: 'Платформа', width: 120.w),
    ColumnConfig(columnName: 'companyName', label: 'Компания', width: 130.w),
    ColumnConfig(columnName: 'dueDate', label: 'Дедлайн', width: 130.w),
  ];

  List<String> get _uniqueStatuses {
    return widget.tickets
        .map((t) => t.stateName)
        .whereType<String>()
        .toSet()
        .toList();
  }

  @override
  void initState() {
    super.initState();
    _filteredTickets = List.from(widget.tickets)..sort((a, b) => b.id.compareTo(a.id));
    _loadColumnSettings().then((_) {
      _dataSource = TicketGridWidget(
        tickets: _filteredTickets,
        columnConfigs: _columnConfigs,
      );
      setState(() {});
    });
    _loadWidths();
  }

  // Сохраняем порядок и видимость
  Future<void> _saveColumnSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final data = _columnConfigs
        .map((c) => {'columnName': c.columnName, 'visible': c.visible})
        .toList();
    await prefs.setString(prefKey, jsonEncode(data));
  }

  Future<void> _saveColumnWidths(Map<String, double> widths) async {
    final prefs = await SharedPreferences.getInstance();

    final jsonString = jsonEncode(widths);
    await prefs.setString(prefWidth, jsonString);
  }
  Future<void> _loadWidths() async {
    _columnWidths = await _getColumnWidths();
    setState(() {});
  }

  Future<Map<String, double>> _getColumnWidths() async {
    final prefs = await SharedPreferences.getInstance();

    final jsonString = prefs.getString(prefWidth);
    if (jsonString == null) return {};

    final Map<String, dynamic> decoded = jsonDecode(jsonString);

    return decoded.map((key, value) => MapEntry(key, value.toDouble()));
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
        for (final item in saved) item['columnName'] as String: item,
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
      _dataSource!.updateTickets(_filteredTickets);
  }

  void _showColumnManager() {
    showDialog(
      context: context,
      builder: (_) =>
          ColumnManagerDialog(
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

  final textStyle = GoogleFonts.poppins(
    fontWeight: FontWeight.w300,
    fontSize: 10.sp.clamp(10, 20),
    color: AppColors.hintTextColor,
  );

  final border = OutlineInputBorder(
    borderRadius: BorderRadius.circular(100.r),
    borderSide: BorderSide(color: AppColors.borderCardColor, width: 1.w),
  );

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
          height: 50.h,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.backgroundColor,
            border: Border(
              bottom: BorderSide(color: Theme
                  .of(context)
                  .dividerColor),
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
              Spacer(),
              Container(
                width: 208.w,
                height: 24.h,
                margin: EdgeInsets.only(top: 8.h, right: 16.w),
                child: DropdownButtonFormField<String?>(
                  value: _selectedStatus,
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
                    const DropdownMenuItem<String?>(
                      value: null,
                      child: Text('Все статусы'),
                    ),
                    ..._uniqueStatuses.map((status) {
                      return DropdownMenuItem<String?>(
                        value: status,
                        child: Text(status),
                      );
                    }),
                  ],
                  onChanged: (value) {
                    //  if (value == null) return;
                    setState(() {
                      _selectedStatus = value;
                      _applyFilter();
                    });
                  },
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: SfDataGridTheme(
            data: SfDataGridThemeData(
              headerColor: AppColors.dataGreadColorTitle,
            ),
            child: SfDataGrid(
              key: ValueKey(_columnConfigs.map((c) => c.columnName).join()),
              source: _dataSource!,
              headerRowHeight: 24.h,
              rowHeight: 24.h,
              allowSorting: false,
              columnWidthMode: ColumnWidthMode.none,
              allowMultiColumnSorting: false,
              allowFiltering: false,
              allowColumnsDragging: true,
              allowColumnsResizing: true,
              allowExpandCollapseGroup: true,
              gridLinesVisibility: GridLinesVisibility.none,
              headerGridLinesVisibility: GridLinesVisibility.none,

              onColumnResizeUpdate: (details) {
                setState(() {
                  _columnWidths[details.column.columnName] = details.width;
                });
                return true;
              },
              onColumnResizeEnd: (details) {
                _saveColumnWidths(_columnWidths);
              },

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
                    final hidden = _columnConfigs
                        .where((c) => !c.visible)
                        .toList();
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

        ),
      ],
    );
  }

  List<GridColumn> _buildColumns() {
    return _columnConfigs
        .where((c) => c.visible)
        .map(
          (c) =>
          GridColumn(
            columnName: c.columnName,
            columnWidthMode: ColumnWidthMode.fitByColumnName,
            width: c.columnName == 'title'
                ? 350.w
                : (_columnWidths[c.columnName] ?? double.nan),
            // ✅ только для title
            label: Container(
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.only(left: 8.w),
              decoration: BoxDecoration(
                  border: Border.symmetric(vertical: BorderSide(
                      color: AppColors.borderCardColor
                  ), horizontal: BorderSide.none)
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
          ),
    )
        .toList();
  }

  void _applyFilter() {
    setState(() {
      if (_selectedStatus == null) {
        // ✅ берём оригинальный полный список
        _filteredTickets = List.from(widget.tickets)..sort((a, b) => b.id.compareTo(a.id));
      } else {
        // фильтруем из оригинального списка, не из _filteredTickets
        _filteredTickets = widget.tickets.where((t) {
          return t.stateName == _selectedStatus;
        }).toList()..sort((a, b) => b.id.compareTo(a.id));
      }
      _dataSource!.updateTickets(_filteredTickets);
    });
  }
}
