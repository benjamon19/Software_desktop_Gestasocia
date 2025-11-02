import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../../utils/app_theme.dart';
import '../../../../../../controllers/cargas_familiares_controller.dart';

class BackupOptionsDialog {
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
              'Opciones de Backup',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppTheme.getTextPrimary(modalContext),
              ),
            ),
            const SizedBox(height: 20),
            
            ListTile(
              leading: const Icon(Icons.cloud_upload, color: Colors.blue),
              title: const Text('Backup en la Nube'),
              subtitle: const Text('Guardar copia en servidor seguro'),
              onTap: () {
                Navigator.pop(modalContext);
                
                if (!cargasController.hasSelectedCarga) {
                  _showErrorSnackbar('Debes seleccionar una carga para crear backup');
                  return;
                }
                
                _showSuccessSnackbar('Backup en la nube - Funcionalidad en desarrollo');
              },
            ),
            
            ListTile(
              leading: const Icon(Icons.download, color: Colors.purple),
              title: const Text('Backup Local'),
              subtitle: const Text('Descargar archivo de respaldo'),
              onTap: () {
                Navigator.pop(modalContext);
                
                if (!cargasController.hasSelectedCarga) {
                  _showErrorSnackbar('Debes seleccionar una carga para crear backup');
                  return;
                }
                
                _showSuccessSnackbar('Backup local - Funcionalidad en desarrollo');
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