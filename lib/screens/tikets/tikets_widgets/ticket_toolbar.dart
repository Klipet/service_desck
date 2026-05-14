import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../const/const_colors.dart';
import '../../../models/tikets_models/tiket_response.dart';
import '../../../services/user_service.dart';
import 'ticket_tab_filter.dart';

class TicketToolbar extends StatefulWidget {
  final List<String> statuses;
  final String? selectedStatus;
  final ValueChanged<String?> onStatusChanged;
  final List<TicketResponse> allTickets;
  final ValueChanged<List<TicketResponse>> onFilterChanged;
  final VoidCallback onManageColumns;
  final VoidCallback? onSearch;
  final VoidCallback? onCreate;
  final VoidCallback? onEdit;
  final VoidCallback? onAttach;
  final VoidCallback? onAssign;
  final VoidCallback? onDelete;

  const TicketToolbar({
    super.key,
    required this.statuses,
    required this.selectedStatus,
    required this.onStatusChanged,
    required this.onManageColumns,
    required this.allTickets,
    required this.onFilterChanged,
    this.onSearch,
    this.onCreate,
    this.onEdit,
    this.onAttach,
    this.onAssign,
    this.onDelete,
  });

  @override
  State<TicketToolbar> createState() => _TicketToolbarState();
}

class _TicketToolbarState extends State<TicketToolbar> {
  TicketTabFilter _activeTab = TicketTabFilter.all;
  final _searchController = TextEditingController();
  final int _currentUserId = UserService.getUser()?.userId ?? -1;

  void _applyTab(TicketTabFilter tab) {
    setState(() => _activeTab = tab);

    List<TicketResponse> result;

    switch (tab) {
      case TicketTabFilter.all:
        result = widget.allTickets;
        break;
      case TicketTabFilter.mine:
        result = widget.allTickets
            .where((t) => t.userId == _currentUserId)
            .toList();
        break;
    }

    widget.onFilterChanged(result);
  }

  void _onSearch() {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) {
      widget.onFilterChanged(widget.allTickets);
      return;
    }
    final result = widget.allTickets.where((t) {
      return t.id.toString().contains(query) ||
          (t.stateName?.toLowerCase().contains(query) ?? false) ||
          (t.userName?.toLowerCase().contains(query) ?? false) ||
          (t.title?.toLowerCase().contains(query) ?? false);
    }).toList();
    widget.onFilterChanged(result);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 50.h,
          padding: EdgeInsets.only(top: 14.w, left: 4.h),
          decoration: BoxDecoration(color: AppColors.backgroundCardColor),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  alignment: Alignment.center,
                  height: 32.h,
                  padding: EdgeInsets.only(left: 8.w),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundColor,
                    border: Border.all(color: AppColors.borderCardColor),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(right: 8.h),
                        child: SvgPicture.asset(
                          'assets/image/tool_bar_ticket/search.svg',
                          width: 16.w,
                          height: 16.h,
                        ),
                      ),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          onSubmitted: (_) => _onSearch(),
                          style: GoogleFonts.poppins(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w300,
                          ),
                          decoration: InputDecoration(
                            isCollapsed: true,
                            contentPadding: EdgeInsets.symmetric(vertical: 0),
                            border: InputBorder.none,
                            hintText: 'Căutare după ID, Statut, Client...',
                            hintStyle: GoogleFonts.poppins(
                              fontSize: 10.sp.clamp(15, 20),
                              color: AppColors.hintTextColor,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      // Кнопка Caută
                      GestureDetector(
                        onTap: () {},
                        child: Container(
                          height: 24.h,
                          alignment: Alignment.center,
                          margin: EdgeInsets.only(left: 4.w, right: 4.w),
                          padding: EdgeInsets.symmetric(
                            vertical: 4.h,
                            horizontal: 14.w,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20.r),

                            gradient: AppColors.gradientColor,
                          ),
                          child: Text(
                            'Caută',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w700,
                              fontSize: 10.sp.clamp(10, 20),
                              color: AppColors.backgroundColor,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const Spacer(),
              GestureDetector(
                onTap: widget.onManageColumns,
                child: Container(
                  height: 32.h,
                  width: 151.w,
                  margin: EdgeInsets.only(right: 13.w),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundColor,
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(
                      color: AppColors.borderCardColor,
                      width: 1.w,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        'assets/image/tool_bar_ticket/column_setting.svg',
                        width: 16.w,
                        height: 16.h,
                      ),
                      SizedBox(width: 4.h),
                      Text(
                        'Gestionare coloane',
                        style: GoogleFonts.poppins(
                          color: AppColors.textTitleFl,
                          fontWeight: FontWeight.w500,
                          fontSize: 10.sp.clamp(10, 20),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        // ── Строка 2: табы + кнопки действий ──
        Stack(
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
              child: Row(
                children: [
                  // Табы
                  Container(
                    height: 32.h,
                    padding: EdgeInsets.all(4.h),
                    decoration: BoxDecoration(
                      color: AppColors.backgroundCardColor,

                      border: BoxBorder.all(
                        color: AppColors.textTitleFl,
                        width: 1.w,
                      ),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Row(
                      children: [
                        _TabButton(
                          label: 'Toate cererile',
                          isActive: _activeTab == TicketTabFilter.all,
                          onTap: () => _applyTab(TicketTabFilter.all),
                        ),
                        SizedBox(width: 4.w),
                        _TabButton(
                          label: 'Cererile mele',
                          isActive: _activeTab == TicketTabFilter.mine,
                          onTap: () => _applyTab(TicketTabFilter.mine),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 8.w),
                  SizedBox(
                    width: 339.w,
                    height: 32.h,
                    child: _DropDawnWidget(
                      label: widget.statuses,
                      selectedStatus: widget.selectedStatus ?? '',
                      onStatusChanged: widget.onStatusChanged,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Container(
                    height: 32.h,
                  //  width: 479.w,
                    padding: EdgeInsets.only(right: 4.h),
                    decoration: BoxDecoration(
                      color: AppColors.backgroundColor,
                      border: BoxBorder.all(
                        color: AppColors.textTitleFl,
                        width: 1.w,
                      ),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Row(
                      children: [
                        // Кнопки действий
                        _ActionButton(
                          width: 89.w,
                          icon: 'assets/image/tool_bar_ticket/create_tiket.svg',
                          label: 'Crează',
                          onTap: widget.onCreate,
                        ),
                        _ActionButton(
                          width: 105.w,
                          icon: 'assets/image/tool_bar_ticket/edit_tiket.svg',
                          label: 'Redactare',
                          onTap: widget.onEdit,
                        ),
                        _ActionButton(
                          width: 84.w,
                          icon: 'assets/image/tool_bar_ticket/add_tiket.svg',
                          label: 'Alipire',
                          onTap: widget.onAttach,
                        ),
                        _ActionButton(
                          width: 92.w,
                          icon: 'assets/image/tool_bar_ticket/get_tiket.svg',
                          label: 'Atribuie',
                          onTap: widget.onAssign,
                        ),
                        _ActionButton(
                          width:  85.w,
                          icon: 'assets/image/tool_bar_ticket/trash_act_tiket.svg',
                          label: 'Șterge',
                          onTap: widget.onDelete,
                        ),
                      ],
                    ),
                  ),
                  // Răspunsuri primite — бейдж потом добавишь
                  SizedBox(width: 4.w),
                  _ActionMessageActualButton(
                      icon: 'assets/image/tool_bar_ticket/inbox.svg',
                      label: 'Răspunsuri primite',
                      width: 151.w,
                      countMessage: 50
                  )
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ── Таб кнопка ──
class _TabButton extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _TabButton({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 24.h,
        width: 103.w,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: isActive
              ? LinearGradient(colors: AppColors.gradientColorTop)
              : LinearGradient(colors: AppColors.gradientDefault),
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 10.sp,
            color: isActive ? Colors.white : AppColors.textColorBlack,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

// ── Кнопка действия ──
class _ActionButton extends StatelessWidget {
  final String icon;
  final String label;
  final double width;
  final VoidCallback? onTap;

  const _ActionButton({required this.icon, required this.label, this.onTap, required this.width});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10.r),
      child: Container(
        width: width,
        margin: EdgeInsets.only(left: 4.w, bottom: 4.h, top: 4.h,),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.backgroundCardColor,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: AppColors.borderCardColor,
            width: 1.w
          )
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(icon,  color: AppColors.textTitleFl, width: 16.w,height: 16.h,),
            SizedBox(width: 4.w),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 10.sp.clamp(10, 25),
                fontWeight: FontWeight.w500,
                color: AppColors.textTitleFl,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionMessageActualButton extends StatelessWidget {
  final String icon;
  final String label;
  final double width;
  final int countMessage;
  final VoidCallback? onTap;

  const _ActionMessageActualButton({required this.icon, required this.label, this.onTap, required this.width, required this.countMessage});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10.r),
      child: Stack(
        alignment: Alignment.topRight,
        children: [
          Container(
            width: width,
            margin: EdgeInsets.only(left: 4.w, bottom: 4.h, top: 4.h,),
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: AppColors.backgroundColor,
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(
                    color: AppColors.textTitleFl,
                    width: 1.w
                )
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(icon,  color: AppColors.textTitleFl, width: 16.w,height: 16.h,),
                SizedBox(width: 4.w),
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 10.sp.clamp(10, 25),
                    fontWeight: FontWeight.w500,
                    color: AppColors.textTitleFl,
                  ),
                ),
              ],
            ),
          ),
          if(countMessage > 0)
          Container(
            width: 20.w,
            height: 20.h,
            alignment: Alignment.center,
          //  margin: EdgeInsets.only(top: 2.h,),
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppColors.gradientColor
            ),
            child: Text(countMessage.toString(), style: GoogleFonts.poppins(
                fontWeight: FontWeight.w500,
                color: AppColors.backgroundColor,
                fontSize: 10.sp.clamp(10, 16)
            ),),
          ),
        ],
      ),
    );
  }
}

class _DropDawnWidget extends StatelessWidget {
  final List<String> label;
  final String selectedStatus;
  final ValueChanged<String?> onStatusChanged;

  const _DropDawnWidget({
    super.key,
    required this.label,
    required this.selectedStatus,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    final textStyle = GoogleFonts.poppins(
      fontWeight: FontWeight.w500,
      fontSize: 10.sp.clamp(15, 20),
      color: AppColors.textTitleFl,
    );



    return Container(
      height: 32.h,
      padding: EdgeInsets.only(left: 8.w, right: 8.w),
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
        color: AppColors.backgroundCardColor,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.textTitleFl, width: 1.w),
      ),
      child: DropdownButton<String?>(
        value: selectedStatus.isEmpty ? null : selectedStatus,
        isExpanded: true,
        isDense: true,
        underline: SizedBox.shrink(),
        // ✅ убирает подчёркивание
        icon: SvgPicture.asset(
          "assets/image/icon_drop_dawn/drop_dawn.svg",
          width: 16.w,
          height: 16.h,
        ),
        iconSize: 16.sp,
        alignment: Alignment.centerLeft,
        dropdownColor: AppColors.backgroundColor,
        borderRadius: BorderRadius.circular(10.r),
        hint: Text(
          'Выбери статус',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w500,
            fontSize: 10.sp.clamp(10, 20),
            color: AppColors.textTitleFl,
          ),
        ),
        items: [
          DropdownMenuItem<String?>(
            value: null,
            child: Text('Все статусы', style: textStyle),
          ),
          ...label.map(
            (status) => status == ''
                ? DropdownMenuItem<String?>(
                    value: '',
                    child: Text('Без статуса', style: textStyle),
                  )
                : DropdownMenuItem<String?>(
                    value: status,
                    child: Text(status, style: textStyle),
                  ),
          ),
        ],
        onChanged: onStatusChanged,
      ),
    );
  }
}
