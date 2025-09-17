class AttendanceStats {
  final int totalAbsen;
  final int totalMasuk;
  final int totalIzin;

  AttendanceStats({
    required this.totalAbsen,
    required this.totalMasuk,
    required this.totalIzin,
  });

  factory AttendanceStats.fromJson(Map<String, dynamic> json) {
    return AttendanceStats(
      totalAbsen: json['total_absen'] ?? 0,
      totalMasuk: json['total_masuk'] ?? 0,
      totalIzin: json['total_izin'] ?? 0,
    );
  }
}
