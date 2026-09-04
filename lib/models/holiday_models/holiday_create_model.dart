// -----------------------------------------------------------
// Holiday (создание, соответствует HolidayDto)
// -----------------------------------------------------------
class HolidayCreateModel {
  // oid в схеме HolidayDto не задокументирован (нет PUT/edit у Holiday на
  // бэке) — читаем его из ответа defensively, только для отображения в списке.
  final int oid;
  final String name;
  final DateTime date;
  final bool isRecurringYearly;

  const HolidayCreateModel({
    this.oid = 0,
    required this.name,
    required this.date,
    this.isRecurringYearly = false,
  });

  factory HolidayCreateModel.fromJson(Map<String, dynamic> json) {
    return HolidayCreateModel(
      oid: json['oid'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      date: DateTime.tryParse(json['date'] as String? ?? '') ?? DateTime.now(),
      isRecurringYearly: json['isRecurringYearly'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'date': date.toIso8601String(),
    'isRecurringYearly': isRecurringYearly,
  };
}
