import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:gestasocia/utils/app_theme.dart';
import '../../../../../../controllers/asociados_controller.dart';

class NewCargaFamiliarDialog {
  static void show(BuildContext context, String asociadoId, String titularNombre) {
    final AsociadosController controller = Get.find<AsociadosController>();
    
    // Controladores de texto
    final nombreController = TextEditingController();
    final apellidoController = TextEditingController();
    final rutController = TextEditingController();
    
    // Variables reactivas
    final selectedParentesco = 'Hijo'.obs;
    final selectedDate = Rxn<DateTime>();
    final isLoading = false.obs;

    // Función para crear carga familiar
    Future<void> createCargaFamiliarAction() async {
      // 1. Validar campos antes de enviar
      if (_validateFields(
        nombreController.text,
        apellidoController.text,
        rutController.text,
        selectedDate.value,
      )) {
        isLoading.value = true;
        
        // 2. Crear la carga vinculada al ID del asociado (comparte su SAP internamente)
        final success = await controller.createCargaFamiliar(
          nombre: nombreController.text.trim(),
          apellido: apellidoController.text.trim(),
          rut: rutController.text.trim(),
          parentesco: selectedParentesco.value,
          fechaNacimiento: selectedDate.value!,
          // No generamos SAP ni código de barras aquí, hereda la entidad del titular
        );
        
        isLoading.value = false;
        
        if (success && context.mounted) {
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
              if (!isLoading.value) createCargaFamiliarAction();
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
              const Icon(
                Icons.person_add,
                color: Color(0xFF10B981),
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Nueva Carga Familiar',
                      style: TextStyle(
                        color: AppTheme.getTextPrimary(context),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Titular: $titularNombre', // Feedback visual del vínculo
                      style: TextStyle(
                        color: AppTheme.getTextSecondary(context),
                        fontSize: 12,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Text(
                'ESC para cancelar • Enter para guardar',
                style: TextStyle(
                  color: AppTheme.getTextSecondary(context),
                  fontSize: 12,
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: 450,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Información Básica',
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
                        context, 
                        'Nombre', 
                        Icons.person, 
                        nombreController,
                        hintText: 'Ej: Benjamín',
                      )),
                      const SizedBox(width: 16),
                      Expanded(child: _buildTextField(
                        context, 
                        'Apellido', 
                        Icons.person_outline, 
                        apellidoController,
                        hintText: 'Ej: Vicuña',
                      )),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  _buildRutTextField(context, rutController),
                  
                  const SizedBox(height: 16),
                  
                  Row(
                    children: [
                      Expanded(child: Obx(() => _buildDropdown(
                        context, 
                        'Parentesco', 
                        ['Hijo', 'Hija', 'Cónyuge'], 
                        Icons.family_restroom,
                        selectedParentesco,
                      ))),
                      const SizedBox(width: 16),
                      Expanded(child: _buildDatePicker(context, selectedDate, 'Fecha Nacimiento')),
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Aviso informativo
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: const Color(0xFF10B981).withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline, color: Color(0xFF10B981), size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'La carga se asociará automáticamente al plan y SAP de $titularNombre.',
                            style: TextStyle(
                              color: AppTheme.getTextPrimary(context),
                              fontSize: 12,
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
          actions: [
            TextButton(
              onPressed: isLoading.value ? null : () => Navigator.of(context).pop(),
              child: Text(
                'Cancelar',
                style: TextStyle(color: AppTheme.getTextSecondary(context)),
              ),
            ),
            Obx(() => ElevatedButton(
              onPressed: isLoading.value ? null : createCargaFamiliarAction,
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
                : const Text('Agregar Carga'),
            )),
          ],
        ),
      ),
    );
  }

  // --- VALIDACIONES ---
  static bool _validateFields(
    String nombre,
    String apellido, 
    String rut,
    DateTime? fechaNacimiento,
  ) {
    if (nombre.trim().length < 2) {
      _showSnack('El nombre debe tener al menos 2 caracteres');
      return false;
    }
    
    if (apellido.trim().length < 2) {
      _showSnack('El apellido debe tener al menos 2 caracteres');
      return false;
    }
    
    if (rut.trim().length < 8) {
      _showSnack('El RUT ingresado parece incompleto');
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
    Get.snackbar(
      'Atención', 
      msg,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.orange.withValues(alpha: 0.9),
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
      duration: const Duration(seconds: 3),
    );
  }

  // --- WIDGETS ---

  static Widget _buildTextField(
    BuildContext context, 
    String label, 
    IconData icon, 
    TextEditingController controller, {
    String? hintText,
  }) {
    return TextField(
      controller: controller,
      style: TextStyle(color: AppTheme.getTextPrimary(context)),
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        hintStyle: TextStyle(
          color: AppTheme.getTextSecondary(context).withValues(alpha: 0.5),
          fontSize: 13,
        ),
        prefixIcon: Icon(icon, color: const Color(0xFF10B981)),
        labelStyle: TextStyle(color: AppTheme.getTextSecondary(context)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppTheme.getBorderLight(context)),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          borderSide: BorderSide(color: Color(0xFF10B981), width: 2),
        ),
        filled: true,
        fillColor: AppTheme.getInputBackground(context),
        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      ),
    );
  }

  static Widget _buildRutTextField(BuildContext context, TextEditingController controller) {
    return TextField(
      controller: controller,
      style: TextStyle(color: AppTheme.getTextPrimary(context)),
      keyboardType: TextInputType.text,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[0-9kK\-]')),
        LengthLimitingTextInputFormatter(12),
        _RutFormatter(),
      ],
      decoration: InputDecoration(
        labelText: 'RUT',
        hintText: 'Ej: 12345678-9',
        hintStyle: TextStyle(color: AppTheme.getTextSecondary(context).withValues(alpha: 0.5)),
        prefixIcon: const Icon(Icons.badge, color: Color(0xFF10B981)),
        labelStyle: TextStyle(color: AppTheme.getTextSecondary(context)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppTheme.getBorderLight(context)),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          borderSide: BorderSide(color: Color(0xFF10B981), width: 2),
        ),
        filled: true,
        fillColor: AppTheme.getInputBackground(context),
      ),
    );
  }

  static Widget _buildDatePicker(BuildContext context, Rxn<DateTime> selectedDate, String label) {
    return Obx(() => InkWell(
      onTap: () async {
        final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: selectedDate.value ?? DateTime(2015),
          firstDate: DateTime(1900),
          lastDate: DateTime.now(),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: const Color(0xFF10B981),
                  onPrimary: Colors.white,
                  surface: AppTheme.getSurfaceColor(context),
                  onSurface: AppTheme.getTextPrimary(context),
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
            const Icon(Icons.calendar_today, color: Color(0xFF10B981), size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (selectedDate.value != null)
                    Text(
                      'Nacimiento',
                      style: TextStyle(fontSize: 10, color: AppTheme.getTextSecondary(context)),
                    ),
                  Text(
                    selectedDate.value != null
                        ? '${selectedDate.value!.day}/${selectedDate.value!.month}/${selectedDate.value!.year}'
                        : label,
                    style: TextStyle(
                      color: selectedDate.value != null 
                          ? AppTheme.getTextPrimary(context)
                          : AppTheme.getTextSecondary(context),
                      fontSize: 14,
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
    // Asegurar valor por defecto válido
    if (!items.contains(selectedValue.value)) selectedValue.value = items.first;

    return DropdownButtonFormField<String>(
      initialValue: selectedValue.value,
      items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
      onChanged: (value) {
        if (value != null) selectedValue.value = value;
      },
      style: TextStyle(color: AppTheme.getTextPrimary(context), fontSize: 15),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF10B981)),
        labelStyle: TextStyle(color: AppTheme.getTextSecondary(context)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppTheme.getBorderLight(context)),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          borderSide: BorderSide(color: Color(0xFF10B981), width: 2),
        ),
        filled: true,
        fillColor: AppTheme.getInputBackground(context),
        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      ),
      dropdownColor: AppTheme.getSurfaceColor(context),
      isExpanded: true,
    );
  }
}

// Formateador de RUT (Sin cambios, solo incluido para integridad)
class _RutFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String text = newValue.text.replaceAll('-', '');
    if (text.length <= 1) return newValue;
    
    String formatted = '';
    if (text.length > 1) {
      String body = text.substring(0, text.length - 1);
      String dv = text.substring(text.length - 1);
      formatted = '$body-$dv';
    }
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}