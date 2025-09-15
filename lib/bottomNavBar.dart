import 'package:flutter/material.dart';
import 'package:tugas_17_flutter/absen.dart';
import 'package:tugas_17_flutter/home.dart';

class BottomNavigator extends StatefulWidget {
  const BottomNavigator({super.key});

  @override
  State<BottomNavigator> createState() => _BottomNavigatorState();
}

class _BottomNavigatorState extends State<BottomNavigator> {
  int _selectedIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = const [HomePage(), AbsenPage()];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],

      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF1A2A80),
        onPressed: () {
          // contoh navigasi ke halaman lain
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AbsenPage()),
          );
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),

      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.grey[50],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFF1A2A80),
        unselectedItemColor: Colors.grey,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.info), label: 'Tentang'),
        ],
      ),
    );
  }
}
