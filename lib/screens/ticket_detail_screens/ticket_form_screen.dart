import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:service_desk/const/const_colors.dart';
import 'package:service_desk/models/new_ticket_models/new_ticket_model_ui.dart';

import '../../models/tikets_models/tiket_response.dart';

class TicketForm extends StatefulWidget {
  final TicketResponse? ticket; // null = пустая форма
  final void Function(NewTicketModelUI data)? onSubmit;
  final VoidCallback? onCancel;

  const TicketForm({super.key,
    this.ticket,
    this.onSubmit,
    this.onCancel});

  @override
  State<TicketForm> createState() => _TicketFormState();
}

class _TicketFormState extends State<TicketForm> {
  final _formKey = GlobalKey<FormState>();
  final _data = NewTicketModelUI();

  final _telefonController = TextEditingController();
  final _subiectController = TextEditingController();
  final _descriereController = TextEditingController();
  final _idBugController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.only(top: 14.h, left: 8.w),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(
                  child: Text('SOLICITARE NOUĂ', style: GoogleFonts.poppins(
                    color: AppColors.hintTextColor,
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w700
                  ),),
                ),

            Expanded(
              child: Align(alignment: Alignment.center,
                child: Container(
                  color: Colors.green,
                  width: 20,
                  height: 20,
                ),
              ),
            )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
