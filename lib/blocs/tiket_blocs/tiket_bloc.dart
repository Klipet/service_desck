
import 'package:bloc/bloc.dart';
import 'package:service_desk/blocs/tiket_blocs/tiket_event.dart';
import 'package:service_desk/blocs/tiket_blocs/tiket_state.dart';
import 'package:service_desk/models/tikets_models/tiket_response.dart';

import '../../services/ticket_service.dart';
import '../../services/user_service.dart';

class TicketBloc extends Bloc<TicketEvent, TicketState> {
  final TicketService ticketService;
  List<TicketResponse> _tickets = [];
  TicketBloc(this.ticketService) : super(TicketInitial()) {
    on<LoadTickets>((event, emit) async {
      emit(TicketLoading());
      try {
        final savedUser = UserService.getUser();
        if(savedUser != null){
          savedUser.apiKey;
          _tickets = await ticketService.getTikets(apiKey: savedUser.apiKey);
        }
        emit(TicketLoaded(_tickets));
      } catch (e) {
        emit(TicketError(e.toString()));
      }
    });

    on<AddTicket>((event, emit) {
      _tickets.add(event.ticket);
      emit(TicketLoaded(List.from(_tickets))); // обновляем состояние
    });
  }
}