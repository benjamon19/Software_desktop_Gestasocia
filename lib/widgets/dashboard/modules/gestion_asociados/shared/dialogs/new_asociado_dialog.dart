import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:gestasocia/utils/app_theme.dart';
import '../../../../../../controllers/asociados_controller.dart';

class NewAsociadoDialog {
  static void show(BuildContext context) {
    final AsociadosController controller = Get.find<AsociadosController>();
    
    // Controladores de texto
    final nombreController = TextEditingController();
    final apellidoController = TextEditingController();
    final rutController = TextEditingController();
    final emailController = TextEditingController();
    final telefonoController = TextEditingController();
    final direccionController = TextEditingController();
    
    // Variables reactivas - VALORES CORREGIDOS
    final selectedEstadoCivil = 'Soltero'.obs;
    final selectedPlan = 'Asociado'.obs;
    final selectedDate = Rxn<DateTime>();
    final isLoading = false.obs;

    // Función para crear asociado
    Future<void> createAsociadoAction() async {
      if (_validateFields(
        nombreController.text,
        apellidoController.text,
        rutController.text,
        emailController.text,
        telefonoController.text,
        direccionController.text,
        selectedDate.value,
      )) {
        isLoading.value = true;
        
        final success = await controller.createAsociado(
          nombre: nombreController.text,
          apellido: apellidoController.text,
          rut: rutController.text,
          fechaNacimiento: selectedDate.value!,
          estadoCivil: selectedEstadoCivil.value,
          email: emailController.text,
          telefono: telefonoController.text,
          direccion: direccionController.text,
          plan: selectedPlan.value,
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
          // Manejar teclas ESC y Enter
          if (event is KeyDownEvent) {
            if (event.logicalKey == LogicalKeyboardKey.escape) {
              if (!isLoading.value) {
                Navigator.of(context).pop();
              }
              return KeyEventResult.handled;
            } else if (event.logicalKey == LogicalKeyboardKey.enter) {
              if (!isLoading.value) {
                createAsociadoAction();
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
                Icons.person_add,
                color: Color(0xFF3B82F6),
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(
                'Nuevo Asociado',
                style: TextStyle(
                  color: AppTheme.getTextPrimary(context),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(
                'ESC para cancelar • Enter para guardar',
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
                      Expanded(child: _buildRutTextField(context, rutController)),
                      const SizedBox(width: 16),
                      Expanded(child: _buildDatePicker(context, selectedDate)),
                    ],
                  ),
                  const SizedBox(height: 16),
                
                  Obx(() => _buildDropdown(
                    context, 
                    'Estado Civil', 
                    ['Soltero', 'Casado', 'Viudo'], 
                    Icons.favorite,
                    selectedEstadoCivil,
                  )),
                  
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
              onPressed: isLoading.value ? null : createAsociadoAction,
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
                : const Text('Agregar Asociado'),
            )),
          ],
        ),
      ),
    );
  }

  static bool _validateFields(
    String nombre,
    String apellido, 
    String rut,
    String email,
    String telefono,
    String direccion,
    DateTime? fechaNacimiento,
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
    
    if (rut.trim().isEmpty) {
      Get.snackbar('Error', 'El RUT es requerido',
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
    
    if (fechaNacimiento == null) {
      Get.snackbar('Error', 'La fecha de nacimiento es requerida',
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
          borderSide: BorderSide(color: AppTheme.primaryColor, width: 2),
        ),
      ),
    );
  }

  // TextField especial para RUT con formateo automático
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
        hintText: '12345678-9',
        prefixIcon: Icon(Icons.badge, color: AppTheme.primaryColor),
        labelStyle: TextStyle(color: AppTheme.getTextSecondary(context)),
        hintStyle: TextStyle(color: AppTheme.getTextSecondary(context).withValues(alpha: 0.7)),
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
      ),
    );
  }

  static Widget _buildDatePicker(BuildContext context, Rxn<DateTime> selectedDate) {
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
                    : 'Fecha Nacimiento',
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
            borderSide: BorderSide(color: AppTheme.primaryColor, width: 2),
          ),
        ),
        dropdownColor: AppTheme.getSurfaceColor(context),
        isExpanded: true,
      ),
    );
  }
}

// Formateador para RUT chileno
class _RutFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String text = newValue.text.replaceAll('-', '');
    
    if (text.length <= 1) {
      return newValue;
    }
    
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