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
import 'package:tugas_17_flutter/utils/app_color.dart';
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
  double _distanceToPpkd = 0.0;
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

  String _getAttendanceLabel(String status) {
    switch (status.toLowerCase()) {
      case 'masuk':
        return "Masuk";
      case 'keluar':
        return "keluar";
      case 'izin':
        return "Izin";
      default:
        return status;
    }
  }

  Future<void> _onRefresh() async {
    await _loadUserData();
    await _loadRecentAttendances();
    await _getCurrentLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        color: Colors.white,
        backgroundColor: Colors.grey[900],
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              // HEADER
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          image: userData?.profilePhotoUrl != null
                              ? DecorationImage(
                                  image: NetworkImage(
                                    userData!.profilePhotoUrl!,
                                  ),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: userData?.profilePhotoUrl == null
                            ? const Icon(
                                Icons.person_rounded,
                                size: 32,
                                color: Colors.white,
                              )
                            : null,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Hai, ${userData?.name ?? '...'}",
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Batch ${userData?.batchKe ?? '...'} • ${userData?.trainingTitle ?? '...'}",
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.white70,
                              ),
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
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 32, 20, 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Time Card
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.grey[900],
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            children: [
                              Text(
                                DateFormat(
                                  "EEEE, dd MMM yyyy",
                                  "id_ID",
                                ).format(DateTime.now()),
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _currentTime,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 48,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -1,
                                ),
                              ),
                              const SizedBox(height: 20),
                              Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.all(20),
                                      decoration: BoxDecoration(
                                        color: AppColors.tealLightCard,
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Column(
                                        children: [
                                          Text(
                                            latestAttendance?.checkInTime ??
                                                "-",
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 28,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          const Text(
                                            "Masuk",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.all(20),
                                      decoration: BoxDecoration(
                                        color: AppColors.tealLightCard,
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Column(
                                        children: [
                                          Text(
                                            latestAttendance?.checkOutTime ??
                                                "-",
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 28,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          const Text(
                                            "Keluar",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // // Location Card
                        // Container(
                        //   width: double.infinity,
                        //   padding: const EdgeInsets.all(20),
                        //   decoration: BoxDecoration(
                        //     color: const Color(0xFF1A1D23),
                        //     borderRadius: BorderRadius.circular(16),
                        //   ),
                        //   child: Row(
                        //     children: [
                        //       Container(
                        //         width: 48,
                        //         height: 48,
                        //         decoration: BoxDecoration(
                        //           color: Colors.orange.withOpacity(0.15),
                        //           borderRadius: BorderRadius.circular(12),
                        //         ),
                        //         child: const Icon(
                        //           Icons.location_on_rounded,
                        //           color: Colors.orange,
                        //           size: 24,
                        //         ),
                        //       ),
                        //       const SizedBox(width: 16),
                        //       Expanded(
                        //         child: Column(
                        //           crossAxisAlignment: CrossAxisAlignment.start,
                        //           children: [
                        //             const Text(
                        //               "Jarak dari lokasi",
                        //               style: TextStyle(
                        //                 color: Colors.white60,
                        //                 fontSize: 13,
                        //                 fontWeight: FontWeight.w500,
                        //               ),
                        //             ),
                        //             const SizedBox(height: 4),
                        //             Text(
                        //               "${_distanceToPpkd.toStringAsFixed(2)} km",
                        //               style: const TextStyle(
                        //                 color: Colors.white,
                        //                 fontSize: 18,
                        //                 fontWeight: FontWeight.w600,
                        //               ),
                        //             ),
                        //           ],
                        //         ),
                        //       ),
                        //     ],
                        //   ),
                        // ),

                        // Section Title
                        sectionTitle("Riwayat Absen"),

                        const SizedBox(height: 16),

                        // Attendance History
                        if (recentAttendances.isNotEmpty)
                          Column(
                            children: recentAttendances.map((attendance) {
                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.grey[900],
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 48,
                                      height: 48,
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.1),
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
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            _getAttendanceLabel(
                                              attendance.status,
                                            ),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            attendance.date,
                                            style: const TextStyle(
                                              color: Colors.white60,
                                              fontSize: 13,
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
                                            ? const Color(0xFF3D2F1A)
                                            : const Color(0xFF1A3D2F),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        attendance.isLate
                                            ? "Terlambat"
                                            : "Tepat waktu",
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 12,
                                          color: attendance.isLate
                                              ? Colors.orange
                                              : Colors.greenAccent,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          )
                        else
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.all(32),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(15),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(13),
                                    ),
                                    child: Icon(
                                      Icons.event_available_rounded,
                                      size: 35,
                                      color: AppColors.teal,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  Text(
                                    "Belum ada absen minggu ini",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
