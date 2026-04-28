import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:service_desk/const/const_colors.dart';
import 'package:window_manager/window_manager.dart';

class CustomTitleBar extends StatelessWidget {
  const CustomTitleBar({super.key});

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveBreakpoints.of(context);
    return GestureDetector(
      // перетаскивание окна
      onPanStart: (_) => windowManager.startDragging(),
      child: Container(
        height: responsive.isDesktop ? 20.h : 20.h,
        color: AppColors.textColorOne,  // ← ваш цвет
        child: Row(
          children: [
            SizedBox(width: 12.w),
            Text(
              "Service Desk",
              style: GoogleFonts.brunoAceSc(
                fontSize: 14.sp.clamp(14, 20),
                fontWeight: FontWeight.w400,
                color: AppColors.backgroundCardColor,
              ),
            ),
            Spacer(),
            // кнопки управления окном
            _WinButton(icon: Icons.remove,
                onTap: () => windowManager.minimize()),
            _WinButton(icon: Icons.crop_square,
                onTap: () async {
                  if (await windowManager.isMaximized()) {
                    windowManager.unmaximize();
                  } else {
                    windowManager.maximize();
                  }
                }),
            _WinButton(icon: Icons.close,
                onTap: () => windowManager.close(),
                isClose: true),
          ],
        ),
      ),
    );
  }
}
class _WinButton extends StatefulWidget {
  const _WinButton({
    required this.icon,
    required this.onTap,
    this.isClose = false,
  });

  final IconData icon;
  final VoidCallback onTap;
  final bool isClose;

  @override
  State<_WinButton> createState() => _WinButtonState();
}

class _WinButtonState extends State<_WinButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit:  (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 46.w,
          height: 40.h,
          color: _hovered
              ? (widget.isClose
              ? const Color(0xFFC42B1C)   // красный при наведении на ✕
              : Colors.white.withOpacity(0.15))
              : Colors.transparent,
          child: Icon(widget.icon, color: Colors.white, size: 16.r),
        ),
      ),
    );
  }
}