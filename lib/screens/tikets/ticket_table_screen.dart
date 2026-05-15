import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/tiket_blocs/tiket_bloc.dart';
import '../../blocs/tiket_blocs/tiket_event.dart';
import '../../blocs/tiket_blocs/tiket_state.dart';
import '../../const/const_app.dart';
import '../../models/model_data_table_tiket/column_config.dart';
import '../../models/tikets_models/tiket_response.dart';
import '../../services/ticket_service.dart';
import '../../utils/ticket_grid_widget.dart';
import '../dialogs/column_manager_dialog.dart';
import 'column_settings_service.dart';
import 'tikets_widgets/ticket_data_grid.dart';
import 'tikets_widgets/ticket_tab_filter.dart';
import 'tikets_widgets/ticket_toolbar.dart';

class TicketScreen extends StatelessWidget {
  const TicketScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => TicketBloc(TicketService())..add(LoadTickets()),
      child: TicketTableScreenUI(),
    );
  }
}

class TicketTableScreenUI extends StatefulWidget {
  const TicketTableScreenUI({super.key});

  @override
  State<TicketTableScreenUI> createState() => _TicketTableScreenUIState();
}

class _TicketTableScreenUIState extends State<TicketTableScreenUI> {
  // ── Services ──────────────────────────────────────────────────────────────
  final _settingsService = ColumnSettingsService();

  // ── State ─────────────────────────────────────────────────────────────────
  List<ColumnConfig> _columnConfigs = [];
  Map<String, double> _columnWidths = {};
  TicketGridWidget? _dataSource;

  // Фильтрация
  String? _selectedStatus;
  List<TicketResponse> _allTickets = [];
  List<TicketResponse> _filteredTickets = [];

  @override
  void initState() {
    super.initState();
    context.read<TicketBloc>().add(LoadTickets());
    _init();
    //  _applyFilter();
  }

  Future<void> _init() async {
    final defaults = defaultColumns(context);
    final configs = await _settingsService.loadColumnSettings(defaults);
    final widths = await _settingsService.loadColumnWidths();
    if (!mounted) return;
    setState(() {
      _columnConfigs = configs;
      _columnWidths = widths;
    });
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  List<String> get _uniqueStatuses =>
      _allTickets.map((t) => t.stateName).whereType<String>().toSet().toList();

  List<TicketResponse> _sorted(List<TicketResponse> list) =>
      List.from(list)..sort((a, b) => b.id.compareTo(a.id));

  /// Вызывается при получении новых тикетов из BLoC
  void _onTicketsLoaded(List<TicketResponse> tickets) {
    _allTickets = tickets;
    _applyFilter();
  }

  void _applyFilter() {
    final filtered = _selectedStatus == null
        ? _sorted(_allTickets)
        : _sorted(
            _allTickets.where((t) => t.stateName == _selectedStatus).toList(),
          );
    setState(() {
      _filteredTickets = filtered;
      if (_dataSource == null) {
        _dataSource = TicketGridWidget(
          tickets: _filteredTickets,
          columnConfigs: _columnConfigs,
        );
      } else {
        _dataSource!.updateTickets(_filteredTickets);
      }
    });
  }

  // ── Column management ─────────────────────────────────────────────────────
  void _showColumnManager() {
    showDialog(
      context: context,
      builder: (_) => ColumnManagerDialog(
        configs: _columnConfigs,
        onChanged: () {
          setState(() {
            _dataSource?.updateTickets(_filteredTickets);
          });
          _settingsService.saveColumnSettings(_columnConfigs);
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
    return Scaffold(
      body: Column(
        children: [
          // Просто передаёт данные вниз — сам не строит UI
          TicketToolbar(
            statuses: _uniqueStatuses,
            selectedStatus: _selectedStatus,
            onStatusChanged: (val) {
              setState(() => _selectedStatus = val);
              _applyFilter();
            },
            onManageColumns: _showColumnManager,
            allTickets: _allTickets,
            onLoadAll: () => context.read<TicketBloc>().add(LoadTickets()),
            onLoadMine: () => context.read<TicketBloc>().add(LoadMyTickets()),
            // ✅ Убран лишний setState — add() сам триггерит ребилд через BLoC
            onSearch: (query) =>
                context.read<TicketBloc>().add(TicketSearch(query)),
          ),

          //Нижняя часть Списка
          BlocBuilder<TicketBloc, TicketState>(
            buildWhen: (previous, current) {
              return current is TicketLoading ||
                  current is TicketLoaded ||
                  current is TicketError;
            },
            builder: (context, state) {
              print("🔄 UI rebuild: ${state.runtimeType}");
              if (state is TicketLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state is TicketLoaded) {
                if (_dataSource == null) {
                  return const Center(child: CircularProgressIndicator());
                }
                return TicketDataGrid(
                  dataSource: _dataSource!,
                  columnConfigs: _columnConfigs,
                  columnWidths: _columnWidths,
                  onColumnResized: (name, width) {
                    _columnWidths[name] = width;
                    _settingsService.saveColumnWidths(_columnWidths);
                  },
                  onColumnMoved: _onColumnMoved,
                );
              }
              if (state is TicketError) {
                return Center(child: Text(state.message));
              }
              return const SizedBox();
            },
          ),
        ],
      ),
    );
  }
}
