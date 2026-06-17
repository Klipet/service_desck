import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:service_desk/const/const_colors.dart';
import 'package:service_desk/screens/dialogs/ticket_marge_dialog.dart';

import '../../blocs/tiket_blocs/tiket_bloc.dart';
import '../../blocs/tiket_blocs/tiket_event.dart';
import '../../blocs/tiket_blocs/tiket_state.dart';
import '../../const/const_app.dart';
import '../../data_base/user_repository.dart';
import '../../models/model_data_table_tiket/column_config.dart';
import '../../models/tikets_models/tiket_response.dart';
import '../../services/ticket_service.dart';
import '../../utils/navigator_provider.dart';
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
      create: (_) => TicketBloc(
        ticketService: TicketService(),
        userRepository: UserRepository(),
      )..add(LoadTickets()),
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
  final _gridKey = GlobalKey();

  // ── State ─────────────────────────────────────────────────────────────────
  List<ColumnConfig> _columnConfigs = [];
  Map<String, double> _columnWidths = {};
  TicketGridWidget? _dataSource;

  // Фильтрация
  String? _selectedStatus;
  List<TicketResponse> _allTickets = [];
  List<TicketResponse> _filteredTickets = [];

  List<int> ticketSelect = [];

  @override
  void initState() {
    super.initState();
    _init();
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

    // ✅ Если BLoC уже вернул данные пока грузились настройки
    if (_allTickets.isNotEmpty) {
      _applyFilter();
    }
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
    if (_columnConfigs.isEmpty) return;
    final filtered = _selectedStatus == null || _selectedStatus == 'Все заявки'
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
          onSelectionChanged: (ids) {
            ticketSelect = ids;
          },
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
    final pinned = ['checkbox', 'newMessage'];

    setState(() {
      // Берём только НЕ закреплённые видимые колонки
      final movable = _columnConfigs
          .where((c) => c.visible && !pinned.contains(c.columnName))
          .toList();

      // from/to приходят с учётом закреплённых — корректируем индекс
      final adjustedFrom = from - pinned.length;
      final adjustedTo = to - pinned.length;

      if (adjustedFrom < 0 || adjustedTo < 0) return; // 👈 защита от pinned
      if (adjustedFrom >= movable.length || adjustedTo >= movable.length)
        return;

      final moved = movable.removeAt(adjustedFrom);
      movable.insert(adjustedTo, moved);

      // Собираем обратно: закреплённые + подвижные + скрытые
      final pinnedConfigs = _columnConfigs
          .where((c) => pinned.contains(c.columnName))
          .toList();
      final hidden = _columnConfigs
          .where((c) => !c.visible && !pinned.contains(c.columnName))
          .toList();

      _columnConfigs = [...pinnedConfigs, ...movable, ...hidden];

      _dataSource = TicketGridWidget(
        tickets: _filteredTickets,
        columnConfigs: _columnConfigs.where((c) => c.visible).toList(),
      );
    });

    _settingsService.saveColumnSettings(_columnConfigs);
  }

  @override
  Widget build(BuildContext context) {
    final navigationProvider = Provider.of<NavigationProvider>(context);
  //  print("Главная заявка, Остальные заявки ${_uniqueStatuses.join(', ')}");
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
            onCreate: () {
              navigationProvider.goToPageAndDestroy(2);
            },
            onAttach: (){
              _alipireDialog(ticketSelect);
            },
            onEdit: (){
              _editTicket(navigationProvider ,ticketSelect);
            },
            onManageColumns: _showColumnManager,
            allTickets: _allTickets,
            onLoadAll: () => context.read<TicketBloc>().add(LoadTickets()),
            onLoadMine: () => context.read<TicketBloc>().add(LoadMyTickets()),
            onSearch: (query) =>
                context.read<TicketBloc>().add(TicketSearch(query)),
            responseGet:() => context.read<TicketBloc>().add(FetchAllMessages()),
          ),

          //Нижняя часть Списка
          Expanded(
            child: BlocConsumer<TicketBloc, TicketState>(
              buildWhen: (previous, current) {
                return current is TicketLoading ||
                    current is TicketLoaded ||
                    current is TicketError;
              },
              listener: (context, state) {
                if (state is TicketLoaded) {
                  _onTicketsLoaded(state.tickets);
                }
              },
              builder: (context, state) {
                if (state is TicketLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is TicketLoaded) {
                  if (_dataSource == null || _columnConfigs.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  return Container(
                    color: AppColors.backgroundColor,
                    child: TicketDataGrid(
                      key: _gridKey,
                      dataSource: _dataSource!,
                      columnConfigs: _columnConfigs,
                      columnWidths: _columnWidths,
                      onColumnResized: (name, width) {
                        _columnWidths[name] = width;
                        _settingsService.saveColumnWidths(_columnWidths);
                      },
                      onSelectionChanged: (ids) {},
                      onColumnMoved: _onColumnMoved,
                    ),
                  );
                }

                if (state is TicketError) {
                  return Center(child: Text(state.message));
                }
                return const SizedBox();
              },
            ),
          ),
        ],
      ),
    );
  }
  void _editTicket(NavigationProvider navigationProvider,  List<int> select) {
    if (select.length > 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Выберите только одну заявку для редактирования")),
      );
      return;
    }

    if (select.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Выберите заявку для редактирования")),
      );
      return;
    }

    final ticketId = select.first;
    navigationProvider.goToPageAndDestroy(2, ticketId: ticketId); // передаём ID
  }

  void _alipireDialog(List<int> select){
    if (select.isEmpty || select.length == 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("вы не выбрали заявку редактирования")),
      );
      return;
    }

    final bloc = context.read<TicketBloc>();

    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: bloc,
        child: BlocListener<TicketBloc, TicketState>(
          listener: (context, state) {
            if (state is TicketMargetSuccess) {
              Navigator.of(context).pop();
              bloc.add(LoadTickets());
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(backgroundColor: Colors.green, content: Text(state.tickets.message)),
              );
            }
            if (state is TicketMargetError) {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(backgroundColor: Colors.red, content: Text(state.tickets.message)),
              );
            }
          },
          child: TicketMargeDialog(
            select: select,
            onMerge: (primaryId, secondaryIds) {
              bloc.add(MenageTickets(primoryTiket: primaryId, secondariTikets: secondaryIds));
            },
          ),
        ),
      ),
    );
  }
}
