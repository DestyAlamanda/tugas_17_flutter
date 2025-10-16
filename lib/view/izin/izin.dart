import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tugas_17_flutter/api/attendance_api.dart';
import 'package:tugas_17_flutter/model/attendace_record.dart';
import 'package:tugas_17_flutter/utils/app_color.dart';
import 'package:tugas_17_flutter/view/widgets/custom_button.dart';
import 'package:tugas_17_flutter/view/widgets/custom_text_form_field.dart';
import 'package:tugas_17_flutter/view/widgets/section_title.dart';

class IzinPage extends StatefulWidget {
  const IzinPage({super.key});

  @override
  State<IzinPage> createState() => _IzinPageState();
}

class _IzinPageState extends State<IzinPage> {
  DateTime? _selectedDate;
  final TextEditingController _alasanController = TextEditingController();
  bool _isLoading = false;
  late Future<List<AttendanceRecord>> _izinFuture;

  @override
  void initState() {
    super.initState();
    _izinFuture = AttendanceService().getAttendanceHistory();
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
              primary: AppColors.teal,
              onPrimary: Colors.white,
              surface: Color(0xFF1E1E1E),
              onSurface: Colors.white,
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
      setState(() {
        _izinFuture = AttendanceService().getAttendanceHistory();
      });
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
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            setState(() {
              _izinFuture = AttendanceService().getAttendanceHistory();
            });
          },
          color: Colors.white,
          backgroundColor: Colors.grey[900],
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🏷 Header
                Padding(
                  padding: const EdgeInsets.all(20),
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

                // Body utama
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
                          sectionTitle("Ajukan Izin"),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.grey[900],
                              borderRadius: BorderRadius.circular(16),
                            ),
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
                                const SizedBox(height: 24),
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

                          const SizedBox(height: 30),
                          sectionTitle("Riwayat Izin"),
                          const SizedBox(height: 16),

                          // 📜 Riwayat
                          FutureBuilder<List<AttendanceRecord>>(
                            future: _izinFuture,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(30),
                                    child: CircularProgressIndicator(),
                                  ),
                                );
                              } else if (snapshot.hasError) {
                                return Text(
                                  "Error: ${snapshot.error}",
                                  style: const TextStyle(color: Colors.white),
                                );
                              } else if (!snapshot.hasData ||
                                  snapshot.data!.isEmpty) {
                                return _emptyHistory();
                              }

                              final izinList =
                                  snapshot.data!
                                      .where(
                                        (r) => r.status.toLowerCase() == 'izin',
                                      )
                                      .toList()
                                    ..sort((a, b) {
                                      final dateA =
                                          a.attendanceDate ?? DateTime(1900);
                                      final dateB =
                                          b.attendanceDate ?? DateTime(1900);
                                      return dateB.compareTo(dateA);
                                    });

                              if (izinList.isEmpty) return _emptyHistory();

                              return Column(
                                children: izinList.map((izin) {
                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[850],
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 70,
                                          height: 70,
                                          decoration: BoxDecoration(
                                            color: AppColors.tealLightCard,
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: const Icon(
                                            Icons.event_note_rounded,
                                            color: Colors.white,
                                            size: 30,
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "${izin.day}, ${izin.date}",
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                "Alasan: ${izin.alasanIzin ?? '-'}",
                                                style: TextStyle(
                                                  color: Colors.white
                                                      .withOpacity(0.7),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              );
                            },
                          ),

                          const SizedBox(height: 80),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

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
              Icons.event_busy_rounded,
              size: 35,
              color: AppColors.teal,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            "Belum ada data izin",
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
