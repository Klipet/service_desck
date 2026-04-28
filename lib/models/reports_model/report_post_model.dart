class ReportPostModel {
  final String name;
  final DateTime dateFrom;
  final DateTime dateTo;
  final bool showTotalCount;
  final int? filterAuthorId;
  final int? filterStatus;
  final int? filterCategory;
  final int? filterPriority;
  final int? filterUserId;
  final String groupBy;
  final String sortBy;
  final bool sortDescending;
  final String dateGrouping;

  ReportPostModel( {
    required this.name,
    required this.dateFrom,
    required this.dateTo,
    required this.showTotalCount,
    required this.filterAuthorId,
    required this.filterStatus,
    required this.filterCategory,
    required this.filterPriority,
    required this.filterUserId,
    required this.groupBy,
    required this.sortBy,
    required this.sortDescending,
    required this.dateGrouping,
  });

  /// 🔄 Из JSON
  factory ReportPostModel.fromJson(Map<String, dynamic> json) {
    return ReportPostModel(
      name: json['name'],
      dateFrom: DateTime.parse(json['dateFrom']),
      dateTo: DateTime.parse(json['dateTo']),
      showTotalCount: json['showTotalCount'],
      filterAuthorId: json['filterAuthorId'],
      filterStatus: json['filterStatus'],
      filterCategory: json['filterCategory'],
      filterPriority: json['filterPriority'],
      filterUserId: json['filterUserId'],
      groupBy: json['groupBy'],
      sortBy: json['sortBy'],
      sortDescending: json['sortDescending'],
        dateGrouping: json['dateGrouping']
    );
  }

  /// 📤 В JSON (для POST)
  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "dateFrom": dateFrom.toIso8601String(),
      "dateTo": dateTo.toIso8601String(),
      "showTotalCount": showTotalCount,
      "filterAuthorId": filterAuthorId,
      "filterStatus": filterStatus,
      "filterCategory": filterCategory,
      "filterPriority": filterPriority,
      "filterUserId": filterUserId,
      "groupBy": groupBy,
      "sortBy": sortBy,
      "sortDescending": sortDescending,
      "dateGrouping": dateGrouping
    };
  }
}