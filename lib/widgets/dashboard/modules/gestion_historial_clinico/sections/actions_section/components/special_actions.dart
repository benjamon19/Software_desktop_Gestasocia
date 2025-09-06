import 'package:flutter/material.dart';
import '../../../../../../../controllers/historial_clinico_controller.dart';
import '../../../shared/widgets/section_title.dart';
import '../../../shared/widgets/action_button.dart';

class SpecialActions extends StatelessWidget {
  final HistorialClinicoController controller;

  const SpecialActions({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle(title: 'Herramientas Clínicas'),
        const SizedBox(height: 12),
        ActionButton(
          icon: Icons.picture_as_pdf,
          title: 'Exportar PDF',
          subtitle: 'Generar reporte clínico',
          color: const Color(0xFFEF4444),
          onPressed: controller.exportHistorial,
        ),
        const SizedBox(height: 8),
        ActionButton(
          icon: Icons.print,
          title: 'Imprimir',
          subtitle: 'Imprimir historial clínico',
          color: const Color(0xFF6B7280),
          onPressed: controller.printHistorial,
        ),
        const SizedBox(height: 8),
        ActionButton(
          icon: Icons.history,
          title: 'Historial Completo',
          subtitle: 'Ver todos los historiales del paciente',
          color: const Color(0xFF10B981),
          onPressed: controller.viewPatientHistory,
        ),
      ],
    );
  }
}