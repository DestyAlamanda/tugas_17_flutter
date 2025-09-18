import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:tugas_17_flutter/api/attendance_api.dart';

class GoogleMapsScreen extends StatefulWidget {
  const GoogleMapsScreen({super.key});

  @override
  State<GoogleMapsScreen> createState() => _GoogleMapsScreenState();
}

class _GoogleMapsScreenState extends State<GoogleMapsScreen>
    with SingleTickerProviderStateMixin {
  gmaps.GoogleMapController? mapController;
  gmaps.LatLng _currentPosition = const gmaps.LatLng(
    -6.200000,
    106.816666,
  ); // default Jakarta
  String _currentAddress = "Alamat tidak ditemukan";
  gmaps.Marker? _marker;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation = const AlwaysStoppedAnimation(3.0);

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _pulseController.repeat(reverse: true);

    _getCurrentLocation();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _showCheckAnimation() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Center(
          child: Lottie.asset(
            'assets/lottie/berhasil.json',
            repeat: false,
            onLoaded: (composition) {
              Future.delayed(composition.duration, () {
                Navigator.of(context).pop();
              });
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111216),
      appBar: AppBar(
        backgroundColor: const Color(0xFF111216),
        title: const Text(
          "Attendance",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          gmaps.GoogleMap(
            initialCameraPosition: gmaps.CameraPosition(
              target: _currentPosition,
              zoom: 16,
            ),
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            markers: _marker != null ? {_marker!} : {},
            onMapCreated: (controller) {
              mapController = controller;
            },
          ),

          // Tombol dummy untuk get lokasi
          Positioned(
            bottom: 300,
            left: 0,
            right: 0,
            child: Center(
              child: ElevatedButton(
                onPressed: _getCurrentLocation,
                child: const Text("Get Current Location"),
              ),
            ),
          ),

          // Bottom sheet
          DraggableScrollableSheet(
            initialChildSize: 0.40,
            minChildSize: 0.2,
            maxChildSize: 0.6,
            builder: (context, scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: Color(0xFF111216),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.grey[400],
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),

                    // Lokasi sekarang
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 30,
                      ),
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
                              Icons.location_city,
                              color: Color(0xFF4effca),
                              size: 30,
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Lokasi Saat Ini",
                                  style: TextStyle(
                                    fontSize: 19,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _currentAddress,
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Tombol CHECK IN
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 200),
                      decoration: BoxDecoration(
                        color: Colors.grey[900],
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: AnimatedBuilder(
                          animation: _pulseAnimation,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: _pulseAnimation.value,
                              child: GestureDetector(
                                onLongPress: () async {
                                  try {
                                    await _getCurrentLocation();

                                    final now = DateTime.now();
                                    final date = DateFormat(
                                      'yyyy-MM-dd',
                                    ).format(now);
                                    final time = DateFormat(
                                      'HH:mm:ss',
                                    ).format(now);

                                    final result = await AttendanceService()
                                        .checkIn(
                                          latitude: _currentPosition.latitude,
                                          longitude: _currentPosition.longitude,
                                          address: _currentAddress,
                                          date: date,
                                          time: time,
                                        );

                                    _showCheckAnimation();

                                    Future.delayed(
                                      const Duration(seconds: 2),
                                      () {
                                        Navigator.pop(context, result['data']);
                                      },
                                    );
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(e.toString())),
                                    );
                                  }
                                },
                                child: Container(
                                  width: 160,
                                  height: 160,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: const LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Color(0xFF2fb398),
                                        Color(0xFF4effca),
                                        Color(0xFF9effe2),
                                      ],
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Color(0xFF2fb398),
                                        blurRadius: 30,
                                      ),
                                      BoxShadow(
                                        color: Color(
                                          0xFF6C5CE7,
                                        ).withOpacity(0.3),
                                        blurRadius: 50,
                                      ),
                                    ],
                                  ),
                                  child: const Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.touch_app_rounded,
                                          color: Colors.white,
                                          size: 48,
                                        ),
                                        SizedBox(height: 12),
                                        Text(
                                          'CHECK IN',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                            fontWeight: FontWeight.w800,
                                            letterSpacing: 2,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return;
    }

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
    _currentPosition = gmaps.LatLng(position.latitude, position.longitude);

    List<Placemark> placemarks = await placemarkFromCoordinates(
      _currentPosition.latitude,
      _currentPosition.longitude,
    );
    Placemark place = placemarks[0];

    setState(() {
      _marker = gmaps.Marker(
        markerId: const gmaps.MarkerId("lokasi_saya"),
        position: _currentPosition,
        infoWindow: gmaps.InfoWindow(
          title: 'Lokasi Anda',
          snippet: "${place.street}, ${place.locality}",
        ),
      );

      _currentAddress = "${place.street}, ${place.locality}, ${place.country}";

      mapController?.animateCamera(
        gmaps.CameraUpdate.newCameraPosition(
          gmaps.CameraPosition(target: _currentPosition, zoom: 16),
        ),
      );
    });
  }
}
