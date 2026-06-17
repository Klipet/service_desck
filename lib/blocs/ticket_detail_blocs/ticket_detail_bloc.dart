import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:service_desk/services/ticket_service.dart';


import '../../data_base/user_repository.dart';
import '../../models/tikets_models/tiket_response.dart';
import '../tiket_blocs/tiket_event.dart';

part 'ticket_detail_event.dart';
part 'ticket_detail_state.dart';

class TicketDetailBloc extends Bloc<TicketDetailEvent, TicketDetailState> {

  TicketDetailBloc() : super(TicketDetailInitial()) {
    on<TicketDetailByIdSearch>(_ticketById);
    on<ResetDetailTicket>((event,emit) {emit(TicketDetailInitial());});
  }

  Future<void> _ticketById( TicketDetailByIdSearch event,
      Emitter<TicketDetailState> emit,) async{
    emit(TicketDetailLoading());
    try{
      final ticketService = TicketService();
      final userRepository = UserRepository();
      final savedUser = await userRepository.getUser();
      final apiKey = savedUser?.apiKey ?? '';
      final ticket = await ticketService.tiketById(ticketId: event.search ?? 0, apiKey: apiKey);
      emit(TicketDetailLoaded(ticket));
    }catch(e){
      emit(TicketDetailError(e.toString()));
    }
  }
}
