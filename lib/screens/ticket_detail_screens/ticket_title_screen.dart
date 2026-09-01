import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:service_desk/const/const_colors.dart';
import 'package:service_desk/models/tikets_models/tiket_response.dart';

import '../../models/dictionaries_items/dictionary_item_model.dart';
import '../widgets/custom_dictionary_dropdown_widget.dart';

class TicketTitleScreen extends StatefulWidget {
  final TicketResponse? ticketResponse;
  final List<DictionaryItem> ticketType;
  final List<DictionaryItem> ticketState;
  final List<DictionaryItem> ticketPreority;
  final List<DictionaryItem> ticketMode;
  final void Function(DictionaryItem item) onTypeSelected;
  final void Function(DictionaryItem item) onStateSelected;
  final void Function(DictionaryItem item) onPriorSelected;
  final void Function(DictionaryItem item) onModeSelected;

  const TicketTitleScreen({
    super.key,
    required this.ticketType,
    required this.ticketState,
    required this.ticketPreority,
    required this.ticketMode,
    required this.onTypeSelected,
    required this.onStateSelected,
    required this.onPriorSelected,
    required this.onModeSelected,
    this.ticketResponse,
  });

  @override
  State<TicketTitleScreen> createState() => _TicketTitleScreenState();
}

class _TicketTitleScreenState extends State<TicketTitleScreen> {

  DictionaryItem? _initialType;
  DictionaryItem? _initialState;
  DictionaryItem? _initialPriority;
  DictionaryItem? _initialMode;


@override
  void initState() {

    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTicket();
    });
  }

  void _loadTicket() {
    final ticket = widget.ticketResponse;
    if (ticket == null) return;

    final type = widget.ticketType.firstWhereOrNull((e) => e.oid == ticket.typeTiketId);
    final state = widget.ticketState.firstWhereOrNull((e) => e.oid == ticket.stateId);
    final priority = widget.ticketPreority.firstWhereOrNull((e) => e.oid == ticket.preorityId);
    final mode = widget.ticketMode.firstWhereOrNull((e) => e.oid == ticket.modeId);

    setState(() {
      _initialType = type;
      _initialState = state;
      _initialPriority = priority;
      _initialMode = mode;
    });

    // сразу отдаём родителю значения "по умолчанию" из тикета
    if (type != null) widget.onTypeSelected(type);
    if (state != null) widget.onStateSelected(state);
    if (priority != null) widget.onPriorSelected(priority);
    if (mode != null) widget.onModeSelected(mode);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Column(
          children: [
            Container(height: 20.h, color: AppColors.backgroundCardColor),
            Container(height: 1.h, color: AppColors.textTitleFl),
            Container(height: 20.h, color: AppColors.backgroundColor),
          ],
        ),
        Container(
          height: 40.h,
          padding: EdgeInsets.only(left: 4.h),
          alignment: Alignment.center,
          child:  Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: CustomDictionaryDropdown(
                  hintText: 'Tip',
                  icon: Icons.category_outlined,
                  items: widget.ticketType,
                  initialValue: _initialType,
                  onSelected: widget.onTypeSelected,
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: CustomDictionaryDropdown(
                  hintText: 'Stare',
                  icon: Icons.flag_outlined,
                  items: widget.ticketState,
                  initialValue: _initialState,
                  onSelected: widget.onStateSelected,
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: CustomDictionaryDropdown(
                  hintText: 'Prioritate',
                  icon: Icons.priority_high,
                  items: widget.ticketPreority,
                  initialValue: _initialPriority,
                  onSelected: widget.onPriorSelected,
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: CustomDictionaryDropdown(
                  hintText: 'Regim',
                  icon: Icons.settings_outlined,
                  items: widget.ticketMode,
                  initialValue: _initialMode,
                  defaultResolver: (items) => items.firstWhereOrNull(
                        (e) => e.name.toLowerCase().contains('standard'),
                  ),
                  onSelected: (item) {
                    widget.onModeSelected(item);
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
