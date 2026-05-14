import 'package:flutter/material.dart';


import '../../const/const_app.dart';
import '../../models/model_data_table_tiket/column_config.dart';
import '../../models/tikets_models/tiket_response.dart';
import '../../utils/ticket_grid_widget.dart';
import '../dialogs/column_manager_dialog.dart';
import 'column_settings_service.dart';
import 'tikets_widgets/ticket_data_grid.dart';
import 'tikets_widgets/ticket_toolbar.dart';

class TicketTableScreen extends StatefulWidget {
  final List<TicketResponse> tickets;
  const TicketTableScreen({super.key, required this.tickets});

  @override
  State<TicketTableScreen> createState() => _TicketTableScreenState();
}

class _TicketTableScreenState extends State<TicketTableScreen> {

  final _settingsService = ColumnSettingsService();

  List<ColumnConfig> _columnConfigs = [];
  Map<String, double> _columnWidths = {};
  String? _selectedStatus;
  TicketGridWidget? _dataSource;
  late List<TicketResponse> _filteredTickets;

  List<String> get _uniqueStatuses => widget.tickets
      .map((t) => t.stateName)
      .whereType<String>()
      .toSet()
      .toList();

  @override
  void initState() {
    super.initState();
    _filteredTickets = _sorted(widget.tickets);
    _init();
  }

  Future<void> _init() async {
   final defaults = defaultColumns(context);
    _columnConfigs = await _settingsService.loadColumnSettings(defaults);
    _columnWidths = await _settingsService.loadColumnWidths();
    _dataSource = TicketGridWidget(
      tickets: _filteredTickets,
      columnConfigs: _columnConfigs,
    );
    setState(() {});
  }

  @override
  void didUpdateWidget(TicketTableScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    _filteredTickets = _sorted(widget.tickets);
    _dataSource?.updateTickets(_filteredTickets);
  }

  List<TicketResponse> _sorted(List<TicketResponse> list) =>
      List.from(list)..sort((a, b) => b.id.compareTo(a.id));

  void _applyFilter() {
    setState(() {
    _filteredTickets = _selectedStatus == null
        ? _sorted(widget.tickets)
        : _sorted(widget.tickets.where((t) => t.stateName == _selectedStatus).toList());
    _dataSource?.updateTickets(_filteredTickets);
    });
  }

  void _showColumnManager() {
    showDialog(
      context: context,
      builder: (_) => ColumnManagerDialog(
        configs: _columnConfigs,
        onChanged: () {
          setState(() {
            _dataSource?.updateTickets(_filteredTickets);
            _settingsService.saveColumnSettings(_columnConfigs);
          });
        },
      ),
    );
  }

  void _onColumnMoved(int from, int to) {
    setState(() {
      final visible = _columnConfigs.where((c) => c.visible).toList();
      final moved = visible.removeAt(from);
      visible.insert(to, moved);
      final hidden = _columnConfigs.where((c) => !c.visible).toList();
      _columnConfigs = [...visible, ...hidden];
      _dataSource = TicketGridWidget(
        tickets: _filteredTickets,
        columnConfigs: visible,
      );
    });
    _settingsService.saveColumnSettings(_columnConfigs);
  }

  @override
  Widget build(BuildContext context) {
    if (_dataSource == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_columnConfigs.where((c) => c.visible).isEmpty) {
      return Column(
        children: [
          TicketToolbar(
            statuses: _uniqueStatuses,
            selectedStatus: _selectedStatus,
            onStatusChanged: (val) {
              setState(() {
                _selectedStatus = val;
              });
              _applyFilter(); //
            },
            onManageColumns: _showColumnManager,
            allTickets: [],
            onFilterChanged: (List<TicketResponse> value) {  },
          ),
          Center(child: Text('Все колонки скрыты')),
        ],
      );
    }
    return Column(
      children: [
        // Просто передаёт данные вниз — сам не строит UI
        TicketToolbar(
          statuses: _uniqueStatuses,
          selectedStatus: _selectedStatus,
          onStatusChanged: (val) {
            setState(() {
              _selectedStatus = val;
            });
            _applyFilter(); //
          },
          onManageColumns: _showColumnManager,
          allTickets: [],
          onFilterChanged: (List<TicketResponse> value) {  },
        ),

        TicketDataGrid(
          dataSource: _dataSource!,
          columnConfigs: _columnConfigs,
          columnWidths: _columnWidths,
          onColumnResized: (name, width) {
            _columnWidths[name] = width;
            _settingsService.saveColumnWidths(_columnWidths);
          },
          onColumnMoved: _onColumnMoved
        ),
      ],
    );
  }
}
