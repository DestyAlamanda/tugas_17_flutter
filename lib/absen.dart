import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class AbsenPage extends StatefulWidget {
  const AbsenPage({super.key});

  @override
  State<AbsenPage> createState() => _AbsenPageState();
}

class _AbsenPageState extends State<AbsenPage> {
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
      backgroundColor: Color(0xFF111216),
      appBar: AppBar(
        backgroundColor: Color(0xFF111216),
        title: const Text(
          "Attendance",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Container(
          //   // height: 70,
          //   width: double.infinity,
          //   margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          //   padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 20),
          //   decoration: BoxDecoration(
          //     color: Colors.grey[800],
          //     borderRadius: BorderRadius.circular(8),
          //   ),
          //   child: Column(
          //     children: [
          //       Text(
          //         "15:00",
          //         style: TextStyle(
          //           color: Colors.white,
          //           fontWeight: FontWeight.bold,
          //           fontSize: 30,
          //         ),
          //       ),
          //     ],
          //   ),
          // ),
          SizedBox(height: 30),
          Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.symmetric(vertical: 100),
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: GestureDetector(
                onLongPress: _showCheckAnimation, // tekan lama
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: const Color(0xFF4effca),
                  child: Center(
                    child: Text(
                      'Absen',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white, fontSize: 20),
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
