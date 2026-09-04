// -----------------------------------------------------------
// EmailTemplate (элемент списка, GET /EmailTemplate/GetAllTemplate)
// -----------------------------------------------------------
class EmailTemplateListModel {
  final int oid;
  final String subjectTemplate;
  final String bodyHtmlTemplate;
  final bool isActive;
  final bool isHtml;
  final int stateOid;
  final String? stateName;

  const EmailTemplateListModel({
    required this.oid,
    required this.subjectTemplate,
    required this.bodyHtmlTemplate,
    required this.isActive,
    required this.isHtml,
    required this.stateOid,
    this.stateName,
  });

  factory EmailTemplateListModel.fromJson(Map<String, dynamic> json) {
    return EmailTemplateListModel(
      oid: json['oid'] as int? ?? 0,
      subjectTemplate: json['subjectTemplate'] as String? ?? '',
      bodyHtmlTemplate: json['bodyHtmlTemplate'] as String? ?? '',
      isActive: json['isActive'] as bool? ?? true,
      isHtml: json['isHtml'] as bool? ?? true,
      stateOid: json['stateOid'] as int? ?? 0,
      stateName: json['stateName'] as String?,
    );
  }
}
