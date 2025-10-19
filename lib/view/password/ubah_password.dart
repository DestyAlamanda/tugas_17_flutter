import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tugas_17_flutter/api/auth_api.dart';
import 'package:tugas_17_flutter/extensions/navigator.dart';
import 'package:tugas_17_flutter/utils/app_color.dart';
import 'package:tugas_17_flutter/view/password/reset_passsword_screen.dart';
import 'package:tugas_17_flutter/view/widgets/custom_button.dart';
import 'package:tugas_17_flutter/view/widgets/custom_text_form_field.dart';

class UbahPassword extends StatefulWidget {
  final String? email; // biar bisa nerima dari LoginScreen

  const UbahPassword({super.key, this.email});

  @override
  State<UbahPassword> createState() => _UbahPasswordState();
}

class _UbahPasswordState extends State<UbahPassword> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _emailController;
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // kalau email dikirim dari LoginScreen, langsung isi
    _emailController = TextEditingController(text: widget.email ?? "");
  }

  Future<void> _handleSendOtp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final response = await _authService.forgotPassword(
        email: _emailController.text.trim(),
      );

      if (mounted) {
        final message = response['message'] ?? 'OTP berhasil dikirim!';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: Colors.green),
        );
        context.push(
          // kalau pakai extension navigator
          ResetPasswordScreen(
            email: _emailController.text.trim(),
            popOnSuccess: false,
          ),
        );
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
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          systemOverlayStyle: SystemUiOverlayStyle.dark,
          backgroundColor: AppColors.background,
          surfaceTintColor: AppColors.background,
          elevation: 0,
          leading: BackButton(color: Colors.grey.shade800),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Text(
                  'Ubah Password',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 30,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Masukkan email anda yang terdaftar untuk menerima kode OTP.',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 25),
                CustomTextFormField(
                  controller: _emailController,
                  hintText: "Email",
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: const Icon(
                    Icons.email_outlined,
                    color: Colors.white54,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Email tidak boleh kosong";
                    }
                    if (!RegExp(
                      r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                    ).hasMatch(value)) {
                      return "Format email tidak valid";
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 32),
                CustomButton(
                  label: "Kirim OTP",
                  isLoading: _isLoading,
                  onPressed: _handleSendOtp,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
