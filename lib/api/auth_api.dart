import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:tugas_17_flutter/api/endpoint/endpoint.dart';
import 'package:tugas_17_flutter/model/batch.dart';
import 'package:tugas_17_flutter/model/training.dart';
import 'package:tugas_17_flutter/model/user_model.dart';
import 'package:tugas_17_flutter/utils/shared_preference.dart';

class AuthService {
  Future<List<Training>> getTrainings() async {
    final url = Uri.parse(Endpoint.trainings);
    try {
      final response = await http.get(
        url,
        headers: {'Accept': 'application/json'},
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body)['data'];
        return data.map((json) => Training.fromJson(json)).toList();
      } else {
        throw 'Gagal memuat data pelatihan.';
      }
    } on SocketException {
      throw 'Tidak ada koneksi internet.';
    }
  }

  Future<List<Batch>> getBatches() async {
    final url = Uri.parse(Endpoint.batches);
    try {
      final response = await http.get(
        url,
        headers: {'Accept': 'application/json'},
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body)['data'];
        return data.map((json) => Batch.fromJson(json)).toList();
      } else {
        throw 'Gagal memuat data batch.';
      }
    } on SocketException {
      throw 'Tidak ada koneksi internet.';
    }
  }

  Future<Map<String, dynamic>> registerUser({
    required String name,
    required String email,
    required String password,
    required String jenisKelamin,
    required String batchId,
    required String trainingId,
    File? profilePhoto,
  }) async {
    final url = Uri.parse(Endpoint.register);
    try {
      Map<String, String> body = {
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': password,
        'jenis_kelamin': jenisKelamin,
        'batch_id': batchId,
        'training_id': trainingId,
      };

      if (profilePhoto != null) {
        List<int> imageBytes = await profilePhoto.readAsBytes();
        String base64Image = base64Encode(imageBytes);
        body['profile_photo'] = 'data:image/jpeg;base64,$base64Image';
      }

      final response = await http.post(
        url,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: json.encode(body),
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return responseData;
      } else if (response.statusCode == 422 && responseData['errors'] != null) {
        final errors = responseData['errors'] as Map<String, dynamic>;
        throw errors.values.first[0];
      } else {
        throw responseData['message'] ?? 'Terjadi kesalahan registrasi.';
      }
    } on SocketException {
      throw 'Tidak ada koneksi internet.';
    }
  }

  Future<Map<String, dynamic>> loginUser({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse(Endpoint.login);
    try {
      final response = await http.post(
        url,
        headers: {'Accept': 'application/json'},
        body: {'email': email, 'password': password},
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        if (responseData['data']?['token'] != null) {
          final token = responseData['data']['token'];
          await PreferenceHandler.saveToken(token);
          await PreferenceHandler.saveLogin(true);
        }
        return responseData;
      } else {
        throw responseData['message'] ?? 'Email atau password salah.';
      }
    } on SocketException {
      throw 'Tidak ada koneksi internet.';
    }
  }

  Future<User> getUserProfile() async {
    final token = await PreferenceHandler.getToken();
    if (token == null) throw 'Token tidak ditemukan. Silakan login kembali.';

    final url = Uri.parse(Endpoint.profile);
    try {
      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body)['data'];
        return User.fromJson(data);
      } else {
        throw 'Gagal mengambil data profil.';
      }
    } on SocketException {
      throw 'Tidak ada koneksi internet.';
    }
  }

  Future<void> logout() async {
    await PreferenceHandler.removeToken();
    await PreferenceHandler.saveLogin(false);
  }
}
