import 'package:flutter/material.dart';
import 'package:service_desk/screens/auth_screen.dart';
import 'package:service_desk/screens/home_screen.dart';

class AppRouter {
  static const String login = '/';
  static const String home = '/home';
  static const String newTicket = '/newTiket';
  static const String tickets = '/tickets';
  static const String setting = '/setting';
  static const String answer = '/answer';

  static Route<dynamic> generateRoute(RouteSettings setting) {
    switch (setting.name) {
      case login:
        return MaterialPageRoute(builder: (_) => const AuthScreen());
      case home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('Маршрут ${setting.name} не найден')),
          ),
        );
    }
  }
}
