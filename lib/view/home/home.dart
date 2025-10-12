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
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
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

    // Timer untuk jam realtime
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
      _refreshAll();
    });
  }

  /// 🔄 Fungsi refresh otomatis dari BottomNavigator
  Future<void> refreshData() async {
    await _refreshAll();
  }

  /// 🔁 Fungsi utama untuk refresh manual maupun otomatis
  Future<void> _refreshAll() async {
    await _loadUserData();
    await _loadRecentAttendances();
    await _getCurrentLocation();
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
              checkInTime: "--:--",
              checkOutTime: "--:--",
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
      await _refreshAll();
    }
  }

  String _calculateTotalHours(String? checkIn, String? checkOut) {
    try {
      if (checkIn == null ||
          checkOut == null ||
          checkIn == "--:--" ||
          checkOut == "--:--") {
        return "--:--";
      }

      final format = DateFormat("HH:mm");
      final start = format.parse(checkIn);
      final end = format.parse(checkOut);
      final diff = end.difference(start);
      final hours = diff.inHours;
      final minutes = diff.inMinutes.remainder(60);

      return "${hours.toString().padLeft(1, '0')}:${minutes.toString().padLeft(2, '0')}";
    } catch (_) {
      return "--:--";
    }
  }

  String formatTime(String? time) {
    if (time == null || time == "-" || time.isEmpty) return "--:--";
    return time;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: RefreshIndicator(
        onRefresh: _refreshAll,
        color: Colors.white,
        backgroundColor: Colors.grey[900],
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
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
                        // Card waktu
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
                                    child: _timeCard(
                                      label: "Masuk",
                                      time: latestAttendance?.checkInTime,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _timeCard(
                                      label: "Keluar",
                                      time: latestAttendance?.checkOutTime,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        sectionTitle("Riwayat Absen"),
                        const SizedBox(height: 16),
                        if (recentAttendances.isNotEmpty)
                          Column(
                            children: recentAttendances
                                .map((a) => _attendanceCard(a))
                                .toList(),
                          )
                        else
                          _emptyHistory(),
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

  Widget _timeCard({required String label, String? time}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.tealLightCard,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            formatTime(time),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 28,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _attendanceCard(AttendanceRecord a) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // tanggal
          Container(
            width: 90,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  DateFormat('dd').format(a.attendanceDate!),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    height: 1.0,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  DateFormat(
                    'EEE',
                    'id_ID',
                  ).format(a.attendanceDate!).toUpperCase(),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _timeInfo("Masuk", a.checkInTime),
                    const Spacer(),
                    _timeInfo("Keluar", a.checkOutTime),
                  ],
                ),
                const SizedBox(height: 5),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  margin: const EdgeInsets.only(top: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      if (a.status == "izin")
                        Expanded(
                          child: Text(
                            "Alasan izin : ${a.alasanIzin ?? '-'}",
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        )
                      else ...[
                        Text(
                          "Total Jam Kerja",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 16,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          _calculateTotalHours(a.checkInTime, a.checkOutTime),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _timeInfo(String label, String? time) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 16),
      ),
      const SizedBox(height: 2),
      Text(
        formatTime(time),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 23,
          fontWeight: FontWeight.w600,
        ),
      ),
    ],
  );

  Widget _emptyHistory() => Center(
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
  );
}
