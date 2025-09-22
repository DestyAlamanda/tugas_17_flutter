import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tugas_17_flutter/api/auth_api.dart';
import 'package:tugas_17_flutter/view/auth/reset_passsword_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  Future<void> _handleSendOtp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final response = await _authService.forgotPassword(
        email: _emailController.text,
      );
      if (mounted) {
        final message = response['message'] ?? 'OTP berhasil dikirim!';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: Colors.green),
        );
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ResetPasswordScreen(
              email: _emailController.text,
              popOnSuccess: false,
            ),
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
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.pink,
        appBar: AppBar(
          systemOverlayStyle: SystemUiOverlayStyle.dark,
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
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
                  'Lupa Password',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Masukkan email Anda yang terdaftar untuk menerima kode OTP.',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(color: Colors.amber),
                ),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    hintText: 'Email',
                    prefixIcon: Icon(Icons.email_outlined),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Email tidak boleh kosong';
                    }
                    if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) {
                      return 'Format email tidak valid';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                          backgroundColor: Colors.amber,
                        ),
                        onPressed: _handleSendOtp,
                        child: const Text(
                          'Kirim OTP',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
