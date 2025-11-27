import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../../../utils/app_theme.dart';
import '../../../../../../../controllers/historial_clinico_controller.dart';

class HistorialHeader extends StatelessWidget {
  final Map<String, dynamic> historial;
  final VoidCallback? onBack;

  const HistorialHeader({
    super.key,
    required this.historial,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HistorialClinicoController>();
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.getSurfaceColor(context),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
        border: Border.all(
          color: AppTheme.getBorderLight(context).withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (onBack != null) ...[
                IconButton(
                  onPressed: onBack,
                  icon: Icon(
                    Icons.arrow_back,
                    color: AppTheme.getTextPrimary(context),
                  ),
                  tooltip: 'Volver a la lista',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(width: 12),
              ],
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.description_outlined,
                  color: AppTheme.primaryColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Historial Clínico',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.getTextPrimary(context),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          Obx(() {
            final currentHistorial = controller.selectedHistorial.value;
            final pacienteNombre = controller.selectedPacienteNombre.value;
            
            if (currentHistorial == null) {
              return const SizedBox();
            }
            
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoItem(
                        context,
                        'Paciente',
                        pacienteNombre.isEmpty ? 'Sin nombre' : pacienteNombre,
                        Icons.person_outline,
                        AppTheme.primaryColor,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildInfoItem(
                        context,
                        'Tipo de Paciente',
                        currentHistorial.pacienteTipo == 'asociado' 
                            ? 'Asociado' 
                            : 'Carga Familiar',
                        Icons.badge_outlined,
                        currentHistorial.pacienteTipo == 'asociado'
                            ? const Color(0xFF3B82F6)
                            : const Color(0xFF10B981),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Fecha, Hora y Odontólogo
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoItem(
                        context,
                        'Fecha',
                        currentHistorial.fechaFormateada,
                        Icons.event_outlined,
                        Colors.orange,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildInfoItem(
                        context,
                        'Hora',
                        currentHistorial.hora,
                        Icons.access_time_outlined,
                        Colors.teal,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildInfoItem(
                        context,
                        'Odontólogo',
                        currentHistorial.odontologo,
                        Icons.local_hospital_outlined,
                        const Color(0xFF3B82F6),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Tipo de Consulta y Estado
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoItem(
                        context,
                        'Tipo de Consulta',
                        currentHistorial.tipoConsultaFormateado,
                        _getTipoConsultaIcon(currentHistorial.tipoConsulta),
                        _getTipoConsultaColor(currentHistorial.tipoConsulta),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildInfoItem(
                        context,
                        'Estado',
                        currentHistorial.estadoFormateado,
                        _getEstadoIcon(currentHistorial.estado),
                        _getEstadoColor(currentHistorial.estado),
                      ),
                    ),
                  ],
                ),
              ],
            );
          }),
        ],
      ),
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
            value,
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

  IconData _getTipoConsultaIcon(String tipo) {
    switch (tipo.toLowerCase()) {
      case 'consulta':
        return Icons.medical_information_outlined;
      case 'control':
        return Icons.check_circle_outline;
      case 'urgencia':
        return Icons.emergency;
      case 'tratamiento':
        return Icons.healing;
      default:
        return Icons.medical_services_outlined;
    }
  }

  Color _getTipoConsultaColor(String tipo) {
    switch (tipo.toLowerCase()) {
      case 'consulta':
        return const Color(0xFF3B82F6);
      case 'control':
        return const Color(0xFF10B981);
      case 'urgencia':
        return const Color(0xFFEF4444);
      case 'tratamiento':
        return const Color(0xFF8B5CF6);
      default:
        return const Color(0xFF6B7280);
    }
  }

  IconData _getEstadoIcon(String estado) {
    switch (estado.toLowerCase()) {
      case 'completado':
        return Icons.check_circle_outline;
      case 'pendiente':
        return Icons.pending_outlined;
      case 'requiere_seguimiento':
        return Icons.refresh_outlined;
      default:
        return Icons.help_outline;
    }
  }

  Color _getEstadoColor(String estado) {
    switch (estado.toLowerCase()) {
      case 'completado':
        return const Color(0xFF10B981);
      case 'pendiente':
        return const Color(0xFFF59E0B);
      case 'requiere_seguimiento':
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFF6B7280);
    }
  }
}