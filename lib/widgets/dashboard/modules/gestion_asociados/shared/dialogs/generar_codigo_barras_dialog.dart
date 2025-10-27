import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:barcode_widget/barcode_widget.dart';
import 'package:screenshot/screenshot.dart';
import 'package:get/get.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../../../utils/app_theme.dart';
import '../../../../../../controllers/asociados_controller.dart';

class GenerarCodigoBarrasDialog {
  static void show(
    BuildContext context, {
    required String asociadoId,
    required String nombreCompleto,
    required String rut,
    String? codigoExistente,
  }) {
    // Si ya tiene código Y NO está vacío, mostrar directamente
    if (codigoExistente != null && codigoExistente.isNotEmpty) {
      _showBarcodeViewer(
        context,
        nombreCompleto: nombreCompleto,
        rut: rut,
        codigoBarras: codigoExistente,
      );
    } else {
      // Si no tiene código, preguntar si quiere generar
      _showConfirmationDialog(
        context,
        asociadoId: asociadoId,
        nombreCompleto: nombreCompleto,
        rut: rut,
      );
    }
  }

  // Dialog de confirmación para generar código nuevo
  static void _showConfirmationDialog(
    BuildContext context, {
    required String asociadoId,
    required String nombreCompleto,
    required String rut,
  }) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.getSurfaceColor(context),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: Row(
          children: [
            Icon(
              Icons.info_outline,
              color: AppTheme.primaryColor,
              size: 28,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Generar Código de Barras',
                style: TextStyle(
                  color: AppTheme.getTextPrimary(context),
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '¿Desea generar un código de barras único para este asociado?',
              style: TextStyle(
                color: AppTheme.getTextPrimary(context),
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppTheme.primaryColor.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: AppTheme.primaryColor,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'El código será único y permanente. Esta acción solo se puede realizar una vez.',
                      style: TextStyle(
                        color: AppTheme.getTextPrimary(context),
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancelar',
              style: TextStyle(
                color: AppTheme.getTextSecondary(context),
              ),
            ),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              // NO cerrar el dialog todavía
              final navigator = Navigator.of(context);
              
              // Generar código
              final String codigoBarras = _generateUniqueBarcode(rut);
              
              // Guardar en Firebase
              final controller = Get.find<AsociadosController>();
              final success = await controller.updateAsociadoBarcode(asociadoId, codigoBarras);
              
              if (success) {
                // Cerrar dialog de confirmación
                navigator.pop();
                
                // Pequeño delay para asegurar que se cerró el anterior
                await Future.delayed(const Duration(milliseconds: 100));
                
                // MOSTRAR INMEDIATAMENTE el código generado
                if (context.mounted) {
                  _showBarcodeViewer(
                    context,
                    nombreCompleto: nombreCompleto,
                    rut: rut,
                    codigoBarras: codigoBarras,
                  );
                }
              } else {
                // Mostrar error
                Get.snackbar(
                  'Error',
                  'No se pudo generar el código de barras',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Get.theme.colorScheme.error.withValues(alpha: 0.8),
                  colorText: Get.theme.colorScheme.onError,
                  margin: const EdgeInsets.all(16),
                  borderRadius: 8,
                );
              }
            },
            icon: const Icon(Icons.check, size: 18),
            label: const Text('Generar Código'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Visualizador del código de barras
  static void _showBarcodeViewer(
    BuildContext context, {
    required String nombreCompleto,
    required String rut,
    required String codigoBarras,
  }) {
    final ScreenshotController screenshotController = ScreenshotController();

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => StatefulBuilder(
        builder: (builderContext, setState) {
          bool isDownloading = false;

          Future<void> downloadBarcode() async {
            if (isDownloading) return;
            
            setState(() {
              isDownloading = true;
            });

            try {
              // Esperar un poco para que el widget esté renderizado
              await Future.delayed(const Duration(milliseconds: 300));
              
              final Uint8List? imageBytes = await screenshotController.capture(
                pixelRatio: 3.0,
              );
              
              if (imageBytes == null) {
                throw Exception('Error al capturar la imagen');
              }

              final String fileName = 'codigo_barras_${rut.replaceAll(RegExp(r'[^0-9]'), '')}.png';

              // Detectar plataforma correctamente
              if (!kIsWeb) {
                if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
                  // ESCRITORIO: Guardar en Documentos
                  final directory = await getApplicationDocumentsDirectory();
                  final String path = '${directory.path}/$fileName';
                  final File file = File(path);
                  await file.writeAsBytes(imageBytes);

                  if (builderContext.mounted) {
                    Get.snackbar(
                      'Éxito',
                      'Imagen guardada correctamente',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: const Color(0xFF059669).withValues(alpha: 0.8),
                      colorText: Colors.white,
                      margin: const EdgeInsets.all(16),
                      borderRadius: 8,
                      duration: const Duration(seconds: 4),
                      mainButton: TextButton(
                        onPressed: () {
                          try {
                            if (Platform.isWindows) {
                              Process.run('explorer', ['/select,', path]);
                            } else if (Platform.isMacOS) {
                              Process.run('open', ['-R', path]);
                            } else if (Platform.isLinux) {
                              Process.run('xdg-open', [directory.path]);
                            }
                          } catch (_) {
                            // Error al abrir carpeta, no hacer nada
                          }
                        },
                        child: const Text(
                          'Abrir carpeta',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                        ),
                      ),
                    );
                  }
                } else if (Platform.isAndroid || Platform.isIOS) {
                  // MÓVIL: Usar share
                  final tempDir = await getTemporaryDirectory();
                  final String tempPath = '${tempDir.path}/$fileName';
                  final File tempFile = File(tempPath);
                  await tempFile.writeAsBytes(imageBytes);

                  await Share.shareXFiles(
                    [XFile(tempPath)],
                    text: 'Código de barras de $nombreCompleto',
                  );

                  if (builderContext.mounted) {
                    Get.snackbar(
                      'Compartir',
                      'Selecciona "Guardar en archivos" o "Guardar en galería"',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: const Color(0xFF059669).withValues(alpha: 0.8),
                      colorText: Colors.white,
                      margin: const EdgeInsets.all(16),
                      borderRadius: 8,
                      duration: const Duration(seconds: 3),
                    );
                  }
                }
              } else {
                throw Exception('La descarga en navegador no está implementada');
              }
            } catch (e) {
              if (builderContext.mounted) {
                Get.snackbar(
                  'Error',
                  'No se pudo guardar la imagen: ${e.toString()}',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Get.theme.colorScheme.error.withValues(alpha: 0.8),
                  colorText: Get.theme.colorScheme.onError,
                  margin: const EdgeInsets.all(16),
                  borderRadius: 8,
                  duration: const Duration(seconds: 4),
                );
              }
            } finally {
              if (builderContext.mounted) {
                setState(() {
                  isDownloading = false;
                });
              }
            }
          }

          return AlertDialog(
            backgroundColor: AppTheme.getSurfaceColor(builderContext),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            title: Row(
              children: [
                const Icon(
                  Icons.qr_code_2,
                  color: Color(0xFF8B5CF6),
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Código de Barras',
                    style: TextStyle(
                      color: AppTheme.getTextPrimary(builderContext),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Screenshot(
                    controller: screenshotController,
                    child: Container(
                      width: 360,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 24),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  AppTheme.primaryColor,
                                  AppTheme.primaryColor.withValues(alpha: 0.8),
                                ],
                              ),
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(16),
                                topRight: Radius.circular(16),
                              ),
                            ),
                            child: Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.business,
                                    color: Colors.white,
                                    size: 40,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                const Text(
                                  'GestAsocia',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'Sistema de Gestión',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.white,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              children: [
                                Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryColor.withValues(alpha: 0.1),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: AppTheme.primaryColor.withValues(alpha: 0.3),
                                      width: 3,
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.person,
                                    size: 40,
                                    color: AppTheme.primaryColor,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Text(
                                  nombreCompleto,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    'RUT: $rut',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.black54,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 32),
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[50],
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.grey[300]!,
                                      width: 1,
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      BarcodeWidget(
                                        barcode: Barcode.code128(),
                                        data: codigoBarras,
                                        width: 280,
                                        height: 80,
                                        drawText: false,
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        codigoBarras,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontFamily: 'monospace',
                                          color: Colors.black87,
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 1.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 24),
                                Text(
                                  'Generado: ${_formatDate(DateTime.now())}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Colors.black45,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: Text(
                  'Cerrar',
                  style: TextStyle(
                    color: AppTheme.getTextSecondary(builderContext),
                  ),
                ),
              ),
              ElevatedButton.icon(
                onPressed: isDownloading ? null : downloadBarcode,
                icon: isDownloading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.download, size: 18),
                label: Text(isDownloading ? 'Guardando...' : 'Descargar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF059669),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  static String _generateUniqueBarcode(String rut) {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString().substring(5);
    final rutNumeros = rut.replaceAll(RegExp(r'[^0-9]'), '');
    final rutCorto = rutNumeros.length >= 4 ? rutNumeros.substring(0, 4) : rutNumeros;
    return 'GESTA$rutCorto$timestamp';
  }

  static String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
           '${date.month.toString().padLeft(2, '0')}/'
           '${date.year} ${date.hour.toString().padLeft(2, '0')}:'
           '${date.minute.toString().padLeft(2, '0')}';
  }
}