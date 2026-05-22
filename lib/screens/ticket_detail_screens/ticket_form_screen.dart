import 'package:flutter/material.dart';

import '../../models/tikets_models/tiket_response.dart';

class TicketForm extends StatefulWidget {
  final TicketResponse? ticket; // null = пустая форма

  const TicketForm({super.key, this.ticket});

  @override
  State<TicketForm> createState() => _TicketFormState();
}

class _TicketFormState extends State<TicketForm> {
  late final TextEditingController _titleController;
  late final TextEditingController _descController;

  @override
  void initState() {
    super.initState();
    // Если тикет есть — заполняем, если нет — пусто
    _titleController = TextEditingController(text: widget.ticket?.title ?? '');
    _descController = TextEditingController(
      text: widget.ticket?.description ?? '',
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [Text(widget.ticket?.title ?? '')],
      ),
    );
  }
}
