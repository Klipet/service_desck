import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/tiket_blocs/tiket_bloc.dart';
import '../../blocs/tiket_blocs/tiket_event.dart';
import '../../blocs/tiket_blocs/tiket_state.dart';
import '../../data_base/user_repository.dart';
import '../../services/ticket_service.dart';
import '../../utils/navigator_provider.dart';
import 'ticket_form_screen.dart';

class TicketDetailPage extends StatelessWidget {

  const TicketDetailPage({super.key,});

  @override
  Widget build(BuildContext context) {
    final ticketId = context.read<NavigationProvider>().ticketId;
      return BlocProvider(
        create: (_) => TicketBloc(
          ticketService: TicketService(),
          userRepository: UserRepository(),
        )..add(LoadTickets()),
        child: TicketDetailPageUI(ticketId: ticketId),
      );

  }
}


class TicketDetailPageUI extends StatefulWidget {
  final int? ticketId;

  const TicketDetailPageUI({super.key, this.ticketId});

  @override
  State<TicketDetailPageUI> createState() => _TicketDetailPageUIState();
}

class _TicketDetailPageUIState extends State<TicketDetailPageUI> {
  @override
  void initState() {
    super.initState();
    if (widget.ticketId != null) {
      context.read<TicketBloc>().add(TicketByIdSearch(widget.ticketId!));
    } else {
      // Режим создания — сбрасываем состояние
        context.read<TicketBloc>().add(ResetTicket());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TicketBloc, TicketState>(
      buildWhen: (previous, current) =>
      current is TicketInitial ||
      current is TicketByIdLoaded ||
          current is TicketLoading ||
          current is TicketError,
      builder: (context, state) {
        if (state is TicketLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is TicketError) {
          return Center(child: Text(state.message));
        }

        // Если редактирование — данные есть, если создание — null
        final ticket = state is TicketByIdLoaded ? state.tickets : null;

        print('выбронный тикет $ticket');
        return TicketForm(ticket: ticket); // ваша форма
      },
    );
  }
}
