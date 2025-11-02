import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:gestasocia/utils/app_theme.dart';
import '../../../../../../controllers/asociados_controller.dart';
import '../../../../../../models/asociado.dart';

class EditAsociadoDialog {
  static void show(BuildContext context, Asociado asociado) {
    final AsociadosController controller = Get.find<AsociadosController>();
    
    // Controladores de texto pre-poblados con los datos actuales
    final nombreController = TextEditingController(text: asociado.nombre);
    final apellidoController = TextEditingController(text: asociado.apellido);
    final emailController = TextEditingController(text: asociado.email);
    final telefonoController = TextEditingController(text: asociado.telefono);
    final direccionController = TextEditingController(text: asociado.direccion);
    
    // Variables reactivas con valores actuales
    final selectedEstadoCivil = asociado.estadoCivil.obs;
    final selectedPlan = asociado.plan.obs;
    final selectedDate = Rxn<DateTime>(asociado.fechaNacimiento);
    final isLoading = false.obs;

    // Función para actualizar asociado
    Future<void> updateAsociadoAction() async {
      // Validar campos requeridos
      if (_validateFields(
        nombreController.text,
        apellidoController.text,
        emailController.text,
        telefonoController.text,
        direccionController.text,
      )) {
        isLoading.value = true;
        
        // Crear asociado actualizado
        final asociadoActualizado = asociado.copyWith(
          nombre: nombreController.text.trim(),
          apellido: apellidoController.text.trim(),
          email: emailController.text.trim(),
          telefono: telefonoController.text.trim(),
          direccion: direccionController.text.trim(),
          estadoCivil: selectedEstadoCivil.value,
          plan: selectedPlan.value,
          fechaNacimiento: selectedDate.value ?? asociado.fechaNacimiento,
        );
        
        final success = await controller.updateAsociado(asociadoActualizado);
        
        isLoading.value = false;
        
        if (success && context.mounted) {
          // Forzar actualización inmediata del UI
          controller.selectedAsociado.refresh();
          // También actualizar la búsqueda para forzar refresh
          controller.searchQuery.refresh();
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
          // Manejar teclas ESC y Enter
          if (event is KeyDownEvent) {
            if (event.logicalKey == LogicalKeyboardKey.escape) {
              if (!isLoading.value) {
                Navigator.of(context).pop();
              }
              return KeyEventResult.handled;
            } else if (event.logicalKey == LogicalKeyboardKey.enter) {
              if (!isLoading.value) {
                updateAsociadoAction();
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
                color: Color(0xFF3B82F6),
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(
                'Editar Asociado',
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
                  // Mostrar RUT (solo lectura)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.getInputBackground(context),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppTheme.getBorderLight(context)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.badge, color: AppTheme.primaryColor),
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
                              asociado.rut,
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
                  
                  // Información Personal
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
                        'Estado Civil', 
                        ['Soltero', 'Casado', 'Viudo'], 
                        Icons.favorite,
                        selectedEstadoCivil,
                      ))),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Información de Contacto
                  Text(
                    'Información de Contacto',
                    style: TextStyle(
                      color: AppTheme.getTextPrimary(context),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  _buildTextField(context, 'Email', Icons.email, emailController),
                  const SizedBox(height: 16),
                  _buildTextField(context, 'Teléfono', Icons.phone, telefonoController),
                  const SizedBox(height: 16),
                  _buildTextField(context, 'Dirección', Icons.location_on, direccionController),
                  
                  const SizedBox(height: 24),
                  
                  // Plan
                  Text(
                    'Plan de Membresía',
                    style: TextStyle(
                      color: AppTheme.getTextPrimary(context),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  Obx(() => _buildDropdown(
                    context, 
                    'Plan', 
                    ['Asociado', 'VIP'], 
                    Icons.card_membership,
                    selectedPlan,
                  )),
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
              onPressed: isLoading.value ? null : updateAsociadoAction,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
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
                : const Text('Actualizar Asociado'),
            )),
          ],
        ),
      ),
    );
  }

  static bool _validateFields(
    String nombre,
    String apellido, 
    String email,
    String telefono,
    String direccion,
  ) {
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
    
    if (email.trim().isEmpty) {
      Get.snackbar('Error', 'El email es requerido',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error.withValues(alpha: 0.8),
        colorText: Get.theme.colorScheme.onError,
      );
      return false;
    }
    
    // Validar formato de email
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email.trim())) {
      Get.snackbar('Error', 'El formato del email no es válido',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error.withValues(alpha: 0.8),
        colorText: Get.theme.colorScheme.onError,
      );
      return false;
    }
    
    if (telefono.trim().isEmpty) {
      Get.snackbar('Error', 'El teléfono es requerido',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error.withValues(alpha: 0.8),
        colorText: Get.theme.colorScheme.onError,
      );
      return false;
    }
    
    if (direccion.trim().isEmpty) {
      Get.snackbar('Error', 'La dirección es requerida',
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
        prefixIcon: Icon(icon, color: AppTheme.primaryColor),
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
          borderSide: BorderSide(color: AppTheme.primaryColor, width: 1),
        ),
      ),
    );
  }

  static Widget _buildDatePicker(BuildContext context, Rxn<DateTime> selectedDate, String label) {
    return Obx(() => InkWell(
      onTap: () async {
        final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: selectedDate.value ?? DateTime(1990),
          firstDate: DateTime(1900),
          lastDate: DateTime.now(),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: AppTheme.primaryColor,
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
            Icon(Icons.calendar_today, color: AppTheme.primaryColor),
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
          prefixIcon: Icon(icon, color: AppTheme.primaryColor),
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
            borderSide: BorderSide(color: AppTheme.primaryColor, width: 1),
          ),
        ),
        dropdownColor: AppTheme.getSurfaceColor(context),
        isExpanded: true,
      ),
    );
  }
}