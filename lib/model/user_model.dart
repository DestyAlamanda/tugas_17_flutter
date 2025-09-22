import 'batch.dart';
import 'training.dart';

class User {
  final int id;
  final String name;
  final String email;
  final String? jenisKelamin;
  final String? batchKe; 
  final String? trainingTitle; 
  final String? profilePhotoUrl;
  final Batch? batch;
  final Training? training;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.jenisKelamin,
    this.batchKe,
    this.trainingTitle,
    this.profilePhotoUrl,
    this.batch,
    this.training,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      jenisKelamin: json['jenis_kelamin'],
      batchKe: json['batch_ke'], // mapping langsung
      trainingTitle: json['training_title'], // mapping langsung
      profilePhotoUrl: json['profile_photo_url'],
      batch: json['batch'] != null ? Batch.fromJson(json['batch']) : null,
      training: json['training'] != null
          ? Training.fromJson(json['training'])
          : null,
    );
  }
}
