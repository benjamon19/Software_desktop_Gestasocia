import 'package:flutter/material.dart';
import '../../../utils/app_theme.dart';

class StatsCardsSection extends StatelessWidget {
  const StatsCardsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final bool isSmallScreen = screenWidth < 600;
    final bool hasVerticalSpace = screenHeight > 600; // Detecta si hay espacio vertical
    
    return Row(
      children: [
        Expanded(
          child: StatCard(
            title: 'Pacientes Activos',
            value: '1,284',
            icon: Icons.people_outline,
            iconColor: const Color(0xFF4299E1),
            backgroundColor: const Color(0xFFEBF8FF),
            isSmallScreen: isSmallScreen,
            hasVerticalSpace: hasVerticalSpace,
          ),
        ),
        SizedBox(width: isSmallScreen ? 8 : 12),
        Expanded(
          child: StatCard(
            title: 'Citas Hoy',
            value: '34',
            icon: Icons.calendar_today_outlined,
            iconColor: const Color(0xFF48BB78),
            backgroundColor: const Color(0xFFF0FDF4),
            isSmallScreen: isSmallScreen,
            hasVerticalSpace: hasVerticalSpace,
          ),
        ),
        SizedBox(width: isSmallScreen ? 8 : 12),
        Expanded(
          child: StatCard(
            title: 'Nuevos Historiales',
            value: '12',
            icon: Icons.person_add_outlined,
            iconColor: const Color(0xFF9F7AEA),
            backgroundColor: const Color(0xFFF9F5FF),
            isSmallScreen: isSmallScreen,
            hasVerticalSpace: hasVerticalSpace,
          ),
        ),
        SizedBox(width: isSmallScreen ? 8 : 12),
        Expanded(
          child: StatCard(
            title: 'Urgencias',
            value: '3',
            icon: Icons.warning_amber_outlined,
            iconColor: const Color(0xFFF56565),
            backgroundColor: const Color(0xFFFFF5F5),
            isSmallScreen: isSmallScreen,
            hasVerticalSpace: hasVerticalSpace,
          ),
        ),
      ],
    );
  }
}

class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;
  final bool isSmallScreen;
  final bool hasVerticalSpace;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.iconColor,
    required this.backgroundColor,
    required this.isSmallScreen,
    required this.hasVerticalSpace,
  });

  @override
  Widget build(BuildContext context) {
    // Si hay espacio vertical, usar layout vertical (original)
    if (hasVerticalSpace) {
      return _buildVerticalLayout(context);
    } else {
      // Si no hay espacio, usar layout horizontal (compacto)
      return _buildHorizontalLayout(context);
    }
  }

  Widget _buildVerticalLayout(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
      decoration: BoxDecoration(
        color: AppTheme.getSurfaceColor(context),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.black.withValues(alpha: 0.3)
                : Colors.grey.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Valor principal (ARRIBA)
          Text(
            value,
            style: TextStyle(
              fontSize: isSmallScreen ? 20 : 24,
              fontWeight: FontWeight.w800,
              color: AppTheme.getTextPrimary(context),
              height: 1.0,
              letterSpacing: -0.5,
            ),
          ),

          SizedBox(height: isSmallScreen ? 6 : 8),

          // Título (MEDIO)
          Text(
            title,
            style: TextStyle(
              fontSize: isSmallScreen ? 10 : 11,
              fontWeight: FontWeight.w600,
              color: AppTheme.getTextSecondary(context),
              letterSpacing: 0.1,
              height: 1.2,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          SizedBox(height: isSmallScreen ? 8 : 10),

          // Icono (ABAJO)
          Container(
            padding: EdgeInsets.all(isSmallScreen ? 6 : 8),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? iconColor.withValues(alpha: 0.2)
                  : backgroundColor,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: isSmallScreen ? 16 : 18,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHorizontalLayout(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 12 : 16,  // Aumentado de 8/12 a 12/16
        vertical: isSmallScreen ? 12 : 14,    // Aumentado de 8/10 a 12/14
      ),
      decoration: BoxDecoration(
        color: AppTheme.getSurfaceColor(context),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.black.withValues(alpha: 0.3)
                : Colors.grey.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        children: [
          // Icono (IZQUIERDA)
          Container(
            padding: EdgeInsets.all(isSmallScreen ? 8 : 10),  // Aumentado de 6/8 a 8/10
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? iconColor.withValues(alpha: 0.2)
                  : backgroundColor,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: isSmallScreen ? 16 : 18,  // Aumentado de 14/16 a 16/18
            ),
          ),

          SizedBox(width: isSmallScreen ? 12 : 14),  // Aumentado de 8/10 a 12/14

          // Contenido (DERECHA)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Valor
                Text(
                  value,
                  style: TextStyle(
                    fontSize: isSmallScreen ? 18 : 20,  // Aumentado de 16/18 a 18/20
                    fontWeight: FontWeight.w800,
                    color: AppTheme.getTextPrimary(context),
                    height: 1.0,
                    letterSpacing: -0.3,
                  ),
                ),

                SizedBox(height: isSmallScreen ? 2 : 3),  // Espaciado entre valor y título

                // Título
                Text(
                  title,
                  style: TextStyle(
                    fontSize: isSmallScreen ? 10 : 11,  // Aumentado de 9/10 a 10/11
                    fontWeight: FontWeight.w600,
                    color: AppTheme.getTextSecondary(context),
                    letterSpacing: 0.1,
                    height: 1.1,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}