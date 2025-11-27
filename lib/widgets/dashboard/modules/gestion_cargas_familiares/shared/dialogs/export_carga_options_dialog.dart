import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../../../utils/app_theme.dart';
import '../../../../../../controllers/cargas_familiares_controller.dart';
import '../../../../../../services/export_carga_service.dart';
import '../../../../../../models/asociado.dart';

class ExportCargaOptionsDialog {
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
              onTap: () async {
                Navigator.pop(modalContext);

                if (!cargasController.hasSelectedCarga) {
                  _showErrorSnackbar('Debes seleccionar una carga familiar para exportar');
                  return;
                }
                
                final carga = cargasController.currentCarga!;
                
                final asociado = await _obtenerAsociadoTitular(carga.asociadoId);
                
                if (asociado == null) {
                  _showErrorSnackbar('No se pudo obtener la información del asociado titular');
                  return;
                }
                
                String? filePath = await FilePicker.platform.saveFile(
                  dialogTitle: 'Guardar PDF como...',
                  fileName: 'carga_${carga.rutFormateado.replaceAll('.', '').replaceAll('-', '')}.pdf',
                  allowedExtensions: ['pdf'],
                  type: FileType.custom,
                );

                if (filePath != null) {
                  try {
                    final success = await ExportCargasService.exportToPDF(
                      asociado, carga, filePath
                    );

                    if (success) {
                      _showSuccessSnackbar('PDF guardado en: $filePath');
                    } else {
                      throw Exception('Error al guardar PDF');
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
                Navigator.pop(modalContext);

                if (!cargasController.hasSelectedCarga) {
                  _showErrorSnackbar('Debes seleccionar una carga familiar para exportar');
                  return;
                }

                final carga = cargasController.currentCarga!;
                
                final asociado = await _obtenerAsociadoTitular(carga.asociadoId);
                
                if (asociado == null) {
                  _showErrorSnackbar('No se pudo obtener la información del asociado titular');
                  return;
                }

                String? filePath = await FilePicker.platform.saveFile(
                  dialogTitle: 'Guardar Excel como...',
                  fileName: 'carga_${carga.rutFormateado.replaceAll('.', '').replaceAll('-', '')}.xlsx',
                  allowedExtensions: ['xlsx'],
                  type: FileType.custom,
                );

                if (filePath != null) {
                  try {
                    final success = await ExportCargasService.exportToExcel(
                      asociado, carga, filePath
                    );
                    
                    if (success) {
                      _showSuccessSnackbar('Excel guardado en: $filePath');
                    } else {
                      throw Exception('Error al guardar Excel');
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

  static Future<Asociado?> _obtenerAsociadoTitular(String asociadoId) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('asociados')
          .doc(asociadoId)
          .get();
      
      if (doc.exists) {
        return Asociado.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

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