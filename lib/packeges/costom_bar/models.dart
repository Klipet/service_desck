import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';


class ChartSegment {
  final double value;
  final int countNorm;
  final Color color;
  final String? label;
  final Gradient? gradient;
  final TextStyle? labelStyle;

  const ChartSegment({
    required this.countNorm,
    required this.value,
    required this.color,
    this.label,
    this.gradient,
    this.labelStyle,
  });
}

// ── Один столбец ─────────────────────────────────────────────────────────────
class ChartBar {
  final List<ChartSegment> segments;
  final Widget xLabel;
  final List<TooltipRow>? tooltip;

  const ChartBar({
    required this.segments,
    required this.xLabel,
    this.tooltip,
  });

  double get total => segments.fold(0.0, (s, e) => s + e.value);
}

// ── Стандартная подпись оси X ─────────────────────────────────────────────────
//
//  ┌──────────────────┐
//  │  Total      46   │  ← topLabel (серый) + topValue (жирный тёмный)
//  │  Лу              │  ← middle  (серый)
//  │  06.04           │  ← bottom  (тёмный, чуть крупнее)
//  └──────────────────┘
//
// Все стили переопределяемы. Передайте свой [builder] для полного контроля.
//
class XLabel extends StatelessWidget {
  // ── Данные ───────────────────────────────────────────────────────────────
  /// Левая часть первой строки: "Total"
  final String? topLabel;

  /// Правая часть первой строки (жирная): "46"
  final String? topValue;

  /// Вторая строка: "Лу" / "W1" / "Янв"
  final String? middle;

  /// Третья строка: "06.04" (только для week)
  final String? bottom;

  // ── Стили (все опциональны, есть дефолты) ────────────────────────────────
  final TextStyle? topLabelStyle;
  final TextStyle? topValueStyle;
  final TextStyle? middleStyle;
  final TextStyle? bottomStyle;

  // ── Разделитель ──────────────────────────────────────────────────────────
  final Color dividerColor;
  final double dividerThickness;

  // ── Паддинг внутри зоны ──────────────────────────────────────────────────
  final EdgeInsets padding;

  // ── Полностью свой виджет вместо стандартного содержимого ────────────────
  /// Если задан — игнорирует все остальные параметры кроме divider.
  final Widget? builder;

  const XLabel({
    super.key,
    this.topLabel,
    this.topValue,
    this.middle,
    this.bottom,
    this.topLabelStyle,
    this.topValueStyle,
    this.middleStyle,
    this.bottomStyle,
    this.dividerColor = const Color(0xFFE0E6ED),
    this.dividerThickness = 1,
    this.padding = const EdgeInsets.only(top: 5),
    this.builder,
  });

  // ── Дефолтные стили (совпадают с дизайном на скриншоте) ─────────────────
  TextStyle get _topLabelDefault => GoogleFonts.poppins(
    fontSize: 9.sp.clamp(9, 14),
    color: const Color(0xFF8A9BA8),
    fontWeight: FontWeight.w400,
  );

  TextStyle get _topValueDefault => GoogleFonts.poppins(
    fontSize: 9.sp.clamp(9, 14),
    color: const Color(0xFF2E3A2F),
    fontWeight: FontWeight.w700,
  );

  TextStyle get _middleDefault => GoogleFonts.poppins(
    fontSize: 9.sp.clamp(9, 14),
    color: const Color(0xFF8A9BA8),
    fontWeight: FontWeight.w400,
  );

  TextStyle get _bottomDefault => GoogleFonts.poppins(
    fontSize: 9.sp.clamp(9, 14),
    color: const Color(0xFF2E3A2F),
    fontWeight: FontWeight.w500,
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: dividerColor, width: dividerThickness),
        ),
      ),
      padding: padding,
      child: builder ??
          Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ── Total  46 ─────────────────────────────────────────────
              if (topLabel != null || topValue != null)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (topLabel != null)
                      Text(
                        topLabel!,
                        style: topLabelStyle ?? _topLabelDefault,
                      ),
                    if (topLabel != null && topValue != null)
                      const SizedBox(width: 4),
                    if (topValue != null)
                      Text(
                        topValue!,
                        style: topValueStyle ?? _topValueDefault,
                      ),
                  ],
                ),
              // ── Лу / W1 / Янв ────────────────────────────────────────
              if (middle != null) ...[
                const SizedBox(height: 1),
                Text(
                  middle!,
                  style: middleStyle ?? _middleDefault,
                  textAlign: TextAlign.center,
                ),
              ],
              // ── 06.04 ─────────────────────────────────────────────────
              if (bottom != null) ...[
                const SizedBox(height: 1),
                Text(
                  bottom!,
                  style: bottomStyle ?? _bottomDefault,
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
    );
  }
}

// ── Строка тултипа ───────────────────────────────────────────────────────────
class TooltipRow {
  final String label;
  final String value;

  const TooltipRow(this.label, this.value);
}

// ── Легенда ──────────────────────────────────────────────────────────────────
class LegendItem {
  final Color color;
  final String label;
  final TextStyle? style;

  const LegendItem({required this.color, required this.label, this.style});
}

// ── Настройки оси Y ──────────────────────────────────────────────────────────
class YAxisConfig {
  final double? maxValue;
  final int divisions;
  final String Function(double)? labelBuilder;
  final bool visible;
  final double width;
  final TextStyle? labelStyle;

  const YAxisConfig({
    this.maxValue,
    this.divisions = 6,
    this.labelBuilder,
    this.visible = true,
    this.width = 30,
    this.labelStyle,
  });

  String format(double v) {
    if (labelBuilder != null) return labelBuilder!(v);
    return v % 1 == 0 ? v.toInt().toString() : v.toStringAsFixed(1);
  }
}