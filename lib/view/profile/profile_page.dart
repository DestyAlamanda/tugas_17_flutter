import 'package:flutter/material.dart';
import 'package:tugas_17_flutter/api/auth_api.dart';
import 'package:tugas_17_flutter/extensions/navigator.dart';
import 'package:tugas_17_flutter/model/user_model.dart';
import 'package:tugas_17_flutter/utils/app_color.dart';
import 'package:tugas_17_flutter/utils/shared_preference.dart';
import 'package:tugas_17_flutter/view/auth/login_screen.dart';
import 'package:tugas_17_flutter/view/password/forgot_password.dart';
import 'package:tugas_17_flutter/view/profile/edit_profile.dart';
import 'package:tugas_17_flutter/view/profile/pengaturan.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  User? userData;
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // 🔹 Load user profile
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

  // 🔑 Fungsi Logout
  static void handleLogout(BuildContext context) async {
    await PreferenceHandler.removeLogin();

    // Snackbar konfirmasi
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("✅ Berhasil keluar dari akun"),
        backgroundColor: Colors.green,
      ),
    );

    // Pindah ke LoginScreen
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  // 🔔 Dialog konfirmasi logout
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            "Konfirmasi Logout",
            style: TextStyle(color: Colors.white),
          ),
          content: const Text(
            "Apakah kamu yakin ingin keluar?",
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "Batal",
                style: TextStyle(color: Colors.white70),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                Navigator.pop(context);
                handleLogout(context);
              },
              child: const Text(
                "Ya, Keluar",
                style: TextStyle(color: Colors.white70),
              ),
            ),
          ],
        );
      },
    );
  }

  // 🔹 Reusable Menu Item
  Widget _menuItem(IconData icon, String title, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
            child: Row(
              children: [
                Icon(icon, color: Colors.white, size: 22),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const Icon(
                  Icons.chevron_right,
                  color: AppColors.teal,
                  size: 26,
                ),
              ],
            ),
          ),
          Divider(color: AppColors.teal, thickness: 1, height: 1),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: Column(
        children: [
          // 🔹 Header Profil
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(30),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
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
                  const SizedBox(height: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        userData?.name ?? '...',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        userData?.email ?? '...',
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

          // 🔹 Body Section
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
                        // 🔸 Menu Container
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 20,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey[900],
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            children: [
                              _menuItem(
                                Icons.person_outlined,
                                "Profil",
                                onTap: () async {
                                  if (userData != null) {
                                    final result = await context.push(
                                      EditProfileScreen(currentUser: userData!),
                                    );
                                    if (result == true) {
                                      setState(() {
                                        _loadUserData();
                                      });
                                    }
                                  }
                                },
                              ),
                              _menuItem(
                                Icons.settings,
                                "Pengaturan",
                                onTap: () {
                                  context.push(const PengaturanAkun());
                                },
                              ),
                              _menuItem(Icons.info_outline, "Tentang Aplikasi"),
                              _menuItem(
                                Icons.lock_reset,
                                "Reset Password",
                                onTap: () {
                                  context.push(const ForgotPasswordScreen());
                                },
                              ),
                              _menuItem(
                                Icons.logout,
                                "Keluar",
                                onTap: () {
                                  _showLogoutDialog(context);
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 300),
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
