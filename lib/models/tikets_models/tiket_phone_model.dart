class TicketPhoneModel {
  final int? id;
  final int? ticketId;
  final int? userId;
  final String? userName;
  final String? phone;
  final int? resultPhoneOid;
  final String? resultPhoneName;
  final String? comment;
  final DateTime? dataCreated;
  final bool? isActive;

  TicketPhoneModel({
    this.id,
    this.ticketId,
    this.userId,
    this.userName,
    this.phone,
    this.resultPhoneOid,
    this.resultPhoneName,
    this.comment,
    this.dataCreated,
    this.isActive,
  });

  factory TicketPhoneModel.fromJson(Map<String, dynamic> json) {
    return TicketPhoneModel(
      id: json['id'] as int?,
      ticketId: json['ticketId'] as int?,
      userId: json['userId'] as int?,
      userName: json['userName'] as String?,
      phone: json['phone'] as String?,
      resultPhoneOid: json['resultPhoneOid'] as int?,
      resultPhoneName: json['resultPhoneName'] as String?,
      comment: json['comment'] as String?,
      dataCreated: json['dataCreated'] != null
          ? DateTime.tryParse(json['dataCreated'].toString())
          : null,
      isActive: json['isActive'] as bool?,
    );
  }

  TicketPhoneModel copyWith({
    int? id,
    int? ticketId,
    int? userId,
    String? userName,
    String? phone,
    int? resultPhoneOid,
    String? resultPhoneName,
    String? comment,
    DateTime? dataCreated,
    bool? isActive,
  }) {
    return TicketPhoneModel(
      id: id ?? this.id,
      ticketId: ticketId ?? this.ticketId,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      phone: phone ?? this.phone,
      resultPhoneOid: resultPhoneOid ?? this.resultPhoneOid,
      resultPhoneName: resultPhoneName ?? this.resultPhoneName,
      comment: comment ?? this.comment,
      dataCreated: dataCreated ?? this.dataCreated,
      isActive: isActive ?? this.isActive,
    );
  }
}
