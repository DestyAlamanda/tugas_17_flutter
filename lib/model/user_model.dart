// To parse this JSON data, do
//
//     final userModel = userModelFromJson(jsonString);

import 'dart:convert';

import 'package:tugas_17_flutter/model/batch.dart';
import 'package:tugas_17_flutter/model/training.dart';

UserModel userModelFromJson(String str) => UserModel.fromJson(json.decode(str));

String userModelToJson(UserModel data) => json.encode(data.toJson());

class UserModel {
  String? message;
  Data? data;

  UserModel({required this.message, required this.data});

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      UserModel(message: json["message"], data: Data.fromJson(json["data"]));

  Map<String, dynamic> toJson() => {"message": message, "data": data?.toJson()};
}

class Data {
  int id;
  String name;
  String email;
  String batchKe;
  String trainingTitle;
  Batch batch;
  Training training;
  String jenisKelamin;
  String profilePhoto;
  String profilePhotoUrl;

  Data({
    required this.id,
    required this.name,
    required this.email,
    required this.batchKe,
    required this.trainingTitle,
    required this.batch,
    required this.training,
    required this.jenisKelamin,
    required this.profilePhoto,
    required this.profilePhotoUrl,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    id: json["id"],
    name: json["name"],
    email: json["email"],
    batchKe: json["batch_ke"],
    trainingTitle: json["training_title"],
    batch: Batch.fromJson(json["batch"]),
    training: Training.fromJson(json["training"]),
    jenisKelamin: json["jenis_kelamin"],
    profilePhoto: json["profile_photo"],
    profilePhotoUrl: json["profile_photo_url"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "email": email,
    "batch_ke": batchKe,
    "training_title": trainingTitle,
    "batch": batch.toJson(),
    "training": training.toJson(),
    "jenis_kelamin": jenisKelamin,
    "profile_photo": profilePhoto,
    "profile_photo_url": profilePhotoUrl,
  };
}
