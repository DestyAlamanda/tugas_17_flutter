import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:tugas_17_flutter/api/endpoint/endpoint.dart';
import 'package:tugas_17_flutter/model/batch2.dart';
import 'package:tugas_17_flutter/model/register_model.dart';
import 'package:tugas_17_flutter/model/register_response.dart';
import 'package:tugas_17_flutter/model/training2.dart';
import 'package:tugas_17_flutter/model/user_model.dart';
import 'package:tugas_17_flutter/utils/shared_preference.dart';

class AuthService {
  static Future<RegisterUserModel> registerUserAuth({
    required String name,
    required String email,
    required String password,
    required String jenisKelamin,
    required File profilePhoto,
    required int batchId,
    required int trainingId,
  }) async {
    final url = Uri.parse(Endpoint.register);

    // baca file -> bytes -> base64
    final readImage = profilePhoto.readAsBytesSync();
    final b64 = base64Encode(readImage);

    // tambahkan prefix agar dikenali backend
    final imageWithPrefix = "data:image/png;base64,$b64";

    final response = await http.post(
      url,
      headers: {
        "Accept": "application/json",
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "name": name,
        "email": email,
        "password": password,
        "jenis_kelamin": jenisKelamin,
        "profile_photo": imageWithPrefix,
        "batch_id": batchId,
        "training_id": trainingId,
      }),
    );

    print("STATUS: ${response.statusCode}");
    print("BODY: ${response.body}");

    if (response.statusCode == 200) {
      return RegisterUserModel.fromJson(json.decode(response.body));
    } else {
      final error = json.decode(response.body);
      throw Exception(error["message"] ?? "Failed to Register");
    }
  }

  // Future<List<ListTrainingModel>> getTrainings() async {
  //   final url = Uri.parse(Endpoint.trainings);
  //   try {
  //     final response = await http.get(
  //       url,
  //       headers: {'Accept': 'application/json'},
  //     );
  //     if (response.statusCode == 200) {
  //       final List<dynamic> data = json.decode(response.body)['data'];
  //       return data.map((json) => ListTrainingModel.fromJson(json)).toList();
  //     } else {
  //       throw 'Gagal memuat data pelatihan.';
  //     }
  //   } on SocketException {
  //     throw 'Tidak ada koneksi internet.';
  //   }
  // }

  // Future<List<ListBatchModel>> getBatches() async {
  //   final url = Uri.parse(Endpoint.batches);
  //   try {
  //     final response = await http.get(
  //       url,
  //       headers: {'Accept': 'application/json'},
  //     );
  //     if (response.statusCode == 200) {
  //       final List<dynamic> data = json.decode(response.body)['data'];
  //       return data.map((json) => ListBatchModel.fromJson(json)).toList();
  //     } else {
  //       throw 'Gagal memuat data batch.';
  //     }
  //   } on SocketException {
  //     throw 'Tidak ada koneksi internet.';
  //   }
  // }
  static Future<ListBatchModel> getAllBatches() async {
    final url = Uri.parse(Endpoint.batches);
    final response = await http.get(
      url,
      headers: {"Accept": "application/json"},
    );

    print("STATUS BATCH: ${response.statusCode}");
    print("BODY BATCH: ${response.body}");

    if (response.statusCode == 200) {
      return ListBatchModel.fromJson(json.decode(response.body));
    } else {
      throw Exception("Gagal mengambil data batch");
    }
  }

  static Future<ListTrainingModel> getAllTrainings() async {
    final url = Uri.parse(Endpoint.trainings);
    final response = await http.get(
      url,
      headers: {"Accept": "application/json"},
    );

    print("STATUS TRAINING: ${response.statusCode}");
    print("BODY TRAINING: ${response.body}");

    if (response.statusCode == 200) {
      return ListTrainingModel.fromJson(json.decode(response.body));
    } else {
      throw Exception("Gagal mengambil data training");
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
  Future<RegisterResponse> registerUser({
    required String name,
    required String email,
    required String password,
    required String jenisKelamin,
    required String batchId,
    required String trainingId,
    File? profilePhoto,
  }) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse(Endpoint.register), // ✅ pakai Endpoint
    );

    request.fields['name'] = name;
    request.fields['email'] = email;
    request.fields['password'] = password;
    request.fields['jenis_kelamin'] = jenisKelamin;
    request.fields['batch_id'] = batchId;
    request.fields['training_id'] = trainingId;

    if (profilePhoto != null) {
      request.files.add(
        await http.MultipartFile.fromPath('profile_photo', profilePhoto.path),
      );
    }

    final response = await request.send();
    final resBody = await response.stream.bytesToString();
    final data = jsonDecode(resBody);

    return RegisterResponse.fromJson(data);
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

  static Future<RegisterResponse> updateUser({required String name}) async {
    final token = await PreferenceHandler.getToken();
    if (token == null) throw 'Token tidak ditemukan. Silakan login kembali.';

    final response = await http.put(
      Uri.parse(Endpoint.updateProfile),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'name': name}),
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      return RegisterResponse.fromJson(data);
    } else {
      throw data['message'] ?? 'Gagal update profil';
    }
  }

  Future<Map<String, dynamic>> updateUserProfile({
    required String name,
    required String email,
  }) async {
    final token = await PreferenceHandler.getToken(); // ✅ Fix disini
    if (token == null) throw 'Token tidak ditemukan.';

    final url = Uri.parse(Endpoint.profile);
    try {
      final response = await http.put(
        url,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({'name': name, 'email': email}),
      );

      final responseData = json.decode(response.body);
      if (response.statusCode == 200) {
        return responseData;
      } else if (response.statusCode == 422 && responseData['errors'] != null) {
        final errors = responseData['errors'] as Map<String, dynamic>;
        throw errors.values.first[0]; // ✅ ambil error pertama
      } else {
        throw responseData['message'] ?? 'Gagal memperbarui profil.';
      }
    } on SocketException {
      throw 'Tidak dapat terhubung ke server.';
    } catch (e) {
      throw e.toString();
    }
  }

  Future<Map<String, dynamic>> updateProfilePhoto({required File photo}) async {
    final token = await PreferenceHandler.getToken(); // ✅ Fix disini
    if (token == null) throw 'Token tidak ditemukan.';

    final url = Uri.parse(Endpoint.updateProfilePhoto);
    try {
      List<int> imageBytes = await photo.readAsBytes();
      String base64Image = base64Encode(imageBytes);

      final response = await http.put(
        url,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'profile_photo': 'data:image/jpeg;base64,$base64Image',
        }),
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        return responseData;
      } else {
        throw responseData['message'] ?? 'Gagal memperbarui foto profil.';
      }
    } on SocketException {
      throw 'Tidak dapat terhubung ke server.';
    } catch (e) {
      throw e.toString();
    }
  }
}
