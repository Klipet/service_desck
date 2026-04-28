class TicketSolutionResponse {
  final int id;
  final int tiket;
  final int author;
  final int user;
  final String messageText;
  final DateTime createdAt;
  final List<String> emailList;

  TicketSolutionResponse({
    required this.id,
    required this.tiket,
    required this.author,
    required this.user,
    required this.messageText,
    required this.createdAt,
    required this.emailList,
  });

  factory TicketSolutionResponse.fromJson(Map<String, dynamic> json) {
    return TicketSolutionResponse(
      id: json["id"]??0,
      tiket: json["tiket"]?? 0,
      author: json["author"]?? 0,
      user: json["user"]?? 0,
      messageText: json["messageText"]?? '',
      createdAt: json["createdAt"] != null && json["createdAt"] != ''
          ? DateTime.parse(json["createdAt"])
          : DateTime.now(),
      emailList: (json["emailList"] as List?)
          ?.where((e) => e != null)
          .map((e) => e.toString())
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "tiket": tiket,
      "author": author,
      "user": user,
      "messageText": messageText,
      "createdAt": createdAt.toIso8601String(),
      "emailList": emailList,
    };
  }
}