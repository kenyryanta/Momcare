// lib/models/nutrient_model.dart

class NutrientModel {
  final String name;
  final String amount;
  final String? description;

  NutrientModel({
    required this.name,
    required this.amount,
    this.description,
  });
}
