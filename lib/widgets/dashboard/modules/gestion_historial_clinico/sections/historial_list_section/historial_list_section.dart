import 'package:flutter/material.dart';
import '../../../../../../utils/app_theme.dart';
import 'components/historial_card.dart';

class HistorialListSection extends StatelessWidget {
  final List<Map<String, dynamic>> historiales;
  final Function(Map<String, dynamic>) onHistorialSelected;
  final Function(String) onFilterChanged;
  final Function(String) onStatusChanged;
  final Function(String) onOdontologoChanged;
  final String selectedFilter;
  final String selectedStatus;
  final String selectedOdontologo;

  const HistorialListSection({
    super.key,
    required this.historiales,
    required this.onHistorialSelected,
    required this.onFilterChanged,
    required this.onStatusChanged,
    required this.onOdontologoChanged,
    required this.selectedFilter,
    required this.selectedStatus,
    required this.selectedOdontologo,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isSmallScreen = screenWidth < 600;
    final bool isVerySmall = screenWidth < 400;
    
    return Container(
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
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header compacto
          Padding(
            padding: EdgeInsets.all(isVerySmall ? 12 : (isSmallScreen ? 14 : 16)),
            child: Row(
              children: [
                Icon(
                  Icons.medical_information_outlined, 
                  color: AppTheme.primaryColor, 
                  size: isVerySmall ? 16 : (isSmallScreen ? 18 : 20)
                ),
                SizedBox(width: isVerySmall ? 8 : 12),
                Expanded(
                  child: Text(
                    isVerySmall ? 'Historiales' : 'Historiales Clínicos',
                    style: TextStyle(
                      fontSize: isVerySmall ? 14 : (isSmallScreen ? 15 : 16),
                      fontWeight: FontWeight.w600,
                      color: AppTheme.getTextPrimary(context),
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isVerySmall ? 6 : 8,
                    vertical: isVerySmall ? 2 : 4,
                  ),
                  decoration: BoxDecoration(
                    color: historiales.isNotEmpty 
                        ? AppTheme.primaryColor
                        : AppTheme.getTextSecondary(context).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    historiales.length.toString(),
                    style: TextStyle(
                      fontSize: isVerySmall ? 10 : (isSmallScreen ? 11 : 12),
                      fontWeight: FontWeight.w600,
                      color: historiales.isNotEmpty ? Colors.white : AppTheme.getTextSecondary(context),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Línea divisoria sutil
          Container(
            height: 1,
            margin: EdgeInsets.symmetric(horizontal: isVerySmall ? 12 : 16),
            color: AppTheme.getTextSecondary(context).withValues(alpha: 0.1),
          ),
          
          // Lista de historiales
          Expanded(
            child: historiales.isEmpty
                ? _buildEmptyState(context)
                : ListView.separated(
                    padding: EdgeInsets.all(isVerySmall ? 8 : (isSmallScreen ? 12 : 16)),
                    itemCount: historiales.length,
                    separatorBuilder: (context, index) => SizedBox(height: isVerySmall ? 6 : 8),
                    itemBuilder: (context, index) {
                      return HistorialCard(
                        historial: historiales[index],
                        onTap: () => onHistorialSelected(historiales[index]),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isVerySmall = screenWidth < 400;
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.folder_open_outlined,
            size: isVerySmall ? 40 : 48,
            color: AppTheme.getTextSecondary(context).withValues(alpha: 0.3),
          ),
          SizedBox(height: isVerySmall ? 8 : 12),
          Text(
            isVerySmall ? 'Sin historiales' : 'No se encontraron historiales',
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