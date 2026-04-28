import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:service_desk/const/const_colors.dart';
import 'package:service_desk/packeges/costom_nav/icon_nav.dart';
import 'package:service_desk/packeges/costom_nav/svg_icon.dart';

import 'nav_item.dart';

class CostomSidebar extends StatefulWidget {
  final List<NavItem> items;
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;
  final String userName;

  const CostomSidebar({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onItemSelected,
    required this.userName,
  });

  @override
  State<CostomSidebar> createState() => _CostomSidebarState();
}

class _CostomSidebarState extends State<CostomSidebar>
    with SingleTickerProviderStateMixin {
  bool _expanded = false;
  late AnimationController _controller;

  late Animation<double> _fadeAnim;

  static double _collapsedW = 48.w;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 1.0, curve: Curves.easeIn),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _expand() {
    setState(() => _expanded = true);
    _controller.forward();
  }

  void _collapse() {
    setState(() => _expanded = false);
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveBreakpoints.of(context);
    return MouseRegion(
      //  onEnter: (_) => _expand(),
      onExit: (_) => _collapse(),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return Container(
            width:responsive.isDesktop ?  48.w : 100.w,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                right: BorderSide(color: AppColors.backgroundColor, width: 0.5),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 20,
                  offset: const Offset(2, 0),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: responsive.isDesktop ? 16.h: 16.h/2),
                // Logo
                _Logo(fadeAnim: _fadeAnim),
                SizedBox(height: 8.h),
                // Nav items
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      for (int i = 0; i < widget.items.length; i++) ...[
                        SizedBox(height: responsive.isDesktop ? 24.h : 24.h*2,),
                        _NavTile(
                          paddingW: 15.w,
                          paddingH: 8.h,
                          item: widget.items[i],
                          selected: widget.selectedIndex == i,
                          fadeAnim: _fadeAnim,
                          onTap: () => widget.onItemSelected(i),
                        ),
                      ],
                    ],
                  ),
                ),

                // Divider before profile
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  child: Divider(
                    height: 1,
                    color: Colors.grey.shade200,
                    thickness: 0.5,
                  ),
                ),

                // Profile
                _ProfileTile(fadeAnim: _fadeAnim, user: widget.userName,),

                const SizedBox(height: 12),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _Logo extends StatelessWidget {
  final Animation<double> fadeAnim;

  const _Logo({required this.fadeAnim});

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveBreakpoints.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: responsive.isDesktop ? 30.w : 90.w,
          height: responsive.isDesktop ? 30.h : 90.h,
          child: SvgPicture.asset(IconNav.logo,fit: BoxFit.contain,),
        ),
      ],
    );
  }
}

class _NavTile extends StatefulWidget {
  final NavItem item;
  final bool selected;
  final double paddingW;
  final double paddingH;
  final Animation<double> fadeAnim;
  final VoidCallback onTap;

  const _NavTile({
    required this.item,
    required this.selected,
    required this.fadeAnim,
    required this.onTap,
    required this.paddingW,
    required this.paddingH,
  });

  @override
  State<_NavTile> createState() => _NavTileState();
}

class _NavTileState extends State<_NavTile> {
  bool _hovered = false;
  OverlayEntry? _overlayEntry;

  @override
  Widget build(BuildContext context) {
    final active = widget.selected;
    final responsive = ResponsiveBreakpoints.of(context);
    // Выбираем нужную иконку
    final iconPath = active ? widget.item.iconSelected : widget.item.icon;

    return MouseRegion(
      onEnter: (_){
        setState((){
          _hovered = true;
          _showTooltip();
        });
      },
      onExit: (_) {
        setState(() {
          _hovered = false;
          _hideTooltip();
        });
      },
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
             width: responsive.isDesktop ? 30.w : 96.w,
              height: responsive.isDesktop ? 16.h : 20.h,
          //    color: Colors.grey,
              child: SvgIcon(assetPath: iconPath),
            ),
          ],
        ),
      ),
    );
  }
  void _hideTooltip() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _showTooltip() {
    final overlay = Overlay.of(context);
    final box = context.findRenderObject() as RenderBox;
    final position = box.localToGlobal(Offset.zero);

    _overlayEntry = OverlayEntry(
      builder: (context) {
        return Positioned(
          left: position.dx + box.size.width + 1,
          top: position.dy + box.size.height / 6 - 16,
          child: Material(
            color: Colors.transparent,
            child: Container(
              height: 32.h,
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              decoration: BoxDecoration(
                color: AppColors.backgroundColor,
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(
                  color: AppColors.borderCardColor,
                  width: 1.w
                )
              ),
              child: Center(
                child: Text(
                  widget.item.label,
                  style: GoogleFonts.poppins(
                    color: Colors.black,
                    fontWeight: FontWeight.w300,
                    fontSize: 10.sp.clamp(10, 40)
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );

    overlay.insert(_overlayEntry!);
  }

}

class _ProfileTile extends StatelessWidget {
  final Animation<double> fadeAnim;
  final String user;

  const _ProfileTile({required this.fadeAnim, required this.user});

  String userCutName(String name) {
    if (name.isEmpty) return '';

    String cut = name.length >= 2 ? name.substring(0, 2) : name;

    return cut[0].toUpperCase() + cut.substring(1).toLowerCase();
  }
  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveBreakpoints.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Container(
          width: responsive.isDesktop ? 26.w : 26.w * 4,
          height: responsive.isDesktop ? 26.h : 26.h * 4,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [Color(0xFFFF9A9E), Color(0xFFFECFEF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(color: Colors.grey.shade200, width: 1.5.w),
          ),
          child: Center(
            child: Text(
              userCutName(user),
              style: TextStyle(
                fontSize: 11.sp.clamp(10, 40),
                fontWeight: FontWeight.w600,
                color: Color(0xFFC2185B),
              ),
            ),
          ),
        ),
      ],
    );
  }
  }
