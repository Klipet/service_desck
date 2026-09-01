import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../const/const_colors.dart';

class YesNoField extends StatefulWidget {
  final String hintText;
  final bool? value;
  final ValueChanged<bool> onChanged;

  const YesNoField({
    required this.hintText,
    required this.value,
    required this.onChanged,
  });

  @override
  State<YesNoField> createState() => _YesNoFieldState();
}

class _YesNoFieldState extends State<YesNoField> {
  final GlobalKey _fieldKey = GlobalKey();
  final GroupId = 'yes_no_dropdown';
  OverlayEntry? _overlayEntry;
  final ValueNotifier<bool> _isOpenNotifier = ValueNotifier(false);

  @override
  void dispose() {
    _hideOverlay();
    _isOpenNotifier.dispose();
    super.dispose();
  }

  @override
  void deactivate() {
    _hideOverlay();
    super.deactivate();
  }

  void _toggleOverlay() {
    if (_overlayEntry == null) {
      _showOverlay();
    } else {
      _hideOverlay();
    }
  }

  void _showOverlay() {
    final RenderBox renderBox =
    _fieldKey.currentContext!.findRenderObject() as RenderBox;
    final position = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    _overlayEntry = OverlayEntry(
      canSizeOverlay: true,
      builder: (context) => Positioned(
        top: position.dy + size.height,
        left: position.dx,
        width: size.width,
        child: TapRegion(
          groupId: GroupId,
          child: Material(
            type: MaterialType.transparency,
            child: _DictDropdownContainer(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _YesNoTile(
                    label: 'Da',
                    onTap: () => _select(true),
                  ),
                  Divider(height: 1.h, thickness: 1.h, color: AppColors.textTitleFl),
                  _YesNoTile(
                    label: 'Nu',
                    onTap: () => _select(false),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
    _isOpenNotifier.value = true;
  }

  void _hideOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    _isOpenNotifier.value = false;
  }

  void _select(bool val) {
    widget.onChanged(val);
    _hideOverlay();
  }

  @override
  Widget build(BuildContext context) {
    return TapRegion(
      groupId: GroupId,
      onTapOutside: (_) => _hideOverlay(),
      child: ValueListenableBuilder<bool>(
        valueListenable: _isOpenNotifier,
        builder: (context, isOpen, child) {
          return GestureDetector(
            onTap: _toggleOverlay,
            child: Container(
              key: _fieldKey,
              alignment: Alignment.centerLeft,
              height: 32.h,
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              decoration: BoxDecoration(
                color: AppColors.backgroundCardColor,
                borderRadius: isOpen
                    ? BorderRadius.only(
                  topLeft: Radius.circular(10.r),
                  topRight: Radius.circular(10.r),
                )
                    : BorderRadius.circular(100.r),
                border: Border(
                  top: BorderSide(color: AppColors.textTitleFl, width: 1.w),
                  left: BorderSide(color: AppColors.textTitleFl, width: 1.w),
                  right: BorderSide(color: AppColors.textTitleFl, width: 1.w),
                  bottom: isOpen
                      ? BorderSide.none
                      : BorderSide(color: AppColors.textTitleFl, width: 1.w),
                ),
              ),
              child: child,
            ),
          );
        },
        child: Row(
          children: [
            Expanded(
              child: Text(
                widget.value == null
                    ? widget.hintText
                    : (widget.value! ? 'Da' : 'Nu'),
                style: GoogleFonts.poppins(
                  fontSize: 13.sp,
                  color: widget.value == null
                      ? AppColors.textColorOne
                      : Colors.black87,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(Icons.expand_more, size: 20.sp, color: AppColors.hintTextColor),
          ],
        ),
      ),
    );
  }
}

class _YesNoTile extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _YesNoTile({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 13.sp,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }
}

class _DictDropdownContainer extends StatelessWidget {
  final Widget child;
  const _DictDropdownContainer({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
        color: AppColors.backgroundCardColor,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(10.r),
          bottomRight: Radius.circular(10.r),
        ),
        border: Border(
          bottom: BorderSide(color: AppColors.textTitleFl, width: 1.w),
          left: BorderSide(color: AppColors.textTitleFl, width: 1.w),
          right: BorderSide(color: AppColors.textTitleFl, width: 1.w),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}