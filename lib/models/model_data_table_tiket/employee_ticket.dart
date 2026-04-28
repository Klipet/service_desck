class EmployeeTicket{
  final int id;
  final String title;
  final String phone;
  final String? bugNumber;
  final DateTime dataCreate;
  final DateTime dataModefire;
  final String? userName;
  final String? workSpaceName;
  final String? stateName;
  final String? typeTiketName;
  final String? preorityName;
  final String? modeName;
  final String? subCategoryName;
  final String? categoryName;
  final String? authorName;
  final String? platformName;
  final String? companyName;
  final DateTime dataDue;

  EmployeeTicket({
    required this.id,
    required this.title,
    required this.phone,
    required this.bugNumber,
    required this.dataCreate,
    required this.dataModefire,
    required this.userName,
    required this.workSpaceName,
    required this.stateName,
    required this.typeTiketName,
    required this.preorityName,
    required this.modeName,
    required this.subCategoryName,
    required this.categoryName,
    required this.authorName,
    required this.platformName,
    required this.companyName,
    required this.dataDue,
});
}