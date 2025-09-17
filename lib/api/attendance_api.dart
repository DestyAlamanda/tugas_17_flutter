import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:tugas_17_flutter/api/auth_api.dart';
import 'package:tugas_17_flutter/api/endpoint/endpoint.dart';
import 'package:tugas_17_flutter/model/attendace_record.dart';
import 'package:tugas_17_flutter/model/attendance_stats.dart';

class AttendanceService {
  final AuthenticationAPI _authService = AuthenticationAPI();

  Future<String> _getAuthToken() async {
    final token = await _authService.getToken();
    if (token == null) throw 'Sesi Anda telah berakhir. Silakan login kembali.';
    return token;
  }

  Future<Map<String, dynamic>> checkIn({
    required double latitude,
    required double longitude,
    required String address,
    required String date,
    required String time,
  }) async {
    final token = await _getAuthToken();
    final url = Uri.parse(Endpoint.checkIn);
    try {
      final response = await http.post(
        url,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: {
          'check_in_lat': latitude.toString(),
          'check_in_lng': longitude.toString(),
          'check_in_address': address,
          'attendance_date': date,
          'check_in': time,
          'status': 'masuk',
        },
      );
      final responseData = json.decode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return responseData;
      } else {
        throw responseData['message'] ?? 'Gagal melakukan check-in.';
      }
    } on SocketException {
      throw 'Tidak dapat terhubung ke server.';
    } catch (e) {
      print('Error in checkIn: $e');
      throw e.toString();
    }
  }

  Future<Map<String, dynamic>> checkOut({
    required double latitude,
    required double longitude,
    required String address,
    required String date,
    required String time,
  }) async {
    final token = await _getAuthToken();
    final url = Uri.parse(Endpoint.checkOut);
    try {
      final response = await http.post(
        url,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: {
          'check_out_lat': latitude.toString(),
          'check_out_lng': longitude.toString(),
          'check_out_address': address,
          'attendance_date': date,
          'check_out': time,
        },
      );
      final responseData = json.decode(response.body);
      if (response.statusCode == 200) {
        return responseData;
      } else {
        throw responseData['message'] ?? 'Gagal melakukan check-out.';
      }
    } on SocketException {
      throw 'Tidak dapat terhubung ke server.';
    } catch (e) {
      print('Error in checkOut: $e');
      throw e.toString();
    }
  }

  Future<Map<String, dynamic>> submitIzin({
    required String alasan,
    required String date,
  }) async {
    final token = await _getAuthToken();
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
      print('Error in submitIzin: $e');
      throw e.toString();
    }
  }

  Future<Map<String, dynamic>> getTodayAttendance() async {
    final token = await _getAuthToken();
    final url = Uri.parse(Endpoint.todayAttendance);
    try {
      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      return json.decode(response.body);
    } on SocketException {
      throw 'Tidak dapat terhubung ke server.';
    } catch (e) {
      print('Error in getTodayAttendance: $e');
      throw e.toString();
    }
  }

  Future<AttendanceStats> getAttendanceStats() async {
    final token = await _getAuthToken();
    final url = Uri.parse(Endpoint.attendanceStats);
    try {
      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      final responseData = json.decode(response.body);
      if (response.statusCode == 200) {
        return AttendanceStats.fromJson(responseData['data']);
      } else {
        throw responseData['message'] ?? 'Gagal memuat statistik.';
      }
    } on SocketException {
      throw 'Tidak dapat terhubung ke server.';
    } catch (e) {
      print('Error in getAttendanceStats: $e');
      throw e.toString();
    }
  }

  Future<List<AttendanceRecord>> getAttendanceHistory({
    String? startDate,
    String? endDate,
  }) async {
    final token = await _getAuthToken();
    var url = Uri.parse(Endpoint.attendanceHistory);

    if (startDate != null && endDate != null) {
      url = url.replace(queryParameters: {'start': startDate, 'end': endDate});
    }

    try {
      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body)['data'];
        return data.map((json) => AttendanceRecord.fromJson(json)).toList();
      } else {
        throw 'Gagal memuat riwayat absensi.';
      }
    } on SocketException {
      throw 'Tidak dapat terhubung ke server.';
    } catch (e) {
      print('Error in getAttendanceHistory: $e');
      throw e.toString();
    }
  }
}
