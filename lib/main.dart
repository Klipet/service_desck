import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:provider/provider.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:service_desk/app_router.dart';
import 'package:service_desk/screens/auth_screen.dart';
import 'package:service_desk/utils/navigator_provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:window_manager/window_manager.dart';


import 'const/const_colors.dart';
import 'data_base/user_model.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await windowManager.ensureInitialized();
  Hive.registerAdapter(UserModelAdapter()); // 👈 сначала регистрируй адаптер
  await Hive.openBox<UserModel>('userBox'); // потом открывай с типом
  await Hive.openBox('settingsBox');
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
  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => NavigationProvider())],
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
    );
  }
}
