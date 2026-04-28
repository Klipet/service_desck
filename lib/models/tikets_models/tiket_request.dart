class TicketRequest {
  final int id;
  final String title;
  final String description;
  final String phone;
  final DateTime dataPhone;
  final bool resaultPhone;
  final DateTime dateSecondPhone;
  final String bugNumber;
  final bool bugTransfer;
  final DateTime dataCreted;
  final DateTime dataModefire;
  final int userId;
  final int workSpaceId;
  final int stateId;
  final int typeTiketId;
  final int preorityId;
  final int modeId;
  final int subCategoryId;
  final int categoryId;
  final int authorId;
  final int platformId;
  final int companyId;

  TicketRequest({
    required this.id,
    required this.title,
    required this.description,
    required this.phone,
    required this.dataPhone,
    required this.resaultPhone,
    required this.dateSecondPhone,
    required this.bugNumber,
    required this.bugTransfer,
    required this.dataCreted,
    required this.dataModefire,
    required this.userId,
    required this.workSpaceId,
    required this.stateId,
    required this.typeTiketId,
    required this.preorityId,
    required this.modeId,
    required this.subCategoryId,
    required this.categoryId,
    required this.authorId,
    required this.platformId,
    required this.companyId,
  });

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "title": title,
      "description": description,
      "phone": phone,
      "dataPhone": dataPhone.toIso8601String(),
      "resaultPhone": resaultPhone,
      "dateSecondPhone": dateSecondPhone.toIso8601String(),
      "bugNumber": bugNumber,
      "bugTransfer": bugTransfer,
      "dataCreted": dataCreted.toIso8601String(),
      "dataModefire": dataModefire.toIso8601String(),
      "userId": userId,
      "workSpaceId": workSpaceId,
      "stateId": stateId,
      "typeTiketId": typeTiketId,
      "preorityId": preorityId,
      "modeId": modeId,
      "subCategoryId": subCategoryId,
      "categoryId": categoryId,
      "authorId": authorId,
      "platformId": platformId,
      "companyId": companyId,
    };
  }
}