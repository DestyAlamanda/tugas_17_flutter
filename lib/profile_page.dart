import 'package:flutter/material.dart';
import 'package:tugas_17_flutter/api/auth_api.dart';
import 'package:tugas_17_flutter/model/user_model.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  User? userData;

  @override
  void initState() {
    super.initState();

    // Inisialisasi date formatting & load data
    _loadUserData();
  }

  final AuthService _authService = AuthService();
  // Load user profile
  Future<void> _loadUserData() async {
    try {
      final savedUser = await _authService.getUserProfile();
      setState(() {
        userData = savedUser;
      });

      print("✅ User data: ${savedUser.name}");
      print(
        "Batch: ${savedUser.batchKe} | Training: ${savedUser.trainingTitle}",
      );
    } catch (e) {
      print('❌ Gagal load data user: $e');
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
              padding: const EdgeInsets.all(30),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    child: const Icon(
                      Icons.person_rounded,
                      size: 30,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "Halo, ${userData?.name ?? '...'}",
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        "Batch: ${userData?.batchKe ?? '...'} ",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.normal,
                          color: Colors.white70,
                        ),
                      ),

                      Text(
                        "Training: ${userData?.trainingTitle ?? '...'}",
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
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 35,
                    horizontal: 16,
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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
                          height: 50,
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
                        const SizedBox(height: 16),
                        Container(
                          height: 50,
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
                        const SizedBox(height: 16),
                        Container(
                          height: 50,
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
                        const SizedBox(height: 16),
                        Container(
                          height: 50,
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

                        const SizedBox(height: 500), // biar bisa discroll
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
