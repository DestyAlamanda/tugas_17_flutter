import 'package:flutter/material.dart';
import 'package:tugas_17_flutter/history.dart';
import 'package:tugas_17_flutter/view/absen/google_map.dart';
import 'package:tugas_17_flutter/view/home/home.dart' hide GoogleMapsScreen;
import 'package:tugas_17_flutter/view/izin/izin.dart';
import 'package:tugas_17_flutter/view/profile/profile_page.dart';

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
    _pages = const [HomePage(), History(), IzinPage(), ProfilePage()];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF111216),
      body: _pages[_selectedIndex],

      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xFF58C5C8),
        shape: const CircleBorder(),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const GoogleMapsScreen()),
          );
        },
        child: Icon(Icons.fingerprint, size: 40, color: Colors.white),
      ),

      bottomNavigationBar: BottomAppBar(
        color: Colors.grey[900],
        shape: const CircularNotchedRectangle(),
        notchMargin: 9,
        child: SizedBox(
          height: 65,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // Kiri
              _buildTabItem(index: 0, icon: Icons.home, label: "Home"),
              _buildTabItem(
                index: 1,
                icon: Icons.history_rounded,
                label: "Riwayat",
              ),

              const SizedBox(width: 48), // ruang untuk FAB
              // Kanan
              _buildTabItem(
                index: 2,
                icon: Icons.calendar_month,
                label: "Izin",
              ),
              _buildTabItem(index: 3, icon: Icons.person, label: "Profile"),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabItem({
    required int index,
    required IconData icon,
    required String label,
  }) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: isSelected ? const Color(0xFF469EA0) : Colors.grey),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isSelected ? Color(0xFF58C5C8) : Colors.grey,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
