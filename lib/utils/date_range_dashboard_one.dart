import 'package:service_desk/utils/period_type_dashboard_one.dart';

class DateRangeDashboardOne {
  final DateTime start;
  final DateTime end;

  DateRangeDashboardOne(this.start, this.end);
}

DateRangeDashboardOne getDateRange(PeriodTypeDashboardOne type) {
  final now = DateTime.now();

  switch (type) {
    case PeriodTypeDashboardOne.week:
      final start = now.subtract(Duration(days: now.weekday - 1));
      final end = start.add(Duration(days: 6)); // Пн–Пт
      return DateRangeDashboardOne(start, end);

    case PeriodTypeDashboardOne.month:
      final start = DateTime(now.year, now.month, 1);
      final end = DateTime(now.year, now.month + 1, 0);
      return DateRangeDashboardOne(start, end);

    case PeriodTypeDashboardOne.year:
      final start = DateTime(now.year, 1, 1);
      final end = DateTime(now.year, 12, 31);
      return DateRangeDashboardOne(start, end);

    case PeriodTypeDashboardOne.spring: // март–май
      return DateRangeDashboardOne(
        DateTime(now.year, 3, 1),
        DateTime(now.year, 5, 31),
      );

    case PeriodTypeDashboardOne.summer: // июнь–август
      return DateRangeDashboardOne(
        DateTime(now.year, 6, 1),
        DateTime(now.year, 8, 31),
      );

    case PeriodTypeDashboardOne.autumn: // сентябрь–ноябрь
      return DateRangeDashboardOne(
        DateTime(now.year, 9, 1),
        DateTime(now.year, 11, 30),
      );

    case PeriodTypeDashboardOne.winter: // декабрь–февраль ⚠️
      if (now.month == 12) {
        return DateRangeDashboardOne(
          DateTime(now.year, 12, 1),
          DateTime(now.year + 1, 2, 28),
        );
      } else {
        return DateRangeDashboardOne(
          DateTime(now.year - 1, 12, 1),
          DateTime(now.year, 2, 28),
        );
      }
  }
}