import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:service_desk/models/new_ticket_models/new_ticket_model_ui.dart';
import 'package:service_desk/models/tikets_models/tiket_response.dart';

import '../../data_base/user_repository.dart';
import '../../models/tikets_models/tiket_post_model.dart';
import '../../services/tiket_post_service.dart';

part 'ticket_post_event.dart';
part 'ticket_post_state.dart';

class TicketPostBloc extends Bloc<TicketPostEvent, TicketPostState> {

  TicketPostBloc() : super(TicketPostInitial()) {
    on<TicketFeatEvent>(_sendDataTicket);
  }

  Future<void> _sendDataTicket(TicketFeatEvent event, Emitter<TicketPostState> emit) async{
    emit(TicketPostInitial());
    final TiketPostService service = TiketPostService();
    try{
      final userRepository = UserRepository();
      final savedUser = await userRepository.getUser();
      final apiKey = savedUser?.apiKey ?? '';
      print(jsonEncode(event.getTicket));
      final response = await service.tiketPost(model: event.getTicket, apiKey: apiKey);
      print(response);
      emit(TicketPostLoaded(response));
    //  if(response)
    } catch (e) {
      emit(TicketPostError(e.toString()));
    }
  }
}
