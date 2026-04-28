class ReportResponseModel {
  final String reportName;
  final DateTime generatedAt;
  final int totalCount;
  final String groupBy;
  final List<ReportRowResponse> rows;

  ReportResponseModel({
    required this.reportName,
    required this.generatedAt,
    required this.totalCount,
    required this.groupBy,
    required this.rows,
  });

  factory ReportResponseModel.fromJson(Map<String, dynamic> json) {
    return ReportResponseModel(
      reportName: json['reportName'],
      generatedAt: DateTime.parse(json['generatedAt']),
      totalCount: json['totalCount'],
      groupBy: json['groupBy'],
      rows: (json['rows'] as List)
          .map((e) => ReportRowResponse.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "reportName": reportName,
      "generatedAt": generatedAt.toIso8601String(),
      "totalCount": totalCount,
      "groupBy": groupBy,
      "rows": rows.map((e) => e.toJson()).toList(),
    };
  }
}
class ReportRowResponse {
  final String label;
  final int count;
  final int closedCount;
  final String authorName;
  final int authorOid;
  final int userOid;
  final String userName;
  final int overdueCount;
  final double avgResolutionHours;

  ReportRowResponse({
    required this.label,
    required this.count,
    required this.closedCount,
    required this.authorName,
    required this.authorOid,
    required this.userOid,
    required this.userName,
    required this.overdueCount,
    required this.avgResolutionHours,
  });

  factory ReportRowResponse.fromJson(Map<String, dynamic> json) {
    return ReportRowResponse(
      label: json['label']?? '',
      count: json['count'] ?? 0,
      closedCount: json['closedCount']?? 0,
      authorName: json['authorName']?? '',
      authorOid: json['authorOid']?? 0,
      userOid: json['userOid'] ?? 0,
      userName: json['userName']?? '',
      overdueCount: json['overdueCount'] ?? 0,
      avgResolutionHours:
      (json['avgResolutionHours'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "label": label,
      "count": count,
      "closedCount": closedCount,
      "authorName": authorName,
      "authorOid": authorOid,
      "userOid": userOid,
      "userName": userName,
      "overdueCount": overdueCount,
      "avgResolutionHours": avgResolutionHours,
    };
  }
}