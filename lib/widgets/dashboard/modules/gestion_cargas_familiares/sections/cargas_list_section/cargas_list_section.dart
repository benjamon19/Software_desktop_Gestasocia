// lib/widgets/dashboard/modules/gestion_cargas_familiares/sections/cargas_list_section/cargas_list_section.dart
import 'package:flutter/material.dart';
import '../../../../../../utils/app_theme.dart';
import '../../../../../../controllers/cargas_familiares_controller.dart' as cargas_controller;

class CargasListSection extends StatelessWidget {
  final List<Map<String, dynamic>> cargas;
  final Function(Map<String, dynamic>) onCargaSelected;
  final cargas_controller.CargasFamiliaresController controller;

  const CargasListSection({
    super.key,
    required this.cargas,
    required this.onCargaSelected,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    if (cargas.isEmpty) {
      return Container(
        decoration: BoxDecoration(
          color: AppTheme.getSurfaceColor(context),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppTheme.primaryColor.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.group_outlined, size: 48, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'Sin resultados',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header de la lista
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppTheme.getSurfaceColor(context),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(Icons.group, color: AppTheme.primaryColor, size: 24),
              const SizedBox(width: 12),
              Text(
                'Lista de Cargas',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.getTextPrimary(context),
                ),
              ),
              const Spacer(),
              _buildRefreshButton(controller),
              const SizedBox(width: 8),
              _buildCounterBadge(context, controller),
            ],
          ),
        ),
        const SizedBox(height: 20),
        
        // Lista de cargas
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: AppTheme.getSurfaceColor(context),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.primaryColor.withValues(alpha: 0.1),
                width: 1,
              ),
            ),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: cargas.length,
              separatorBuilder: (context, index) => Divider(
                color: AppTheme.getBorderLight(context),
                thickness: 1,
                height: 1,
              ),
              itemBuilder: (context, index) {
                final carga = cargas[index];
                return _buildCargaListItem(context, carga);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRefreshButton(cargas_controller.CargasFamiliaresController controller) {
    return IconButton(
      onPressed: () => controller.refreshCargas(),
      icon: Icon(Icons.refresh, color: AppTheme.primaryColor),
      tooltip: 'Recargar lista',
    );
  }

  Widget _buildCounterBadge(BuildContext context, cargas_controller.CargasFamiliaresController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '${cargas.length} cargas',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppTheme.primaryColor,
        ),
      ),
    );
  }

  Widget _buildCargaListItem(BuildContext context, Map<String, dynamic> carga) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => onCargaSelected(carga),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            // Avatar con icono de parentesco
            Stack(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: _getParentescoColor(carga['parentesco']).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _getParentescoColor(carga['parentesco']).withValues(alpha: 0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Icon(
                    _getParentescoIcon(carga['parentesco']), 
                    size: 28, 
                    color: _getParentescoColor(carga['parentesco'])
                  ),
                ),
                // Indicador de estado
                Positioned(
                  bottom: 2,
                  right: 2,
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: _getEstadoColor(carga['estado']),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),
            
            // Información de la carga
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${carga['nombre']} ${carga['apellido']}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.getTextPrimary(context),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.badge,
                          size: 14, color: AppTheme.getTextSecondary(context)),
                      const SizedBox(width: 4),
                      Text(
                        carga['rut'],
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.getTextSecondary(context),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(_getParentescoIcon(carga['parentesco']),
                          size: 14, color: _getParentescoColor(carga['parentesco'])),
                      const SizedBox(width: 4),
                      Text(
                        '${carga['parentesco']} • ${carga['edad']} años',
                        style: TextStyle(
                          fontSize: 14,
                          color: _getParentescoColor(carga['parentesco']),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(Icons.person,
                          size: 14, color: AppTheme.getTextSecondary(context)),
                      const SizedBox(width: 4),
                      Text(
                        'Titular: ${carga['titular']}',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppTheme.getTextSecondary(context),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(width: 8),
            Icon(
              Icons.chevron_right,
              color: AppTheme.getTextSecondary(context),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getParentescoIcon(String parentesco) {
    switch (parentesco.toLowerCase()) {
      case 'hijo': case 'hija': return Icons.child_care;
      case 'cónyuge': return Icons.favorite;
      case 'padre': case 'madre': return Icons.elderly;
      default: return Icons.person;
    }
  }

  Color _getParentescoColor(String parentesco) {
    switch (parentesco.toLowerCase()) {
      case 'hijo': case 'hija': return const Color(0xFF10B981);
      case 'cónyuge': return const Color(0xFFEC4899);
      case 'padre': case 'madre': return const Color(0xFF8B5CF6);
      default: return const Color(0xFF6B7280);
    }
  }

  Color _getEstadoColor(String estado) {
    switch (estado.toLowerCase()) {
      case 'activa': return const Color(0xFF10B981);
      case 'suspendida': return const Color(0xFFF59E0B);
      default: return const Color(0xFFEF4444);
    }
  }
}