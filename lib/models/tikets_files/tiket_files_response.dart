class TicketFileResponse {
  final int id;
  final String? fileUrl;
  final String? fileName;
  final bool isResponse;
  final int tiketOid;
  final int tiketResponseOid;

  TicketFileResponse({
    required this.id,
    required this.fileUrl,
    required this.fileName,
    required this.isResponse,
    required this.tiketOid,
    required this.tiketResponseOid,
  });

  factory TicketFileResponse.fromJson(Map<String, dynamic> json) {
    return TicketFileResponse(
      id: json["id"]??0,
      fileUrl: json["fileUrl"]?.toString() ?? "",
      fileName: json["fileName"]?.toString() ?? "",
      isResponse: json["isResponse"] ?? false,
      tiketOid: json["tiketOid"] ?? 0,
      tiketResponseOid: json["tiketResponseOid"] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "fileUrl": fileUrl,
      "fileName": fileName,
      "isResponse": isResponse,
      "tiketOid": tiketOid,
      "tiketResponseOid": tiketResponseOid,
    };
  }
}