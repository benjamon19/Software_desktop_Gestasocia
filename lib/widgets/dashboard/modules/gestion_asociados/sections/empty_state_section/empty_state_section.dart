import 'package:flutter/material.dart';
import '../../../../../../utils/app_theme.dart';

class EmptyStateSection extends StatelessWidget {
  const EmptyStateSection({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isVerySmall = screenWidth < 400;
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline,
            size: isVerySmall ? 40 : 48,
            color: AppTheme.getTextSecondary(context).withValues(alpha: 0.3),
          ),
          SizedBox(height: isVerySmall ? 8 : 12),
          Text(
            isVerySmall ? 'Sin asociados' : 'No se encontraron asociados',
            style: TextStyle(
              fontSize: isVerySmall ? 12 : 14,
              color: AppTheme.getTextSecondary(context),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}