class TicketMargeModel {
  final int prymoryTiketId;
  final List<int> secindTiketId;

  TicketMargeModel({
    required this.prymoryTiketId,
    required this.secindTiketId,
  });

  Map<String, dynamic> toJson() {
    return {
      'prymoryTiketId': prymoryTiketId,
      'secindTiketId': secindTiketId,
    };
  }
}

class MergeTicketResponse {
  final int state;
  final String message;

  MergeTicketResponse({
    required this.state,
    required this.message,
  });

  factory MergeTicketResponse.fromJson(Map<String, dynamic> json) {
    return MergeTicketResponse(
      state: json['state'] as int,
      message: json['message'] as String,
    );
  }
}