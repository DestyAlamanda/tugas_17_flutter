import 'package:flutter/material.dart';
import 'package:tugas_17_flutter/api/auth_api.dart';
import 'package:tugas_17_flutter/bottomNavBar.dart';
import 'package:tugas_17_flutter/view/auth/register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  final AuthService _authService = AuthService();

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final response = await _authService.loginUser(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (mounted) {
        FocusScope.of(context).unfocus();
        final message = response['message'] ?? "Login berhasil";
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: Colors.green),
        );

        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const BottomNavigator()),
          (Route<dynamic> route) => false,
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
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E0E0E), // hitam gelap
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 40),

                // Logo
                // Center(
                //   child: Image.asset(
                //     "assets/logo.png", // ganti dengan logo kamu
                //     height: 60,
                //   ),
                // ),
                const SizedBox(height: 24),

                const Text(
                  "Login",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Welcome back! Enter your email address and\npassword ",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 40),

                // Ilustrasi
                // Image.asset(
                //   "assets/illustration.png", // ganti dengan ilustrasi kamu
                //   height: 160,
                // ),
                const SizedBox(height: 40),

                // Email
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "EMAIL",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _emailController,
                  style: const TextStyle(color: Colors.white),
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: "Email or Phone Number",
                    hintStyle: const TextStyle(color: Colors.white54),
                    enabledBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white24),
                    ),
                    focusedBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF22C1C3)),
                    ),
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
                const SizedBox(height: 24),

                // Password
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "PASSWORD",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _passwordController,
                  style: const TextStyle(color: Colors.white),
                  obscureText: !_isPasswordVisible,
                  decoration: InputDecoration(
                    hintText: "Password",
                    hintStyle: const TextStyle(color: Colors.white54),
                    enabledBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white24),
                    ),
                    focusedBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF22C1C3)),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: Colors.white54,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Password tidak boleh kosong";
                    }
                    if (value.length < 6) {
                      return "Password minimal 6 karakter";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),

                // Forget Password
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {},
                    child: const Text(
                      "Forget password?",
                      style: TextStyle(color: Color(0xFF22C1C3)),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Tombol Submit
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF22C1C3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            "Submit",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 24),

                // Register
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Don’t have access? ",
                      style: TextStyle(color: Colors.white),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const RegisterPage(),
                          ),
                        );
                      },
                      child: const Text(
                        "Click here.",
                        style: TextStyle(
                          color: Color(0xFF22C1C3),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
