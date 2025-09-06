import 'package:flutter/material.dart';
import '../../../../../../utils/app_theme.dart';

class EmptyStateSection extends StatelessWidget {
  final bool hasSearchQuery;
  final String searchQuery;
  final VoidCallback onNewHistorial;

  const EmptyStateSection({
    super.key, 
    this.hasSearchQuery = false, 
    this.searchQuery = '', 
    required this.onNewHistorial
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: hasSearchQuery 
                  ? const Color(0xFFF59E0B).withValues(alpha: 0.1)
                  : AppTheme.primaryColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              hasSearchQuery ? Icons.search_off : Icons.medical_information_outlined,
              size: 80,
              color: hasSearchQuery ? const Color(0xFFF59E0B) : AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            hasSearchQuery ? 'No se encontraron historiales' : 'No hay historial clínico',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.getTextPrimary(context),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            hasSearchQuery 
                ? 'No se encontraron historiales para "$searchQuery"\nIntenta con un término diferente'
                : 'Aún no hay historiales clínicos en el sistema\nComienza agregando el primer historial',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: AppTheme.getTextSecondary(context),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: onNewHistorial,
            icon: const Icon(Icons.medical_information, size: 20),
            label: Text(hasSearchQuery ? 'Agregar Nuevo Historial' : 'Crear Primer Historial'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
          if (!hasSearchQuery) ...[
            const SizedBox(height: 32),
            _buildFeatureOptions(context),
          ],
        ],
      ),
    );
  }

  Widget _buildFeatureOptions(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildFeatureItem(
          context,
          icon: Icons.medical_information_outlined,
          title: 'Historiales Clínicos',
          description: 'Historial completo de consultas',
        ),
        const SizedBox(width: 40),
        _buildFeatureItem(
          context,
          icon: Icons.healing_outlined,
          title: 'Tratamientos',
          description: 'Seguimiento de procedimientos',
        ),
        const SizedBox(width: 40),
        _buildFeatureItem(
          context,
          icon: Icons.schedule_outlined,
          title: 'Controles',
          description: 'Programación de citas',
        ),
      ],
    );
  }

  Widget _buildFeatureItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
  }) {
    return SizedBox(
      width: 140,
      child: Column(
        children: [
          Icon(
            icon,
            size: 32,
            color: AppTheme.primaryColor,
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.getTextPrimary(context),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.getTextSecondary(context),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}