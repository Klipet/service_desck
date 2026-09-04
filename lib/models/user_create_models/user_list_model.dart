// -----------------------------------------------------------
// User (элемент списка, GET /User).
// ВНИМАНИЕ: в swagger UserDto не содержит oid/id — читаем 'oid' из ответа
// defensively (сервер вероятно его отдаёт, просто не задокументировал).
// Если oid отсутствует (0) — редактирование этой записи заблокировано,
// чтобы случайно не отправить PUT на несуществующий/чужой id.
// Пароль из ответа НЕ читаем и нигде не храним/не показываем.
// -----------------------------------------------------------
class UserListModel {
  final int oid;
  final String name;
  final String firstName;
  final String email;
  final String? phone;
  final String loghin;
  final bool isActive;
  final DateTime dateCreated;
  final int workSpaceId;

  const UserListModel({
    this.oid = 0,
    required this.name,
    required this.firstName,
    required this.email,
    this.phone,
    required this.loghin,
    this.isActive = true,
    required this.dateCreated,
    required this.workSpaceId,
  });

  factory UserListModel.fromJson(Map<String, dynamic> json) {
    return UserListModel(
      oid: (json['oid'] ?? json['id']) as int? ?? 0,
      name: json['name'] as String? ?? '',
      firstName: json['firstName'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String?,
      loghin: json['loghin'] as String? ?? '',
      isActive: json['isActive'] as bool? ?? true,
      dateCreated:
          DateTime.tryParse(json['dateCreated'] as String? ?? '') ??
              DateTime.now(),
      workSpaceId: json['workSpaceId'] as int? ?? 0,
    );
  }
}
