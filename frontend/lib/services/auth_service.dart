import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class AuthService with ChangeNotifier {
  static const String baseUrl = 'http://192.168.1.10:5000/api';

  bool _isAuthenticated = false;
  String? _token;
  User? _currentUser;

  // Getter for authentication status
  bool get isAuthenticated => _isAuthenticated;
  String? get token => _token;
  User? get currentUser => _currentUser;

  AuthService() {
    _loadFromPrefs();
  }

  // Load token and user data from SharedPreferences
  Future<void> _loadFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _token = prefs.getString('token');
      final userDataString = prefs.getString('user_data');
      if (_token != null && userDataString != null) {
        _currentUser = User.fromJson(jsonDecode(userDataString));
        _isAuthenticated = true;
      } else {
        _isAuthenticated = false;
      }
      notifyListeners();
    } catch (e) {
      _isAuthenticated = false;
      _token = null;
      _currentUser = null;
    }
  }

  // Login user
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );
      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', data['token']);
        if (data['user'] != null) {
          await prefs.setString('user_data', jsonEncode(data['user']));
        }
        _token = data['token'];
        _currentUser = User.fromJson(data['user']);
        _isAuthenticated = true;
        notifyListeners();
        return data;
      } else {
        throw Exception(data['message'] ?? 'Login failed');
      }
    } catch (e) {
      throw Exception('Login error: $e');
    }
  }

  // Register user
  Future<Map<String, dynamic>> register(String username, String email,
      String password, int age, int weight, int height, int trimester) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'email': email,
          'password': password,
          'age': age,
          'weight': weight,
          'height': height,
          'trimester': trimester
        }),
      );
      return jsonDecode(response.body);
    } catch (e) {
      throw Exception('Registration error: $e');
    }
  }

  // Get current user from SharedPreferences
  Future<User?> getCurrentUser() async {
    if (_currentUser != null) return _currentUser;

    final prefs = await SharedPreferences.getInstance();
    final userDataString = prefs.getString('user_data');
    if (userDataString == null) return null;

    _currentUser = User.fromJson(jsonDecode(userDataString));
    return _currentUser;
  }

  // Logout user
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('user_data');
    _isAuthenticated = false;
    _token = null;
    _currentUser = null;
    notifyListeners();
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    if (_token != null) return _isAuthenticated;

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    _isAuthenticated = token != null;
    if (_isAuthenticated && _currentUser == null) {
      await getCurrentUser();
    }
    notifyListeners();
    return _isAuthenticated;
  }
}
