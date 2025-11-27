import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:gestasocia/utils/app_theme.dart';
import '../../../../../../controllers/cargas_familiares_controller.dart';

class BarcodeSearchDialog {
  static void show(BuildContext context) {
    final CargasFamiliaresController controller = Get.find<CargasFamiliaresController>();
    final barcodeController = TextEditingController();
    final isSearching = false.obs;
    final focusNode = FocusNode();

    Future<void> searchByBarcode() async {
      if (barcodeController.text.trim().isEmpty) {
        Get.snackbar(
          'Error',
          'Por favor ingrese o escanee un código de barras',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Get.theme.colorScheme.error.withValues(alpha: 0.8),
          colorText: Get.theme.colorScheme.onError,
        );
        return;
      }

      isSearching.value = true;
      
      await controller.searchCargas(barcodeController.text.trim());
      
      isSearching.value = false;
      
      if (context.mounted) {
        Navigator.of(context).pop();
      }
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      focusNode.requestFocus();
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Focus(
        autofocus: true,
        onKeyEvent: (node, event) {
          if (event is KeyDownEvent) {
            if (event.logicalKey == LogicalKeyboardKey.escape) {
              if (!isSearching.value) {
                focusNode.dispose();
                Navigator.of(context).pop();
              }
              return KeyEventResult.handled;
            }
          }
          return KeyEventResult.ignored;
        },
        child: AlertDialog(
          backgroundColor: AppTheme.getSurfaceColor(context),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Row(
            children: [
              const Icon(
                Icons.qr_code_scanner,
                color: Color(0xFF10B981),
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(
                'Búsqueda de Carga Familiar',
                style: TextStyle(
                  color: AppTheme.getTextPrimary(context),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Escanee el código de barras de la carga familiar con la pistola',
                  style: TextStyle(
                    color: AppTheme.getTextSecondary(context),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 20),
                
                // Campo de texto para el código de barras
                TextField(
                  controller: barcodeController,
                  focusNode: focusNode,
                  autofocus: true,
                  style: TextStyle(
                    color: AppTheme.getTextPrimary(context),
                    fontSize: 16,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Código de Barras de la Carga',
                    hintText: 'Esperando escaneo...',
                    prefixIcon: const Icon(
                      Icons.family_restroom,
                      color: Color(0xFF10B981),
                    ),
                    labelStyle: TextStyle(
                      color: AppTheme.getTextSecondary(context),
                    ),
                    hintStyle: TextStyle(
                      color: AppTheme.getTextSecondary(context).withValues(alpha: 0.7),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: AppTheme.getBorderLight(context)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: AppTheme.getBorderLight(context)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFF10B981), width: 2),
                    ),
                  ),
                  onSubmitted: (_) {
                    if (!isSearching.value) {
                      searchByBarcode();
                    }
                  },
                ),
                
                const SizedBox(height: 16),
                
                // Indicador visual
                Obx(() => Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isSearching.value 
                        ? Colors.orange.withValues(alpha: 0.1)
                        : const Color(0xFF10B981).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSearching.value
                          ? Colors.orange.withValues(alpha: 0.3)
                          : const Color(0xFF10B981).withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isSearching.value ? Icons.hourglass_empty : Icons.info_outline,
                        color: isSearching.value ? Colors.orange : const Color(0xFF10B981),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          isSearching.value 
                              ? 'Buscando carga familiar...'
                              : 'La pistola buscará automáticamente al escanear',
                          style: TextStyle(
                            color: isSearching.value ? Colors.orange : const Color(0xFF10B981),
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: isSearching.value ? null : () {
                focusNode.dispose();
                Navigator.of(context).pop();
              },
              child: Text(
                'Cancelar',
                style: TextStyle(
                  color: AppTheme.getTextSecondary(context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}