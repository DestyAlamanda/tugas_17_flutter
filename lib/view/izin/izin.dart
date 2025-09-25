import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tugas_17_flutter/api/attendance_api.dart';
import 'package:tugas_17_flutter/model/attendace_record.dart';
import 'package:tugas_17_flutter/view/widgets/custom_button.dart';
import 'package:tugas_17_flutter/view/widgets/custom_text_form_field.dart';

class AppColors {
  static const primary = Color(0xFF58C5C8);
  static const textPrimary = Colors.black87;
}

class IzinPage extends StatefulWidget {
  const IzinPage({super.key});

  @override
  State<IzinPage> createState() => _IzinPageState();
}

class _IzinPageState extends State<IzinPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTime? _selectedDate;
  final TextEditingController _alasanController = TextEditingController();
  bool _isLoading = false;

  late Future<List<AttendanceRecord>> _izinFuture;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _izinFuture = AttendanceService().getAttendanceHistory();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _alasanController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primary, // header & tombol OK
              onPrimary: Colors.white, // teks di header
              surface: Color(0xFF1E1E1E), // background dialog
              onSurface: Colors.white, // teks tanggal
            ),
            dialogTheme: DialogThemeData(
              backgroundColor: const Color(0xFF111216),
            ),
          ),
          child: child!,
        );
      },
    );
    if (pickedDate != null) {
      setState(() => _selectedDate = pickedDate);
    }
  }

  Future<void> _kirimIzin() async {
    if (_selectedDate == null || _alasanController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Tanggal dan alasan harus diisi!")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await AttendanceService().submitIzin(
        alasan: _alasanController.text,
        date: DateFormat('yyyy-MM-dd').format(_selectedDate!),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response['message'] ?? "Izin berhasil diajukan"),
        ),
      );

      _alasanController.clear();
      _selectedDate = null;

      // refresh tab riwayat
      setState(() {
        _izinFuture = AttendanceService().getAttendanceHistory();
      });

      _tabController.animateTo(1);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    String tanggalIzin = _selectedDate != null
        ? DateFormat('dd MMM yyyy').format(_selectedDate!)
        : "Pilih tanggal izin";

    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: Column(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(30),
              child: Center(
                child: Text(
                  "Halaman Izin",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFF111216),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  TabBar(
                    controller: _tabController,
                    labelColor: AppColors.primary,
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: AppColors.primary,
                    indicatorWeight: 3,
                    tabs: const [
                      Tab(
                        icon: Icon(Icons.add_circle_outline),
                        text: "Ajukan Izin",
                      ),
                      Tab(icon: Icon(Icons.history_rounded), text: "Riwayat"),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        // TAB 1 - Ajukan Izin
                        SingleChildScrollView(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Tanggal Izin",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              GestureDetector(
                                onTap: _pickDate,
                                child: AbsorbPointer(
                                  child: CustomTextFormField(
                                    controller: TextEditingController(
                                      text: tanggalIzin,
                                    ),
                                    hintText: "Pilih tanggal izin",
                                    prefixIcon: const Icon(
                                      Icons.calendar_today,
                                      color: Colors.white54,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              const Text(
                                "Alasan",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              CustomTextFormField(
                                controller: _alasanController,
                                hintText: "Tuliskan alasan izin...",
                                keyboardType: TextInputType.multiline,
                                prefixIcon: const Icon(
                                  Icons.edit_note_rounded,
                                  color: Colors.white54,
                                ),
                              ),
                              const SizedBox(height: 30),
                              CustomButton(
                                onPressed: _isLoading ? null : _kirimIzin,
                                label: _isLoading
                                    ? "Mengirim..."
                                    : "Kirim Izin",
                                isLoading: _isLoading,
                              ),
                            ],
                          ),
                        ),

                        // TAB 2 - Riwayat Izin
                        FutureBuilder<List<AttendanceRecord>>(
                          future: _izinFuture,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            } else if (snapshot.hasError) {
                              return Center(
                                child: Text("Error: ${snapshot.error}"),
                              );
                            } else if (!snapshot.hasData ||
                                snapshot.data!.isEmpty) {
                              return const Center(
                                child: Text(
                                  "Belum ada data izin",
                                  style: TextStyle(color: Colors.white),
                                ),
                              );
                            }

                            // filter hanya status izin
                            final izinList = snapshot.data!
                                .where((r) => r.status.toLowerCase() == 'izin')
                                .toList();

                            // sort terbaru dulu
                            izinList.sort((a, b) {
                              final dateA = a.attendanceDate ?? DateTime(1900);
                              final dateB = b.attendanceDate ?? DateTime(1900);
                              return dateB.compareTo(dateA);
                            });

                            if (izinList.isEmpty) {
                              return const Center(
                                child: Text(
                                  "Belum ada data izin",
                                  style: TextStyle(color: Colors.white),
                                ),
                              );
                            }

                            return ListView.builder(
                              padding: const EdgeInsets.all(20),
                              itemCount: izinList.length,
                              itemBuilder: (context, index) {
                                final izin = izinList[index];
                                return Card(
                                  color: Colors.grey[850],
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: ListTile(
                                    leading: Container(
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
                                    title: Text(
                                      "${izin.day}, ${izin.date}",
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    subtitle: Text(
                                      "Alasan: ${izin.alasanIzin ?? '-'}",
                                      style: const TextStyle(
                                        color: Colors.white70,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
