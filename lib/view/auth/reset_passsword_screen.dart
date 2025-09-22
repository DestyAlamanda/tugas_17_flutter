import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pinput/pinput.dart';
import 'package:tugas_17_flutter/api/auth_api.dart';
import 'package:tugas_17_flutter/view/auth/login_screen.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String email;
  final bool popOnSuccess;

  const ResetPasswordScreen({
    super.key,
    required this.email,
    this.popOnSuccess = false,
  });

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _otpController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  late Timer _timer;
  int _secondsRemaining = 600;

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  void startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        if (mounted) setState(() => _secondsRemaining--);
      } else {
        timer.cancel();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Waktu habis, silakan minta OTP baru.'),
              backgroundColor: Colors.orange,
            ),
          );
          Navigator.of(context).pop();
        }
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _otpController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String get _timerText {
    int minutes = _secondsRemaining ~/ 60;
    int seconds = _secondsRemaining % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Future<void> _handleResetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final response = await _authService.resetPassword(
        email: widget.email,
        otp: _otpController.text,
        password: _passwordController.text,
      );
      if (mounted) {
        final message = response['message'] ?? 'Password berhasil diubah!';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: Colors.green),
        );

        if (widget.popOnSuccess) {
          int count = 0;
          Navigator.of(context).popUntil((_) => count++ >= 2);
        } else {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const LoginScreen()),
            (route) => false,
          );
        }
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
        backgroundColor: Colors.white, // warna background aja
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildHeader(context),
                  const SizedBox(height: 24),
                  Text(
                    _timerText,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.pink,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildOtpInput(),
                  const SizedBox(height: 32),
                  _buildPasswordFields(),
                  const SizedBox(height: 32),
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.pink,
                            ),
                            onPressed: _handleResetPassword,
                            child: const Text(
                              'Reset Password',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      children: [
        const Text(
          'Reset Password',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: Colors.black,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: const TextStyle(color: Colors.black54, fontSize: 16),
            children: <TextSpan>[
              const TextSpan(text: 'Masukkan kode OTP yang dikirim ke\n'),
              TextSpan(
                text: widget.email,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.pink,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOtpInput() {
    final defaultPinTheme = PinTheme(
      width: 52,
      height: 56,
      textStyle: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade400),
      ),
    );

    return Pinput(
      length: 6,
      controller: _otpController,
      defaultPinTheme: defaultPinTheme,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      focusedPinTheme: defaultPinTheme.copyWith(
        decoration: defaultPinTheme.decoration!.copyWith(
          border: Border.all(color: Colors.pink, width: 1.5),
        ),
      ),
      errorPinTheme: defaultPinTheme.copyWith(
        decoration: defaultPinTheme.decoration!.copyWith(
          border: Border.all(color: Colors.red),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return 'OTP tidak boleh kosong';
        if (value.length < 6) return 'OTP harus 6 digit';
        return null;
      },
      errorTextStyle: const TextStyle(fontSize: 13, color: Colors.red),
    );
  }

  Widget _buildPasswordFields() {
    return Column(
      children: [
        TextFormField(
          controller: _passwordController,
          obscureText: !_isPasswordVisible,
          decoration: InputDecoration(
            labelText: 'Password Baru',
            prefixIcon: const Icon(Icons.lock_outline),
            suffixIcon: IconButton(
              icon: Icon(
                _isPasswordVisible
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: Colors.grey,
              ),
              onPressed: () =>
                  setState(() => _isPasswordVisible = !_isPasswordVisible),
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Password tidak boleh kosong';
            }
            if (value.length < 8) return 'Minimal 8 karakter';
            if (!RegExp(r'[A-Z]').hasMatch(value))
              return 'Harus ada huruf besar';
            if (!RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(value)) {
              return 'Harus ada simbol';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _confirmPasswordController,
          obscureText: !_isConfirmPasswordVisible,
          decoration: InputDecoration(
            labelText: 'Konfirmasi Password',
            prefixIcon: const Icon(Icons.lock_outline),
            suffixIcon: IconButton(
              icon: Icon(
                _isConfirmPasswordVisible
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: Colors.grey,
              ),
              onPressed: () => setState(
                () => _isConfirmPasswordVisible = !_isConfirmPasswordVisible,
              ),
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          validator: (v) {
            if (v != _passwordController.text) {
              return 'Konfirmasi password tidak cocok';
            }
            return null;
          },
        ),
      ],
    );
  }
}
