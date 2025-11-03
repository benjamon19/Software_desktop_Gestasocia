import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:gestasocia/utils/app_theme.dart';
import '../../../../../../controllers/cargas_familiares_controller.dart';
import '../../../../../../models/carga_familiar.dart';

class EditCargaDialog {
  static void show(BuildContext context, CargaFamiliar carga) {
    final CargasFamiliaresController controller = Get.find<CargasFamiliaresController>();
    
    // Controladores de texto pre-poblados con los datos actuales
    final nombreController = TextEditingController(text: carga.nombre);
    final apellidoController = TextEditingController(text: carga.apellido);
    final emailController = TextEditingController(text: carga.email ?? '');
    final telefonoController = TextEditingController(text: carga.telefono ?? '');
    final direccionController = TextEditingController(text: carga.direccion ?? '');
    
    // Variables reactivas con valores actuales
    final selectedParentesco = carga.parentesco.obs;
    final selectedDate = Rxn<DateTime>(carga.fechaNacimiento);
    final isLoading = false.obs;

    // Función para actualizar carga
    Future<void> updateCargaAction() async {
      if (_validateFields(
        nombreController.text,
        apellidoController.text,
      )) {
        isLoading.value = true;
        
        // Crear carga actualizada
        final cargaActualizada = carga.copyWith(
          nombre: nombreController.text.trim(),
          apellido: apellidoController.text.trim(),
          parentesco: selectedParentesco.value,
          fechaNacimiento: selectedDate.value ?? carga.fechaNacimiento,
          email: emailController.text.trim(),
          telefono: telefonoController.text.trim(),
          direccion: direccionController.text.trim(),
        );
        
        final success = await controller.updateCarga(cargaActualizada);
        
        isLoading.value = false;
        
        if (success && context.mounted) {
          controller.selectedCarga.refresh();
          Navigator.of(context).pop();
        }
      }
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Focus(
        autofocus: true,
        onKeyEvent: (node, event) {
          if (event is KeyDownEvent) {
            if (event.logicalKey == LogicalKeyboardKey.escape) {
              if (!isLoading.value) {
                Navigator.of(context).pop();
              }
              return KeyEventResult.handled;
            } else if (event.logicalKey == LogicalKeyboardKey.enter) {
              if (!isLoading.value) {
                updateCargaAction();
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
                Icons.edit,
                color: Color(0xFF10B981),
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(
                'Editar Carga Familiar',
                style: TextStyle(
                  color: AppTheme.getTextPrimary(context),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(
                'ESC para cancelar • Enter para actualizar',
                style: TextStyle(
                  color: AppTheme.getTextSecondary(context),
                  fontSize: 12,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: 500,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.getInputBackground(context),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppTheme.getBorderLight(context)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.badge, color: const Color(0xFF10B981)),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'RUT (No editable)',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppTheme.getTextSecondary(context),
                              ),
                            ),
                            Text(
                              carga.rutFormateado,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.getTextPrimary(context),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  Text(
                    'Información Personal',
                    style: TextStyle(
                      color: AppTheme.getTextPrimary(context),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  Row(
                    children: [
                      Expanded(child: _buildTextField(context, 'Nombre', Icons.person, nombreController)),
                      const SizedBox(width: 16),
                      Expanded(child: _buildTextField(context, 'Apellido', Icons.person_outline, apellidoController)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  Row(
                    children: [
                      Expanded(child: _buildDatePicker(context, selectedDate, 'Fecha de Nacimiento')),
                      const SizedBox(width: 16),
                      Expanded(child: Obx(() => _buildDropdown(
                        context, 
                        'Parentesco', 
                        ['Hijo', 'Hija', 'Cónyuge'], 
                        Icons.family_restroom,
                        selectedParentesco,
                      ))),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  Text(
                    'Información de Contacto',
                    style: TextStyle(
                      color: AppTheme.getTextPrimary(context),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  _buildTextField(context, 'Email (Opcional)', Icons.email, emailController),
                  const SizedBox(height: 16),
                  _buildTextField(context, 'Teléfono (Opcional)', Icons.phone, telefonoController),
                  const SizedBox(height: 16),
                  _buildTextField(context, 'Dirección (Opcional)', Icons.location_on, direccionController),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: isLoading.value ? null : () => Navigator.of(context).pop(),
              child: Text(
                'Cancelar',
                style: TextStyle(
                  color: AppTheme.getTextSecondary(context),
                ),
              ),
            ),
            Obx(() => ElevatedButton(
              onPressed: isLoading.value ? null : updateCargaAction,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: isLoading.value 
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text('Actualizar Carga'),
            )),
          ],
        ),
      ),
    );
  }

  static bool _validateFields(String nombre, String apellido) {
    if (nombre.trim().isEmpty) {
      Get.snackbar('Error', 'El nombre es requerido',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error.withValues(alpha: 0.8),
        colorText: Get.theme.colorScheme.onError,
      );
      return false;
    }
    
    if (apellido.trim().isEmpty) {
      Get.snackbar('Error', 'El apellido es requerido',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error.withValues(alpha: 0.8),
        colorText: Get.theme.colorScheme.onError,
      );
      return false;
    }
    
    return true;
  }

  static Widget _buildTextField(BuildContext context, String label, IconData icon, TextEditingController controller) {
    return TextField(
      controller: controller,
      style: TextStyle(color: AppTheme.getTextPrimary(context)),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF10B981)),
        labelStyle: TextStyle(color: AppTheme.getTextSecondary(context)),
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
          borderSide: const BorderSide(color: Color(0xFF10B981), width: 1),
        ),
      ),
    );
  }

  static Widget _buildDatePicker(BuildContext context, Rxn<DateTime> selectedDate, String label) {
    return Obx(() => InkWell(
      onTap: () async {
        final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: selectedDate.value ?? DateTime(2020),
          firstDate: DateTime(1900),
          lastDate: DateTime.now(),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: const Color(0xFF10B981),
                ),
              ),
              child: child!,
            );
          },
        );
        if (picked != null && context.mounted) {
          selectedDate.value = picked;
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        decoration: BoxDecoration(
          border: Border.all(color: AppTheme.getBorderLight(context)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today, color: const Color(0xFF10B981)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                selectedDate.value != null
                    ? '${selectedDate.value!.day.toString().padLeft(2, '0')}/${selectedDate.value!.month.toString().padLeft(2, '0')}/${selectedDate.value!.year}'
                    : label,
                style: TextStyle(
                  color: selectedDate.value != null 
                      ? AppTheme.getTextPrimary(context)
                      : AppTheme.getTextSecondary(context),
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    ));
  }

  static Widget _buildDropdown(BuildContext context, String label, List<String> items, IconData icon, RxString selectedValue) {
    if (!items.contains(selectedValue.value)) {
      selectedValue.value = items.first;
    }
    return SizedBox(
      width: double.infinity,
      child: DropdownButtonFormField<String>(
        initialValue: selectedValue.value,
        items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
        onChanged: (value) {
          if (value != null) {
            selectedValue.value = value;
          }
        },
        style: TextStyle(color: AppTheme.getTextPrimary(context)),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: const Color(0xFF10B981)),
          labelStyle: TextStyle(color: AppTheme.getTextSecondary(context)),
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
            borderSide: const BorderSide(color: Color(0xFF10B981), width: 1),
          ),
        ),
        dropdownColor: AppTheme.getSurfaceColor(context),
        isExpanded: true,
      ),
    );
  }
}