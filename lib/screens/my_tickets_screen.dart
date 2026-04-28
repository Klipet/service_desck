import 'package:flutter/material.dart';

class MyTicketsScreen extends StatelessWidget {
  const MyTicketsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        "Экран всех моих тикетов",
        style: TextStyle(fontSize: 18),
      ),
    );
  }
}