import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// ← new imports for bottom navigation
import 'package:pregnancy_app/main.dart';
import 'package:pregnancy_app/theme/app_theme.dart';
import 'package:pregnancy_app/utils/constants.dart';

class FoodResultScreen extends StatefulWidget {
  final File? imageFile;
  final String? dishName;
  final String? imageId;
  final double? calories;
  final double? protein;
  final double? fat;
  final double? carbs;

  const FoodResultScreen.imageResult({
    super.key,
    required this.imageFile,
    required this.dishName,
    required this.imageId,
  })  : calories = null,
        protein = null,
        fat = null,
        carbs = null;

  const FoodResultScreen.textResult({
    super.key,
    required this.calories,
    required this.protein,
    required this.fat,
    required this.carbs,
  })  : imageFile = null,
        dishName = null,
        imageId = null;

  @override
  State<FoodResultScreen> createState() => _FoodResultScreenState();
}

class _FoodResultScreenState extends State<FoodResultScreen> {
  late double _calories;
  late double _protein;
  late double _fat;
  late double _carbs;
  bool _isLoading = false;
  bool get _isTextMode => widget.imageFile == null;

  @override
  void initState() {
    super.initState();
    _calories = widget.calories ?? 0.0;
    _protein = widget.protein ?? 0.0;
    _fat = widget.fat ?? 0.0;
    _carbs = widget.carbs ?? 0.0;

    if (_isTextMode) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showSavePrompt();
      });
    }
  }

  Future<void> _fetchNutritionInfo() async {
    if (widget.imageId == null) return;
    setState(() => _isLoading = true);
    try {
      final resp = await http.post(
        Uri.parse(
            'http://192.168.1.10:5000/food_detection/get_nutritional_info'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'imageId': widget.imageId}),
      );
      if (resp.statusCode == 200) {
        final data =
            jsonDecode(resp.body)['nutritional_info'] as Map<String, dynamic>;
        setState(() {
          _calories = data['calories'] != null
              ? (data['calories'] as num).toDouble()
              : 0.0;
          _protein = data['protein'] != null
              ? (data['protein'] as num).toDouble()
              : 0.0;
          _fat = data['fat'] != null ? (data['fat'] as num).toDouble() : 0.0;
          _carbs =
              data['carbs'] != null ? (data['carbs'] as num).toDouble() : 0.0;
        });
        _showSavePrompt();
      } else {
        throw Exception('Failed to fetch nutrition: ${resp.statusCode}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSavePrompt() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Save Nutritional Info'),
        content: const Text('Would you like to save this nutrition data?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _saveNutritionalInfo();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveNutritionalInfo() async {
    setState(() => _isLoading = true);
    final payload = {
      'calories': _calories,
      'protein': _protein,
      'fat': _fat,
      'carbs': _carbs,
    };

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    if (token == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Please log in first.')));
      setState(() => _isLoading = false);
      return;
    }

    try {
      final resp = await http.post(
        Uri.parse(
            'http://192.168.1.10:5000/food_detection/store_nutritional_info'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(payload),
      );
      final msg = resp.statusCode == 200
          ? jsonDecode(resp.body)['message']
          : 'Failed to save';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Widget _buildNutritionCard(String label, double value, String unit) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        title: Text(label),
        trailing: Text('${value.toStringAsFixed(1)} $unit'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isTextMode ? 'Nutrition Summary' : 'Food Result'),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: ListView(
              children: [
                if (!_isTextMode) ...[
                  if (widget.imageFile != null) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        widget.imageFile!,
                        height: 250,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Detected Food:',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      widget.dishName ?? '',
                      style: const TextStyle(
                          fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                  ],
                  if (_calories == 0)
                    ElevatedButton(
                      onPressed: _fetchNutritionInfo,
                      child: const Text('Get Nutritional Info'),
                    ),
                  if (_calories > 0) ...[
                    const SizedBox(height: 12),
                    _buildNutritionCard('Calories', _calories, 'kcal'),
                    _buildNutritionCard('Protein', _protein, 'g'),
                    _buildNutritionCard('Fat', _fat, 'g'),
                    _buildNutritionCard('Carbs', _carbs, 'g'),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _saveNutritionalInfo,
                      child: const Text('Save to Profile'),
                    ),
                  ],
                ] else ...[
                  _buildNutritionCard('Calories', _calories, 'kcal'),
                  _buildNutritionCard('Protein', _protein, 'g'),
                  _buildNutritionCard('Fat', _fat, 'g'),
                  _buildNutritionCard('Carbs', _carbs, 'g'),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _saveNutritionalInfo,
                    child: const Text('Save to Profile'),
                  ),
                ],
              ],
            ),
          ),
          if (_isLoading) const Center(child: CircularProgressIndicator()),
        ],
      ),

      // ← added bottom navigation bar
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppTheme.primaryColor,
        unselectedItemColor: AppTheme.secondaryTextColor,
        currentIndex: 2, // Tracker tab selected
        onTap: (index) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => MainNavigationScreen(initialIndex: index),
            ),
          );
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: AppConstants.homeTab,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.forum_outlined),
            activeIcon: Icon(Icons.forum),
            label: AppConstants.forumTab,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.camera_alt),
            activeIcon: Icon(Icons.camera_alt),
            label: 'Tracker',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            activeIcon: Icon(Icons.chat_bubble),
            label: AppConstants.chatTab,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: AppConstants.profileTab,
          ),
        ],
      ),
    );
  }
}
