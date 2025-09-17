class LoginUserModel {
  final String message;
  final String token;

  LoginUserModel({required this.message, required this.token});

  factory LoginUserModel.fromJson(Map<String, dynamic> json) {
    return LoginUserModel(
      message: json['message'] ?? '',
      token: json['token'] ?? '',
    );
  }

  void operator [](String other) {}
}
