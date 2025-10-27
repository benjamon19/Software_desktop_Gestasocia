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
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.getSurfaceColor(context),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).brightness == Brightness.dark 
                ? Colors.black.withValues(alpha: 0.3)
                : Colors.grey.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header con contador y badges
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${historiales.length} historial${historiales.length != 1 ? 'es' : ''} clínico${historiales.length != 1 ? 's' : ''}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.getTextPrimary(context),
                  ),
                ),
                // Estadísticas rápidas
                Row(
                  children: [
                    _buildStatBadge(
                      context,
                      'Completados',
                      historiales.where((h) => h['estado'] == 'Completado').length,
                      const Color(0xFF10B981),
                    ),
                    const SizedBox(width: 8),
                    _buildStatBadge(
                      context,
                      'Pendientes',
                      historiales.where((h) => h['estado'] == 'Pendiente').length,
                      const Color(0xFFF59E0B),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Divider
          Divider(
            height: 1,
            color: AppTheme.getBorderLight(context),
          ),
          
          // Lista de historiales
          Expanded(
            child: historiales.isEmpty
                ? _buildEmptyState(context)
                : ListView.separated(
                    padding: const EdgeInsets.all(20),
                    itemCount: historiales.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
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

  Widget _buildStatBadge(BuildContext context, String label, int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            '$count',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: AppTheme.getTextSecondary(context).withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No se encontraron historiales',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.getTextPrimary(context),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Intenta con otros filtros de búsqueda',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.getTextSecondary(context),
            ),
          ),
        ],
      ),
    );
  }
}