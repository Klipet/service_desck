class TicketMessageModel {
  final int id;
  final int ticketId;
  final int authorId;
  final String mailMessageId;
  final String messageText;
  final DateTime createdAt;
  final DateTime readAt;
  final bool isRead;

  TicketMessageModel({
    required this.id,
    required this.ticketId,
    required this.authorId,
    required this.mailMessageId,
    required this.messageText,
    required this.createdAt,
    required this.readAt,
    required this.isRead,
  });

  factory TicketMessageModel.fromJson(Map<String, dynamic> json) {
    return TicketMessageModel(
      id: json["id"] ??0,
      ticketId: json["tiket"]??0,
      authorId: json["author"]??0,
      mailMessageId: json["mailMessageId"] ?? '',
      messageText: json["messageText"] ?? '',
      createdAt:  json["createdAt"] !=null ? DateTime.parse(json["createdAt"]) : DateTime.now(),
      readAt:json["readAt"] !=null ? DateTime.parse(json['readAt']): DateTime.now(),
      isRead: json['isRead'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "tiket": ticketId,
      "author": authorId,
      "mailMessageId": mailMessageId,
      "messageText": messageText,
      "createdAt": createdAt,
    };
  }
}