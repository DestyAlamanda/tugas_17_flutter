import 'package:flutter/material.dart';
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

  final AuthenticationAPI _authService = AuthenticationAPI();

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
      final response = await AuthenticationAPI.registerUser(
        name: _nameController.text,
        email: _emailController.text,
        password: _passwordController.text,
        jenisKelamin: _selectedGender!,
        batchId: _selectedBatch!.id,
        trainingId: _selectedTraining!.id,
      );

      if (mounted) {
        final message = response.message ?? 'Registrasi berhasil!';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: Colors.green),
        );
        Navigator.of(context).pop();
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
      backgroundColor: Colors.white,
      body: _isDataLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 80,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Create Account",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Sign up to get started",
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF888888),
                        ),
                      ),
                      const SizedBox(height: 25),

                      // Full Name
                      _buildLabel("Full Name"),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _nameController,
                        keyboardType: TextInputType.name,
                        decoration: _inputDecoration("Masukkan nama lengkap"),
                        validator: (value) => value == null || value.isEmpty
                            ? 'Nama tidak boleh kosong'
                            : null,
                      ),
                      const SizedBox(height: 25),

                      // Email
                      _buildLabel("Email"),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: _inputDecoration("Masukkan email"),
                        validator: (value) {
                          if (value == null || value.isEmpty)
                            return 'Email tidak boleh kosong';
                          if (!RegExp(
                            r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                          ).hasMatch(value)) {
                            return 'Format email tidak valid';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 25),

                      // Password
                      _buildLabel("Password"),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: !_isPasswordVisible,
                        decoration: _inputDecoration("Masukkan kata sandi")
                            .copyWith(
                              suffixIcon: IconButton(
                                onPressed: () {
                                  setState(
                                    () => _isPasswordVisible =
                                        !_isPasswordVisible,
                                  );
                                },
                                icon: Icon(
                                  _isPasswordVisible
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                        validator: (value) {
                          if (value == null || value.isEmpty)
                            return 'Password tidak boleh kosong';
                          if (value.length < 6)
                            return 'Password minimal 6 karakter';
                          return null;
                        },
                      ),
                      const SizedBox(height: 25),

                      // Dropdown Pelatihan
                      _buildLabel("Pelatihan"),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<Training>(
                        initialValue: _selectedTraining,
                        decoration: _inputDecoration("Pilih Pelatihan"),
                        items: _trainings.map((training) {
                          return DropdownMenuItem<Training>(
                            value: training,
                            child: Text(training.title),
                          );
                        }).toList(),
                        onChanged: (val) =>
                            setState(() => _selectedTraining = val),
                        validator: (val) =>
                            val == null ? 'Pelatihan harus dipilih' : null,
                      ),
                      const SizedBox(height: 25),

                      // Dropdown Batch
                      _buildLabel("Batch"),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<Batch>(
                        initialValue: _selectedBatch,
                        decoration: _inputDecoration("Pilih Batch"),
                        items: _batches.map((batch) {
                          return DropdownMenuItem<Batch>(
                            value: batch,
                            child: Text(batch.batchKe),
                          );
                        }).toList(),
                        onChanged: (val) =>
                            setState(() => _selectedBatch = val),
                        validator: (val) =>
                            val == null ? 'Batch harus dipilih' : null,
                      ),
                      const SizedBox(height: 25),

                      // Dropdown Gender
                      const SizedBox(height: 8),
                      Text('Jenis Kelamin', style: TextStyle(fontSize: 14)),
                      Row(
                        children: [
                          Expanded(
                            child: RadioListTile<String>(
                              title: const Text(
                                'Laki-laki',
                                style: TextStyle(fontSize: 14),
                              ),
                              value: 'L',
                              groupValue: _selectedGender,
                              onChanged: (v) =>
                                  setState(() => _selectedGender = v),
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                          Expanded(
                            child: RadioListTile<String>(
                              title: const Text(
                                'Perempuan',
                                style: TextStyle(fontSize: 14),
                              ),
                              value: 'P',
                              groupValue: _selectedGender,
                              onChanged: (v) =>
                                  setState(() => _selectedGender = v),
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),

                      // Register Button
                      ElevatedButton(
                        onPressed: _isLoading ? null : _handleRegister,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff21BDCA),
                          fixedSize: const Size(327, 56),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text(
                                "Sign Up",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                      const SizedBox(height: 30),

                      // Link Sign In
                      Center(
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const Text.rich(
                            TextSpan(
                              text: "Already have an account? ",
                              style: TextStyle(
                                color: Color(0xff888888),
                                fontSize: 12,
                              ),
                              children: [
                                TextSpan(
                                  text: 'Sign In',
                                  style: TextStyle(
                                    color: Color(0xff21BDCA),
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12,
                                  ),
                                ),
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

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Color(0xff888888),
        fontSize: 12,
        fontWeight: FontWeight.w400,
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(fontSize: 15, color: Colors.grey),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
    );
  }
}
