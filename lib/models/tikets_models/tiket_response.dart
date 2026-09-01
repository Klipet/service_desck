import 'package:service_desk/models/tikets_files/tiket_files_response.dart';
import 'package:service_desk/models/tikets_models/tiket_phone_model.dart';

import '../ticket_message/ticket_comment_model.dart';
import '../tikets_solutions/tiket_solution_response.dart';

class TicketResponse {
  final int id;
  final String? title;
  final String? description;
  final String? phone;
  final DateTime dataPhone;
  final bool resaultPhone;
  final DateTime dateSecondPhone;
  final String? bugNumber;
  final bool bugTransfer;
  final DateTime dataCreted;
  final DateTime dataModefire;
  final int userId;
  final String? userName;
  final int workSpaceId;
  final String? workSpaceName;
  final int stateId;
  final String? stateName;
  final int typeTiketId;
  final String? typeTiketName;
  final int preorityId;
  final String? preorityName;
  final int modeId;
  final String? modeName;
  final int subCategoryId;
  final String? subCategoryName;
  final int categoryId;
  final String? categoryName;
  final int authorId;
  final String? authorName;
  final int platformId;
  final String? platformName;
  final int companyId;
  final String? companyName;
  final DateTime dueDate;
  final List<TicketFileResponse> files;
  final List<TicketSolutionResponse> solution;
  final List<TicketMessageModel> comment;
  final List<TicketPhoneModel> phoneTicket;

  TicketResponse({
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
    required this.userName,
    required this.workSpaceId,
    required this.workSpaceName,
    required this.stateId,
    required this.stateName,
    required this.typeTiketId,
    required this.typeTiketName,
    required this.preorityId,
    required this.preorityName,
    required this.modeId,
    required this.modeName,
    required this.subCategoryId,
    required this.subCategoryName,
    required this.categoryId,
    required this.categoryName,
    required this.authorId,
    required this.authorName,
    required this.platformId,
    required this.platformName,
    required this.companyId,
    required this.companyName,
    required this.dueDate,
    required this.files,
    required this.solution,
    required this.comment,
    required this.phoneTicket
  });

  factory TicketResponse.fromJson(Map<String, dynamic> json) {
    return TicketResponse(
      id: json["id"] ?? 0,
      title: json["title"]?? '',
      description: json["description"]?? '',
      phone: json["phone"]?? '',
      dataPhone: json["dataPhone"] != null
          ? DateTime.parse(json["dataPhone"])
          : DateTime.now(),
      resaultPhone: json["resaultPhone"] ?? false,
      dateSecondPhone: json["dateSecondPhone"] != null
          ? DateTime.parse(json["dateSecondPhone"])
          : DateTime.now(),
      bugNumber: json["bugNumber"] ?? "",
      bugTransfer: json["bugTransfer"]?? false,
      dataCreted: json["dataCreted"] !=null ? DateTime.parse(json["dataCreted"]) : DateTime.now(),
      dataModefire:json["dataModefire"] !=null ? DateTime.parse(json["dataModefire"]) : DateTime.now(),
      userId: json["userId"]?? 0,
      userName: json["userName"]?? '',
      workSpaceId: json["workSpaceId"]?? 0,
      workSpaceName: json["workSpaceName"]?? '',
      stateId: json["stateId"]?? 0,
      stateName: json["stateName"]?? '',
      typeTiketId: json["typeTiketId"]?? 0,
      typeTiketName: json["typeTiketName"]?? '',
      preorityId: json["preorityId"]?? 0,
      preorityName: json["preorityName"]?? '',
      modeId: json["modeId"]?? 0,
      modeName: json["modeName"]?? '',
      subCategoryId: json["subCategoryId"]?? 0,
      subCategoryName: json["subCategoryName"]?? '',
      categoryId: json["categoryId"]?? 0,
      categoryName: json["categoryName"]?? '',
      authorId: json["authorId"]?? 0,
      authorName: json["authorName"]?? '',
      platformId: json["platformId"]?? 0,
      platformName: json["platformName"]?? '',
      companyId: json["companyId"]?? 0,
      companyName: json["companyName"]?? '',
      dueDate:json["dueDate"] != null ? DateTime.parse(json["dueDate"]) : DateTime.now(),
      files: json['files'] == null
          ? []
          : (json['files'] as List)
          .map((e) => TicketFileResponse.fromJson(e))
          .toList(),
      solution: json['solution'] == null
          ? []
          : (json['solution'] as List)
          .map((e) => TicketSolutionResponse.fromJson(e))
          .toList(),
      comment: json['message'] == null
          ? []
          : (json['message'] as List)
          .map((e) => TicketMessageModel.fromJson(e))
          .toList(),
      phoneTicket: json['phones'] == null
          ? []
          : (json['phones'] as List)
          .map((e) => TicketPhoneModel.fromJson(e))
          .toList(),
    );
  }
}