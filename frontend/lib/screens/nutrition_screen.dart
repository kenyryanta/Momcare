// lib/screens/nutrition_screen.dart

import 'package:flutter/material.dart';
import 'package:pregnancy_app/models/food_model.dart';
import 'package:pregnancy_app/models/nutrient_model.dart';
import 'package:pregnancy_app/theme/app_theme.dart';
import 'package:pregnancy_app/utils/constants.dart';
import 'package:pregnancy_app/widgets/food_item.dart';
import 'package:pregnancy_app/screens/morning_sickness_screen.dart';

class NutritionScreen extends StatelessWidget {
  const NutritionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Sample data for nutrients
    final List<NutrientModel> nutrients = [
      NutrientModel(
        name: 'Calories',
        amount: '+300 calories/day',
        description: 'Extra energy needed for pregnancy',
      ),
      NutrientModel(
        name: 'Protein',
        amount: '60g/day',
        description: 'Increased from 46g/day pre-pregnancy',
      ),
      NutrientModel(
        name: 'Folate',
        amount: '600μg/day',
        description: 'Prevents neural tube defects',
      ),
      NutrientModel(
        name: 'Iron',
        amount: '27mg/day',
        description: 'Prevents anemia',
      ),
      NutrientModel(
        name: 'Calcium',
        amount: '1000mg/day',
        description: 'Builds baby\'s bones and teeth',
      ),
    ];

    // Sample data for protein foods
    final List<FoodModel> proteinFoods = [
      FoodModel(
        name: 'Eggs',
        benefit: 'Complete protein, choline for brain development',
        imageUrl:
            'https://images.unsplash.com/photo-1607690424560-35d07269a95e',
      ),
      FoodModel(
        name: 'Salmon',
        benefit: 'Omega-3 for brain development',
        imageUrl:
            'https://images.unsplash.com/photo-1519708227418-c8fd9a32b7a2',
      ),
      FoodModel(
        name: 'Lean Meat',
        benefit: 'Easily absorbed heme iron',
        imageUrl:
            'https://images.unsplash.com/photo-1607623814075-e51df1bdc82f',
      ),
      FoodModel(
        name: 'Greek Yogurt',
        benefit: 'Protein and calcium for bone health',
        imageUrl:
            'https://images.unsplash.com/photo-1505252585461-04db1eb84625',
      ),
    ];

    // Sample data for vegetable foods
    final List<FoodModel> vegetableFoods = [
      FoodModel(
        name: 'Spinach',
        benefit: 'Rich in iron, folate, and vitamin K',
        imageUrl:
            'https://images.unsplash.com/photo-1576045057995-568f588f82fb',
      ),
      FoodModel(
        name: 'Broccoli',
        benefit: 'Rich in folate, calcium, and fiber',
        imageUrl:
            'https://images.unsplash.com/photo-1459411621453-7b03977f4bfc',
      ),
      FoodModel(
        name: 'Legumes',
        benefit: 'Plant protein and fiber source',
        imageUrl:
            'https://images.unsplash.com/photo-1515543904379-3d757afe72e1',
      ),
      FoodModel(
        name: 'Sweet Potatoes',
        benefit: 'Vitamin A for fetal development',
        imageUrl:
            'https://images.unsplash.com/photo-1596097635121-14b38c5d7a63',
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.firstTrimesterNutrition),
        backgroundColor: AppTheme.nutritionCardColor,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with illustration
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.nutritionCardColor.withOpacity(0.3),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'First Trimester\nNutrition Guide',
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(
                                color: AppTheme.primaryTextColor,
                                height: 1.3,
                              ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Essential nutrients for you and your baby\'s health',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    ),
                  ),
                  Image.asset(
                    'assets/images/nutrition_illustration.png',
                    height: 120,
                  ),
                ],
              ),
            ),

            // Nutrition summary card
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppConstants.dailyNutritionalNeeds,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: AppTheme.nutritionCardColor.withOpacity(0.8),
                        ),
                  ),
                  const SizedBox(height: 16),

                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        ...nutrients
                            .map((nutrient) => _buildNutrientRow(
                                  context,
                                  nutrient.name,
                                  nutrient.amount,
                                  nutrient.description,
                                ))
                            .toList(),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Protein foods section
                  Text(
                    AppConstants.proteinSources,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: AppTheme.nutritionCardColor.withOpacity(0.8),
                        ),
                  ),
                  const SizedBox(height: 16),

                  SizedBox(
                    height: 220,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: proteinFoods.length,
                      itemBuilder: (context, index) {
                        return FoodItem(
                          food: proteinFoods[index],
                          isHorizontal: true,
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Vegetable foods section
                  Text(
                    AppConstants.vegetables,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: AppTheme.nutritionCardColor.withOpacity(0.8),
                        ),
                  ),
                  const SizedBox(height: 16),

                  SizedBox(
                    height: 220,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: vegetableFoods.length,
                      itemBuilder: (context, index) {
                        return FoodItem(
                          food: vegetableFoods[index],
                          isHorizontal: true,
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Tips for morning sickness
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppTheme.nutritionCardColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppConstants.tipsForMorningSickness,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 16),
                        _buildTipItem('Eat small portions more frequently'),
                        _buildTipItem('Avoid oily and spicy foods'),
                        _buildTipItem('Keep crackers by your bedside'),
                        _buildTipItem('Stay hydrated throughout the day'),
                        _buildTipItem('Try ginger tea or candies'),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const MorningSicknessScreen(),
                              ),
                            );
                          },
                          child: const Text('View More Tips'),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Ask a question button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // Navigate to chat screen
                      },
                      icon: const Icon(Icons.question_answer),
                      label: const Text(AppConstants.askNutritionQuestion),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.nutritionCardColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNutrientRow(
    BuildContext context,
    String nutrient,
    String amount,
    String? description,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.nutritionCardColor.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.lunch_dining,
              color: AppTheme.nutritionCardColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nutrient,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (description != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ],
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.nutritionCardColor.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '• ',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
