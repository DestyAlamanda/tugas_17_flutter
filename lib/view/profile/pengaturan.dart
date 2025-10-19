import 'package:flutter/material.dart';
import 'package:tugas_17_flutter/extensions/navigator.dart';
import 'package:tugas_17_flutter/utils/app_color.dart';
import 'package:tugas_17_flutter/view/password/ubah_password.dart';
import 'package:tugas_17_flutter/view/widgets/section_title.dart';

class PengaturanAkun extends StatefulWidget {
  const PengaturanAkun({super.key});

  @override
  State<PengaturanAkun> createState() => _PengaturanAkunState();
}

class _PengaturanAkunState extends State<PengaturanAkun> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.teal),
          onPressed: () {
            FocusScope.of(context).unfocus();
            Navigator.of(context).pop();
          },
        ),
        title: const Text(
          'Pengaturan Akun',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            sectionTitle("Ubah Password"),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(16),
              ),

              child: Column(
                children: [
                  _menuItem(
                    Icons.lock_reset,

                    "Reset Password",
                    onTap: () {
                      context.push(const UbahPassword());
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _menuItem(IconData icon, String title, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
            child: Row(
              children: [
                Icon(icon, color: Colors.white, size: 30),
                const SizedBox(width: 20),
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
}
