import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart'; // ✅ import tambahan
import 'package:tugas_17_flutter/api/attendance_api.dart';
import 'package:tugas_17_flutter/api/user_api.dart';
import 'package:tugas_17_flutter/google_map.dart';
import 'package:tugas_17_flutter/model/attendace_record.dart';
import 'package:tugas_17_flutter/model/user_model.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  UserModel? userData;
  AttendanceRecord? latestAttendance;
  final AttendanceService _attendanceService = AttendanceService();

  @override
  void initState() {
    super.initState();

    initializeDateFormatting('id_ID', null).then((_) {
      _loadUserData();
      _loadLatestAttendance();
    });
  }

  Future<void> _loadUserData() async {
    try {
      final savedUser = await UserAPI.getProfile();
      setState(() {
        userData = savedUser;
      });
    } catch (e) {
      print('Gagal load data user: $e');
    }
  }

  // Ambil data check-in hari ini
  Future<void> _loadLatestAttendance() async {
    try {
      final todayData = await _attendanceService.getTodayAttendance();
      if (todayData['data'] != null) {
        setState(() {
          latestAttendance = AttendanceRecord.fromJson(todayData['data']);
        });
      }
    } catch (e) {
      print('Gagal load absensi hari ini: $e');
    }
  }

  Future<void> _openGoogleMaps() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const GoogleMapsScreen()),
    );

    if (result != null) {
      // setelah check-in berhasil, load riwayat terbaru dari server
      await _loadLatestAttendance();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: Column(
        children: [
          // HEADER
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 26,
                    child: SizedBox(
                      width: 36,
                      height: 36,
                      child: const Icon(
                        Icons.person_rounded,
                        size: 20,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Halo, ${userData?.data?.name ?? ''}",
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        "Batch: ${userData?.data?.batchKe ?? '-'} | Training: ${userData?.data?.trainingTitle ?? '-'}",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.normal,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // BODY
          Expanded(
            child: Transform.translate(
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
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 35,
                    horizontal: 16,
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.grey[900],
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            children: [
                              const Text(
                                "Senin, 20 Juni 2024",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                "00 : 00 : 00",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Row(
                                children: [
                                  Container(
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 16,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 35,
                                      vertical: 20,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[800],
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Column(
                                      children: const [
                                        Text(
                                          "08:00",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 30,
                                          ),
                                        ),
                                        Text(
                                          "Check In",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Spacer(),
                                  Container(
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 16,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 35,
                                      vertical: 20,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[800],
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Column(
                                      children: const [
                                        Text(
                                          "15:00",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 30,
                                          ),
                                        ),
                                        Text(
                                          "Check Out",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
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

                        const SizedBox(height: 20),

                        // LOKASI ABSEN
                        const Text(
                          "Lokasi Absen",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          height: 70,
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey[900],
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "jalan merdeka no 1",
                              style: TextStyle(color: Colors.white),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // RIWAYAT ABSEN
                        Row(
                          children: const [
                            Text(
                              "Riwayat Absen",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Spacer(),
                            Text(
                              "Lihat Semua",
                              style: TextStyle(
                                color: Color(0xFF469EA0),
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // CARD RIWAYAT
                        if (latestAttendance != null)
                          Container(
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
                                    color: const Color(0xFF122C29),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.event_rounded,
                                    color: Color(0xFF4effca),
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        latestAttendance!.status == 'masuk'
                                            ? "Check In"
                                            : "Check Out",
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        latestAttendance!.date,
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 14,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: latestAttendance!.isLate
                                        ? const Color(
                                            0xFF332F1A,
                                          ) // late → background gelap
                                        : const Color(
                                            0xFF122C29,
                                          ), // on time → background biru gelap
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Text(
                                    latestAttendance!.isLate
                                        ? "late"
                                        : "on time",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: latestAttendance!.isLate
                                          ? Colors
                                                .yellow // late → teks kuning
                                          : const Color(
                                              0xFF4effca,
                                            ), // on time → teks hijau
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                        const SizedBox(height: 500), // contoh konten panjang
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
