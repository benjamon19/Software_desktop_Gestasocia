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
      // Validar campos antes de enviar
      if (_validateFields(
        nombreController.text,
        apellidoController.text,
        emailController.text,
        telefonoController.text,
        direccionController.text,
        selectedDate.value,
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
          fechaNacimiento: selectedDate.value!,
        );
        
        final success = await controller.updateAsociado(asociadoActualizado);
        
        isLoading.value = false;
        
        if (success && context.mounted) {
          // Forzar actualización inmediata del UI
          controller.selectedAsociado.refresh();
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
          if (event is KeyDownEvent) {
            if (event.logicalKey == LogicalKeyboardKey.escape) {
              if (!isLoading.value) Navigator.of(context).pop();
              return KeyEventResult.handled;
            } else if (event.logicalKey == LogicalKeyboardKey.enter) {
              if (!isLoading.value) updateAsociadoAction();
              return KeyEventResult.handled;
            }
          }
          return KeyEventResult.ignored;
        },
        child: AlertDialog(
          backgroundColor: AppTheme.getSurfaceColor(context),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Row(
            children: [
              const Icon(Icons.edit, color: Color(0xFF3B82F6), size: 28),
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
                  // RUT (Solo lectura)
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
                        if (asociado.sap != null) ...[
                          const SizedBox(width: 24),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'SAP',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.getTextSecondary(context),
                                ),
                              ),
                              Text(
                                asociado.sap!,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.getTextPrimary(context),
                                ),
                              ),
                            ],
                          ),
                        ]
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
                      Expanded(child: _buildTextField(
                        context, 'Nombre', Icons.person, nombreController,
                        hintText: 'Ej: Juan Andrés'
                      )),
                      const SizedBox(width: 16),
                      Expanded(child: _buildTextField(
                        context, 'Apellido', Icons.person_outline, apellidoController,
                        hintText: 'Ej: Pérez González'
                      )),
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
                        ['Soltero', 'Casado', 'Viudo', 'Divorciado', 'Conviviente Civil'], 
                        Icons.favorite,
                        selectedEstadoCivil,
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
                  
                  _buildTextField(
                    context, 'Email', Icons.email, emailController,
                    hintText: 'Ej: juan.perez@email.com',
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    context, 'Teléfono', Icons.phone, telefonoController,
                    hintText: 'Ej: 9 1234 5678',
                    keyboardType: TextInputType.phone,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    context, 'Dirección', Icons.location_on, direccionController,
                    hintText: 'Ej: Av. Providencia 1234, Depto 501',
                  ),
                  
                  const SizedBox(height: 24),
                  
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
              child: Text('Cancelar', style: TextStyle(color: AppTheme.getTextSecondary(context))),
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
                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text('Actualizar Asociado'),
            )),
          ],
        ),
      ),
    );
  }

  // --- VALIDACIONES ROBUSTAS ---
  static bool _validateFields(
    String nombre,
    String apellido, 
    String email,
    String telefono,
    String direccion,
    DateTime? fechaNacimiento,
  ) {
    if (nombre.trim().length < 2) {
      _showSnack('El nombre debe tener al menos 2 letras');
      return false;
    }
    if (apellido.trim().length < 2) {
      _showSnack('El apellido debe tener al menos 2 letras');
      return false;
    }
    
    if (!GetUtils.isEmail(email.trim())) {
      _showSnack('Ingresa un correo electrónico válido');
      return false;
    }
    
    if (telefono.trim().length < 8) {
      _showSnack('El teléfono debe tener al menos 8 dígitos');
      return false;
    }
    
    if (direccion.trim().length < 5) {
      _showSnack('La dirección debe ser más específica');
      return false;
    }

    if (fechaNacimiento == null) {
      _showSnack('La fecha de nacimiento es requerida');
      return false;
    }

    if (fechaNacimiento.isAfter(DateTime.now())) {
      _showSnack('La fecha de nacimiento no puede ser futura');
      return false;
    }

    return true;
  }

  static void _showSnack(String msg) {
    Get.snackbar('Atención', msg,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.orange.withValues(alpha: 0.9),
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
      duration: const Duration(seconds: 3),
    );
  }

  // --- WIDGETS AUXILIARES ---

  static Widget _buildTextField(
    BuildContext context, 
    String label, 
    IconData icon, 
    TextEditingController controller, {
    String? hintText,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      style: TextStyle(color: AppTheme.getTextPrimary(context)),
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        hintStyle: TextStyle(color: AppTheme.getTextSecondary(context).withValues(alpha: 0.5), fontSize: 13),
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
          borderSide: BorderSide(color: AppTheme.primaryColor, width: 2),
        ),
        filled: true,
        fillColor: AppTheme.getInputBackground(context),
        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
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
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          border: Border.all(color: AppTheme.getBorderLight(context)),
          borderRadius: BorderRadius.circular(8),
          color: AppTheme.getInputBackground(context),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today, color: AppTheme.primaryColor),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (selectedDate.value != null)
                    Text(
                      'Fecha Nacimiento',
                      style: TextStyle(fontSize: 10, color: AppTheme.getTextSecondary(context)),
                    ),
                  Text(
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
                ],
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
        style: TextStyle(color: AppTheme.getTextPrimary(context), fontSize: 16),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: AppTheme.primaryColor),
          labelStyle: TextStyle(color: AppTheme.getTextSecondary(context)),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: AppTheme.getBorderLight(context)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: AppTheme.primaryColor, width: 2),
          ),
          filled: true,
          fillColor: AppTheme.getInputBackground(context),
          contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        ),
        dropdownColor: AppTheme.getSurfaceColor(context),
      ),
    );
  }
}