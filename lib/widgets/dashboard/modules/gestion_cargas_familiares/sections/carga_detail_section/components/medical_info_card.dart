import 'package:flutter/material.dart';
import '../../../../../../../utils/app_theme.dart';
import '../../../shared/widgets/section_title.dart';

class MedicalInfoCard extends StatelessWidget {
  final Map<String, dynamic> carga;

  const MedicalInfoCard({super.key, required this.carga});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle(title: 'Información Médica'),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildInfoItem(context, 'Última Visita', carga['ultimaVisita'], Icons.medical_services_outlined)),
              const SizedBox(width: 16),
              Expanded(child: _buildInfoItem(context, 'Próxima Cita', carga['proximaCita'] ?? 'No agendada', Icons.event_outlined)),
            ],
          ),
          if (carga['alertas'].isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFEF4444).withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.warning_amber, color: Color(0xFFEF4444), size: 20),
                      const SizedBox(width: 8),
                      Text('Urgencias (${carga['alertas'].length})', 
                           style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFFEF4444))),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ...carga['alertas'].map<Widget>((alerta) => 
                    Text('• $alerta', style: const TextStyle(fontSize: 12, color: Color(0xFFEF4444)))).toList(),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoItem(BuildContext context, String label, String value, IconData icon) {
    return Container(
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
              Icon(icon, size: 16, color: AppTheme.getTextSecondary(context)),
              const SizedBox(width: 8),
              Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppTheme.getTextSecondary(context))),
            ],
          ),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.getTextPrimary(context))),
        ],
      ),
    );
  }
}