import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../../../utils/app_theme.dart';
import '../../../../../../controllers/historial_clinico_controller.dart';
import '../../../../../../models/historial_clinico.dart';

class AddImageDialog {
  static void show(BuildContext context, String historialId) {
    final controller = Get.find<HistorialClinicoController>();
    final Rxn<File> selectedImage = Rxn<File>();
    final RxBool isUploading = false.obs;

    Future<void> pickImage() async {
      try {
        FilePickerResult? result = await FilePicker.platform.pickFiles(
          type: FileType.image,
          allowMultiple: false,
        );

        if (result == null || result.files.isEmpty) {
          Get.log('Usuario canceló la selección');
          return;
        }

        final filePath = result.files.first.path;
        if (filePath == null) {
          Get.snackbar(
            'Error',
            'No se pudo acceder al archivo',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red.withValues(alpha: 0.8),
            colorText: Colors.white,
          );
          return;
        }

        final imageFile = File(filePath);
        Get.log('Archivo seleccionado: $filePath');

        final fileSize = await imageFile.length();
        if (fileSize > 10 * 1024 * 1024) {
          Get.snackbar(
            'Error',
            'La imagen no debe superar 10MB',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red.withValues(alpha: 0.8),
            colorText: Colors.white,
          );
          return;
        }

        selectedImage.value = imageFile;
      } catch (e) {
        Get.log('Error seleccionando imagen: $e');
        Get.snackbar(
          'Error',
          'No se pudo seleccionar la imagen',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withValues(alpha: 0.8),
          colorText: Colors.white,
        );
      }
    }

    Future<void> uploadImage(BuildContext innerContext) async {
      if (selectedImage.value == null) {
        Get.snackbar(
          'Error',
          'Selecciona una imagen primero',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withValues(alpha: 0.8),
          colorText: Colors.white,
        );
        return;
      }

      final bool wasMounted = innerContext.mounted;
      if (!wasMounted) return;

      isUploading.value = true;

      try {
        final success = await controller.uploadImagenHistorial(
          historialId,
          selectedImage.value!,
        );

        if (success) {
          if (controller.selectedHistorial.value?.id == historialId) {
            try {
              final doc = await FirebaseFirestore.instance
                  .collection('historiales_clinicos')
                  .doc(historialId)
                  .get();
              if (doc.exists) {
                final updated = HistorialClinico.fromMap(doc.data()!, doc.id);
                controller.selectedHistorial.value = updated;
              }
            } catch (e) {
              Get.log('Error al refrescar historial: $e');
            }
          }

          if (wasMounted && innerContext.mounted) {
            Navigator.of(innerContext).pop();
          }
        }
      } catch (e) {
        Get.log('Error subiendo imagen: $e');
      } finally {
        if (wasMounted && innerContext.mounted) {
          isUploading.value = false;
        }
      }
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Builder(
        builder: (innerContext) {
          return Focus(
            autofocus: true,
            onKeyEvent: (node, event) {
              if (event is KeyDownEvent) {
                if (event.logicalKey == LogicalKeyboardKey.escape) {
                  if (!isUploading.value && innerContext.mounted) {
                    Navigator.of(innerContext).pop();
                  }
                  return KeyEventResult.handled;
                } else if (event.logicalKey == LogicalKeyboardKey.enter) {
                  if (!isUploading.value && selectedImage.value != null) {
                    uploadImage(innerContext);
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
                    Icons.add_photo_alternate_outlined,
                    color: Colors.purple,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Agregar Imagen',
                    style: TextStyle(
                      color: AppTheme.getTextPrimary(context),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Obx(() => Text(
                    isUploading.value 
                        ? 'Subiendo...' 
                        : 'ESC para cancelar${selectedImage.value != null ? " • Enter para subir" : ""}',
                    style: TextStyle(
                      color: AppTheme.getTextSecondary(context),
                      fontSize: 12,
                      fontWeight: FontWeight.normal,
                    ),
                  )),
                ],
              ),
              content: SizedBox(
                width: 500,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Sube radiografías, fotos intraorales u otros archivos médicos',
                        style: TextStyle(
                          color: AppTheme.getTextSecondary(context),
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      Obx(() {
                        if (isUploading.value) {
                          return Center(
                            child: Container(
                              height: 300,
                              width: 350,
                              decoration: BoxDecoration(
                                color: AppTheme.getInputBackground(context),
                                border: Border.all(
                                  color: AppTheme.getBorderLight(context),
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.purple),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'Subiendo imagen...',
                                      style: TextStyle(
                                        color: AppTheme.getTextSecondary(context),
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }
                        if (selectedImage.value != null) {
                          return Center(
                            child: Column(
                              children: [
                                Container(
                                  constraints: const BoxConstraints(
                                    maxHeight: 300,
                                    maxWidth: 350,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppTheme.getInputBackground(context),
                                    border: Border.all(
                                      color: Colors.purple.withValues(alpha: 0.3),
                                      width: 2,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.file(
                                      selectedImage.value!,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.check_circle,
                                      color: Colors.purple,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Imagen lista para subir',
                                      style: TextStyle(
                                        color: Colors.purple,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                TextButton.icon(
                                  onPressed: () => selectedImage.value = null,
                                  icon: const Icon(Icons.refresh, size: 18),
                                  label: const Text('Cambiar imagen'),
                                  style: TextButton.styleFrom(
                                    foregroundColor: AppTheme.getTextSecondary(context),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                        return Center(
                          child: InkWell(
                            onTap: pickImage,
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              width: 350,
                              height: 250,
                              decoration: BoxDecoration(
                                color: AppTheme.getInputBackground(context),
                                border: Border.all(
                                  color: AppTheme.getBorderLight(context),
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      color: Colors.purple.withValues(alpha: 0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.cloud_upload_outlined,
                                      color: Colors.purple,
                                      size: 56,
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  Text(
                                    'Haz clic para seleccionar archivo',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.getTextPrimary(context),
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.purple.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.purple.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.info_outline,
                              size: 18,
                              color: Colors.purple,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Formatos: JPG, PNG, GIF, WEBP • Máximo 10 MB',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.getTextSecondary(context),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actionsAlignment: MainAxisAlignment.end,
              actions: [
                Obx(() => TextButton(
                  onPressed: isUploading.value 
                      ? null 
                      : () {
                          if (innerContext.mounted) {
                            Navigator.of(innerContext).pop();
                          }
                        },
                  child: Text(
                    'Cancelar',
                    style: TextStyle(
                      color: isUploading.value 
                          ? AppTheme.getTextSecondary(context).withValues(alpha: 0.5)
                          : AppTheme.getTextSecondary(context),
                    ),
                  ),
                )),
                Obx(() => ElevatedButton(
                  onPressed: (isUploading.value || selectedImage.value == null) 
                      ? null 
                      : () => uploadImage(innerContext),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isUploading.value 
                        ? Colors.grey 
                        : Colors.purple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text(isUploading.value ? 'Subiendo...' : 'Subir Imagen'),
                )),
              ],
            ),
          );
        },
      ),
    );
  }
}