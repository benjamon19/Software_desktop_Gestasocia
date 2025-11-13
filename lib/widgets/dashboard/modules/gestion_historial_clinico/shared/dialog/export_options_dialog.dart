import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import '../../../../../../utils/app_theme.dart';
import '../../../../../../controllers/historial_clinico_controller.dart';
import '../../../../../../services/export_service_historial.dart';

class ExportOptionsDialog {
  static void show(BuildContext context) {
    final HistorialClinicoController controller = Get.find<HistorialClinicoController>();

    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.getSurfaceColor(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (modalContext) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Exportar Historial',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppTheme.getTextPrimary(modalContext),
              ),
            ),
            const SizedBox(height: 20),

            // --- Opción PDF ÚNICA ---
            ListTile(
              leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
              title: const Text('Exportar a PDF'),
              subtitle: const Text('Informe completo en formato PDF'),
              onTap: () async {
                // Cerrar modal
                Navigator.pop(modalContext);

                // Validar selección
                if (!controller.hasSelectedHistorial) {
                  _showErrorSnackbar('Debes seleccionar un historial para exportar.');
                  return;
                }

                final historial = controller.selectedHistorial.value;
                if (historial == null) return;

                // Pedir ubicación para guardar PDF
                String? filePath = await FilePicker.platform.saveFile(
                  dialogTitle: 'Guardar PDF como...',
                  fileName: 'historial_${historial.pacienteId}_${DateTime.now().millisecondsSinceEpoch}.pdf',
                  allowedExtensions: ['pdf'],
                  type: FileType.custom,
                );

                if (filePath != null) {
                  try {
                    bool success = await ExportService.exportHistorialToPDF(historial, filePath);

                    if (success) {
                      _showSuccessSnackbar('PDF guardado en:\n$filePath');
                    } else {
                      _showErrorSnackbar('No se pudo generar el PDF. Inténtalo de nuevo.');
                    }
                  } catch (e) {
                    _showErrorSnackbar('Error inesperado: $e');
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  // --- Helpers ---
  static void _showSuccessSnackbar(String message) {
    Get.snackbar(
      'Éxito',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF059669).withValues(alpha: 204),
      colorText: Colors.white,
      duration: const Duration(seconds: 4),
    );
  }

  static void _showErrorSnackbar(String message) {
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red.withValues(alpha: 204),
      colorText: Colors.white,
      duration: const Duration(seconds: 4),
    );
  }
}