class BarDataModel {
  final String dayLabel; // "Лу", "Ма" …
  final String dateLabel; // "06.04"
  final int total;
  final int overdue; // тёмный сегмент
  final int clean; // зелёный сегмент

  const BarDataModel({
    required this.dayLabel,
    required this.dateLabel,
    required this.total,
    required this.overdue,
    required this.clean,
  });
}