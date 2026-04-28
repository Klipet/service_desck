import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:service_desk/const/const_colors.dart';
import 'package:service_desk/packeges/costom_bar/sbc_theme.dart';

import 'models.dart';

// ─────────────────────────────────────────────────────────────────────────────
// StackedBarChart
// ─────────────────────────────────────────────────────────────────────────────
class StackedBarChart extends StatefulWidget {
  final List<ChartBar> bars;

  /// Виджет над карточкой (title + legend). Используйте [ChartHeader].
  final Widget? header;

  final ChartTheme theme;
  final YAxisConfig yAxis;
  final bool showCard;
  final double? maxY;
  final Widget? emptyWidget;

  const StackedBarChart({
    super.key,
    required this.bars,
    this.header,
    this.theme = const ChartTheme(),
    this.yAxis = const YAxisConfig(),
    this.showCard = true,
    this.maxY,
    this.emptyWidget,
  });

  @override
  State<StackedBarChart> createState() => _StackedBarChartState();
}

class _StackedBarChartState extends State<StackedBarChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;
  int? _tapped;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: widget.theme.animDuration,
    );
    _anim = CurvedAnimation(parent: _ctrl, curve: widget.theme.animCurve);
    if (widget.bars.isNotEmpty) _ctrl.forward();
  }

  @override
  void didUpdateWidget(StackedBarChart old) {
    super.didUpdateWidget(old);
    if (old.bars != widget.bars) {
      _tapped = null;
      _ctrl.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  double get _maxY {
    final forced = widget.maxY ?? widget.yAxis.maxValue;
    if (forced != null) return forced;
    if (widget.bars.isEmpty) return 10;
    final mx = widget.bars.map((b) => b.total).reduce(math.max);
    if (mx <= 0) return 10;
    final step = (mx / widget.yAxis.divisions).ceilToDouble();
    return step * widget.yAxis.divisions;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => _build(constraints),
    );
  }

  Widget _build(BoxConstraints constraints) {
    final t = widget.theme;
    final maxY = _maxY;
    final hasHeader = widget.header != null;
    final hasYAxis = widget.yAxis.visible && widget.showCard;

    const headerH = 30.0;
    const headerGap = 5.0;

    // Доступная высота для строки [ось Y + карточка]
    final availH = constraints.hasBoundedHeight
        ? constraints.maxHeight - (hasHeader ? headerH + headerGap : 0)
        : t.chartHeight +
              t.xLabelHeight +
              t.cardPadding.vertical +
              t.cardPadding.horizontal;

    // Высота области столбцов
    // -2 = border карточки (1px сверху + 1px снизу)
    final chartH = (availH - t.cardPadding.vertical - t.xLabelHeight - 2).clamp(
      60.0,
      double.infinity,
    );

    // Тема с вычисленным chartHeight
    final et = t.copyWith(chartHeight: chartH);

    // ── Внутренность карточки ─────────────────────────────────────────────
    final inner = widget.bars.isEmpty
        ? (widget.emptyWidget ??
              SizedBox(
                height: chartH + et.xLabelHeight,
                child: Center(
                  child: Text(
                    'Нет данных',
                    style: TextStyle(color: Colors.green),
                  ),
                ),
              ))
        : AnimatedBuilder(
            animation: _anim,
            builder: (ctx, _) => SizedBox(
              height: chartH + et.xLabelHeight,
              child: CustomPaint(
                painter: _GridPainter(
                  divisions: widget.yAxis.divisions,
                  color: et.gridColor,
                  chartH: chartH,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: List.generate(widget.bars.length, (i) {
                    return Expanded(
                      child: _BarCol(
                        bar: widget.bars[i],
                        theme: et,
                        maxY: maxY,
                        animVal: _anim.value,
                        isSelected: _tapped == i,
                        onTap: () =>
                            setState(() => _tapped = _tapped == i ? null : i),
                      ),
                    );
                  }),
                ),
              ),
            ),
          );

    // ── Карточка ──────────────────────────────────────────────────────────
    final card = widget.showCard
        ? Container(
            height: availH,
            decoration: BoxDecoration(
              color: et.cardColor,
              borderRadius: BorderRadius.circular(et.cardRadius),
              border: Border.all(color: et.cardBorderColor),
              boxShadow: et.cardShadow,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(et.cardRadius),
              child: Padding(padding: et.cardPadding, child: inner),
            ),
          )
        : SizedBox(height: availH, child: inner);

    // ── Ось Y снаружи слева ───────────────────────────────────────────────
    final withYAxis = hasYAxis
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _YAxis(
                maxY: maxY,
                cfg: widget.yAxis,
                theme: et,
                topOffset: et.cardPadding.top,
              ),
              const SizedBox(width: 4),
              Expanded(child: card),
            ],
          )
        : SizedBox(width: double.infinity, child: card);

    // ── Заголовок снаружи сверху ──────────────────────────────────────────
    if (!hasHeader) return withYAxis;

    final headerPad = hasYAxis ? widget.yAxis.width + 6 : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      children: [
        Padding(
          padding: EdgeInsets.only(left: headerPad),
          child: widget.header!,
        ),
        const SizedBox(height: headerGap),
        Expanded(child: withYAxis),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ChartHeader — title + legend снаружи карточки
// ─────────────────────────────────────────────────────────────────────────────
class ChartHeader extends StatelessWidget {
  final String title;
  final List<LegendItem> legend;
  final ChartTheme theme;

  const ChartHeader({
    super.key,
    required this.title,
    this.legend = const [],
    this.theme = const ChartTheme(),
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 15,
      runSpacing: 6,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 10.sp.clamp(10, 20),
            fontWeight: FontWeight.w700,
            color: AppColors.hintTextColor,
          ),
        ),
        ...legend.map(
          (item) => Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 10.w,
                height: 10.h,
                decoration: BoxDecoration(
                  color: item.color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 4),
              Text(item.label, style: item.style ?? theme.legendStyle),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _YAxis
// ─────────────────────────────────────────────────────────────────────────────
class _YAxis extends StatelessWidget {
  final double maxY;
  final YAxisConfig cfg;
  final ChartTheme theme;
  final double topOffset;

  const _YAxis({
    required this.maxY,
    required this.cfg,
    required this.theme,
    required this.topOffset,
  });

  @override
  Widget build(BuildContext context) {
    final divs = cfg.divisions;
    final style = cfg.labelStyle ?? theme.yAxisLabelStyle;
    final totalH = topOffset + theme.chartHeight + theme.xLabelHeight;

    return SizedBox(
      width: cfg.width,
      height: totalH,
      child: Stack(
        children: List.generate(divs + 1, (i) {
          final val = maxY * (divs - i) / divs;
          final top = topOffset + theme.chartHeight * i / divs;
          return Positioned(
            top: top - 7,
            right: 0,
            child: Text(
              cfg.format(val),
              style: style,
              textAlign: TextAlign.right,
            ),
          );
        }),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _GridPainter
// ─────────────────────────────────────────────────────────────────────────────
class _GridPainter extends CustomPainter {
  final int divisions;
  final Color color;
  final double chartH;

  const _GridPainter({
    required this.divisions,
    required this.color,
    required this.chartH,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color
      ..strokeWidth = 1;
    for (var i = 0; i <= divisions; i++) {
      final y = chartH * i / divisions;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), p);
    }
  }

  @override
  bool shouldRepaint(_GridPainter o) =>
      o.divisions != divisions || o.color != color;
}

// ─────────────────────────────────────────────────────────────────────────────
// _BarCol — один столбец
// ─────────────────────────────────────────────────────────────────────────────
class _BarCol extends StatelessWidget {
  final ChartBar bar;
  final ChartTheme theme;
  final double maxY;
  final double animVal;
  final bool isSelected;
  final VoidCallback onTap;

  const _BarCol({
    required this.bar,
    required this.theme,
    required this.maxY,
    required this.animVal,
    required this.isSelected,
    required this.onTap,
  });


  @override
  Widget build(BuildContext context) {
    final totalH = maxY > 0
        ? (bar.total / maxY) * theme.chartHeight * animVal
        : 0.0;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          // ── Зона столбца — занимает всё доступное место ───────────────
          Expanded(
            child: Stack(
              alignment: Alignment.bottomCenter,
              clipBehavior: Clip.none,
              children: [
                if (isSelected)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.03),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                // передаём реальную высоту через LayoutBuilder
                LayoutBuilder(
                  builder: (ctx, bc) => _SegmentStack(
                    bar: bar,
                    theme: theme.copyWith(chartHeight: bc.maxHeight),
                    maxY: maxY,
                    animVal: animVal,
                  ),
                ),
                if (isSelected && bar.tooltip != null)
                  Positioned(
                    top: 0,
                    child: _TooltipPopup(rows: bar.tooltip!, theme: theme),
                  ),
              ],
            ),
          ),
          // ── Подпись X — фиксированная высота снизу ────────────────────
          SizedBox(height: theme.xLabelHeight, child: bar.xLabel),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _SegmentStack — сегменты снизу вверх
// ─────────────────────────────────────────────────────────────────────────────
class _SegmentStack extends StatelessWidget {
  final ChartBar bar;
  final ChartTheme theme;
  final double maxY;
  final double animVal;

  const _SegmentStack({
    required this.bar,
    required this.theme,
    required this.maxY,
    required this.animVal,
  });

  @override
  Widget build(BuildContext context) {
    final totalH =
    maxY > 0 ? (bar.total / maxY) * theme.chartHeight * animVal : 0.0;
    if (totalH <= 0) return const SizedBox.shrink();

    final clampedH = totalH.clamp(0.0, theme.chartHeight);

    // segments[0] = нижний (зелёный), segments[1] = верхний (тёмный)
    final segs    = bar.segments;
    final heights = segs
        .map((s) => bar.total > 0 ? (s.value / bar.total) * clampedH : 0.0)
        .toList();

    final greenH = heights.isNotEmpty ? heights[0] : 0.0;
    final darkH  = heights.length > 1 ? heights[1] : 0.0;

    // Минимальная высота при которой лейбл помещается ВНУТРИ сегмента
    const minInnerH = 20.0;

    return SizedBox(
      width: theme.barWidth,
      height: clampedH,
      child: Stack(
        clipBehavior: Clip.none,
        children: [

          // ── Сами сегменты ──────────────────────────────────────────────
          Positioned.fill(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(segs.length, (idx) {
                final i      = segs.length - 1 - idx; // рисуем сверху вниз
                final seg    = segs[i];
                final h      = heights[i].clamp(0.0, theme.chartHeight);
                final isTop  = i == segs.length - 1;
                final isBot  = i == 0;

                return Container(
                  width:  theme.barWidth,
                  height: h,
                  decoration: BoxDecoration(
                    gradient: seg.gradient,
                  //  color: seg.gradient == null ? seg.color : null,
                    borderRadius: BorderRadius.only(
                      topLeft:     isTop ? Radius.circular(theme.barTopRadius) : Radius.zero,
                      topRight:    isTop ? Radius.circular(theme.barTopRadius) : Radius.zero,
                    //  bottomLeft:  isBot ? Radius.circular(theme.barBottomRadius) : Radius.zero,
                    //  bottomRight: isBot ? Radius.circular(theme.barBottomRadius) : Radius.zero,
                    ),
                  ),
                );
              }),
            ),
          ),

          // ── Лейбл зелёного (segments[0]) ──────────────────────────────
          // Если сегмент достаточно высокий — внутри снизу,
          // если маленький — над столбцом снаружи
          if (segs.isNotEmpty && segs[0].label != null)
            greenH >= minInnerH
                ? Positioned(
              bottom: 6,
              left: 0,
              right: 0,
              child: Text(
                segs[0].label!,
                style: segs[0].labelStyle ?? theme.segmentLabelStyle,
                textAlign: TextAlign.center,
              ),
            )
                : Positioned(
              bottom: clampedH + 4, // над всем столбцом
              left: 0,
              right: 0,
              child: Text(
                segs[0].label!,
                style: (segs[0].labelStyle ?? theme.segmentLabelStyle)
                    .copyWith(color: segs[0].color),
                textAlign: TextAlign.center,
              ),
            ),

          // ── Лейбл тёмного (segments[1]) ───────────────────────────────
          // Если сегмент достаточно высокий — по центру внутри,
          // если маленький — над тёмным блоком снаружи
          if (segs.length > 1 && segs[1].label != null)
            darkH >= minInnerH
                ? Positioned(
              // центр тёмного сегмента (он наверху)
              top: (clampedH - darkH) / 2 + darkH / 2 - 8,
              left: 0,
              right: 0,
              child: Text(
                segs[1].label!,
                style: segs[1].labelStyle ?? theme.segmentLabelStyle,
                textAlign: TextAlign.center,
              ),
            )
                : Positioned(
              bottom: clampedH + 4,
              left: 0,
              right: 0,
              child: Text(
                segs[1].label!,
                style: (segs[1].labelStyle ?? theme.segmentLabelStyle)
                    .copyWith(color: segs[1].color),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _TooltipPopup
// ─────────────────────────────────────────────────────────────────────────────
class _TooltipPopup extends StatelessWidget {
  final List<TooltipRow> rows;
  final ChartTheme theme;

  const _TooltipPopup({required this.rows, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: theme.tooltipBg,
          borderRadius: BorderRadius.circular(theme.tooltipRadius),
          border: Border.all(color: theme.tooltipBorder),
          boxShadow: const [
            BoxShadow(
              color: Color(0x33000000),
              blurRadius: 6,
              offset: Offset(0, 4),
            ),
          ],
        ),
        padding: theme.tooltipPadding,
        child: IntrinsicWidth(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: rows
                .map(
                  (r) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 1),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('${r.label}  ', style: theme.tooltipLabelStyle),
                        Text(r.value, style: theme.tooltipValueStyle),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }
}
