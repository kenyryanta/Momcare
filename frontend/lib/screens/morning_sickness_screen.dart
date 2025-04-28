// lib/screens/morning_sickness_screen.dart

import 'package:flutter/material.dart';
import 'package:pregnancy_app/models/food_model.dart';
import 'package:pregnancy_app/models/tip_model.dart';
import 'package:pregnancy_app/theme/app_theme.dart';
import 'package:pregnancy_app/utils/constants.dart';
import 'package:pregnancy_app/widgets/food_item.dart';
import 'package:pregnancy_app/widgets/tip_card.dart';

class MorningSicknessScreen extends StatelessWidget {
  const MorningSicknessScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Sample data for tips
    final List<TipModel> tips = [
      TipModel(
        title: 'Eat Small, Frequent Meals',
        description:
            'Instead of three large meals, try eating five or six smaller meals throughout the day to keep your stomach from being empty.',
        iconName: 'access_time',
      ),
      TipModel(
        title: 'Stay Hydrated',
        description:
            'Sip water throughout the day. Try adding lemon or ginger for flavor if plain water triggers nausea.',
        iconName: 'water_drop',
      ),
      TipModel(
        title: 'Ginger Products',
        description:
            'Try ginger tea, ginger candies, or ginger supplements which may help reduce nausea.',
        iconName: 'spa',
      ),
      TipModel(
        title: 'Avoid Trigger Foods',
        description:
            'Stay away from spicy, greasy, or strong-smelling foods that may trigger nausea.',
        iconName: 'no_food',
      ),
      TipModel(
        title: 'Rest Well',
        description:
            'Fatigue can worsen morning sickness. Try to get plenty of rest and take naps when needed.',
        iconName: 'hotel',
      ),
    ];

    // Sample data for recommended foods
    final List<FoodModel> recommendedFoods = [
      FoodModel(
        name: 'Crackers',
        benefit: 'Easy to digest and can help settle your stomach',
        imageUrl:
            'https://images.unsplash.com/photo-1590779033100-9f60a05a013d',
      ),
      FoodModel(
        name: 'Bananas',
        benefit: 'Provide potassium and are gentle on the stomach',
        imageUrl:
            'https://images.unsplash.com/photo-1528825871115-3581a5387919',
      ),
      FoodModel(
        name: 'Plain toast',
        benefit: 'Simple carbohydrates that are easy to digest',
        imageUrl:
            'https://images.unsplash.com/photo-1525351484163-7529414344d8',
      ),
      FoodModel(
        name: 'Ginger tea',
        benefit: 'May help reduce nausea and vomiting',
        imageUrl:
            'https://images.unsplash.com/photo-1594631252845-29fc4cc8cde9',
      ),
      FoodModel(
        name: 'Cold foods',
        benefit: 'Often better tolerated as they have less aroma',
        imageUrl:
            'https://images.unsplash.com/photo-1505576399279-565b52d4ac71',
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.morningSicknessTitle),
        backgroundColor: AppTheme.morningCardColor,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header image
            Container(
              height: 200,
              width: double.infinity,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/morning_sickness.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.7),
                    ],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Managing Morning Sickness',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Effective strategies to help you feel better',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Tips section
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppConstants.tipsTitle,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: AppTheme.morningCardColor.withOpacity(0.8),
                        ),
                  ),
                  const SizedBox(height: 20),

                  // List of tips
                  ...tips
                      .map((tip) => TipCard(
                            tip: tip,
                            iconColor: AppTheme.morningCardColor,
                          ))
                      .toList(),

                  const SizedBox(height: 30),

                  // Recommended foods section
                  Text(
                    AppConstants.recommendedFoodsTitle,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: AppTheme.morningCardColor.withOpacity(0.8),
                        ),
                  ),
                  const SizedBox(height: 20),

                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppTheme.morningCardColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Foods that may help:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // List of recommended foods
                        ...recommendedFoods
                            .map((food) => FoodItem(
                                  food: food,
                                  isHorizontal: false,
                                ))
                            .toList(),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // When to seek help section
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.warning_amber_rounded,
                              color: Colors.red[700],
                              size: 24,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'When to Seek Medical Help',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.red[700],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Contact your healthcare provider if you experience:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildWarningItem(
                            'Inability to keep fluids down for 24 hours'),
                        _buildWarningItem(
                            'Signs of dehydration (dark urine, dizziness)'),
                        _buildWarningItem(
                            'Weight loss of more than 2 pounds in a week'),
                        _buildWarningItem(
                            'Vomiting blood or material that looks like coffee grounds'),
                        _buildWarningItem(
                            'Severe weakness, dizziness, or fainting'),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Chat with nutritionist button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // Navigate to chat screen
                      },
                      icon: const Icon(Icons.chat),
                      label: const Text(AppConstants.chatWithNutritionist),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.morningCardColor,
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

  Widget _buildWarningItem(String text) {
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
