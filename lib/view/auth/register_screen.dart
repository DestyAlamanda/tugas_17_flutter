import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tugas_17_flutter/api/auth_api.dart';
import 'package:tugas_17_flutter/model/batch.dart';
import 'package:tugas_17_flutter/model/training.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  List<Batch> _batches = [];
  List<Training> _trainings = [];
  Batch? _selectedBatch;
  Training? _selectedTraining;

  String? _selectedGender;
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  bool _isDataLoading = true;

  final AuthService _authService = AuthService();

  /// 🔑 Tambahan untuk foto
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _fetchDropdownData();
  }

  Future<void> _fetchDropdownData() async {
    try {
      final batches = await _authService.getBatches();
      final trainings = await _authService.getTrainings();
      if (mounted) {
        setState(() {
          _batches = batches;
          _trainings = trainings;
          _isDataLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat data: ${e.toString()}')),
        );
        setState(() => _isDataLoading = false);
      }
    }
  }

  /// 🔑 Fungsi pilih gambar
  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (pickedFile != null) {
      setState(() => _profileImage = File(pickedFile.path));
    }
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedGender == null ||
        _selectedBatch == null ||
        _selectedTraining == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Lengkapi semua data!')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await _authService.registerUser(
        name: _nameController.text,
        email: _emailController.text,
        password: _passwordController.text,
        jenisKelamin: _selectedGender!,
        batchId: _selectedBatch!.id.toString(),
        trainingId: _selectedTraining!.id.toString(),
        profilePhoto: _profileImage, // 🔑 kirim foto
      );

      if (mounted) {
        final message = response['message'] ?? 'Registrasi berhasil';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: Colors.green),
        );

        Navigator.of(context).pop(); // kembali ke login
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E0E0E), // dark bg
      body: _isDataLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 30),

                    // const Icon(Icons.inbox, color: Colors.white, size: 48),
                    // const SizedBox(height: 12),
                    // const Text(
                    //   "Registration",
                    //   style: TextStyle(
                    //     fontSize: 22,
                    //     fontWeight: FontWeight.bold,
                    //     color: Colors.white,
                    //   ),
                    // ),
                    // const SizedBox(height: 8),
                    // const Text(
                    //   "Create your personal account now to access all",
                    //   textAlign: TextAlign.center,
                    //   style: TextStyle(color: Colors.white70, fontSize: 14),
                    // ),
                    // const SizedBox(height: 20),

                    /// 🔑 Tambahan UI foto profil
                    Column(
                      children: [
                        GestureDetector(
                          onTap:
                              _pickImage, // klik lingkaran langsung pilih foto
                          child: CircleAvatar(
                            radius: 52,
                            backgroundColor: Colors.white24,
                            child: CircleAvatar(
                              radius: 50,
                              backgroundImage: _profileImage != null
                                  ? FileImage(_profileImage!)
                                  : null,
                              backgroundColor: Colors.white,
                              child: _profileImage == null
                                  ? const Icon(
                                      Icons.person_add_alt_1_outlined,
                                      size: 40,
                                      color: Colors.grey,
                                    )
                                  : null,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Name
                    _buildLabel("NAME"),
                    const SizedBox(height: 4),
                    _buildTextField(
                      controller: _nameController,
                      hint: "Name",
                      validator: (v) =>
                          v == null || v.isEmpty ? "Nama wajib diisi" : null,
                    ),
                    const SizedBox(height: 20),

                    // Email
                    _buildLabel("EMAIL"),
                    const SizedBox(height: 4),
                    _buildTextField(
                      controller: _emailController,
                      hint: "Email",
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return "Email wajib diisi";
                        }
                        if (!RegExp(
                          r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                        ).hasMatch(v)) {
                          return "Format email tidak valid";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Password
                    _buildLabel("PASSWORD"),
                    const SizedBox(height: 4),
                    _buildTextField(
                      controller: _passwordController,
                      hint: "Password",
                      obscure: !_isPasswordVisible,
                      suffix: IconButton(
                        icon: Icon(
                          _isPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: Colors.white54,
                        ),
                        onPressed: () => setState(
                          () => _isPasswordVisible = !_isPasswordVisible,
                        ),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return "Password wajib diisi";
                        }
                        if (v.length < 6) {
                          return "Password minimal 6 karakter";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Dropdown Training
                    _buildLabel("PELATIHAN"),
                    const SizedBox(height: 4),
                    _buildDropdown<Training>(
                      hint: "Pilih Pelatihan",
                      value: _selectedTraining,
                      items: _trainings
                          .map(
                            (t) => DropdownMenuItem(
                              value: t,
                              child: Text(
                                t.title,
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (val) =>
                          setState(() => _selectedTraining = val),
                    ),
                    const SizedBox(height: 20),

                    // Dropdown Batch
                    _buildLabel("BATCH"),
                    const SizedBox(height: 4),
                    _buildDropdown<Batch>(
                      hint: "Pilih Batch",
                      value: _selectedBatch,
                      items: _batches
                          .map(
                            (b) => DropdownMenuItem(
                              value: b,
                              child: Text(
                                b.batchKe,
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (val) => setState(() => _selectedBatch = val),
                    ),
                    const SizedBox(height: 20),

                    // Gender
                    _buildLabel("JENIS KELAMIN"),
                    Row(
                      children: [
                        Expanded(
                          child: RadioListTile<String>(
                            activeColor: const Color(0xFF22C1C3),
                            title: const Text(
                              "Laki-laki",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                            value: "L",
                            groupValue: _selectedGender,
                            onChanged: (v) =>
                                setState(() => _selectedGender = v),
                          ),
                        ),
                        Expanded(
                          child: RadioListTile<String>(
                            activeColor: const Color(0xFF22C1C3),
                            title: const Text(
                              "Perempuan",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                            value: "P",
                            groupValue: _selectedGender,
                            onChanged: (v) =>
                                setState(() => _selectedGender = v),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleRegister,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF22C1C3),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text(
                                "Next",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Back to login
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Text.rich(
                        TextSpan(
                          text: "back to ",
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                          children: [
                            TextSpan(
                              text: "Login",
                              style: TextStyle(
                                color: Color(0xFF22C1C3),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.white,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    String? Function(String?)? validator,
    bool obscure = false,
    Widget? suffix,
  }) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      obscureText: obscure,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white54),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white24),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF22C1C3)),
        ),
        suffixIcon: suffix,
      ),
      validator: validator,
    );
  }

  Widget _buildDropdown<T>({
    required String hint,
    required List<DropdownMenuItem<T>> items,
    required T? value,
    required void Function(T?) onChanged,
  }) {
    return DropdownButtonFormField<T>(
      dropdownColor: const Color(0xFF1A1A1A),
      initialValue: value,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white54),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white24),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF22C1C3)),
        ),
      ),
      items: items,
      onChanged: onChanged,
      validator: (v) => v == null ? "Wajib dipilih" : null,
      style: const TextStyle(color: Colors.white),
    );
  }
}
