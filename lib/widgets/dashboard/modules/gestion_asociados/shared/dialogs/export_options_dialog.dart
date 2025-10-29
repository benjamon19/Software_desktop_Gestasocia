import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart'; // Asegúrate de tener este paquete

import '../../../../../../utils/app_theme.dart';
import '../../../../../../controllers/asociados_controller.dart';
import '../../../../../../services/export_service.dart';

class ExportOptionsDialog {
  static void show(BuildContext context) {
    // Obtenemos el controller aquí
    final AsociadosController asociadosController = Get.find<AsociadosController>();

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
              onTap: () async {
                // 1. Cerrar el modal
                Navigator.pop(modalContext);

                // 2. Validar selección
                if (!asociadosController.hasSelectedAsociado) {
                  _showErrorSnackbar('Debes seleccionar un asociado para exportar');
                  return;
                }
                
                final asociado = asociadosController.currentAsociado!;
                
                // 3. Pedir al usuario dónde guardar
                String? filePath = await FilePicker.platform.saveFile(
                  dialogTitle: 'Guardar PDF como...',
                  fileName: 'asociado_${asociado.rut}.pdf',
                  allowedExtensions: ['pdf'],
                  type: FileType.custom,
                );

                // 4. Si el usuario seleccionó una ruta, exportar
                if (filePath != null) {
                  try {
                    final cargas = asociadosController.cargasFamiliares
                        .where((c) => c.asociadoId == asociado.id)
                        .toList();
                    
                    final success = await ExportService.exportToPDF(asociado, cargas, filePath);

                    if (success) {
                      _showSuccessSnackbar('PDF guardado en: $filePath');
                    } else {
                      // El error específico se imprimirá desde el ExportService
                      throw Exception('Error desconocido al guardar PDF');
                    }
                  } catch (e) {
                    _showErrorSnackbar('Error al exportar PDF: $e');
                  }
                }
              },
            ),

            // --- Opción Excel ---
            ListTile(
              leading: const Icon(Icons.table_chart, color: Colors.green),
              title: const Text('Exportar a Excel'),
              subtitle: const Text('Datos en formato de hoja de cálculo'),
              onTap: () async {
                // 1. Cerrar el modal
                Navigator.pop(modalContext);

                // 2. Validar selección
                if (!asociadosController.hasSelectedAsociado) {
                  _showErrorSnackbar('Debes seleccionar un asociado para exportar');
                  return;
                }

                final asociado = asociadosController.currentAsociado!;

                // 3. Pedir al usuario dónde guardar
                String? filePath = await FilePicker.platform.saveFile(
                  dialogTitle: 'Guardar Excel como...',
                  fileName: 'asociado_${asociado.rut}.xlsx',
                  allowedExtensions: ['xlsx'],
                  type: FileType.custom,
                );

                // 4. Si el usuario seleccionó una ruta, exportar
                if (filePath != null) {
                  try {
                    final cargas = asociadosController.cargasFamiliares
                        .where((c) => c.asociadoId == asociado.id)
                        .toList();

                    final success = await ExportService.exportToExcel(asociado, cargas, filePath);
                    
                    if (success) {
                      _showSuccessSnackbar('Excel guardado en: $filePath');
                    } else {
                      throw Exception('Error desconocido al guardar Excel');
                    }
                  } catch (e) {
                    _showErrorSnackbar('Error al exportar Excel: $e');
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  // --- Helpers para Snackbars ---

  static void _showSuccessSnackbar(String message) {
    Get.snackbar(
      'Éxito',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF059669).withValues(alpha: 204), // 0.8 opacidad
      colorText: Colors.white,
      duration: const Duration(seconds: 4),
    );
  }

  static void _showErrorSnackbar(String message) {
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red.withValues(alpha: 204), // 0.8 opacidad
      colorText: Colors.white,
      duration: const Duration(seconds: 4),
    );
  }
}