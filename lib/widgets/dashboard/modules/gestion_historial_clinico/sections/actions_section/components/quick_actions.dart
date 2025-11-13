// quick_actions.dart
import 'package:flutter/material.dart';
import '../../../../../../../controllers/historial_clinico_controller.dart';
import '../../../../../../../utils/app_theme.dart';
import '../../../shared/widgets/section_title.dart';
import '../../../shared/widgets/action_button.dart';
import '../../../shared/dialog/export_options_dialog.dart';
import '../../../shared/dialog/edit_historial_dialog.dart';
import '../../../shared/dialog/add_historial_dialog.dart';
import '../../../shared/dialog/add_image_dialog.dart'; 
import '../../../shared/dialog/delete_confirmation_dialog.dart';
import 'patient_link.dart';
import '../../../../../../../models/historial_clinico.dart'; // ← Importa el modelo

class QuickActions extends StatelessWidget {
  final HistorialClinico historial; // ← Ahora es el objeto completo
  final HistorialClinicoController controller;
  final VoidCallback onDeleteHistorial;

  const QuickActions({
    super.key,
    required this.historial,
    required this.controller,
    required this.onDeleteHistorial,
  });

  @override
  Widget build(BuildContext context) {
    // Obtenemos el nombre del paciente usando el controlador (como ya haces en otras partes)
    final pacienteInfo = controller.getPacienteInfoForDisplay(historial);
    final String pacienteNombre = pacienteInfo['nombre'] ?? 'Paciente no encontrado';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- GESTIÓN DE DATOS ---
        const SectionTitle(title: 'Gestión de Datos'),
        const SizedBox(height: 12),

        ActionButton(
          icon: Icons.edit_outlined,
          title: 'Editar Historial',
          subtitle: 'Modificar datos clínicos',
          color: const Color(0xFF3B82F6),
          onPressed: () {
            // Convertimos el historial a Map para el diálogo (si aún lo requiere)
            final historialMap = controller.toDisplayMap(historial);
            EditHistorialDialog.show(context, historialMap);
          },
        ),

        const SizedBox(height: 8),

        ActionButton(
          icon: Icons.add_circle_outline,
          title: 'Crear Otro Historial',
          subtitle: 'Para el mismo paciente',
          color: const Color(0xFF10B981),
          onPressed: () {
            final historialMap = controller.toDisplayMap(historial);
            AddHistorialDialog.show(context, historialMap);
          },
        ),

        const SizedBox(height: 24),

        // --- ACCIONES RÁPIDAS ---
        const SectionTitle(title: 'Acciones Rápidas'),
        const SizedBox(height: 12),

        ActionButton(
          icon: Icons.add_photo_alternate_outlined,
          title: 'Agregar Imagen',
          subtitle: 'Subir radiografía o foto',
          color: Colors.purple,
          onPressed: () {
            AddImageDialog.show(context, historial.id!);
          },
        ),

        const SizedBox(height: 24),

        // --- OPCIONES AVANZADAS ---
        const SectionTitle(title: 'Opciones Avanzadas'),
        const SizedBox(height: 12),

        ActionButton(
          icon: Icons.download,
          title: 'Exportar Datos',
          subtitle: 'Descargar información en PDF',
          color: const Color(0xFF059669),
          onPressed: () {
            ExportOptionsDialog.show(context);
          },
        ),

        const SizedBox(height: 24),

        // --- INFORMACIÓN DEL PACIENTE ---
        PatientLink(historial: controller.toDisplayMap(historial)),

        const SizedBox(height: 24),

        // --- ZONA DE PELIGRO ---
        const SectionTitle(title: 'Zona de Peligro'),
        const SizedBox(height: 12),

        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFEF4444).withValues(alpha: 0.05),
            border: Border.all(
              color: const Color(0xFFEF4444).withValues(alpha: 0.2),
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.warning_amber,
                    color: Color(0xFFEF4444),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Eliminar Historial',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFEF4444),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Esta acción no se puede deshacer. Se eliminarán todos los datos del historial clínico, incluyendo diagnósticos, tratamientos e imágenes asociadas.',
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.getTextSecondary(context),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _showDeleteConfirmation(context, pacienteNombre),
                  icon: const Icon(
                    Icons.delete_outline,
                    size: 18,
                    color: Color(0xFFEF4444),
                  ),
                  label: const Text(
                    'Eliminar Historial',
                    style: TextStyle(
                      color: Color(0xFFEF4444),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFEF4444)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showDeleteConfirmation(BuildContext context, String pacienteNombre) {
    DeleteConfirmationDialog.show(
      context,
      historial: historial,
      pacienteNombre: pacienteNombre,
      onConfirm: onDeleteHistorial,
    );
  }
}