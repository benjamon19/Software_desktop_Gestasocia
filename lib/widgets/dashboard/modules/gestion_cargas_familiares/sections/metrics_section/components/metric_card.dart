import 'package:flutter/material.dart';
import '../../../../../../../utils/app_theme.dart';

class MetricsSection extends StatelessWidget {
  const MetricsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final bool isSmallScreen = screenWidth < 600;
    final bool hasVerticalSpace = screenHeight > 600; // Detecta si hay espacio vertical
    
    return Row(
      children: [
        Expanded(
          child: MetricCard(
            title: 'Total Cargas',
            value: '52',
            icon: Icons.group_outlined,
            iconColor: const Color(0xFF4299E1),
            backgroundColor: const Color(0xFFEBF8FF),
            isSmallScreen: isSmallScreen,
            hasVerticalSpace: hasVerticalSpace,
          ),
        ),
        SizedBox(width: isSmallScreen ? 8 : 12),
        Expanded(
          child: MetricCard(
            title: 'Pendientes',
            value: '8',
            icon: Icons.pending_actions_outlined,
            iconColor: const Color(0xFF48BB78),
            backgroundColor: const Color(0xFFF0FDF4),
            isSmallScreen: isSmallScreen,
            hasVerticalSpace: hasVerticalSpace,
          ),
        ),
        SizedBox(width: isSmallScreen ? 8 : 12),
        Expanded(
          child: MetricCard(
            title: 'Vencimientos',
            value: '3',
            icon: Icons.schedule_outlined,
            iconColor: const Color(0xFF9F7AEA),
            backgroundColor: const Color(0xFFF9F5FF),
            isSmallScreen: isSmallScreen,
            hasVerticalSpace: hasVerticalSpace,
          ),
        ),
        SizedBox(width: isSmallScreen ? 8 : 12),
        Expanded(
          child: MetricCard(
            title: 'Urgencias',
            value: '2',
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

class MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;
  final bool isSmallScreen;
  final bool hasVerticalSpace;

  const MetricCard({
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
        horizontal: isSmallScreen ? 12 : 16,
        vertical: isSmallScreen ? 12 : 14,
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
            padding: EdgeInsets.all(isSmallScreen ? 8 : 10),
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

          SizedBox(width: isSmallScreen ? 12 : 14),

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
                    fontSize: isSmallScreen ? 18 : 20,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.getTextPrimary(context),
                    height: 1.0,
                    letterSpacing: -0.3,
                  ),
                ),

                SizedBox(height: isSmallScreen ? 2 : 3),

                // Título
                Text(
                  title,
                  style: TextStyle(
                    fontSize: isSmallScreen ? 10 : 11,
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