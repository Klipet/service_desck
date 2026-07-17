
class TicketPostModel {
  int id;
  String title;
  String description;
  String phone;
  DateTime? dataPhone;
  bool resaultPhone;
  DateTime? dateSecondPhone;
  String bugNumber;
  bool bugTransfer;
  DateTime dataCreted;
  DateTime dataModefire;
  int userId; // Tehnician responsabil
  int workSpaceId; // Grupa
  int stateId; // Statut
  int typeTiketId; // Tipul solicitării
  int preorityId; // Prioritate
  int modeId; // Regim
  int subCategoryId;
  int categoryId;
  int authorId; // Контакт/автор обращения — резолвится по телефону/компании
  int platformId;
  int companyId;
  bool isActive;

  TicketPostModel({
    this.id = 0,
    this.title = '',
    this.description = '',
    this.phone = '',
    this.dataPhone,
    this.resaultPhone = false,
    this.dateSecondPhone,
    this.bugNumber = '',
    this.bugTransfer = false,
    DateTime? dataCreted,
    DateTime? dataModefire,
    this.userId = 0,
    this.workSpaceId = 0,
    this.stateId = 0,
    this.typeTiketId = 0,
    this.preorityId = 0,
    this.modeId = 0,
    this.subCategoryId = 0,
    this.categoryId = 0,
    this.authorId = 0,
    this.platformId = 0,
    this.companyId = 0,
    this.isActive = true,
  })  : dataCreted = dataCreted ?? DateTime.now(),
        dataModefire = dataModefire ?? DateTime.now();

  factory TicketPostModel.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic v) =>
        v == null ? null : DateTime.tryParse(v as String);

    return TicketPostModel(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      dataPhone: parseDate(json['dataPhone']),
      resaultPhone: json['resaultPhone'] as bool? ?? false,
      dateSecondPhone: parseDate(json['dateSecondPhone']),
      bugNumber: json['bugNumber'] as String? ?? '',
      bugTransfer: json['bugTransfer'] as bool? ?? false,
      dataCreted: parseDate(json['dataCreted']) ?? DateTime.now(),
      dataModefire: parseDate(json['dataModefire']) ?? DateTime.now(),
      userId: json['userId'] as int? ?? 0,
      workSpaceId: json['workSpaceId'] as int? ?? 0,
      stateId: json['stateId'] as int? ?? 0,
      typeTiketId: json['typeTiketId'] as int? ?? 0,
      preorityId: json['preorityId'] as int? ?? 0,
      modeId: json['modeId'] as int? ?? 0,
      subCategoryId: json['subCategoryId'] as int? ?? 0,
      categoryId: json['categoryId'] as int? ?? 0,
      authorId: json['authorId'] as int? ?? 0,
      platformId: json['platformId'] as int? ?? 0,
      companyId: json['companyId'] as int? ?? 0,
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'phone': phone,
      'dataPhone': dataPhone?.toIso8601String(),
      'resaultPhone': resaultPhone,
      'dateSecondPhone': dateSecondPhone?.toIso8601String(),
      'bugNumber': bugNumber,
      'bugTransfer': bugTransfer,
      'dataCreted': dataCreted.toIso8601String(),
      'dataModefire': dataModefire.toIso8601String(),
      'userId': userId,
      'workSpaceId': workSpaceId,
      'stateId': stateId,
      'typeTiketId': typeTiketId,
      'preorityId': preorityId,
      'modeId': modeId,
      'subCategoryId': subCategoryId,
      'categoryId': categoryId,
      'authorId': authorId,
      'platformId': platformId,
      'companyId': companyId,
      'isActive': isActive,
    };
  }
}