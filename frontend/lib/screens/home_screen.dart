// lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:pregnancy_app/screens/morning_sickness_screen.dart';
import 'package:pregnancy_app/screens/nutrition_screen.dart';
import 'package:pregnancy_app/theme/app_theme.dart';
import 'package:pregnancy_app/utils/constants.dart';
import 'package:pregnancy_app/widgets/feature_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.appName),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () {},
// lib/screens/home_screen.dart (continued)
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Pregnancy week tracker
              Container(
                padding: const EdgeInsets.all(20),
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.primaryColor, AppTheme.accentColor],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryColor.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${AppConstants.weekLabel} 8',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              AppConstants.firstTrimester,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            '56 days to go',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    LinearPercentIndicator(
                      percent: 0.2,
                      lineHeight: 10,
                      backgroundColor: Colors.white.withOpacity(0.3),
                      progressColor: Colors.white,
                      barRadius: const Radius.circular(5),
                      padding: EdgeInsets.zero,
                      animation: true,
                      animationDuration: 1000,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildWeekIndicator('1', true),
                        _buildWeekIndicator('12', true),
                        _buildWeekIndicator('24', false),
                        _buildWeekIndicator('40', false),
                      ],
                    ),
                  ],
                ),
              ),

              // Quick access cards
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Quick Access',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ),
              const SizedBox(height: 16),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.1,
                children: [
                  FeatureCard(
                    icon: Icons.restaurant,
                    title: AppConstants.nutritionFeature,
                    color: AppTheme.nutritionCardColor,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const NutritionScreen(),
                        ),
                      );
                    },
                  ),
                  FeatureCard(
                    icon: Icons.sick,
                    title: AppConstants.morningSicknessFeature,
                    color: AppTheme.morningCardColor,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MorningSicknessScreen(),
                        ),
                      );
                    },
                  ),
                  FeatureCard(
                    icon: Icons.monitor_weight,
                    title: AppConstants.weightTrackerFeature,
                    color: AppTheme.weightCardColor,
                    onTap: () {
                      // Navigate to weight tracker
                    },
                  ),
                  FeatureCard(
                    icon: Icons.calendar_today,
                    title: AppConstants.appointmentsFeature,
                    color: AppTheme.appointmentCardColor,
                    onTap: () {
                      // Navigate to appointments
                    },
                  ),
                ],
              ),

              // Daily tips section
              Padding(
                padding: const EdgeInsets.all(16),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.lightbulb_outline,
                            color: AppTheme.secondaryColor,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            AppConstants.dailyTipLabel,
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Try eating small, frequent meals to help manage morning sickness. Keep crackers by your bedside to eat before getting up.',
                        style: TextStyle(
                          fontSize: 16,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
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
                            child: const Text('Read More'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Upcoming appointments
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Upcoming Appointments',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.appointmentCardColor.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.calendar_today,
                        color: AppTheme.appointmentCardColor,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Prenatal Checkup',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'March 25, 2025 • 10:00 AM',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: AppTheme.secondaryTextColor,
                      ),
                      onPressed: () {
                        // Navigate to appointment details
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWeekIndicator(String week, bool isPassed) {
    return Column(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isPassed ? Colors.white : Colors.white.withOpacity(0.3),
          ),
          child: Center(
            child: Text(
              week,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isPassed ? AppTheme.primaryColor : Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Week',
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withOpacity(0.8),
          ),
        ),
      ],
    );
  }
}
