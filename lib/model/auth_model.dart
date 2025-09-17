import 'package:tugas_17_flutter/model/batch.dart';
import 'package:tugas_17_flutter/model/training.dart';

class AuthResponse {
  final String message;
  final AuthData data;

  AuthResponse({required this.message, required this.data});

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      message: json['message'],
      data: AuthData.fromJson(json['data']),
    );
  }

  Map<String, dynamic> toJson() => {'message': message, 'data': data.toJson()};
}

class AuthData {
  final String token;
  final User user;
  final String? profilePhotoUrl;

  AuthData({required this.token, required this.user, this.profilePhotoUrl});

  factory AuthData.fromJson(Map<String, dynamic> json) {
    return AuthData(
      token: json['token'],
      user: User.fromJson(json['user']),
      profilePhotoUrl: json['profile_photo_url'],
    );
  }

  Map<String, dynamic> toJson() => {
    'token': token,
    'user': user.toJson(),
    'profile_photo_url': profilePhotoUrl,
  };
}

class User {
  final int id;
  final String name;
  final String email;
  final String? jenisKelamin;
  final String? profilePhoto;
  final Batch? batch;
  final Training? training;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.jenisKelamin,
    this.profilePhoto,
    this.batch,
    this.training,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      jenisKelamin: json['jenis_kelamin'],
      profilePhoto: json['profile_photo'],
      batch: json['batch'] != null ? Batch.fromJson(json['batch']) : null,
      training: json['training'] != null
          ? Training.fromJson(json['training'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'jenis_kelamin': jenisKelamin,
    'profile_photo': profilePhoto,
    'batch': batch?.toJson(),
    'training': training?.toJson(),
  };
}
