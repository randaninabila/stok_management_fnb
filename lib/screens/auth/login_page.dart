
import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final AuthService _authService = AuthService();

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController =
      TextEditingController();

  final TextEditingController _passwordController =
      TextEditingController();

  bool _isPasswordVisible = false;
  bool _isLoading = false;

  // Proses login
  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final user = await _authService.login(
        email: _emailController.text,
        password: _passwordController.text,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Selamat datang, ${user.name}!'),
          backgroundColor: const Color(0xFF1C3028),
        ),
      );

      // Navigasi berdasarkan status login
      // akan ditangani AuthWrapper pada tahap berikutnya.

    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceFirst('Exception: ', ''),
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
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
    const backgroundColor = Color(0xFF315C4D);
    const buttonColor = Color(0xFF1C3028);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 36,
              vertical: 24,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 50),

                  // Judul
                  const Center(
                    child: Text(
                      'Login',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 42,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 42),

                  // Email
                  const Text(
                    'Email',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 8),

                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 15,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(9),
                        borderSide: const BorderSide(
                          color: Colors.black,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(9),
                        borderSide: const BorderSide(
                          color: Colors.black,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(9),
                        borderSide: const BorderSide(
                          color: buttonColor,
                          width: 2,
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Email wajib diisi';
                      }

                      if (!RegExp(
                        r'^[^@]+@[^@]+\.[^@]+$',
                      ).hasMatch(value.trim())) {
                        return 'Format email tidak valid';
                      }

                      return null;
                    },
                  ),

                  const SizedBox(height: 18),

                  // Password
                  const Text(
                    'Password',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 8),

                  TextFormField(
                    controller: _passwordController,
                    obscureText: !_isPasswordVisible,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 15,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible =
                                !_isPasswordVisible;
                          });
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(9),
                        borderSide: const BorderSide(
                          color: Colors.black,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(9),
                        borderSide: const BorderSide(
                          color: Colors.black,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(9),
                        borderSide: const BorderSide(
                          color: buttonColor,
                          width: 2,
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Password wajib diisi';
                      }

                      return null;
                    },
                  ),

                  const SizedBox(height: 36),

                  // Sign Up
                  Row(
                    children: [
                      const Text(
                        "Don't have an account? ",
                        style: TextStyle(
                          color: Color(0xFFD5E2DB),
                          fontSize: 11,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            '/register',
                          );
                        },
                        child: const Text(
                          'Sign Up',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Login Button
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: buttonColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(9),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Login',
                              style: TextStyle(fontSize: 15),
                            ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  const Center(
                    child: Text(
                      'Or',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Google Login - akan diintegrasikan nanti
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: OutlinedButton(
                      onPressed: null,
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.white,
                        disabledBackgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(9),
                        ),
                        side: const BorderSide(
                          color: Colors.black,
                        ),
                      ),
                      child: const Text(
                        'Google Sign-In (Coming Soon)',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
