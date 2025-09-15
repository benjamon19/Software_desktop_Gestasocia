import 'package:flutter/material.dart';
import '../../../../../../../controllers/historial_clinico_controller.dart';
import '../../../shared/widgets/section_title.dart';
import '../../../shared/widgets/action_button.dart';

class CrudActions extends StatelessWidget {
  final HistorialClinicoController controller;

  const CrudActions({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle(title: 'Gestión del Historial'),
        const SizedBox(height: 12),
        ActionButton(
          icon: Icons.edit,
          title: 'Editar Historial',
          subtitle: 'Modificar información clínica',
          color: const Color(0xFF3B82F6),
          onPressed: controller.editHistorial,
        ),
        const SizedBox(height: 8),
        ActionButton(
          icon: Icons.copy,
          title: 'Duplicar Historial',
          subtitle: 'Crear plantilla basada en este historial',
          color: const Color(0xFF8B5CF6),
          onPressed: controller.duplicateHistorial,
        ),
        const SizedBox(height: 8),
        ActionButton(
          icon: Icons.delete_outline,
          title: 'Eliminar Historial',
          subtitle: 'Remover del historial clínico',
          color: const Color(0xFFEF4444),
          onPressed: controller.deleteHistorial,
        ),
      ],
    );
  }
}