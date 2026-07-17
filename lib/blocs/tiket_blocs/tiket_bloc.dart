
import 'package:bloc/bloc.dart';
import 'package:service_desk/blocs/tiket_blocs/tiket_event.dart';
import 'package:service_desk/blocs/tiket_blocs/tiket_state.dart';
import 'package:service_desk/models/tikets_models/ticket_marge_model.dart';
import 'package:service_desk/models/tikets_models/tiket_response.dart';
import 'package:service_desk/services/ticket_by_id_service.dart';

import '../../data_base/user_repository.dart';
import '../../screens/tikets/tikets_widgets/ticket_tab_filter.dart';
import '../../services/ticket_service.dart';
import '../../services/tiket_search_service.dart';


class TicketBloc extends Bloc<TicketEvent, TicketState> {
  final TicketService ticketService;
  List<TicketResponse> _tickets = [];
  final UserRepository userRepository;
  TicketBloc({required this.ticketService, required this.userRepository}) : super(TicketInitial()) {
    on<LoadTickets>((event, emit) async {
      emit(TicketLoading());
      try {
        final savedUser = await userRepository.getUser();
        if (savedUser != null) {
          savedUser.apiKey;
          _tickets = await ticketService.getTikets(apiKey: savedUser.apiKey);
        }
        emit(TicketLoaded(_tickets, activeTab: TicketTabFilter.all));
      } catch (e) {
        emit(TicketError(e.toString()));
      }
    });

    on<AddTicket>((event, emit) {
      final current = state is TicketLoaded
          ? (state as TicketLoaded).tickets
          : [];
      emit(TicketLoaded(
        [...current, event.ticket],
        isNewTicket: true, // ✅
        newTicket: event.ticket, // ✅
      ));
    });


    on<AddComment>((event, emit) {
      final current = state;
      emit(CommentLoaded(event.ticketModel));
      if (current is TicketLoaded) {
        print("возвращаем список обратно ${current.runtimeType}");
        emit(current); // 👈 возвращаем список обратно
      }
    });


    //Search Ticket
    on<TicketSearch>((event, emit) async {
      emit(TicketLoading());
      try {
        final savedUser = await userRepository.getUser();


        // если пусто — загружаем весь список
        if (event.search!.trim().isEmpty) {
          final tickets = await ticketService.getTikets(
              apiKey: savedUser!.apiKey);
          emit(TicketLoaded(tickets));
          return;
        }
        final search = TicketSearchService();
        final response = await search.getTicketSearch(
          apiKey: savedUser!.apiKey,
          query: event.search!,
        );
        emit(TicketLoaded(response));
      } catch (e) {
        emit(TicketError(e.toString()));
      }
    });

    on<LoadMyTickets>((event, emit) async {
      emit(TicketLoading());
      try {
        final savedUser = await userRepository.getUser();
        final search = TicketByIdService();
        final response = await search.getTicketById(
          apiKey: savedUser!.apiKey,
          user: savedUser.userId,
        );

        emit(TicketLoaded(response, activeTab: TicketTabFilter.mine));
      } catch (e) {
        print(e);
        emit(TicketError(e.toString()));
      }
    });

    on<ResetTicket>((event, emit) {emit(TicketInitial());});
    on<MenageTickets>(_menageTiketsPost);
    on<FetchAllMessages>(_onFetchAllMessages);
  }




  Future<void> _menageTiketsPost(MenageTickets event, Emitter<TicketState> emit) async {
    emit(TicketLoading());
    try {
      final savedUser = await userRepository.getUser();
      final apiKey = savedUser?.apiKey ?? '';

      final request = TicketMargeModel(
        prymoryTiketId: event.primoryTiket,
        secindTiketId: event.secondariTikets,
      );

      final result = await ticketService.menageTickets(apiKey: apiKey, request: request,);
      emit(TicketMargetSuccess(result));

    } catch (e) {
      emit(TicketMargetError(MergeTicketResponse(state: 404, message: "Ошибка")));
    }
  }


  Future<void> _onFetchAllMessages(
      FetchAllMessages event,
      Emitter<TicketState> emit,
      ) async {
    emit(MessageLoad());
    final savedUser = await userRepository.getUser();
    final apiKey = savedUser?.apiKey ?? '';
    final result = await ticketService.getMessageTicket(apiKey: apiKey);
    emit(TicketMessageLoaded(messages: result));
  }

}
