import 'package:flutter/material.dart';
import '../../../../../../../utils/app_theme.dart';
import '../../../../../../../models/carga_familiar.dart';

class PersonalInfoCard extends StatelessWidget {
  final CargaFamiliar carga;

  const PersonalInfoCard({
    super.key,
    required this.carga,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(context),
          const SizedBox(height: 20),
          _buildInfoGrid(context),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.family_restroom_outlined,
            color: AppTheme.primaryColor,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          'Información Personal',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.getTextPrimary(context),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoGrid(BuildContext context) {
    return Column(
      children: [
        // Primera fila: Nombre Completo y RUT
        Row(
          children: [
            Expanded(
              child: _buildInfoItem(
                context,
                'Nombre Completo',
                carga.nombreCompleto, // El modelo ya garantiza que no es null
                Icons.person_outline,
                AppTheme.primaryColor,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildInfoItem(
                context,
                'RUT',
                carga.rutFormateado, // El modelo ya garantiza que no es null
                Icons.badge_outlined,
                Colors.blue,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Segunda fila: Fecha de Nacimiento y Edad
        Row(
          children: [
            Expanded(
              child: _buildInfoItem(
                context,
                'Fecha de Nacimiento',
                carga.fechaNacimientoFormateada, // El modelo ya garantiza que no es null
                Icons.cake_outlined,
                Colors.orange,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildInfoItem(
                context,
                'Edad',
                '${carga.edad} años', // El modelo garantiza que edad no es null
                Icons.timeline_outlined,
                Colors.purple,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Tercera fila: Parentesco y Estado
        Row(
          children: [
            Expanded(
              child: _buildInfoItem(
                context,
                'Parentesco',
                carga.parentesco, // El modelo ya garantiza que no es null
                Icons.favorite_outline,
                Colors.pink,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildInfoItem(
                context,
                'Estado',
                carga.estado, // El modelo ya garantiza que no es null
                _getEstadoIcon(carga.isActive), // isActive es bool, no bool?
                _getEstadoColor(carga.isActive), // isActive es bool, no bool?
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Cuarta fila: Fecha de Creación (ancho completo)
        _buildInfoItem(
          context,
          'Fecha de Registro',
          carga.fechaCreacionFormateada, // El modelo ya garantiza que no es null
          Icons.calendar_today_outlined,
          Colors.teal,
        ),
      ],
    );
  }

  Widget _buildInfoItem(BuildContext context, String label, String value, IconData icon, Color iconColor) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.getSurfaceColor(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.getBorderLight(context).withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header con icono y label
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  icon,
                  size: 16,
                  color: iconColor,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.getTextSecondary(context),
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Valor
          Text(
            value.isEmpty ? 'No especificado' : value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppTheme.getTextPrimary(context),
              height: 1.3,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  IconData _getEstadoIcon(bool isActive) {
    return isActive ? Icons.check_circle_outline : Icons.cancel_outlined;
  }

  Color _getEstadoColor(bool isActive) {
    return isActive ? Colors.green : Colors.red;
  }
}