import 'package:intl/intl.dart';

class AttendanceRecord {
  final int id;
  final String day;
  final String date;
  final String checkInTime;
  final String checkOutTime;
  final String status;
  final String? alasanIzin;
  final DateTime? attendanceDate; // ✅ Tambahan untuk sorting

  AttendanceRecord({
    required this.id,
    required this.day,
    required this.date,
    required this.checkInTime,
    required this.checkOutTime,
    required this.status,
    this.alasanIzin,
    this.attendanceDate,
  });

  bool get isLate {
    if (status != 'masuk' || checkInTime == '-') return false;
    try {
      final timeParts = checkInTime.split(':');
      final hour = int.parse(timeParts[0]);
      return hour >= 8;
    } catch (e) {
      return false;
    }
  }

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) {
    DateTime? attendanceDate;
    if (json['attendance_date'] != null) {
      try {
        attendanceDate = DateTime.parse(json['attendance_date']);
      } catch (e) {}
    }

    return AttendanceRecord(
      id: json['id'] ?? 0,
      day: attendanceDate != null
          ? DateFormat('EEEE', 'id_ID').format(attendanceDate)
          : 'Unknown',
      date: attendanceDate != null
          ? DateFormat('dd MMM yy', 'id_ID').format(attendanceDate)
          : 'N/A',
      checkInTime: json['check_in_time'] ?? '-',
      checkOutTime: json['check_out_time'] ?? '-',
      status: json['status'] ?? 'masuk',
      alasanIzin: json['alasan_izin'],
      attendanceDate: attendanceDate, // ✅ simpan aslinya
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'day': day,
      'date': date,
      'check_in_time': checkInTime,
      'check_out_time': checkOutTime,
      'status': status,
      'alasan_izin': alasanIzin,
      'attendance_date': attendanceDate?.toIso8601String(), // ✅ simpan ISO date
    };
  }
}
