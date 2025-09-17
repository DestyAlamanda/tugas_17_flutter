import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:tugas_17_flutter/api/endpoint/endpoint.dart';
import 'package:tugas_17_flutter/model/batch.dart';
import 'package:tugas_17_flutter/model/login_model.dart';
import 'package:tugas_17_flutter/model/register_model.dart';
import 'package:tugas_17_flutter/model/training.dart';

class AuthenticationAPI {
  /// REGISTER
  static Future<RegisterUserModel> registerUser({
    required String name,
    required String email,
    required String password,
    required String jenisKelamin,
    required int batchId,
    required int trainingId,
  }) async {
    final url = Uri.parse(Endpoint.register);

    try {
      final response = await http.post(
        url,
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/x-www-form-urlencoded",
        },
        body: {
          "name": name,
          "email": email,
          "password": password,
          "jenis_kelamin": jenisKelamin,
          "batch_id": batchId.toString(),
          "training_id": trainingId.toString(),
        },
      );

      if (response.statusCode == 200) {
        return RegisterUserModel.fromJson(json.decode(response.body));
      } else {
        final error = json.decode(response.body);
        throw Exception(error["message"] ?? "Register gagal");
      }
    } catch (e) {
      throw Exception("Register gagal: $e");
    }
  }

  /// LOGIN
  static Future<LoginUserModel> loginUser({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse(Endpoint.login);

    try {
      final response = await http.post(
        url,
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/x-www-form-urlencoded",
        },
        body: {"email": email, "password": password},
      );

      if (response.statusCode == 200) {
        return LoginUserModel.fromJson(json.decode(response.body));
      } else {
        final error = json.decode(response.body);
        throw Exception(error["message"] ?? "Login gagal");
      }
    } catch (e) {
      throw Exception("Login gagal: $e");
    }
  }

  /// GET TRAININGS
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
      throw 'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.';
    } catch (e) {
      throw e.toString();
    }
  }

  /// GET BATCHES
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
      throw 'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.';
    } catch (e) {
      throw e.toString();
    }
  }
}
