import 'user_model.dart';

class LoginResponse {
  final int status;
  final String apikey;
  final UserModel user;

  LoginResponse({
    required this.status,
    required this.apikey,
    required this.user,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      status: json["status"] ?? 0,
      apikey: json["apikey"],
      user: UserModel.fromJson(json["user"]),
    );
  }
}
