// lib/widgets/tip_card.dart

import 'package:flutter/material.dart';
import 'package:pregnancy_app/models/tip_model.dart';
import 'package:pregnancy_app/theme/app_theme.dart';

class TipCard extends StatelessWidget {
  final TipModel tip;
  final Color iconColor;
  final Color backgroundColor;

  const TipCard({
    Key? key,
    required this.tip,
    this.iconColor = AppTheme.morningCardColor,
    this.backgroundColor = Colors.white,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    IconData getIconData() {
      switch (tip.iconName) {
        case 'access_time':
          return Icons.access_time;
        case 'water_drop':
          return Icons.water_drop;
        case 'spa':
          return Icons.spa;
        case 'no_food':
          return Icons.no_food;
        case 'hotel':
          return Icons.hotel;
        default:
          return Icons.info_outline;
      }
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: backgroundColor,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                getIconData(),
                color: iconColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tip.title,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    tip.description,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
