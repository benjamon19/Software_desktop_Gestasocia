import 'package:flutter/material.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:screenshot/screenshot.dart';
import 'package:get/get.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../../../utils/app_theme.dart';
import '../../../../../../controllers/cargas_familiares_controller.dart';
import '../../../../../../controllers/asociados_controller.dart';

class GenerarCodigoBarrasCargaDialog {
  static void show(
    BuildContext context, {
    required String cargaId,
    required String nombreCompleto,
    required String rut,
    required String asociadoSap,
    String? codigoExistente,
  }) {

    final bool tieneCodigoBarras = codigoExistente != null && codigoExistente.trim().isNotEmpty;
    
    if (tieneCodigoBarras) {
      _showBarcodeViewer(
        context,
        cargaId: cargaId,
        nombreCompleto: nombreCompleto,
        rut: rut,
        asociadoSap: asociadoSap,
        codigoBarras: codigoExistente,
      );
    } else {
      _showConfirmationDialog(
        context,
        cargaId: cargaId,
        nombreCompleto: nombreCompleto,
        rut: rut,
        asociadoSap: asociadoSap,
      );
    }
  }

  static void _showConfirmationDialog(
    BuildContext context, {
    required String cargaId,
    required String nombreCompleto,
    required String rut,
    required String asociadoSap,
  }) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.getSurfaceColor(context),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Row(
          children: [
            const Icon(Icons.info_outline, color: Color(0xFF10B981), size: 28),
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
              '¿Desea generar un código de barras único para esta carga familiar?',
              style: TextStyle(color: AppTheme.getTextPrimary(context), fontSize: 15),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, color: Color(0xFF10B981), size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'El código será único y permanente. Esta acción solo se puede realizar una vez.',
                      style: TextStyle(color: AppTheme.getTextPrimary(context), fontSize: 13),
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
            child: Text('Cancelar', style: TextStyle(color: AppTheme.getTextSecondary(context))),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              final navigator = Navigator.of(context);
              final String codigoBarras = _generateUniqueBarcode(rut);
              final controller = Get.find<CargasFamiliaresController>();
              final success = await controller.updateCargaBarcode(cargaId, codigoBarras);

              if (success) {
                navigator.pop();
                await Future.delayed(const Duration(milliseconds: 100));
                if (context.mounted) {
                  _showBarcodeViewer(
                    context,
                    cargaId: cargaId,
                    nombreCompleto: nombreCompleto,
                    rut: rut,
                    asociadoSap: asociadoSap,
                    codigoBarras: codigoBarras,
                  );
                }
              } else {
                Get.snackbar('Error', 'No se pudo generar el código de barras');
              }
            },
            icon: const Icon(Icons.check, size: 18),
            label: const Text('Generar Código'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ],
      ),
    );
  }

  static void _showBarcodeViewer(
    BuildContext context, {
    required String cargaId,
    required String nombreCompleto,
    required String rut,
    required String asociadoSap,
    required String codigoBarras,
  }) {
    final ScreenshotController screenshotController = ScreenshotController();

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => StatefulBuilder(
        builder: (builderContext, setState) {
          bool isDownloading = false;
          bool isSharing = false;

          // --- MÉTODO DESCARGAR ---
          Future<void> downloadBarcode() async {
            if (isDownloading) return;
            setState(() => isDownloading = true);

            try {
              await Future.delayed(const Duration(milliseconds: 300));
              final Uint8List? imageBytes = await screenshotController.capture(pixelRatio: 3.0);
              if (imageBytes == null) throw Exception('Error al capturar');

              final String fileName = 'codigo_barras_carga_${rut.replaceAll(RegExp(r'[^0-9]'), '')}.png';
              
              String? filePath = await FilePicker.platform.saveFile(
                dialogTitle: 'Guardar Código de Barras...',
                fileName: fileName,
                allowedExtensions: ['png'],
                type: FileType.custom,
              );

              if (filePath != null) {
                final File file = File(filePath);
                await file.writeAsBytes(imageBytes);
                if (builderContext.mounted) {
                  Get.snackbar(
                    'Éxito', 'Imagen guardada correctamente',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: const Color(0xFF10B981).withValues(alpha: 0.8),
                    colorText: Colors.white,
                    margin: const EdgeInsets.all(16),
                    borderRadius: 8,
                    duration: const Duration(seconds: 4),
                  );
                }
              }
            } catch (e) {
              Get.snackbar('Error', 'No se pudo guardar: $e');
            } finally {
              if (builderContext.mounted) setState(() => isDownloading = false);
            }
          }

          // --- MÉTODO ENVIAR WHATSAPP ---
          Future<void> shareWhatsappAction() async {
            if (isSharing) return;
            setState(() => isSharing = true);

            try {
              String? telefono;
              final cargasController = Get.find<CargasFamiliaresController>();
              final carga = cargasController.getCargaById(cargaId);
              
              if (carga != null) {
                telefono = carga.telefono;
                if (telefono == null || telefono.isEmpty) {
                  final asociadosController = Get.find<AsociadosController>();
                  final asociado = asociadosController.getAsociadoById(carga.asociadoId);
                  telefono = asociado?.telefono;
                }
              }

              if (telefono == null || telefono.isEmpty) {
                Get.snackbar('Atención', 'No hay teléfono registrado para enviar el mensaje',
                  backgroundColor: Colors.orange.withValues(alpha: 0.8), 
                  colorText: Colors.white,
                  snackPosition: SnackPosition.BOTTOM,
                  margin: const EdgeInsets.all(16),
                  borderRadius: 8,
                );
                return;
              }

              await Future.delayed(const Duration(milliseconds: 300));
              final Uint8List? imageBytes = await screenshotController.capture(pixelRatio: 3.0);
              
              if (imageBytes == null) {
                Get.snackbar('Error', 'No se pudo generar la imagen');
                return;
              }

              final String fileName = 'carnet_${rut.replaceAll(RegExp(r'[^0-9]'), '')}.png';
              String? filePath = await FilePicker.platform.saveFile(
                dialogTitle: 'Guardar Carnet para WhatsApp...',
                fileName: fileName,
                allowedExtensions: ['png'],
                type: FileType.custom,
              );

              if (filePath == null) {
                return; 
              }

              final File file = File(filePath);
              await file.writeAsBytes(imageBytes);

              String phone = telefono.replaceAll(RegExp(r'[^0-9]'), '');
              if (phone.length == 9 && !phone.startsWith('56')) phone = '56$phone';

              final String mensaje = Uri.encodeComponent(
                'Hola, le adjuntamos su carnet digital de carga familiar.\n\n'
                'Paciente: $nombreCompleto\n'
                'RUT: $rut\n\n'
                'Por favor guarde esta imagen para presentarla en sus próximas visitas.'
              );

              final Uri url = Uri.parse("https://wa.me/$phone?text=$mensaje");

              if (await canLaunchUrl(url)) {
                await launchUrl(url, mode: LaunchMode.externalApplication);
                
                // 5. Notificación estilo UNIFICADO
                Get.snackbar(
                  'WhatsApp Abierto', 
                  'Imagen guardada en: $filePath\n\nPor favor arrástrela al chat.',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: const Color(0xFF25D366),
                  colorText: Colors.white,
                  margin: const EdgeInsets.all(16),
                  borderRadius: 8,
                  duration: const Duration(seconds: 6),
                  icon: const Icon(Icons.attach_file, color: Colors.white),
                );
              } else {
                Get.snackbar('Error', 'No se pudo abrir WhatsApp');
              }

            } catch (e) {
              Get.snackbar('Error', 'Ocurrió un problema: $e');
            } finally {
              if (builderContext.mounted) setState(() => isSharing = false);
            }
          }

          return AlertDialog(
            backgroundColor: AppTheme.getSurfaceColor(builderContext),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            title: Row(
              children: [
                const Icon(Icons.qr_code_2, color: Color(0xFF10B981), size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Código de Barras - Carga Familiar',
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
                          // Header
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 24),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  const Color(0xFF10B981),
                                  const Color(0xFF10B981).withValues(alpha: 0.8),
                                ],
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
                                  child: Image.asset(
                                    'assets/images/gestasocia_icon.png',
                                    width: 40,
                                    height: 40,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                const Text(
                                  'GestAsocia',
                                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1.2),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'Carga Familiar',
                                  style: TextStyle(fontSize: 12, color: Colors.white, letterSpacing: 0.5),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              children: [
                                Container(
                                  width: 80, height: 80,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF10B981).withValues(alpha: 0.1),
                                    shape: BoxShape.circle,
                                    border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.3), width: 3),
                                  ),
                                  child: const Icon(Icons.family_restroom, size: 40, color: Color(0xFF10B981)),
                                ),
                                const SizedBox(height: 20),
                                Text(nombreCompleto, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87), textAlign: TextAlign.center),
                                const SizedBox(height: 12),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF10B981).withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.3), width: 1),
                                  ),
                                  child: Text('Asociado SAP: $asociadoSap', style: const TextStyle(fontSize: 14, color: Color(0xFF10B981), fontWeight: FontWeight.w600)),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                  decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(20)),
                                  child: Text('RUT: $rut', style: const TextStyle(fontSize: 14, color: Colors.black54, fontWeight: FontWeight.w500)),
                                ),
                                const SizedBox(height: 32),
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[50], borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.grey[300]!, width: 1),
                                  ),
                                  child: Column(
                                    children: [
                                      BarcodeWidget(barcode: Barcode.code128(), data: codigoBarras, width: 280, height: 80, drawText: false),
                                      const SizedBox(height: 12),
                                      Text(codigoBarras, style: const TextStyle(fontSize: 13, fontFamily: 'monospace', color: Colors.black87, fontWeight: FontWeight.w600, letterSpacing: 1.5)),
                                    ],
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
                child: Text('Cerrar', style: TextStyle(color: AppTheme.getTextSecondary(builderContext))),
              ),
              ElevatedButton.icon(
                onPressed: isSharing ? null : shareWhatsappAction,
                icon: isSharing 
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.send_to_mobile, size: 18),
                label: const Text('Enviar por WhatsApp'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF25D366),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              ElevatedButton.icon(
                onPressed: isDownloading ? null : downloadBarcode,
                icon: isDownloading
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.download, size: 18),
                label: const Text('Descargar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
    return 'CARGA$rutCorto$timestamp';
  }
}