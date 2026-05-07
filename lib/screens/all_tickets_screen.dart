import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:service_desk/const/const_colors.dart';
import 'package:service_desk/screens/table_great_tickets/tiket_great_table.dart';

import 'package:service_desk/services/user_service.dart';
import 'package:signalr_netcore/hub_connection.dart';
import 'package:signalr_netcore/hub_connection_builder.dart';

import '../blocs/tiket_blocs/tiket_bloc.dart';
import '../blocs/tiket_blocs/tiket_event.dart';
import '../blocs/tiket_blocs/tiket_state.dart';
import '../main.dart';
import '../models/tikets_models/tiket_response.dart';
import '../services/ticket_service.dart';
import '../utils/ticket_grid_widget.dart';
import 'tikets/ticket_table_screen.dart';

class AllTicketsScreen extends StatelessWidget {
  const AllTicketsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // return BlocProvider(
    //   create: (_) => TicketBloc(TicketService())..add(LoadTickets()),
    return AllTicketsScreenUI();
    //  );
  }
}

class AllTicketsScreenUI extends StatefulWidget {
  const AllTicketsScreenUI({super.key});

  @override
  State<AllTicketsScreenUI> createState() => _AllTicketsScreenUIState();
}

class _AllTicketsScreenUIState extends State<AllTicketsScreenUI> {
  TicketResponse? _hoveredTicket;
  Offset _hoverOffset = Offset.zero;
  final ScrollController _scrollController = ScrollController();

  TicketGridWidget? dataSource;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.of(context).size;
    const cardWidth = 200.0;
    const cardHeight = 200.0;
    const offset = 10.0;
    final bottomSafe =
        kBottomNavigationBarHeight + MediaQuery.of(context).padding.bottom;

    double left = _hoverOffset.dx + offset;
    double top = _hoverOffset.dy + offset;
    // ограничение справа
    if (left + cardWidth > screen.width) {
      left = screen.width - cardWidth - offset;
    }
    // ограничение снизу (учитываем BottomNavigationBar)
    final bottomLimit = screen.height - bottomSafe;
    if (top + cardHeight > bottomLimit) {
      top = bottomLimit - cardHeight - offset;
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: BlocBuilder<TicketBloc, TicketState>(
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
            WidgetsBinding.instance.addPostFrameCallback((_) {
              dataSource?.updateTickets(state.tickets);
            });
            return TicketTableScreen(tickets: state.tickets);
          }

          if (state is TicketError) {
            return Center(child: Text(state.message));
          }

          return const SizedBox();
        },
      ),
    );
  }
}
