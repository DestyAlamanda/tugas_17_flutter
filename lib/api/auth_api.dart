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

  Future<Map<String, dynamic>> forgotPassword({required String email}) async {
    final url = Uri.parse(Endpoint.forgotPassword);
    try {
      final response = await http.post(
        url,
        headers: {'Accept': 'application/json'},
        body: {'email': email},
      );
      final responseData = json.decode(response.body);
      if (response.statusCode == 200) {
        return responseData;
      } else {
        throw responseData['message'] ?? 'Gagal mengirim OTP.';
      }
    } on SocketException {
      throw 'Tidak dapat terhubung ke server.';
    } catch (e) {
      throw e.toString();
    }
  }

  Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String otp,
    required String password,
  }) async {
    final url = Uri.parse(Endpoint.resetPassword);
    try {
      final response = await http.post(
        url,
        headers: {'Accept': 'application/json'},
        body: {
          'email': email,
          'otp': otp,
          'password': password,
          'password_confirmation': password,
        },
      );
      final responseData = json.decode(response.body);
      if (response.statusCode == 200) {
        return responseData;
      } else {
        throw responseData['message'] ?? 'Gagal mereset password.';
      }
    } on SocketException {
      throw 'Tidak dapat terhubung ke server.';
    } catch (e) {
      throw e.toString();
    }
  }

  Future<Map<String, dynamic>> submitIzin({
    required String alasan,
    required String date,
  }) async {
    final token = await PreferenceHandler.getToken();
    if (token == null) throw 'Token tidak ditemukan. Silakan login kembali.';

    final url = Uri.parse(Endpoint.submitIzin);
    try {
      final response = await http.post(
        url,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({'alasan_izin': alasan, 'date': date}),
      );

      final responseData = json.decode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return responseData;
      } else {
        throw responseData['message'] ?? 'Gagal mengajukan izin.';
      }
    } on SocketException {
      throw 'Tidak dapat terhubung ke server.';
    } catch (e) {
      throw 'Error di submitIzin: $e';
    }
  }

  /// ✅ Register user dengan foto (multipart)
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
      var request = http.MultipartRequest('POST', url);

      request.fields['name'] = name;
      request.fields['email'] = email;
      request.fields['password'] = password;
      request.fields['password_confirmation'] = password;
      request.fields['jenis_kelamin'] = jenisKelamin;
      request.fields['batch_id'] = batchId;
      request.fields['training_id'] = trainingId;

      if (profilePhoto != null) {
        request.files.add(
          await http.MultipartFile.fromPath('profile_photo', profilePhoto.path),
        );
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
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
