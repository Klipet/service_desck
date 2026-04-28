class TicketSolutionRequest {
  final int id;
  final int tiket;
  final int author;
  final int user;
  final String messageText;
  final DateTime createdAt;
  final List<String> emailList;

  TicketSolutionRequest({
    required this.id,
    required this.tiket,
    required this.author,
    required this.user,
    required this.messageText,
    required this.createdAt,
    required this.emailList,
  });

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