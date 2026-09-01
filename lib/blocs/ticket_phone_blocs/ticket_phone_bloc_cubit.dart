import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../../data_base/user_repository.dart';
import '../../models/tikets_models/tiket_phone_model.dart';
import '../../services/ticket_phone_service.dart';

part 'ticket_phone_bloc_state.dart';

class TicketPhoneBlocCubit extends Cubit<TicketPhoneBlocState> {
  final TicketPhoneService _service;
  TicketPhoneBlocCubit(TicketPhoneService? service,) :  _service = service ?? TicketPhoneService(),
  super(const TicketPhoneInitial());

  Future<void> load(int ticketId) async {
    emit(const TicketPhoneLoading());

    try {
      final userRepository = UserRepository();
      final savedUser = await userRepository.getUser();
      final apiKey = savedUser?.apiKey ?? '';
      final result = await _service.getByTicket( apiKey: apiKey, ticketId: ticketId);

      emit(TicketPhoneLoaded(result));
    } catch (e) {
      emit(TicketPhoneError(e.toString()));
    }
  }

}
