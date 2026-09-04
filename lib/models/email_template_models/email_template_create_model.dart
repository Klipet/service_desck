// -----------------------------------------------------------
// EmailTemplate (создание, соответствует EmailTemplateDto)
// -----------------------------------------------------------
class EmailTemplateCreateModel {
  final int oid;
  final String subjectTemplate;
  final String bodyHtmlTemplate;
  final bool isActive;
  final bool isHtml;
  final int stateOid;
  final String? stateName;

  const EmailTemplateCreateModel({
    this.oid = 0,
    required this.subjectTemplate,
    required this.bodyHtmlTemplate,
    this.isActive = true,
    this.isHtml = true,
    required this.stateOid,
    this.stateName,
  });

  Map<String, dynamic> toJson() => {
    'oid': oid,
    'subjectTemplate': subjectTemplate,
    'bodyHtmlTemplate': bodyHtmlTemplate,
    'isActive': isActive,
    'isHtml': isHtml,
    'stateOid': stateOid,
    'stateName': stateName,
  };
}
