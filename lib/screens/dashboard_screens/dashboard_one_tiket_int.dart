import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:service_desk/const/const_colors.dart';
import 'package:service_desk/models/reports_model/report_response_model.dart';

import '../../blocs/report_dashboard_tiket_inputs_bloc/report_table_input_bloc.dart';
import '../../blocs/report_dashboard_tiket_inputs_bloc/report_table_input_event.dart';
import '../../blocs/report_dashboard_tiket_inputs_bloc/report_table_input_state.dart';
import '../../data_base/data_models/user_model_db.dart';
import '../../data_base/user_repository.dart';
import '../../models/reports_model/report_post_model.dart';
import '../../packeges/costom_bar/models.dart';
import '../../packeges/costom_bar/sbc_theme.dart';
import '../../packeges/costom_bar/stacked_bar_chart.dart';
import '../../services/report_service.dart';
import '../../utils/period_type_dashboard_one.dart';
import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Маппинг PeriodType → dateGrouping для API
// ─────────────────────────────────────────────────────────────────────────────
extension _PeriodExt on PeriodTypeDashboardOne {
  String get apiGrouping => switch (this) {
    PeriodTypeDashboardOne.week => '0', // Day   → "2026-04-21"
    PeriodTypeDashboardOne.month => '1', // Week  → "2026-W15"
    _ => '2', // Month → "2026-04"
  };
}

// ─────────────────────────────────────────────────────────────────────────────
// Генератор всех ключей периода (для заполнения пустых слотов)
// ─────────────────────────────────────────────────────────────────────────────
class _Keys {
  static List<String> of(
    PeriodTypeDashboardOne p,
    DateTime from,
    DateTime to,
  ) => switch (p) {
    PeriodTypeDashboardOne.week => _days(from, to),
    PeriodTypeDashboardOne.month => _weeks(from, to),
    _ => _months(from, to),
  };

  static List<String> _days(DateTime from, DateTime to) {
    final r = <String>[];
    var d = _d(from);
    while (!d.isAfter(_d(to))) {
      r.add('${d.year}-${_p(d.month)}-${_p(d.day)}');
      d = d.add(const Duration(days: 1));
    }
    return r;
  }

  static List<String> _weeks(DateTime from, DateTime to) {
    final r = <String>[];
    var mon = from.subtract(Duration(days: from.weekday - 1));
    while (!mon.isAfter(to)) {
      final k = '${mon.year}-W${_p(_isoWeek(mon))}';
      if (!r.contains(k)) r.add(k);
      mon = mon.add(const Duration(days: 7));
    }
    return r;
  }

  static List<String> _months(DateTime from, DateTime to) {
    final r = <String>[];
    var d = DateTime(from.year, from.month);
    while (!d.isAfter(DateTime(to.year, to.month))) {
      r.add('${d.year}-${_p(d.month)}');
      d = DateTime(d.year, d.month + 1);
    }
    return r;
  }

  static DateTime _d(DateTime d) => DateTime(d.year, d.month, d.day);

  static String _p(int n) => n.toString().padLeft(2, '0');

  static int _isoWeek(DateTime d) {
    final doy = d.difference(DateTime(d.year, 1, 1)).inDays + 1;
    return ((doy + DateTime(d.year, 1, 1).weekday - 2) ~/ 7) + 1;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Построитель XLabel по типу периода и ключу
// ─────────────────────────────────────────────────────────────────────────────
class _XLabelBuilder {
  static const _days = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'];
  static const _months = [
    '',
    'Янв',
    'Фев',
    'Мар',
    'Апр',
    'Май',
    'Июн',
    'Июл',
    'Авг',
    'Сен',
    'Окт',
    'Ноя',
    'Дек',
  ];

  /// Строит [XLabel] для столбца.
  /// [total] = 0 → подпись "Total" не показывается.
  static XLabel build(String key, PeriodTypeDashboardOne period, int total) {
    final topStr = total > 0 ? total : 0;

    return switch (period) {
      PeriodTypeDashboardOne.week => _weekLabel(key, topStr.toString()),
      PeriodTypeDashboardOne.month => _monthLabel(key, topStr.toString()),
      _ => _yearLabel(key, topStr.toString()),
    };
  }

  // "2026-04-21" → middle: "Лу", bottom: "06.04"
  static XLabel _weekLabel(String key, String? top) {
    final date = DateTime.tryParse(key);
    if (date == null) return XLabel(topLabel: top, middle: key);
    return XLabel(
      //  topLabel: top,
      //  middle: _days[date.weekday - 1],
      //  bottom: '${_p(date.day)}.${_p(date.month)}',
      builder: _saptanima(top, date),
    );
  }

  // "2026-W15" → middle: "W2", bottom: "Апр"
  static XLabel _monthLabel(String key, String? top) {

    return XLabel(
    //  topLabel: top,
    //  middle: 'W$weekInMonth',
   //   bottom: _months[weekMon.month.clamp(0, 12)],
      builder: _luna(top, key),
    );
  }

  // "2026-04" → middle: "Апр"
  static XLabel _yearLabel(String key, String? top) {
    final parts = key.split('-');
    if (parts.length < 2) return XLabel(topLabel: top, middle: key);
    final mo = int.tryParse(parts[1]) ?? 0;
    return XLabel(
      //    topLabel: top,
      //    middle: _months[mo.clamp(0, 12)]
      builder: _anLuni(top, mo),
    );
  }

  static String _p(int n) => n.toString().padLeft(2, '0');




  static Widget _luna(String? top, String key) {
    final m = RegExp(r'^(\d{4})-W(\d{1,2})$').firstMatch(key.trim());
    if (m == null) return XLabel(topLabel: top, middle: key);

    final year = int.parse(m.group(1)!);
    final weekNum = int.parse(m.group(2)!);

    // Первый понедельник ISO-недели weekNum
    final jan4 = DateTime(year, 1, 4);
    final week1Mon = jan4.subtract(Duration(days: jan4.weekday - 1));
    final weekMon = week1Mon.add(Duration(days: (weekNum - 1) * 7));

    // Порядковый номер недели внутри своего месяца
    final weekInMonth = ((weekMon.day - 1) ~/ 7) + 1;

    return Container(
      margin: EdgeInsets.symmetric(vertical: 3.w, horizontal: 4.h),
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6.r),
        border: Border.all(color: AppColors.borderCardColor, width: 1.w),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Total",
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500,
                  color: AppColors.hintTextColor,
                  fontSize: 10.sp.clamp(10, 20),
                ),
              ),
              Spacer(),
              Text(
                top ?? '0',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500,
                  color: AppColors.hintTextColor,
                  fontSize: 10.sp.clamp(10, 20),
                ),
              ),
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                'W$weekInMonth',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w700,
                  color: AppColors.hintTextColor,
                  fontSize: 10.sp.clamp(10, 20),
                ),
              ),
              Spacer(),
              Text(
                _months[weekMon.month.clamp(0, 12)],
                textAlign: TextAlign.start,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w700,
                  color: AppColors.hintTextColor,
                  fontSize: 10.sp.clamp(10, 20),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }


  static Widget _saptanima(String? top, DateTime date) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 2.w, horizontal: 4.h),
      padding: EdgeInsets.symmetric(horizontal: 5.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6.r),
        border: Border.all(color: AppColors.borderCardColor, width: 1.w),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Total",
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500,
                  color: AppColors.hintTextColor,
                  fontSize: 10.sp.clamp(10, 20),
                ),
              ),
              Spacer(),
              Text(
                top ?? '0',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500,
                  color: AppColors.hintTextColor,
                  fontSize: 10.sp.clamp(10, 20),
                ),
              ),
            ],
          ),
          Expanded(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  _days[date.weekday - 1],
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w300,
                    color: AppColors.hintTextColor,
                    fontSize: 10.sp.clamp(10, 20),
                  ),
                ),
                Spacer(),
                Text(
                  '${_p(date.day)}.${_p(date.month)}',
                  textAlign: TextAlign.start,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w300,
                    color: AppColors.hintTextColor,
                    fontSize: 10.sp.clamp(10, 20),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _anLuni(String? top, int mo) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 2.w, horizontal: 4.h),
      padding: EdgeInsets.symmetric(horizontal: 3.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6.r),
        border: Border.all(color: AppColors.borderCardColor, width: 1.w),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Total",
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500,
                  color: AppColors.hintTextColor,
                  fontSize: 10.sp.clamp(10, 20),
                ),
              ),
              Spacer(),
              Text(
                top ?? '0',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500,
                  color: AppColors.hintTextColor,
                  fontSize: 10.sp.clamp(10, 20),
                ),
              ),
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                _months[mo.clamp(0, 12)],
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w700,
                  color: AppColors.hintTextColor,
                  fontSize: 20.sp.clamp(10, 20),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Публичный виджет
// ─────────────────────────────────────────────────────────────────────────────
class DashboardOneTiketInt extends StatelessWidget {
  final DateTime startData;
  final DateTime endData;
  final PeriodTypeDashboardOne period;
  final int? company;

  const DashboardOneTiketInt({
    super.key,
    required this.startData,
    required this.endData,
    required this.period,
    this.company,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ReportTableInputBloc(reportService: ReportService(), userRepository: UserRepository()),
      child: _View(
        startData: startData,
        endData: endData,
        period: period,
        company: company,
      ),
    );
  }
}

class _View extends StatefulWidget {
  final DateTime startData;
  final DateTime endData;
  final PeriodTypeDashboardOne period;
  final int? company;

  const _View({
    required this.startData,
    required this.endData,
    required this.period,
    this.company,
  });

  @override
  State<_View> createState() => _ViewState();
}

class _ViewState extends State<_View> {
  final _userRepo = UserRepository();
  UserModelDB? _user;


  Future<void> _load() async {
    final user = await _userRepo.getUser();
    if (!mounted) return;
    setState(() => _user = user);
    context.read<ReportTableInputBloc>().add(
      ReportTableInputRequested(
        ReportPostModel(
          name: 'DashboardBarChart',
          dateFrom: widget.startData,
          dateTo: widget.endData,
          showTotalCount: true,
          filterAuthorId: 0,
          filterStatus: 0,
          filterCategory: 0,
          filterPriority: 0,
          filterUserId: _user?.userId ?? 0,
          groupBy: '5',
          sortBy: '2',
          sortDescending: false,
          dateGrouping: widget.period.apiGrouping,
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void didUpdateWidget(_View old) {
    super.didUpdateWidget(old);
    if (old.period != widget.period ||
        old.startData != widget.startData ||
        old.endData != widget.endData) {
      _load();
    }
  }

  static final ChartTheme _theme = ChartTheme(
    chartHeight: 500.h,
    barWidth: 84.w,
    cardRadius: 10.r,
    xLabelHeight: 65.h,
  );
  static const _yAxis = YAxisConfig(divisions: 10);

  static final _header = ChartHeader(
    title: 'SOLICITĂRI PRIMITE',
    legend: [
      LegendItem(
        color: ChartTheme.green,
        label: 'Fără încălcări',
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.w300,
          color: AppColors.hintTextColor,
          fontSize: 10.sp.clamp(10, 20),
        ),
      ),
      LegendItem(
        color: ChartTheme.dark,
        label: 'Expirate',
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.w300,
          color: AppColors.hintTextColor,
          fontSize: 10.sp.clamp(10, 20),
        ),
      ),
    ],
    theme: _theme,
  );

  List<ChartBar> _convert(List<ReportRowResponse> rows) {
    // Индекс данных по label (trim на случай пробелов)
    final dataMap = {for (final r in rows) r.label.trim(): r};

    // Полный список ключей периода
    final keys = _Keys.of(widget.period, widget.startData, widget.endData);

    return keys.map((key) {
      final r = dataMap[key];
      final total = r?.count ?? 0;
      final overdue = (r?.overdueCount ?? 0).clamp(0, total);
      final clean = total - overdue;

      return ChartBar(
        segments: [
          // Нижний зелёный
          if (clean > 0)
            ChartSegment(
              countNorm: clean,
              value: clean.toDouble(),
              color: ChartTheme.green,
              label: '$clean',
                labelStyle: GoogleFonts.poppins(
                  fontWeight: FontWeight.w700,
                  fontSize: 10.sp.clamp(10, 20),
                  color: AppColors.backgroundColor
                ),
              gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: AppColors.gradientColorBottom)
            ),
          // Верхний тёмный
          if (overdue > 0)
            ChartSegment(
              countNorm: 0,
              value: overdue.toDouble(),
              color: ChartTheme.dark,
              label: '$overdue',
                labelStyle: GoogleFonts.poppins(
                    fontWeight: FontWeight.w700,
                    fontSize: 10.sp.clamp(10, 20),
                    color: AppColors.backgroundColor
                ),
              gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                  colors: AppColors.gradientColorTop)
            ),
          // Пустой слот — нужен чтобы столбец занял место в Row
          if (total == 0)
            const ChartSegment(countNorm: 0, value: 0, color: Colors.transparent),
        ],
        // XLabel строится автоматически по типу периода
        xLabel: _XLabelBuilder.build(key, widget.period, total),
        tooltip: total > 0
            ? [
                TooltipRow('Total', '$total'),
                TooltipRow('Fără încălcări', '$clean'),
                TooltipRow('Expirate', '$overdue'),
              ]
            : null,
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReportTableInputBloc, ReportTableInputState>(
      builder: (_, state) {
        if (state is ReportInputLoading) {
          return StackedBarChart(
            bars: const [],
            header: _header,
            theme: _theme,
            yAxis: _yAxis,
            emptyWidget: const SizedBox(
              height: 200,
              child: Center(
                child: CircularProgressIndicator(color: ChartTheme.green),
              ),
            ),
          );
        }

        if (state is ReportInputSuccess) {
          return StackedBarChart(
            bars: _convert(state.report.rows),
            header: _header,
            theme: _theme,
            yAxis: _yAxis,
          );
        }

        if (state is ReportInputFailure) {
          return StackedBarChart(
            bars: const [],
            header: _header,
            theme: _theme,
            yAxis: _yAxis,
            emptyWidget: const SizedBox(
              height: 260,
              child: Center(child: Text('Ошибка загрузки')),
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}
