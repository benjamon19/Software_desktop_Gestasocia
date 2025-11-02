import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../../utils/app_theme.dart';
import '../../../../../../controllers/cargas_familiares_controller.dart';

class ExportOptionsDialog {
  static void show(BuildContext context) {
    final CargasFamiliaresController cargasController = Get.find<CargasFamiliaresController>();

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
              'Opciones de Exportación',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppTheme.getTextPrimary(modalContext),
              ),
            ),
            const SizedBox(height: 20),
            
            // --- Opción PDF ---
            ListTile(
              leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
              title: const Text('Exportar a PDF'),
              subtitle: const Text('Informe completo en formato PDF'),
              onTap: () {
                Navigator.pop(modalContext);

                if (!cargasController.hasSelectedCarga) {
                  _showErrorSnackbar('Debes seleccionar una carga para exportar');
                  return;
                }

                _showSuccessSnackbar('Exportación a PDF - Funcionalidad en desarrollo');
              },
            ),

            // --- Opción Excel ---
            ListTile(
              leading: const Icon(Icons.table_chart, color: Colors.green),
              title: const Text('Exportar a Excel'),
              subtitle: const Text('Datos en formato de hoja de cálculo'),
              onTap: () {
                Navigator.pop(modalContext);

                if (!cargasController.hasSelectedCarga) {
                  _showErrorSnackbar('Debes seleccionar una carga para exportar');
                  return;
                }

                _showSuccessSnackbar('Exportación a Excel - Funcionalidad en desarrollo');
              },
            ),
          ],
        ),
      ),
    );
  }

  static void _showSuccessSnackbar(String message) {
    Get.snackbar(
      'Información',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF10B981).withValues(alpha: 0.8),
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );
  }

  static void _showErrorSnackbar(String message) {
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red.withValues(alpha: 0.8),
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );
  }
}