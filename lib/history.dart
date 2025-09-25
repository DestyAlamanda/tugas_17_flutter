import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tugas_17_flutter/api/attendance_api.dart';
import 'package:tugas_17_flutter/model/attendace_record.dart';
import 'package:tugas_17_flutter/model/attendance_stats.dart';

// Kalau punya file AppColors, pake AppColors.primary
class AppColors {
  static const primary = Color(0xFF58C5C8);
  static const textPrimary = Colors.black87;
}

class History extends StatefulWidget {
  const History({super.key});

  @override
  State<History> createState() => _HistoryState();
}

class _HistoryState extends State<History> {
  final AttendanceService _attendanceService = AttendanceService();

  AttendanceStats? stats;
  List<AttendanceRecord> records = [];
  bool isLoading = true;

  // Rentang tanggal
  DateTimeRange? _selectedDateRange;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    try {
      List<AttendanceRecord> resultRecords;

      if (_selectedDateRange != null) {
        final start = DateFormat(
          'yyyy-MM-dd',
        ).format(_selectedDateRange!.start);
        final end = DateFormat('yyyy-MM-dd').format(_selectedDateRange!.end);

        resultRecords = await _attendanceService.getAttendanceHistory(
          startDate: start,
          endDate: end,
        );
      } else {
        resultRecords = await _attendanceService.getAttendanceHistory();
      }

      // Hitung statistik
      final hadir = resultRecords.where((r) => r.status == "masuk").length;
      final izin = resultRecords.where((r) => r.status == "izin").length;
      final total = resultRecords.length;

      setState(() {
        stats = AttendanceStats(
          totalAbsen: total,
          totalMasuk: hadir,
          totalIzin: izin,
        );
        records = resultRecords;
        isLoading = false;
      });
    } catch (e) {
      print("❌ Gagal memuat riwayat: $e");
      setState(() => isLoading = false);
    }
  }

  /// Pilih rentang tanggal
  Future<void> _pickDateRange() async {
    final dateRange = await showDateRangePicker(
      context: context,
      initialDateRange: _selectedDateRange,
      firstDate: DateTime(2025),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: AppColors.primary),
            ),
          ),
          child: child!,
        );
      },
    );

    if (dateRange != null) {
      setState(() {
        _selectedDateRange = dateRange;
        isLoading = true;
      });
      _loadHistory();
    }
  }

  @override
  Widget build(BuildContext context) {
    String fromDate = _selectedDateRange != null
        ? DateFormat('dd MMM yyyy').format(_selectedDateRange!.start)
        : "Mulai";
    String toDate = _selectedDateRange != null
        ? DateFormat('dd MMM yyyy').format(_selectedDateRange!.end)
        : "Selesai";

    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: Column(
        children: [
          // HEADER
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(30),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[900],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        // Judul + ikon kalender
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "Riwayat",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 10),

                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: IconButton(
                                onPressed: _pickDateRange,
                                icon: const Icon(
                                  Icons.calendar_month_outlined,
                                  color: Color(
                                    0xFF58C5C8,
                                  ), // bisa diganti AppColors.primary
                                  size: 24,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Dari - Sampai
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                children: [
                                  const Text(
                                    "Dari : ",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[800],
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      fromDate,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 5,
                              ),
                              child: Column(
                                children: const [
                                  SizedBox(height: 40),
                                  Text(
                                    "-",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 26,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                children: [
                                  const Text(
                                    "Sampai : ",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[800],
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      toDate,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // BODY
          Expanded(
            child: Transform.translate(
              offset: const Offset(0, -10),
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFF111216),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),

                child: isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      )
                    : SingleChildScrollView(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (stats != null)
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.grey[900],
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: _buildBox(
                                        "${stats!.totalMasuk}",
                                        "Hadir",
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: _buildBox(
                                        "${stats!.totalIzin}",
                                        "Izin",
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: _buildBox(
                                        "${stats!.totalAbsen}",
                                        "Total",
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            const SizedBox(height: 30),

                            const Text(
                              "Riwayat Absensi",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),

                            if (records.isEmpty)
                              const Center(
                                child: Text(
                                  "Belum ada data absensi",
                                  style: TextStyle(color: Colors.white70),
                                ),
                              )
                            else
                              Column(
                                children: records.map((record) {
                                  final statusLabel = record.status == "izin"
                                      ? "Izin"
                                      : record.status == "masuk"
                                      ? "Masuk"
                                      : "Pulang";

                                  final timeStatus = record.isLate
                                      ? "Terlambat"
                                      : record.status == "izin"
                                      ? record.alasanIzin ?? "-"
                                      : "Tepat Waktu";

                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 10),
                                    child: _buildHistoryCard(
                                      statusLabel,
                                      "${record.day}, ${record.date}",
                                      timeStatus,
                                      record.isLate,
                                    ),
                                  );
                                }).toList(),
                              ),
                            const SizedBox(height: 100),
                          ],
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Statistik box
  Widget _buildBox(String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // Kartu riwayat
  Widget _buildHistoryCard(
    String status,
    String date,
    String timeStatus,
    bool isLate,
  ) {
    return Container(
      height: 90,
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.event_rounded,
              color: AppColors.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  status,
                  style: const TextStyle(color: Colors.white, fontSize: 20),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  date,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          // 👉 badge waktu (terlambat/tepat waktu/alasan izin) bisa ditambahkan lagi kalau perlu
        ],
      ),
    );
  }
}
