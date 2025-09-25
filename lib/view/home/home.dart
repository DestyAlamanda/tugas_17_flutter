import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:tugas_17_flutter/api/attendance_api.dart';
import 'package:tugas_17_flutter/api/auth_api.dart';
import 'package:tugas_17_flutter/model/attendace_record.dart';
import 'package:tugas_17_flutter/model/user_model.dart';
import 'package:tugas_17_flutter/view/absen/google_map.dart';
import 'package:tugas_17_flutter/view/widgets/section_title.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  User? userData;
  AttendanceRecord? latestAttendance;
  List<AttendanceRecord> recentAttendances = [];
  final AttendanceService _attendanceService = AttendanceService();
  String _currentTime = DateFormat.Hms().format(DateTime.now());

  DateTime _lastDate = DateTime.now();
  final AuthService _authService = AuthService();

  String _currentAddress = "Memuat lokasi...";
  double _distanceToPpkd = 0.0; // dalam KM
  final double _ppkdLat = -6.210881;
  final double _ppkdLng = 106.812942;

  @override
  void initState() {
    super.initState();

    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _currentTime = DateFormat.Hms().format(DateTime.now());
        });

        final now = DateTime.now();
        if (now.day != _lastDate.day) {
          _lastDate = now;
          _resetForNewDay();
        }
      }
    });

    initializeDateFormatting('id_ID', null).then((_) {
      _loadUserData();
      _loadRecentAttendances();
      _getCurrentLocation();
    });
  }

  void _resetForNewDay() {
    setState(() {
      latestAttendance = null;
      recentAttendances.clear();
    });
    _loadRecentAttendances();
  }

  Future<void> _loadUserData() async {
    try {
      final savedUser = await _authService.getUserProfile();
      setState(() {
        userData = savedUser;
      });
    } catch (e) {
      print('❌ Gagal memuat data pengguna: $e');
    }
  }

  Future<void> _loadRecentAttendances() async {
    try {
      final resultRecords = await _attendanceService.getAttendanceHistory();
      if (resultRecords.isNotEmpty) {
        final oneWeekAgo = DateTime.now().subtract(const Duration(days: 6));

        setState(() {
          // filter 7 hari terakhir
          recentAttendances = resultRecords.where((record) {
            try {
              if (record.attendanceDate != null) {
                return record.attendanceDate!.isAfter(oneWeekAgo) ||
                    record.attendanceDate!.isAtSameMomentAs(oneWeekAgo);
              }
              return false;
            } catch (_) {
              return false;
            }
          }).toList();

          // ambil absensi hari ini
          latestAttendance = resultRecords.firstWhere(
            (r) =>
                r.attendanceDate != null &&
                r.attendanceDate!.day == DateTime.now().day &&
                r.attendanceDate!.month == DateTime.now().month &&
                r.attendanceDate!.year == DateTime.now().year,
            orElse: () => AttendanceRecord(
              id: 0,
              day: DateFormat('EEEE', 'id_ID').format(DateTime.now()),
              date: DateFormat('dd MMM yy', 'id_ID').format(DateTime.now()),
              checkInTime: "-",
              checkOutTime: "-",
              status: "masuk",
              attendanceDate: DateTime.now(),
            ),
          );
        });
      }
    } catch (e) {
      print('❌ Gagal memuat absensi: $e');
    }
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        return;
      }
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    List<Placemark> placemarks = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );
    Placemark place = placemarks[0];

    double distanceMeters = Geolocator.distanceBetween(
      position.latitude,
      position.longitude,
      _ppkdLat,
      _ppkdLng,
    );

    if (!mounted) return;
    setState(() {
      _currentAddress =
          "${place.street}, ${place.subLocality}, ${place.locality}, ${place.country}";
      _distanceToPpkd = distanceMeters / 1000;
    });
  }

  Future<void> _openGoogleMaps() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const GoogleMapsScreen()),
    );
    if (result != null) {
      await _loadRecentAttendances();
      await _getCurrentLocation();
    }
  }

  // ✅ Fungsi untuk label status
  String _getAttendanceLabel(String status) {
    switch (status.toLowerCase()) {
      case 'masuk':
        return "Masuk";
      case 'pulang':
        return "Pulang";
      case 'izin':
        return "Izin";
      default:
        return status;
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
                    radius: 28,
                    backgroundColor: Colors.orange,
                    backgroundImage: userData?.profilePhotoUrl != null
                        ? NetworkImage(userData!.profilePhotoUrl!)
                        : null,
                    child: userData?.profilePhotoUrl == null
                        ? const Icon(
                            Icons.person_rounded,
                            size: 30,
                            color: Colors.white,
                          )
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Hai, ${userData?.name ?? '...'}",
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        "Batch ${userData?.batchKe ?? '...'} |  ${userData?.trainingTitle ?? '...'}",
                        style: const TextStyle(
                          fontSize: 16,
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
                    vertical: 40,
                    horizontal: 16,
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Tanggal + Jam
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 18,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey[900],
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Column(
                            children: [
                              Text(
                                DateFormat(
                                  "EEEE, dd MMM yyyy",
                                  "id_ID",
                                ).format(DateTime.now()),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 19,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _currentTime,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 38,
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
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Column(
                                      children: [
                                        Text(
                                          latestAttendance?.checkInTime ?? "-",
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 30,
                                          ),
                                        ),
                                        const Text(
                                          "Masuk",
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
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Column(
                                      children: [
                                        Text(
                                          latestAttendance?.checkOutTime ?? "-",
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 30,
                                          ),
                                        ),
                                        const Text(
                                          "Pulang",
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

                        // Lokasi Absen
                        sectionTitle("Lokasi Absen"),
                        const SizedBox(height: 16),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey[900],
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.location_on,
                                color: Colors.white70,
                                size: 22,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  "Jarak dari lokasi: ${_distanceToPpkd.toStringAsFixed(2)} km",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Riwayat Absen
                        Row(
                          children: [
                            sectionTitle("Riwayat Absen"),
                            const Spacer(),
                          ],
                        ),

                        const SizedBox(height: 16),

                        if (recentAttendances.isNotEmpty)
                          Column(
                            children: recentAttendances.map((attendance) {
                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.grey[900],
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Icon(
                                        Icons.event_rounded,
                                        color: Color(0xFF58C5C8),
                                        size: 24,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            _getAttendanceLabel(
                                              attendance.status,
                                            ),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 20,
                                            ),
                                          ),
                                          Text(
                                            attendance.date,
                                            style: const TextStyle(
                                              color: Colors.white70,
                                              fontSize: 14,
                                            ),
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
                                        color: attendance.isLate
                                            ? const Color(0xFF332F1A)
                                            : const Color(0xFF122C29),
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Text(
                                        attendance.isLate
                                            ? "Terlambat"
                                            : "Tepat waktu",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: attendance.isLate
                                              ? Colors.yellow
                                              : const Color(0xFF58C5C8),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          )
                        else
                          const Text(
                            "Belum ada data absen minggu ini",
                            style: TextStyle(color: Colors.white70),
                          ),

                        const SizedBox(height: 500),
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
