import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:service_desk/data_base/data_models/user_model_permisions_db.dart';
import 'package:service_desk/data_base/user_repository.dart';

import '../../../blocs/tiket_blocs/tiket_bloc.dart';
import '../../../blocs/tiket_blocs/tiket_state.dart';
import '../../../const/const_colors.dart';
import '../../../data_base/data_models/user_model_db.dart';
import '../../../models/tikets_models/tiket_response.dart';
import 'ticket_tab_filter.dart';

class TicketToolbar extends StatefulWidget {


  final List<TicketResponse> allTickets;

  final VoidCallback? onLoadAll;
  final VoidCallback? onLoadMine;

  final VoidCallback onManageColumns;
  final ValueChanged<String?>? onSearch;

  //статусы дробдаун
  final ValueChanged<String?> onStatusChanged;
  final List<String> statuses;
  final String? selectedStatus;

  //response primite
  final VoidCallback? responseGet;


  // кнопки с тикетами
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

    this.onLoadAll,
    this.onLoadMine,

    this.onSearch,
    this.onCreate,
    this.onEdit,
    this.onAttach,
    this.onAssign,
    this.onDelete,
    this.responseGet,
  });

  @override
  State<TicketToolbar> createState() => _TicketToolbarState();
}

class _TicketToolbarState extends State<TicketToolbar> {
  TicketTabFilter _activeTab = TicketTabFilter.all;
  final _searchController = TextEditingController();
  final _userRepo = UserRepository();
  Set<String> _permissions = {};

  @override
  void initState() {
    super.initState();
    _loadPermissions();
  }

  void _applyTab(TicketTabFilter tab) {
    setState(() => _activeTab = tab);
    print(
      "🔘 tab: $tab onLoadAll: ${widget.onLoadAll} onLoadMine: ${widget.onLoadMine}",
    );

    switch (tab) {
      case TicketTabFilter.all:
        widget.onLoadAll?.call();
        break;
      case TicketTabFilter.mine:
        widget.onLoadMine?.call();
        break;
    }
  }

  Future<void> _loadPermissions() async {
    final perms = await _userRepo.getPermissions();
    setState(() {
      _permissions = perms.map((p) => p.name).toSet(); // твоё поле
    });
  }

  void _onSearch() {
    final String? query = _searchController.text;
    widget.onSearch?.call(query ?? null); // ✅ передаём строку наверх
  }

  bool _has(String permission) => _permissions.contains(permission);

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
                        onTap: _onSearch,
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
                      selectedStatus: widget.selectedStatus ?? 'Все заявки',
                      onStatusChanged: widget.onStatusChanged ,
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
                          isDisabled: _has('ticket.create'),
                        ),

                        _ActionButton(
                          width: 105.w,
                          icon: 'assets/image/tool_bar_ticket/edit_tiket.svg',
                          label: 'Redactare',
                          onTap: widget.onEdit,
                          isDisabled: _has('ticket.update'),
                        ),

                        _ActionButton(
                          width: 84.w,
                          icon: 'assets/image/tool_bar_ticket/add_tiket.svg',
                          label: 'Alipire',
                          onTap: widget.onAttach,
                          isDisabled: _has('ticket.attach'),
                        ),
                        _ActionButton(
                          width: 92.w,
                          icon: 'assets/image/tool_bar_ticket/get_tiket.svg',
                          label: 'Atribuie',
                          onTap: widget.onAssign,
                          isDisabled: _has('ticket.assign'),
                        ),
                        _ActionButton(
                          width: 85.w,
                          icon:
                              'assets/image/tool_bar_ticket/trash_act_tiket.svg',
                          label: 'Șterge',
                          onTap: widget.onDelete,
                          isDisabled: _has('ticket.delete'),
                        ),
                      ],
                    ),
                  ),
                  // Răspunsuri primite — бейдж потом добавишь
                  SizedBox(width: 4.w),
                  BlocBuilder<TicketBloc, TicketState>(
                    builder: (context, state) {
                      final count = state is TicketMessageLoaded
                          ? state.unreadCount
                          : 0;

                      return _ActionMessageActualButton(
                        onTap: widget.responseGet,
                        icon: 'assets/image/tool_bar_ticket/inbox.svg',
                        label: 'Răspunsuri primite',
                        width: 151.w,
                        countMessage: count,
                      );
                    },
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
  final bool isDisabled;

  const _ActionButton({
    required this.icon,
    required this.label,
    this.onTap,
    required this.width,
    this.isDisabled = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDisabled
        ? AppColors.textTitleFl
        : AppColors.hintTextColor;
    return InkWell(
      onTap: isDisabled ? onTap : null,
      borderRadius: BorderRadius.circular(10.r),
      child: Container(
        width: width,
        margin: EdgeInsets.only(left: 4.w, bottom: 4.h, top: 4.h),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.colorButtonTiket,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: AppColors.borderCardColor, width: 1.w),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(icon, color: color, width: 16.w, height: 16.h),
            SizedBox(width: 4.w),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 10.sp.clamp(10, 25),
                fontWeight: FontWeight.w500,
                color: color,
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

  const _ActionMessageActualButton({
    required this.icon,
    required this.label,
    this.onTap,
    required this.width,
    required this.countMessage,
  });

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
            margin: EdgeInsets.only(left: 4.w, bottom: 4.h, top: 4.h),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.backgroundColor,
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(color: AppColors.textTitleFl, width: 1.w),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  icon,
                  color: AppColors.textTitleFl,
                  width: 16.w,
                  height: 16.h,
                ),
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
          if (countMessage > 0)
            Container(
              width: 20.w,
              height: 20.h,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppColors.gradientColor,
              ),
              child: Text(
                countMessage.toString(),
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500,
                  color: AppColors.backgroundColor,
                  fontSize: 10.sp.clamp(10, 16),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _DropDawnWidget extends StatefulWidget {
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
  State<_DropDawnWidget> createState() => _DropDawnWidgetState();
}

class _DropDawnWidgetState extends State<_DropDawnWidget> {

  final LayerLink _layerLink = LayerLink();
  bool _isOpen = false;
  final OverlayPortalController _controller = OverlayPortalController();


  @override
  void dispose() {
    if (_controller.isShowing) {
      _controller.hide();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return OverlayPortal(
      controller: _controller,
      // ✅ overlayChildBuilder рисуется ПОД основным виджетом автоматически
      overlayChildBuilder: (context) {
        final RenderBox box = this.context.findRenderObject() as RenderBox;
        final size = box.size;
        final offset = box.localToGlobal(Offset.zero);

        return Positioned(
          left: offset.dx,
          top: offset.dy + size.height - 1,
          width: size.width,
          child: _DropdownMenu(
            labels:  widget.label,
            onSelect: (value) {
              widget.onStatusChanged(value);
              _controller.hide();
              setState(() => _isOpen = false);
            },
          ),
        );
      },
      child: CompositedTransformTarget(
        link: _layerLink,
        child: GestureDetector(
          onTap: () {
            setState(() => _isOpen = !_isOpen);
            _isOpen ? _controller.show() : _controller.hide();
          },
          child: Container(
            height:  32.h ,
            padding: EdgeInsets.symmetric(horizontal: 14.w),
            decoration: BoxDecoration(
              color: AppColors.backgroundColor,
              borderRadius: _isOpen
                  ? BorderRadius.vertical(top: Radius.circular(20.r))
                  : BorderRadius.circular(20.r),
              border: Border.all(color: AppColors.textTitleFl, width: 1.w),
            ),
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    widget.selectedStatus == '' ? "Все заявки" :  widget.selectedStatus ,
                    style: GoogleFonts.poppins(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textTitleFl,
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child:  SvgPicture.asset('assets/image/icon_drop_dawn/drop_dawn.svg', width: 22.w, height: 22.h,),

                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DropdownMenu extends StatelessWidget {
  final List<String> labels;
  final ValueChanged<String> onSelect;

  const _DropdownMenu({required this.labels, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final allLabels = [ ...labels, "Все заявки"];

    return Material(
      color: Colors.transparent,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8.h),
        decoration: BoxDecoration(
          color: AppColors.backgroundColor,
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(12.r)),
          border: Border(
            left: BorderSide(color: AppColors.textTitleFl, width: 1.w),
            right: BorderSide(color: AppColors.textTitleFl, width: 1.w),
            bottom: BorderSide(color: AppColors.textTitleFl, width: 1.w),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: allLabels.map((label) {
            return InkWell(
              onTap: () => onSelect(label),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 5.h),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: label != labels.last
                        ? BorderSide(color: AppColors.textTitleFl, width: 0.5.w)
                        : BorderSide.none,
                  ),
                ),
                child: Text(
                  label,
                //  label == '' ? "Все заявки" : label ,
                  style: GoogleFonts.poppins(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textTitleFl,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
