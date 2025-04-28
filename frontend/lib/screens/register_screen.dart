import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../utils/validators.dart';
import '../widgets/custom_text_field.dart';
import '../theme/app_theme.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _authService = AuthService();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );

    _animationController.forward();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  void _toggleConfirmPasswordVisibility() {
    setState(() {
      _obscureConfirmPassword = !_obscureConfirmPassword;
    });
  }

  String? _validateConfirmPassword(String? value) {
    return Validators.validateConfirmPassword(value, _passwordController.text);
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _authService.register(
        _usernameController.text.trim(),
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (response['success'] == true) {
        // Registrasi berhasil
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? 'Registrasi berhasil'),
            backgroundColor: Colors.green,
          ),
        );
        // Kembali ke halaman login
        Navigator.pop(context);
      } else {
        // Registrasi gagal
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? 'Registrasi gagal'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios,
              color: AppTheme.primaryTextColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Daftar Akun',
          style: TextStyle(
            color: AppTheme.primaryTextColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Teks pembuka
                    Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.app_registration_rounded,
                            size: 80,
                            color: AppTheme.secondaryColor,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Buat Akun Baru',
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Isi data di bawah ini untuk membuat akun baru',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Username field
                    CustomTextField(
                      controller: _usernameController,
                      hintText: 'Masukkan nama pengguna',
                      labelText: 'Nama Pengguna',
                      prefixIcon: const Icon(Icons.person_outline,
                          color: AppTheme.primaryColor),
                      validator: Validators.validateUsername,
                    ),

                    // Email field
                    CustomTextField(
                      controller: _emailController,
                      hintText: 'Masukkan email anda',
                      labelText: 'Email',
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: const Icon(Icons.email_outlined,
                          color: AppTheme.primaryColor),
                      validator: Validators.validateEmail,
                    ),

                    // Password field
                    CustomTextField(
                      controller: _passwordController,
                      hintText: 'Masukkan password anda',
                      labelText: 'Password',
                      obscureText: _obscurePassword,
                      prefixIcon: const Icon(Icons.lock_outline,
                          color: AppTheme.primaryColor),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Colors.grey,
                        ),
                        onPressed: _togglePasswordVisibility,
                      ),
                      validator: Validators.validatePassword,
                    ),

                    // Konfirmasi password field
                    CustomTextField(
                      controller: _confirmPasswordController,
                      hintText: 'Konfirmasi password anda',
                      labelText: 'Konfirmasi Password',
                      obscureText: _obscureConfirmPassword,
                      prefixIcon: const Icon(Icons.lock_outline,
                          color: AppTheme.primaryColor),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirmPassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Colors.grey,
                        ),
                        onPressed: _toggleConfirmPasswordVisibility,
                      ),
                      validator: _validateConfirmPassword,
                    ),

                    const SizedBox(height: 32),

                    // Tombol register
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _register,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          textStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white)
                            : const Text('Daftar'),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Link ke Login
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Sudah punya akun? ',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context); // Kembali ke login
                          },
                          child: const Text(
                            'Masuk sekarang',
                            style: TextStyle(
                              color: AppTheme.primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
