import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../const/const_colors.dart';
import '../../models/company_model.dart';
import '../../models/dictionaries_items/dictionary_item_model.dart';
import '../../models/dictionaries_items/phone_resault_item.dart';
import '../../models/tikets_models/tiket_phone_model.dart';
import '../widgets/custom_date_time_field.dart';
import '../widgets/custom_dictionary_dropdown_widget.dart';

class PhoneRecordsSection extends StatelessWidget {
  final List<TicketPhoneModel> records;
  final List<Phone> authorPhones;
  final List<PhoneResaultItem> results; // <-- НОВОЕ: справочник результатов
  final VoidCallback onAdd;
  final void Function(int index, TicketPhoneModel updated) onChanged;
  final void Function(int index) onRemove;

  const PhoneRecordsSection({
    super.key,
    required this.records,
    required this.authorPhones,
    required this.results,
    required this.onAdd,
    required this.onChanged,
    required this.onRemove,
  });

  static const flexPhone = 5;
  static const flexResult = 3;
  static const flexDate = 2;
  static const flexComment = 4;
  static const flexAction = 1;

  static const double _rowHeight = 40;
  static const int _maxVisibleRows = 3;

  @override
  Widget build(BuildContext context) {
    final tableHeight = records.isEmpty
        ? _rowHeight
        : (records.length > _maxVisibleRows
                      ? _maxVisibleRows
                      : records.length) *
                  _rowHeight +
              2;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          constraints: BoxConstraints(maxHeight: tableHeight.h + 34.h),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: AppColors.textTitleFl, width: 1.w),
              left: BorderSide(color: AppColors.textTitleFl, width: 1.w),
              right: BorderSide(color: AppColors.textTitleFl, width: 1.w),
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(10.r),
              bottomRight: Radius.circular(10.r),
              topLeft: Radius.circular(10.r),
              topRight: Radius.circular(10.r),
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeaderRow(),
              Divider(height: 1, color: AppColors.textTitleFl.withOpacity(0.5)),
              if (records.isEmpty)
                _buildEmptyRow()
              else
                Expanded(
                  child: ListView.separated(
                    padding: EdgeInsets.zero,
                    itemCount: records.length,
                    separatorBuilder: (_, __) =>
                        Divider(height: 1, color: Colors.grey.shade200),
                    itemBuilder: (context, index) {
                      final record = records[index];
                      return SizedBox(
                        height: _rowHeight.h,
                        key: ValueKey(record.id ?? 'new_$index'),
                        child: _PhoneTableRow(
                          record: record,
                          authorPhones: authorPhones,
                          results: results,
                          onChanged: (updated) => onChanged(index, updated),
                          onRemove: () => onRemove(index),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderRow() {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: AppColors.textTitleFl, width: 1.w),
        ),
        borderRadius: BorderRadius.only(topRight: Radius.circular(10.r),topLeft: Radius.circular(10.r)),
        color: Colors.grey.shade100,
      ),
      //
      padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 6.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(width: 180.w, child: _headerCell('Telefon')),
          _colDivider(),
          SizedBox(width: 80.w, child: _headerCell('Rezultat')),
          _colDivider(),
          SizedBox(width: 80.w, child: _headerCell('Data')),
          _colDivider(),
          SizedBox(width: 130.w, child: _headerCell('Comentariu')),
          _colDivider(),
          InkWell(
            onTap: onAdd,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.add_circle_outline,
                  size: 15.sp,
                  color: AppColors.textTitleFl,
                ),
                SizedBox(width: 2.w),
                Text(
                  'Adaugă',
                  style: GoogleFonts.poppins(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textTitleFl,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _colDivider() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 5.w),
      child: Container(width: 1, height: 12.h, color: Colors.grey.shade300),
    );
  }

  Widget _headerCell(String text) {
    return SizedBox(
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 10.sp,
          fontWeight: FontWeight.w600,
          color: AppColors.textTitleFl,
        ),
      ),
    );
  }

  Widget _buildEmptyRow() {
    return SizedBox(
      height: _rowHeight.h,
      child: Center(
        child: Text(
          'Niciun apel adăugat',
          style: GoogleFonts.poppins(
            fontSize: 12.sp,
            color: Colors.grey.shade500,
          ),
        ),
      ),
    );
  }
}

class _PhoneTableRow extends StatefulWidget {
  final TicketPhoneModel record;
  final List<Phone> authorPhones;
  final List<PhoneResaultItem> results;
  final ValueChanged<TicketPhoneModel> onChanged;
  final VoidCallback onRemove;

  const _PhoneTableRow({
    required this.record,
    required this.authorPhones,
    required this.results,
    required this.onChanged,
    required this.onRemove,
  });

  @override
  State<_PhoneTableRow> createState() => _PhoneTableRowState();
}



class _PhoneTableRowState extends State<_PhoneTableRow> {
  static const _customOid = -1;

  late final TextEditingController _commentController;

  @override
  void initState() {
    super.initState();
    _commentController = TextEditingController(text: widget.record.comment);
  }

  @override
  void didUpdateWidget(covariant _PhoneTableRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    final externalComment = widget.record.comment ?? '';
    if (oldWidget.record.comment != widget.record.comment &&
        _commentController.text != externalComment) {
      final offset = _commentController.selection.baseOffset.clamp(
        0,
        externalComment.length,
      );
      _commentController.text = externalComment;
      _commentController.selection = TextSelection.collapsed(offset: offset);
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _emit(TicketPhoneModel updated) => widget.onChanged(updated);

  Future<String?> _askCustomPhone(BuildContext context, String? initial) async {
    final controller = TextEditingController(text: initial);
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14.r),
        ),
        title: Text(
          'Introduceți numărul',
          style: GoogleFonts.poppins(fontSize: 15.sp),
        ),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.phone,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Anulare'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, controller.text),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final record = widget.record;
    final authorPhones = widget.authorPhones;

    final phoneItems = <DictionaryItem>[
      ...authorPhones.map(
        (p) =>
            DictionaryItem(oid: p.oid ?? 0, name: p.number ?? '', active: true),
      ),
      DictionaryItem(oid: _customOid, name: 'Alt număr...', active: true),
    ];

    final knownMatch = authorPhones.firstWhereOrNull(
      (p) => p.number == record.phone,
    );
    final currentDictValue = knownMatch != null
        ? DictionaryItem(
            oid: knownMatch.oid ?? 0,
            name: knownMatch.number ?? '',
            active: true,
          )
        : (record.phone != null && record.phone!.isNotEmpty
              ? DictionaryItem(
                  oid: _customOid,
                  name: record.phone!,
                  active: true,
                )
              : null);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 6.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 180.w,
            child: CustomDictionaryDropdown(
              hintText: 'Telefon',
              icon: Icons.phone,
              items: phoneItems,
              initialValue: currentDictValue,
              onSelected: (item) async {
                if (item.oid == _customOid) {
                  final entered = await _askCustomPhone(context, record.phone);
                  if (entered != null && entered.trim().isNotEmpty) {
                    _emit(record.copyWith(phone: entered.trim()));
                  }
                } else {
                  _emit(record.copyWith(phone: item.name));
                }
              },
            ),
          ),
          _rowDivider(),
          SizedBox(
            width: 80.w,
            child: _CellResultDropdown(
              results: widget.results,
              selectedOid: record.resultPhoneOid,
              onSelected: (item) => _emit(
                record.copyWith(
                  resultPhoneOid: item.oid,
                  resultPhoneName: item.name,
                ),
              ),
            ),
          ),
          _rowDivider(),
          SizedBox(
            width: 80.w,
            child: CustomDateTimeField(
              value: record.dataCreated,
              onPick: (date) => _emit(record.copyWith(dataCreated: date)),
            ),
          ),
          _rowDivider(),
          SizedBox(
            width: 130.w,
            child: TextField(
              controller: _commentController,
              onChanged: (v) => _emit(record.copyWith(comment: v)),
              style: GoogleFonts.poppins(
                fontSize: 12.sp,
                color: Colors.black87,
              ),
              decoration: InputDecoration(
                isDense: true,
                isCollapsed: true,
                hintText: '—',
                hintStyle: GoogleFonts.poppins(
                  fontSize: 12.sp,
                  color: Colors.grey.shade400,
                ),
                border: InputBorder.none,
              ),
            ),
          ),
          _rowDivider(),
          SizedBox(width: 4.w),
          Expanded(
            //  flex: PhoneRecordsSection.flexAction,
            child: InkWell(
              onTap: widget.onRemove,
              child: Icon(
                Icons.close,
                size: 16.sp,
                color: Colors.grey.shade400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _rowDivider() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 5.w),
      child: Container(width: 1, height: 20.h, color: Colors.grey.shade200),
    );
  }
}

// =============================== ЯЧЕЙКИ ===============================

/// Dropdown результата звонка на основе справочника PhoneResaultItem.
class _CellResultDropdown extends StatelessWidget {
  final List<PhoneResaultItem> results;
  final int? selectedOid;
  final ValueChanged<PhoneResaultItem> onSelected;

  const _CellResultDropdown({
    required this.results,
    required this.selectedOid,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final current = results.firstWhereOrNull((r) => r.oid == selectedOid);
    final color = _colorFor(current);

    return PopupMenuButton<PhoneResaultItem>(
      onSelected: onSelected,
      itemBuilder: (context) => results
          .map(
            (item) => PopupMenuItem(
              value: item,
              child: Row(
                children: [
                  Container(
                    width: 8.w,
                    height: 8.w,
                    decoration: BoxDecoration(
                      color: _colorFor(item),
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Text(item.name, style: GoogleFonts.poppins(fontSize: 13.sp)),
                ],
              ),
            ),
          )
          .toList(),
      child: Row(
        children: [
          Container(
            width: 8.w,
            height: 8.w,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          SizedBox(width: 5.w),
          Expanded(
            child: Text(
              current?.name ?? '—',
              style: GoogleFonts.poppins(
                fontSize: 12.sp,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  /// Подставьте сюда реальную логику определения цвета по вашему справочнику
  /// (например, по oid конкретных значений "Да"/"Нет"/"Недозвон" и т.п.),
  /// если у результатов нет собственного поля цвета.
  Color _colorFor(PhoneResaultItem? item) {
    if (item == null) return Colors.grey.shade400;
    return Color(0xFF2ECC71);
  }
}
