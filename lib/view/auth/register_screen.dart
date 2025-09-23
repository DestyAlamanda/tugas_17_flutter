import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';
import 'package:tugas_17_flutter/api/auth_api.dart';
import 'package:tugas_17_flutter/extensions/navigator.dart';
import 'package:tugas_17_flutter/model/batch2.dart';
import 'package:tugas_17_flutter/model/register_model.dart';
import 'package:tugas_17_flutter/model/training2.dart';
import 'package:tugas_17_flutter/utils/app_color.dart';
import 'package:tugas_17_flutter/view/auth/login_screen.dart';
import 'package:tugas_17_flutter/view/widgets/custom_button.dart';
import 'package:tugas_17_flutter/view/widgets/custom_text_form_field.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  bool hidePassword = true;
  bool isLoading = false;
  String? errorMessage;
  RegisterUserModel? user;

  String? selectedGender;
  batches? selectedBatch;
  Datum? selectedTraining;

  final ImagePicker _picker = ImagePicker();
  XFile? pickedFile;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passController = TextEditingController();

  Map<String, String> genderMap = {"Laki-laki": "L", "Perempuan": "P"};

  List<batches> batchList = [];
  List<Datum> trainingList = [];

  @override
  void initState() {
    super.initState();
    fetchDropdownData();
  }

  Future<void> fetchDropdownData() async {
    try {
      final batchResponse = await AuthService.getAllBatches();
      final trainingResponse = await AuthService.getAllTrainings();
      setState(() {
        batchList = batchResponse.data ?? [];
        trainingList = trainingResponse.data ?? [];
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Gagal memuat data dropdown: $e")));
    }
  }

  Future<void> pickFoto() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      pickedFile = image;
    });
  }

  Future<void> registerUser() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final pass = passController.text.trim();

    if (name.isEmpty || email.isEmpty || pass.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Semua field wajib diisi")));
      return;
    }

    if (selectedGender == null ||
        selectedBatch == null ||
        selectedTraining == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Pilih jenis kelamin, batch, dan pelatihan"),
        ),
      );
      return;
    }
    if (pickedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Foto profil belum dipilih")),
      );
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      RegisterUserModel result = await AuthService.registerUserAuth(
        name: name,
        email: email,
        password: pass,
        jenisKelamin: selectedGender!,
        profilePhoto: File(pickedFile!.path),
        batchId: selectedBatch!.id!,
        trainingId: selectedTraining!.id!,
      );

      setState(() {
        user = result;
      });

      // ✅ Dialog sukses dengan Lottie
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          backgroundColor: Colors.black,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Lottie.asset(
                "assets/lottie/berhasil.json",
                width: 150,
                height: 150,
                repeat: false,
                onLoaded: (composition) {
                  Future.delayed(composition.duration, () {
                    Navigator.of(context).pop();
                    context.push(const LoginScreen());
                  });
                },
              ),
              const SizedBox(height: 10),
              Text(
                result.message ?? "Pendaftaran berhasil!",
                style: const TextStyle(fontSize: 16, color: Colors.white),
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      setState(() => errorMessage = e.toString());

      // ❌ Dialog gagal
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: Colors.black,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Lottie.asset(
                "assets/lottie/berhasil.json",
                width: 150,
                height: 150,
                repeat: false,
              ),
              const SizedBox(height: 10),
              Text(
                "Gagal mendaftar: $errorMessage",
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 24),

              // Foto profil
              GestureDetector(
                onTap: pickFoto,
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.grey[800],
                  backgroundImage: pickedFile != null
                      ? FileImage(File(pickedFile!.path))
                      : null,
                  child: pickedFile == null
                      ? const Icon(
                          Icons.person_add,
                          size: 40,
                          color: Colors.white,
                        )
                      : null,
                ),
              ),
              const SizedBox(height: 32),

              // Nama
              _labelText("NAMA"),
              CustomTextFormField(
                controller: nameController,
                hintText: "Masukkan nama lengkap",
              ),
              const SizedBox(height: 16),

              // Email
              _labelText("EMAIL"),
              CustomTextFormField(
                controller: emailController,
                hintText: "Masukkan email",
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              // Kata sandi
              _labelText("KATA SANDI"),
              CustomTextFormField(
                controller: passController,
                hintText: "Masukkan kata sandi",
                obscureText: hidePassword,

                suffixIcon: IconButton(
                  icon: Icon(
                    hidePassword ? Icons.visibility_off : Icons.visibility,
                    color: Colors.grey,
                  ),
                  onPressed: () => setState(() => hidePassword = !hidePassword),
                ),
              ),
              const SizedBox(height: 16),

              // Pelatihan
              _labelText("PELATIHAN"),
              DropdownButtonFormField<Datum>(
                dropdownColor: Colors.black,
                initialValue: selectedTraining,
                items: trainingList
                    .map(
                      (t) => DropdownMenuItem(
                        value: t,
                        child: Text(
                          t.title ?? "Pelatihan ${t.id}",
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (val) => setState(() => selectedTraining = val),
                decoration: const InputDecoration(
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: AppColors.teal),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: AppColors.teal),
                  ),
                ),
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 16),

              // Batch
              _labelText("BATCH"),
              DropdownButtonFormField<batches>(
                dropdownColor: Colors.black,
                initialValue: selectedBatch,
                items: batchList
                    .map(
                      (b) => DropdownMenuItem(
                        value: b,
                        child: Text(
                          b.batchKe ?? "Batch ${b.id}",
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (val) => setState(() => selectedBatch = val),
                decoration: const InputDecoration(
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: AppColors.teal),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: AppColors.teal),
                  ),
                ),
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 16),

              // Jenis kelamin
              _labelText("JENIS KELAMIN"),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Radio<String>(
                    value: "L",
                    groupValue: selectedGender,
                    onChanged: (val) => setState(() => selectedGender = val),
                    activeColor: Colors.teal,
                  ),
                  const Text(
                    "Laki-laki",
                    style: TextStyle(color: Colors.white),
                  ),
                  const SizedBox(width: 16),
                  Radio<String>(
                    value: "P",
                    groupValue: selectedGender,
                    onChanged: (val) => setState(() => selectedGender = val),
                    activeColor: Colors.teal,
                  ),
                  const Text(
                    "Perempuan",
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Tombol Daftar
              // Ganti bagian ElevatedButton lama dengan ini
              CustomButton(
                label: "Daftar",
                onPressed: registerUser,
                isLoading: isLoading,
              ),

              const SizedBox(height: 16),

              // Kembali ke Login
              GestureDetector(
                onTap: () => context.push(const LoginScreen()),
                child: const Text(
                  "Kembali ke Login",
                  style: TextStyle(
                    color: Color(0xFF58C5C8),
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Label kecil di atas field
  Widget _labelText(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        ),
      ),
    );
  }

  // Input field underline
  Widget _inputField({
    required TextEditingController controller,
    required String hint,
    bool obscure = false,
    Widget? suffix,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.grey),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.teal),
        ),
        suffixIcon: suffix,
      ),
    );
  }

  InputDecoration _underlineInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.grey),
      enabledBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.grey),
      ),
      focusedBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.teal),
      ),
    );
  }
}
