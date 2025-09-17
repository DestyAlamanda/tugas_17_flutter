class RegisterUserModel {
  final String message;
  final UserData? data;

  RegisterUserModel({required this.message, this.data});

  factory RegisterUserModel.fromJson(Map<String, dynamic> json) {
    return RegisterUserModel(
      message: json['message'] ?? '',
      data: json['data'] != null ? UserData.fromJson(json['data']) : null,
    );
  }

  Object? toJson() {
    return null;
  }
}

class UserData {
  final int id;
  final String name;
  final String email;
  final String jenisKelamin;
  final int batchId;
  final int trainingId;

  UserData({
    required this.id,
    required this.name,
    required this.email,
    required this.jenisKelamin,
    required this.batchId,
    required this.trainingId,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      jenisKelamin: json['jenis_kelamin'] ?? '',
      batchId: json['batch_id'] ?? 0,
      trainingId: json['training_id'] ?? 0,
    );
  }
}
