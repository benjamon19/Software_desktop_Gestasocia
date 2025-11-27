import 'package:flutter/material.dart';
import '../../utils/app_theme.dart';
import 'content/stats_cards_section.dart';
import 'content/charts_grid_section.dart';

class DashboardContent extends StatelessWidget {
  const DashboardContent({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    
    // Detectar tipos de pantalla
    final bool isSmallScreen = screenWidth < 600;
    final bool isMediumScreen = screenWidth >= 600 && screenWidth < 1200;
    final bool isShortScreen = screenHeight < 700;
    
    // Padding adaptativo
    double horizontalPadding = isSmallScreen ? 16 : (isMediumScreen ? 24 : 30);
    double verticalPadding = isShortScreen ? 16 : (isSmallScreen ? 20 : 30);
    
    // Tamaños de texto adaptativos
    double titleSize = isSmallScreen ? 20 : (isMediumScreen ? 22 : 24);
    double subtitleSize = isSmallScreen ? 12 : (isMediumScreen ? 13 : 14);
    
    // Espaciado adaptativo
    double headerSpacing = isShortScreen ? 4 : (isSmallScreen ? 6 : 8);
    double sectionSpacing = isShortScreen ? 16 : (isSmallScreen ? 20 : 30);
    
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: verticalPadding,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header adaptativo
          _buildHeader(
            context,
            titleSize,
            subtitleSize,
            isSmallScreen,
          ),
          
          SizedBox(height: headerSpacing),
          
          // Subtítulo
          Text(
            'Bienvenido de vuelta, aquí está tu resumen del día',
            style: TextStyle(
              fontSize: subtitleSize,
              color: AppTheme.getTextSecondary(context),
            ),
          ),
          
          SizedBox(height: sectionSpacing),
          
          // Sección de tarjetas estadísticas
          const StatsCardsSection(),
          
          SizedBox(height: sectionSpacing),
          
          const Expanded(
            child: ChartsGridSection(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    double titleSize,
    double subtitleSize,
    bool isSmallScreen,
  ) {
    return Row(
      children: [
        Expanded(
          child: Text(
            'Resumen General',
            style: TextStyle(
              fontSize: titleSize,
              fontWeight: FontWeight.bold,
              color: AppTheme.getTextPrimary(context),
            ),
          ),
        ),
        
        if (!isSmallScreen) ...[
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: AppTheme.getTextSecondary(context).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.access_time,
                  size: 14,
                  color: AppTheme.getTextSecondary(context),
                ),
                const SizedBox(width: 4),
                Text(
                  'Se actualiza al iniciar sesión y solo si hay cambios relevantes.',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppTheme.getTextSecondary(context),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}