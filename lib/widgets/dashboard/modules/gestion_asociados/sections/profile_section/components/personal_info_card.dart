import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../../../utils/app_theme.dart';
import '../../../../../../../controllers/asociados_controller.dart';

class PersonalInfoCard extends StatelessWidget {
  final Map<String, dynamic> asociado;

  const PersonalInfoCard({
    super.key,
    required this.asociado,
  });

  @override
  Widget build(BuildContext context) {
    final AsociadosController controller = Get.find<AsociadosController>();
    
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(context),
          const SizedBox(height: 20),
          Obx(() {
            final currentAsociado = controller.selectedAsociado.value;
            if (currentAsociado == null) {
              return const SizedBox();
            }
            return _buildInfoGrid(context, currentAsociado);
          }),
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
            Icons.person_outline,
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

  Widget _buildInfoGrid(BuildContext context, dynamic currentAsociado) {
    return Column(
      children: [
        // Primera fila: Nombre Completo y RUT
        Row(
          children: [
            Expanded(
              child: _buildInfoItem(
                context,
                'Nombre Completo',
                currentAsociado.nombreCompleto,
                Icons.person_outline,
                AppTheme.primaryColor,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildInfoItem(
                context,
                'RUT',
                currentAsociado.rutFormateado,
                Icons.badge_outlined,
                Colors.blue,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Segunda fila: Email y Teléfono
        Row(
          children: [
            Expanded(
              child: _buildInfoItem(
                context,
                'Email',
                currentAsociado.email,
                Icons.email_outlined,
                const Color(0xFF3B82F6),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildInfoItem(
                context,
                'Teléfono',
                currentAsociado.telefono,
                Icons.phone_outlined,
                Colors.green,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Tercera fila: Fecha de Nacimiento y Estado Civil
        Row(
          children: [
            Expanded(
              child: _buildInfoItem(
                context,
                'Fecha de Nacimiento',
                currentAsociado.fechaNacimientoFormateada,
                Icons.cake_outlined,
                Colors.orange,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildInfoItem(
                context,
                'Estado Civil',
                currentAsociado.estadoCivil,
                Icons.favorite_outline,
                Colors.purple,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Cuarta fila: Plan y Fecha de Ingreso
        Row(
          children: [
            Expanded(
              child: _buildInfoItem(
                context,
                'Plan de Membresía',
                currentAsociado.plan,
                Icons.card_membership_outlined,
                _getPlanColor(currentAsociado.plan),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildInfoItem(
                context,
                'Fecha de Ingreso',
                currentAsociado.fechaIngresoFormateada,
                Icons.calendar_today_outlined,
                Colors.teal,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Quinta fila: Dirección (ancho completo)
        _buildInfoItem(
          context,
          'Dirección',
          currentAsociado.direccion,
          Icons.location_on_outlined,
          const Color(0xFFEF4444),
        ),
      ],
    );
  }

  Widget _buildInfoItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color iconColor,
  ) {
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

  Color _getPlanColor(String? plan) {
    if (plan == null) return Colors.grey;
    
    switch (plan.toLowerCase()) {
      case 'vip':
        return Colors.purple;
      case 'asociado':
        return AppTheme.primaryColor;
      default:
        return Colors.grey;
    }
  }
}