import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'food_result_screen.dart';

class FoodCapture extends StatefulWidget {
  const FoodCapture({Key? key}) : super(key: key);

  @override
  State<FoodCapture> createState() => _FoodCaptureState();
}

class _FoodCaptureState extends State<FoodCapture> {
  final picker = ImagePicker();
  bool _isLoading = false;
  final List<Map<String, TextEditingController>> _controllers = [];

  @override
  void initState() {
    super.initState();
    _addItem();
  }

  @override
  void dispose() {
    for (var pair in _controllers) {
      pair['name']?.dispose();
      pair['quantity']?.dispose();
    }
    super.dispose();
  }

  void _addItem() {
    setState(() {
      _controllers.add({
        'name': TextEditingController(),
        'quantity': TextEditingController(),
      });
    });
  }

  void _removeItem(int index) {
    setState(() {
      _controllers[index]['name']?.dispose();
      _controllers[index]['quantity']?.dispose();
      _controllers.removeAt(index);
    });
  }

  Future<void> _submitTextItems() async {
    setState(() => _isLoading = true);

    final items = _controllers
        .map((pair) {
          final name = pair['name']!.text.trim();
          final qtyText = pair['quantity']!.text.trim();
          final qty = double.tryParse(qtyText) ?? 0.0;
          return (name.isNotEmpty && qty > 0)
              ? {'name': name, 'quantity': qty}
              : null;
        })
        .where((e) => e != null)
        .cast<Map<String, dynamic>>()
        .toList();

    if (items.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Enter valid items.')));
      setState(() => _isLoading = false);
      return;
    }

    try {
      final response = await http.post(
        Uri.parse(
            'http://192.168.0.101:5000/food_detection/get_nutrition_by_text'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'items': items}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final calories = (data['calories'] is num)
            ? (data['calories'] as num).toDouble()
            : 0.0;
        final protein = (data['protein'] is num)
            ? (data['protein'] as num).toDouble()
            : 0.0;
        final fat =
            (data['fat'] is num) ? (data['fat'] as num).toDouble() : 0.0;
        final carbs =
            (data['carbs'] is num) ? (data['carbs'] as num).toDouble() : 0.0;

        setState(() => _isLoading = false);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => FoodResultScreen.textResult(
              calories: calories,
              protein: protein,
              fat: fat,
              carbs: carbs,
            ),
          ),
        );
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _openCamera() async {
    final picked = await picker.pickImage(source: ImageSource.camera);
    if (picked != null) _processImage(File(picked.path));
  }

  Future<void> _pickImageFromGallery() async {
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) _processImage(File(picked.path));
  }

  Future<void> _processImage(File imageFile) async {
    setState(() => _isLoading = true);

    final bytes = await imageFile.readAsBytes();
    final image = img.decodeImage(bytes);
    if (image == null) {
      setState(() => _isLoading = false);
      return;
    }

    final compressed = img.encodeJpg(image, quality: 25);
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('http://192.168.0.101:5000/food_detection/detect_food'),
    );
    request.files.add(http.MultipartFile.fromBytes(
      'file',
      compressed,
      filename: 'image.jpg',
    ));
    final streamed = await request.send();
    final resBody = await streamed.stream.bytesToString();
    final decoded = jsonDecode(resBody) as Map<String, dynamic>;

    setState(() => _isLoading = false);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => FoodResultScreen.imageResult(
          imageFile: imageFile,
          dishName: decoded['dish_name'] ?? 'Unknown',
          imageId: decoded['imageId']?.toString() ?? '',
        ),
      ),
    );
  }

  Widget _buildTextForm() => Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _controllers.length,
              itemBuilder: (ctx, i) {
                final pair = _controllers[i];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: pair['name'],
                          decoration:
                              const InputDecoration(labelText: 'Food Name'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: pair['quantity'],
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          decoration:
                              const InputDecoration(labelText: 'Quantity'),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _removeItem(i),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.add),
            label: const Text('Add Item'),
            onPressed: _addItem,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            child: const Text('Get Nutritional Info'),
            onPressed: _submitTextItems,
          ),
        ],
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Capture or Enter Food'),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // 1) Header text
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Please enter your foods:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // 2) Card wrapping the text form
                Expanded(
                  child: Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: _buildTextForm(),
                    ),
                  ),
                ),

                const SizedBox(height: 16),
                // 3) Divider before image buttons
                const Divider(height: 1, thickness: 1),
                const SizedBox(height: 16),

                // 4) Gallery / Camera buttons at bottom
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      icon: const Icon(Icons.image),
                      label: const Text('Gallery'),
                      onPressed: _pickImageFromGallery,
                    ),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Camera'),
                      onPressed: _openCamera,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Loading indicator overlay
          if (_isLoading) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
