import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:service_desk/app_router.dart';
import 'package:service_desk/data_base/init_isar.dart';
import 'package:service_desk/data_base/user_repository.dart';
import 'package:service_desk/services/hub_connecter.dart';
import 'package:service_desk/services/ticket_service.dart';
import 'package:service_desk/utils/navigator_provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:service_desk/utils/notification_windows.dart';
import 'package:window_manager/window_manager.dart';

import 'blocs/tiket_blocs/tiket_bloc.dart';
import 'blocs/tiket_blocs/tiket_event.dart';
import 'blocs/tiket_blocs/tiket_state.dart';
import 'const/const_colors.dart';




Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await InitIsar.init();
  await windowManager.ensureInitialized();
  WindowOptions windowOptions =  WindowOptions(
    backgroundColor: Colors.transparent,
    titleBarStyle: TitleBarStyle.hidden,
    minimumSize: Size(1186, 768),   // ← минимальный размер
    center: true,
  );
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  final ticketBloc = TicketBloc(ticketService: TicketService(), userRepository: UserRepository())..add(LoadTickets());
  final hub = HubConnecterR.init(ticketBloc);
  // unawaited — не блокируем запуск приложения
  unawaited(hub.startWithAutoReconnect());
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
        BlocProvider.value(value: ticketBloc), // ✅
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(1280, 635),
      minTextAdapt: true,
      splitScreenMode: true,
      child: ChangeNotifierProvider(
        create: (_) => NavigationProvider(),
        child: BlocListener<TicketBloc, TicketState>(  // ✅
          listener: (context, state) {
            if (state is TicketLoaded && state.isNewTicket) {
              if(state.newTicket != null) {
                NotificationWindows().showTicketNotification(state.newTicket!);
              }
            }
            else if(state is CommentLoaded){
              NotificationWindows().showCommentNotification(state.tickets);
            }
          },
          child: MaterialApp(
            color: AppColors.backgroundCardColor,
            debugShowCheckedModeBanner: false,
            supportedLocales: const [
              Locale('en'),
              Locale('ru'),
              Locale('ro'),
            ],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            builder: (context, child) {
              return ResponsiveBreakpoints.builder(
                child: child!,
                breakpoints: const [
                  Breakpoint(start: 0, end: 451, name: MOBILE),
                  Breakpoint(start: 451, end: 801, name: TABLET),
                  Breakpoint(start: 801, end: double.infinity, name: DESKTOP),
                ],
              );
            },
            initialRoute: AppRouter.login,
            onGenerateRoute: AppRouter.generateRoute,
          ),
        ),
      ),
    );
  }
}
