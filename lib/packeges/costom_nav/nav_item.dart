
import 'package:service_desk/packeges/costom_nav/svg_icon.dart';
class NavItem {
  final String icon;          // обычная иконка
  final String iconSelected;  // иконка при выборе
  final String label;
  final int? badge;

  const NavItem({
    required this.icon,
    required this.iconSelected,
    required this.label,
    this.badge,
  });
}