import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tugas_17_flutter/api/attendance_api.dart';
import 'package:tugas_17_flutter/model/attendace_record.dart';
import 'package:tugas_17_flutter/model/attendance_stats.dart';
import 'package:tugas_17_flutter/view/widgets/section_title.dart';

import 'utils/app_color.dart';

// class AppColors {
//   static const primary = Color(0xFF58C5C8)
//   static const textPrimary = Colors.black87;
// }

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
              primary: AppColors.teal,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: AppColors.teal),
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

  Future<void> _onRefresh() async {
    await _loadHistory();
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
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.teal),
            )
          : SafeArea(
              child: RefreshIndicator(
                onRefresh: _onRefresh,
                color: Colors.white,
                backgroundColor: Colors.grey[900],
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    children: [
                      // HEADER
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey[900],
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            children: [
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
                                ],
                              ),
                              const SizedBox(height: 20),

                              // Dari - Sampai
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF111216),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Text(
                                          "Periode Waktu",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 20,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        const Spacer(),
                                        Container(
                                          decoration: BoxDecoration(
                                            color: AppColors.tealLight,
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: IconButton(
                                            onPressed: _pickDateRange,
                                            icon: const Icon(
                                              Icons.calendar_month_outlined,
                                              color: AppColors.teal,
                                              size: 24,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),

                                    // Row: Dari → Icon → Sampai
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Container(
                                            padding: const EdgeInsets.all(16),
                                            decoration: BoxDecoration(
                                              color: AppColors.tealCard,
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                            ),
                                            child: _buildDateBox(
                                              "Dari :",
                                              fromDate,
                                            ),
                                          ),
                                        ),

                                        const Padding(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 15,
                                          ),
                                          child: Column(
                                            children: [
                                              SizedBox(height: 40),
                                              Icon(
                                                Icons.arrow_forward,
                                                color: Colors.white,
                                                size: 24,
                                              ),
                                            ],
                                          ),
                                        ),

                                        Expanded(
                                          child: Container(
                                            padding: const EdgeInsets.all(16),
                                            decoration: BoxDecoration(
                                              color: AppColors.tealCard,
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                            ),
                                            child: _buildDateBox(
                                              "Sampai :",
                                              toDate,
                                            ),
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
                      Transform.translate(
                        offset: const Offset(0, 10),
                        child: Container(
                          width: double.infinity,
                          decoration: const BoxDecoration(
                            color: Color(0xFF111216),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(30),
                              topRight: Radius.circular(30),
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 24,
                          ),
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

                                  child: Column(
                                    children: [
                                      Text(
                                        "Statistik",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      Row(
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
                                    ],
                                  ),
                                ),
                              const SizedBox(height: 30),

                              sectionTitle("Riwayat Absen"),
                              const SizedBox(height: 16),

                              if (records.isEmpty)
                                Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(32),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(15),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(
                                              0.08,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              13,
                                            ),
                                          ),
                                          child: const Icon(
                                            Icons.event_available_rounded,
                                            size: 38,
                                            color: AppColors.teal,
                                          ),
                                        ),
                                        const SizedBox(height: 18),
                                        Text(
                                          "Belum ada data absensi",
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.grey.shade700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              else
                                ListView.builder(
                                  physics: const NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  itemCount: records.length,
                                  itemBuilder: (context, index) {
                                    final record = records[index];
                                    final statusLabel = record.status == "izin"
                                        ? "Izin"
                                        : record.status == "masuk"
                                        ? "Masuk"
                                        : "Pulang";
                                    final timeStatus = record.isLate
                                        ? "Terlambat"
                                        : "Tepat Waktu";
                                    return _buildHistoryCard(
                                      statusLabel,
                                      "${record.day}, ${record.date}",
                                      timeStatus,
                                      record.isLate,
                                    );
                                  },
                                ),

                              const SizedBox(height: 150),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildDateBox(String title, String date) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.tealLight,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            date,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBox(String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.tealLightCard,
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

  Widget _buildHistoryCard(
    String status,
    String date,
    String timeStatus,
    bool isLate,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.tealLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.event_rounded,
              color: AppColors.teal,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  status,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  date,
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isLate
                  ? Colors.redAccent.withOpacity(0.15)
                  : Colors.greenAccent.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              timeStatus,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12,
                color: isLate ? Colors.redAccent : Colors.greenAccent,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
