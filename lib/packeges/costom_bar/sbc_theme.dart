import 'package:flutter/material.dart';
class ChartTheme {
  // palette
  static const Color green = Color(0xFF7DC832);
  static const Color dark  = Color(0xFF2E3A2F);
  static const Color gray  = Color(0xFF8A9BA8);

  // card
  final Color cardColor;
  final Color cardBorderColor;
  final double cardRadius;
  final List<BoxShadow> cardShadow;
  final EdgeInsets cardPadding;

  // grid
  final Color gridColor;

  // bars
  final double barWidth;
  final double barTopRadius;
  final double barBottomRadius;
  final double minLabelHeight; // мин высота сегмента для показа label

  // segment labels
  final TextStyle segmentLabelStyle;

  // y-axis
  final TextStyle yAxisLabelStyle;

  // tooltip
  final Color tooltipBg;
  final Color tooltipBorder;
  final double tooltipRadius;
  final TextStyle tooltipLabelStyle;
  final TextStyle tooltipValueStyle;
  final EdgeInsets tooltipPadding;

  // header (title + legend) — снаружи карточки
  final TextStyle titleStyle;
  final TextStyle legendStyle;
  final double legendDotSize;

  // animation
  final Duration animDuration;
  final Curve animCurve;

  // sizing
  final double chartHeight;  // высота зоны столбцов
  final double xLabelHeight; // высота зоны подписей X

  const ChartTheme({
    this.barBottomRadius = 10,
    this.cardColor       = const Color(0xFFFFFFFF),
    this.cardBorderColor = const Color(0xFFE0E6ED),
    this.cardRadius      = 12,
    this.cardShadow      = const [
      BoxShadow(color: Color(0x0A000000), blurRadius: 8, offset: Offset(0, 2)),
    ],
    this.cardPadding     = const EdgeInsets.fromLTRB(16, 12, 16, 0),

    this.gridColor       = const Color(0xFFE8EDF2),

    this.barWidth        = 50,
    this.barTopRadius    = 3,
    this.minLabelHeight  = 16,

    this.segmentLabelStyle = const TextStyle(
      color: Colors.white,
      fontSize: 11,
      fontWeight: FontWeight.w600,
    ),

    this.yAxisLabelStyle = const TextStyle(
      fontSize: 10,
      color: Color(0xFF8A9BA8),
    ),

    this.tooltipBg          = const Color(0xFF2E3A2F),
    this.tooltipBorder      = const Color(0xFF2E3A2F),
    this.tooltipRadius      = 8,
    this.tooltipLabelStyle  = const TextStyle(fontSize: 10, color: Color(0xFF9BB09F)),
    this.tooltipValueStyle  = const TextStyle(
      fontSize: 12, color: Colors.white, fontWeight: FontWeight.w600,
    ),
    this.tooltipPadding     = const EdgeInsets.symmetric(horizontal: 12, vertical: 8),

    this.titleStyle = const TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.5,
      color: Color(0xFF2E3A2F),
    ),
    this.legendStyle  = const TextStyle(fontSize: 11, color: Color(0xFF8A9BA8)),
    this.legendDotSize = 9,

    this.animDuration  = const Duration(milliseconds: 600),
    this.animCurve     = Curves.easeOutCubic,

    this.chartHeight   = 200,
    this.xLabelHeight  = 50,
  });

  ChartTheme copyWith({
    Color? cardColor, Color? cardBorderColor, double? cardRadius,
    List<BoxShadow>? cardShadow, EdgeInsets? cardPadding,
    Color? gridColor, double? barWidth, double? barTopRadius,
    double? minLabelHeight, TextStyle? segmentLabelStyle,
    TextStyle? yAxisLabelStyle, Color? tooltipBg, Color? tooltipBorder,
    double? tooltipRadius, TextStyle? tooltipLabelStyle,
    TextStyle? tooltipValueStyle, EdgeInsets? tooltipPadding,
    TextStyle? titleStyle, TextStyle? legendStyle, double? legendDotSize,
    Duration? animDuration, Curve? animCurve,
    double? chartHeight, double? xLabelHeight,
  }) => ChartTheme(
    cardColor: cardColor ?? this.cardColor,
    cardBorderColor: cardBorderColor ?? this.cardBorderColor,
    cardRadius: cardRadius ?? this.cardRadius,
    cardShadow: cardShadow ?? this.cardShadow,
    cardPadding: cardPadding ?? this.cardPadding,
    gridColor: gridColor ?? this.gridColor,
    barWidth: barWidth ?? this.barWidth,
    barTopRadius: barTopRadius ?? this.barTopRadius,
    minLabelHeight: minLabelHeight ?? this.minLabelHeight,
    segmentLabelStyle: segmentLabelStyle ?? this.segmentLabelStyle,
    yAxisLabelStyle: yAxisLabelStyle ?? this.yAxisLabelStyle,
    tooltipBg: tooltipBg ?? this.tooltipBg,
    tooltipBorder: tooltipBorder ?? this.tooltipBorder,
    tooltipRadius: tooltipRadius ?? this.tooltipRadius,
    tooltipLabelStyle: tooltipLabelStyle ?? this.tooltipLabelStyle,
    tooltipValueStyle: tooltipValueStyle ?? this.tooltipValueStyle,
    tooltipPadding: tooltipPadding ?? this.tooltipPadding,
    titleStyle: titleStyle ?? this.titleStyle,
    legendStyle: legendStyle ?? this.legendStyle,
    legendDotSize: legendDotSize ?? this.legendDotSize,
    animDuration: animDuration ?? this.animDuration,
    animCurve: animCurve ?? this.animCurve,
    chartHeight: chartHeight ?? this.chartHeight,
    xLabelHeight: xLabelHeight ?? this.xLabelHeight,
  );
}