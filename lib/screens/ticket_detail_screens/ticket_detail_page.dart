import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:service_desk/blocs/company_blocs/company_bloc.dart';
import 'package:service_desk/blocs/ticket_post_blocs/ticket_post_bloc.dart';

import '../../blocs/ticket_detail_blocs/ticket_detail_bloc.dart';
import '../../blocs/ticket_phone_blocs/ticket_phone_bloc_cubit.dart';
import '../../data_base/repository/dictionaries_repository.dart';
import '../../models/tikets_models/tiket_post_model.dart';
import '../../services/ticket_phone_service.dart';
import '../../utils/navigator_provider.dart';
import '../tikets/ticket_table_screen.dart';
import 'ticket_form_screen.dart';

class TicketDetailPage extends StatelessWidget {
  const TicketDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ticketId = context.read<NavigationProvider>().ticketId;
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => TicketDetailBloc()),
        BlocProvider(create: (_) => CompanyBloc()),
        BlocProvider(create: (_) => TicketPostBloc()),
        BlocProvider(
          create: (_) =>
              TicketPhoneBlocCubit(TicketPhoneService())..load(ticketId ?? 0),
        ),
      ],
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
  final _dictionariesRepo = DictionariesRepository();

  @override
  void initState() {
    super.initState();
    context.read<CompanyBloc>().add(FeatCompanyEvent());
    if (widget.ticketId != null) {
      context.read<TicketDetailBloc>().add(
        TicketDetailByIdSearch(widget.ticketId!),
      );
    } else {
      // Режим создания — сбрасываем состояние
      context.read<TicketDetailBloc>().add(ResetDetailTicket());
    }
  }

  @override
  Widget build(BuildContext context) {
    final navigationProvider = Provider.of<NavigationProvider>(context);
    final currentPage = navigationProvider.currentPageIndex;

    return BlocListener<TicketPostBloc, TicketPostState>(
      listener: (context, state) {
        if (state is TicketPostError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Ошибка сохранения: ${state.message}')),
          );
        }

        if (state is TicketPostLoaded) {
          navigationProvider.goToPageAndDestroy(1);
        }
      },
      child: BlocBuilder<TicketDetailBloc, TicketDetailState>(
        builder: (context, state) {
          if (state is TicketDetailLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is TicketDetailError) {
            return Center(child: Text(state.message));
          }

          // Если редактирование — данные есть, если создание — null
          final ticket = state is TicketDetailLoaded ? state.ticket : null;
          return BlocBuilder<TicketPhoneBlocCubit, TicketPhoneBlocState>(
            builder: (context, phoneState) {
              final phones = phoneState is TicketPhoneLoaded
                  ? phoneState.items
                  : null;

              return TicketFormScreen(
                ticket: ticket,
                dictionariesRepo: _dictionariesRepo,
                phones: phones ?? [],
                onSubmit: (data) {
                  context.read<TicketPostBloc>().add(TicketFeatEvent(data));
                },
                onCancel: () => navigationProvider.goToPageAndDestroy(1),
              ); // ваша форма
            },
          );
        },
      ),
    );
  }
}
