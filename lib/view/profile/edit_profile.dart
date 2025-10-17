import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';
import 'package:tugas_17_flutter/api/auth_api.dart';
import 'package:tugas_17_flutter/model/user_model.dart';
import 'package:tugas_17_flutter/utils/app_color.dart';
import 'package:tugas_17_flutter/view/widgets/custom_button.dart';
import 'package:tugas_17_flutter/view/widgets/custom_text_form_field.dart';

class EditProfileScreen extends StatefulWidget {
  final User currentUser;
  const EditProfileScreen({super.key, required this.currentUser});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;

  File? _profileImage;
  bool _isLoading = false;
  final ImagePicker _picker = ImagePicker();
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.currentUser.name);
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _handleUpdateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    String? successMessage;

    try {
      final textResponse = await _authService.updateUserProfile(
        name: _nameController.text,
        email: widget.currentUser.email, // tetap dikirim, tapi tidak diedit
      );
      successMessage = textResponse['message'];

      if (_profileImage != null) {
        final photoResponse = await _authService.updateProfilePhoto(
          photo: _profileImage!,
        );
        successMessage = photoResponse['message'];
      }

      if (mounted) {
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
                      if (mounted) {
                        Navigator.of(context).pop();
                        Navigator.of(context).pop(true);
                      }
                    });
                  },
                ),
                const SizedBox(height: 10),
                Text(
                  successMessage ?? "Profil berhasil diperbarui!",
                  style: const TextStyle(fontSize: 16, color: Colors.white),
                ),
              ],
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            backgroundColor: Colors.black,
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Lottie.asset(
                  "assets/lottie/gagal.json",
                  width: 150,
                  height: 150,
                  repeat: false,
                ),
                const SizedBox(height: 10),
                Text(
                  "Gagal memperbarui: $e",
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          systemOverlayStyle: SystemUiOverlayStyle.dark,
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
            'Profil',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 20),
                _buildProfilePicker(),
                const SizedBox(height: 32),
                _buildFormFields(),
                const SizedBox(height: 40),
                CustomButton(
                  label: "Simpan Perubahan",
                  isLoading: _isLoading,
                  onPressed: () {
                    FocusScope.of(context).unfocus();
                    _handleUpdateProfile();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfilePicker() {
    ImageProvider currentImage;
    if (_profileImage != null) {
      currentImage = FileImage(_profileImage!);
    } else if (widget.currentUser.profilePhotoUrl != null &&
        widget.currentUser.profilePhotoUrl!.isNotEmpty) {
      currentImage = NetworkImage(widget.currentUser.profilePhotoUrl!);
    } else {
      currentImage = const AssetImage('assets/images/foto.png');
    }

    return Center(
      child: Column(
        children: [
          CircleAvatar(
            radius: 52,
            backgroundColor: Colors.grey.shade300,
            child: CircleAvatar(
              radius: 50,
              backgroundColor: Colors.white,
              foregroundImage: currentImage,
              onForegroundImageError: (exception, stackTrace) {},
              child: const Icon(Icons.person, size: 50, color: Colors.grey),
            ),
          ),
          TextButton.icon(
            onPressed: _pickImage,
            icon: const Icon(
              Icons.camera_alt_outlined,
              size: 20,
              color: AppColors.teal,
            ),
            label: const Text(
              'Ubah Foto Profil',
              style: TextStyle(color: AppColors.teal),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            "Nama",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        // Nama Lengkap
        CustomTextFormField(
          controller: _nameController,
          hintText: 'Nama Lengkap',
          prefixIcon: const Icon(Icons.person_outline, color: Colors.white),
          validator: (v) => v!.isEmpty ? 'Nama tidak boleh kosong' : null,
        ),
        const SizedBox(height: 20),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            "Email",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        // Email (tampil, tapi tidak bisa diedit)
        _buildStaticField(
          'Email',
          widget.currentUser.email,
          Icons.email_outlined,
        ),

        const SizedBox(height: 20),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            "Jenis Kelamin",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        _buildStaticField(
          'Jenis Kelamin',
          widget.currentUser.jenisKelamin == 'L'
              ? 'Laki-laki'
              : widget.currentUser.jenisKelamin == 'P'
              ? 'Perempuan'
              : '-',
          Icons.wc,
        ),

        const SizedBox(height: 20),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            "Batch",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        _buildStaticField(
          'Batch',
          widget.currentUser.batchKe ?? '-',
          Icons.group,
        ),
        const SizedBox(height: 20),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            "Jurusan",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        _buildStaticField(
          'Jurusan',
          widget.currentUser.trainingTitle ?? '-',
          Icons.school,
        ),
      ],
    );
  }

  Widget _buildStaticField(String label, String value, IconData icon) {
    return AbsorbPointer(
      child: CustomTextFormField(
        controller: TextEditingController(text: value),
        hintText: label,
        prefixIcon: Icon(icon, color: Colors.white),
      ),
    );
  }
}
