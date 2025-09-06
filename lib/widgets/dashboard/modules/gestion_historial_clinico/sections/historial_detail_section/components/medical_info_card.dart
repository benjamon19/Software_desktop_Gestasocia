import 'package:flutter/material.dart';
import '../../../../../../../utils/app_theme.dart';
import '../../../shared/widgets/section_title.dart';

class MedicalInfoCard extends StatelessWidget {
  final Map<String, dynamic> historial;

  const MedicalInfoCard({super.key, required this.historial});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle(title: 'Información Médica Adicional'),
          const SizedBox(height: 16),
          
          // Estado del tratamiento
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _getEstadoBackgroundColor(historial['estado']),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _getEstadoColor(historial['estado']).withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _getEstadoColor(historial['estado']),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _getEstadoIcon(historial['estado']),
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Estado del Tratamiento',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: _getEstadoColor(historial['estado']),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        historial['estado'],
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: _getEstadoColor(historial['estado']),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Resumen del caso
          if (historial['estado'] == 'Pendiente')
            _buildPendingAlert(context)
          else
            _buildCompletedSummary(context),
          
          const SizedBox(height: 16),
          
          // Información del historial
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.getInputBackground(context),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppTheme.getBorderLight(context)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 16,
                      color: AppTheme.getTextSecondary(context),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Información del Historial',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.getTextSecondary(context),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildSmallInfoItem(
                        context,
                        'Tipo',
                        historial['tipoConsulta'],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildSmallInfoItem(
                        context,
                        'Edad del Paciente',
                        '${historial['pacienteEdad']} años',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _buildSmallInfoItem(
                  context,
                  'Registro en Sistema',
                  'Registrado el ${historial['fecha']} por ${historial['odontologo']}',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPendingAlert(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF59E0B).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFF59E0B).withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.pending_actions,
                color: Color(0xFFF59E0B),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Tratamiento Pendiente',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFFF59E0B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Este tratamiento requiere seguimiento. Próxima cita programada: ${historial['proximaCita'] ?? 'Por programar'}',
            style: TextStyle(
              fontSize: 12,
              color: const Color(0xFFF59E0B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletedSummary(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF10B981).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.check_circle,
                color: Color(0xFF10B981),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Tratamiento Completado',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF10B981),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Tratamiento finalizado exitosamente. ${historial['proximaCita'] != null ? 'Control programado para: ${historial['proximaCita']}' : 'Sin controles pendientes.'}',
            style: TextStyle(
              fontSize: 12,
              color: const Color(0xFF10B981),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmallInfoItem(BuildContext context, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: AppTheme.getTextSecondary(context),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppTheme.getTextPrimary(context),
          ),
        ),
      ],
    );
  }

  Color _getEstadoColor(String estado) {
    switch (estado.toLowerCase()) {
      case 'completado': return const Color(0xFF10B981);
      case 'pendiente': return const Color(0xFFF59E0B);
      default: return const Color(0xFF6B7280);
    }
  }

  Color _getEstadoBackgroundColor(String estado) {
    return _getEstadoColor(estado).withValues(alpha: 0.1);
  }

  IconData _getEstadoIcon(String estado) {
    switch (estado.toLowerCase()) {
      case 'completado': return Icons.check_circle;
      case 'pendiente': return Icons.pending_actions;
      default: return Icons.info;
    }
  }
}