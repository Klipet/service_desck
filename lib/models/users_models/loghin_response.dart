import 'user_model.dart';

class LoginResponse {
  final String apikey;
  final UserModel user;

  LoginResponse({
    required this.apikey,
    required this.user,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      apikey: json["apikey"],
      user: UserModel.fromJson(json["user"]),
    );
  }
}