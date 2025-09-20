// import 'dart:convert';

// import 'package:http/http.dart' as http;
// import 'package:tugas_17_flutter/api/endpoint/endpoint.dart';
// import 'package:tugas_17_flutter/model/user_model.dart';
// import 'package:tugas_17_flutter/utils/shared_preference.dart';

// class UserAPI {
//   // update profile
//   static Future<UserModel> updateProfile({required String name}) async {
//     final url = Uri.parse(Endpoint.profile);
//     final token = await PreferenceHandler.getToken();

//     if (token == null) {
//       throw Exception("Token tidak ditemukan, silakan login ulang");
//     }

//     final response = await http.put(
//       url,
//       body: jsonEncode({"name": name}),
//       headers: {
//         "Accept": "application/json",
//         "Content-Type": "application/json",
//         "Authorization": "Bearer $token",
//       },
//     );

//     if (response.statusCode == 200) {
//       final jsonResponse = json.decode(response.body);
//       return UserModel.fromJson(jsonResponse["data"]);
//     } else {
//       final error = json.decode(response.body);
//       throw Exception(error["message"] ?? "Update profil gagal");
//     }
//   }

//   // get profile
//   static Future<UserModel> getProfile() async {
//     final url = Uri.parse(Endpoint.profile);
//     final token = await PreferenceHandler.getToken();

//     if (token == null) {
//       throw Exception("Token tidak ditemukan, silakan login ulang");
//     }

//     final response = await http.get(
//       url,
//       headers: {"Accept": "application/json", "Authorization": "Bearer $token"},
//     );

//     if (response.statusCode == 200) {
//       final jsonResponse = json.decode(response.body);
//       return UserModel.fromJson(jsonResponse["data"]);
//     } else {
//       final error = json.decode(response.body);
//       throw Exception(error["message"] ?? "Gagal mengambil profil");
//     }
//   }
// }
