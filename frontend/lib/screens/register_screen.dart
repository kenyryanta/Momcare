import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../services/auth_service.dart';
import '../utils/validators.dart';
import '../widgets/custom_text_field.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

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
  final _ageController = TextEditingController();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  final _trimesterController = TextEditingController();
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
        int.tryParse(_ageController.text.trim()) ?? 0,
        int.tryParse(_weightController.text.trim()) ?? 0,
        int.tryParse(_heightController.text.trim()) ?? 0,
        int.tryParse(_trimesterController.text.trim()) ?? 0,
      );

      if (response['success'] == true) {
        final token = response['token'];
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwtoken', token);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? 'Registrasi berhasil'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } else {
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

  Future<void> setNutritionGoal() async {
    // Retrieve the JWT token from storage
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('jwt_token') ?? '';

    // Send a POST request to the protected route with the token
    final response = await http.post(
      Uri.parse(
          'http://192.168.1.10:5000/nutrition/set_goal'), // Replace with your actual API endpoint
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token', // Send the JWT token here
      },
    );

    if (response.statusCode == 201) {
      // Successfully set the goal
      final data = json.decode(response.body);
      print(data['message']);
      // Navigate to the dashboard or home screen
      Navigator.pushReplacementNamed(context, '/dashboard');
    } else {
      // Handle error
      print('Failed to set goal');
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _ageController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    _trimesterController.dispose();
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
                    // Opening text
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

                    // Confirm password field
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

                    const SizedBox(height: 16),

                    // Age field
                    CustomTextField(
                      controller: _ageController,
                      hintText: 'Masukkan usia anda',
                      labelText: 'Usia',
                      keyboardType: TextInputType.number,
                      prefixIcon: const Icon(Icons.calendar_today,
                          color: AppTheme.primaryColor),
                      validator: Validators.validateAge,
                    ),

                    // Weight field
                    CustomTextField(
                      controller: _weightController,
                      hintText: 'Masukkan berat badan anda (kg)',
                      labelText: 'Berat Badan',
                      keyboardType: TextInputType.number,
                      prefixIcon: const Icon(Icons.accessibility_new,
                          color: AppTheme.primaryColor),
                      validator: Validators.validateWeight,
                    ),

                    // Height field
                    CustomTextField(
                      controller: _heightController,
                      hintText: 'Masukkan tinggi badan anda (cm)',
                      labelText: 'Tinggi Badan',
                      keyboardType: TextInputType.number,
                      prefixIcon: const Icon(Icons.height,
                          color: AppTheme.primaryColor),
                      validator: Validators.validateHeight,
                    ),

                    // Trimester field
                    CustomTextField(
                      controller: _trimesterController,
                      hintText: 'Masukkan trimester ke-berapa',
                      labelText: 'Trimester',
                      keyboardType: TextInputType.number,
                      prefixIcon: const Icon(Icons.pregnant_woman,
                          color: AppTheme.primaryColor),
                      validator: Validators.validateTrimester,
                    ),

                    const SizedBox(height: 32),

                    // Register button
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

                    // Login link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Sudah punya akun? ',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context); // Go back to login
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
