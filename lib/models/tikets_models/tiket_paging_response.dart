import 'package:service_desk/models/tikets_models/tiket_response.dart';

class TicketPagingResponse {
  final int totalCount;
  final int totalPages;
  final int page;
  final int pageSize;
  final List<TicketResponse> tikets;

  TicketPagingResponse({
    required this.totalCount,
    required this.pageSize,
    required this.page,
    required this.tikets,
    required this.totalPages,
  });
  factory TicketPagingResponse.fromJson(Map<String, dynamic> json){
    return TicketPagingResponse(
      totalCount: json["totalCount"] ?? 0,
      totalPages: json["totalPages"] ?? 0,
      page: json["page"] ?? 0,
      pageSize: json["pageSize"] ?? 0,
      tikets: json["tikets"] ?? [],

    );
  }
}
