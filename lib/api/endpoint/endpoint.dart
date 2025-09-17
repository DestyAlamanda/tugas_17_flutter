class Endpoint {
  static const String baseURL = "https://appabsensi.mobileprojp.com/api";
  static const String register = "$baseURL/register";

  static const String login = "$baseURL/login";
  // Endpoint profile
  static const String profile = "$baseURL/profile";
  static const String updateProfile = "$baseURL/profile";
  // Endpoint Data Master
  static final String trainings = '$baseURL/trainings';
  static final String batches = '$baseURL/batches';
  // Endpoint Absensi & Izin
  static final String checkIn = '$baseURL/absen/check-in';
  static final String checkOut = '$baseURL/absen/check-out';
  static final String submitIzin = '$baseURL/izin';
  static final String todayAttendance = '$baseURL/absen/today';
  static final String attendanceHistory = '$baseURL/absen/history';
  static final String attendanceStats = '$baseURL/absen/stats';
}
