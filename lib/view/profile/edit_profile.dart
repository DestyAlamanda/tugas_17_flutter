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
  late final TextEditingController _emailController;

  File? _profileImage;
  bool _isLoading = false;
  final ImagePicker _picker = ImagePicker();
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.currentUser.name);
    _emailController = TextEditingController(text: widget.currentUser.email);
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
        email: _emailController.text,
      );
      successMessage = textResponse['message'];

      if (_profileImage != null) {
        final photoResponse = await _authService.updateProfilePhoto(
          photo: _profileImage!,
        );
        successMessage = photoResponse['message'];
      }

      if (mounted) {
        // ✅ Tampilkan dialog berhasil
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
                        Navigator.of(context).pop(); // tutup dialog
                        Navigator.of(context).pop(true); // balik ke ProfilePage
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
        // ❌ Tampilkan dialog gagal
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
            'Edit Profil',
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
          const SizedBox(height: 8),
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
      children: [
        CustomTextFormField(
          controller: _nameController,
          hintText: 'Nama Lengkap',
          prefixIcon: const Icon(Icons.person_outline, color: Colors.white),
          validator: (v) => v!.isEmpty ? 'Nama tidak boleh kosong' : null,
        ),
        const SizedBox(height: 16),
        CustomTextFormField(
          controller: _emailController,
          hintText: 'Email',
          keyboardType: TextInputType.emailAddress,
          prefixIcon: const Icon(Icons.email_outlined, color: Colors.white),
          validator: (v) {
            if (v == null || v.isEmpty) {
              return 'Email tidak boleh kosong';
            }
            if (!RegExp(r'\S+@\S+\.\S+').hasMatch(v)) {
              return 'Format email tidak valid';
            }
            return null;
          },
        ),
      ],
    );
  }
}
