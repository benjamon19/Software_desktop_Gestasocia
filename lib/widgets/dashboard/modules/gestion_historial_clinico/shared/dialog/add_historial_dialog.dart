import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../../../../utils/app_theme.dart';
import '../../../../../../controllers/historial_clinico_controller.dart';

class AddHistorialDialog {
  static void show(BuildContext context, Map<String, dynamic> pacienteData) {
    final HistorialClinicoController controller = Get.find<HistorialClinicoController>();
    
    // Controladores de texto vacíos para nuevo historial
    final motivoController = TextEditingController();
    final diagnosticoController = TextEditingController();
    final tratamientoRecomendadoController = TextEditingController();
    final tratamientoRealizadoController = TextEditingController();
    final dienteTratadoController = TextEditingController();
    final observacionesController = TextEditingController();
    final alergiasController = TextEditingController();
    final medicamentosController = TextEditingController();
    final costoController = TextEditingController();
    
    // Variables reactivas con valores por defecto
    final selectedTipoConsulta = 'consulta'.obs;
    final selectedOdontologo = 'dr.lopez'.obs;
    final selectedEstado = 'pendiente'.obs;
    final selectedProximaCita = Rxn<DateTime>();

    // Función para crear historial
    Future<void> createHistorialAction() async {
      // Validar campos requeridos
      if (motivoController.text.trim().isEmpty) {
        Get.snackbar(
          'Error',
          'El motivo de consulta es requerido',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withValues(alpha: 0.8),
          colorText: Colors.white,
        );
        return;
      }

      // ✅ Cerrar el diálogo inmediatamente
      Navigator.of(context).pop();
      
      try {
        // Parsear costo si existe
        double? costo;
        if (costoController.text.trim().isNotEmpty) {
          costo = double.tryParse(costoController.text.trim());
        }

        // Crear nuevo historial con los datos del paciente actual
        final historialData = {
          // Información del paciente (mismo paciente)
          'pacienteId': pacienteData['pacienteId'],
          'pacienteTipo': pacienteData['pacienteTipo'],
          'pacienteNombre': pacienteData['pacienteNombre'],
          'pacienteRut': pacienteData['pacienteRut'],
          'pacienteEdad': pacienteData['pacienteEdad'],
          'pacienteTelefono': pacienteData['pacienteTelefono'] ?? '',
          
          // Información de la consulta
          'tipoConsulta': selectedTipoConsulta.value,
          'odontologo': selectedOdontologo.value == 'dr.lopez' ? 'Dr. López' : 'Dr. Martínez',
          'fecha': DateTime.now(),
          'hora': '${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}',
          'motivoPrincipal': motivoController.text.trim(),
          
          // Diagnóstico y tratamiento
          'diagnostico': diagnosticoController.text.trim().isEmpty ? null : diagnosticoController.text.trim(),
          'tratamientoRecomendado': tratamientoRecomendadoController.text.trim().isEmpty ? null : tratamientoRecomendadoController.text.trim(),
          'tratamientoRealizado': tratamientoRealizadoController.text.trim().isEmpty ? null : tratamientoRealizadoController.text.trim(),
          'dienteTratado': dienteTratadoController.text.trim().isEmpty ? null : dienteTratadoController.text.trim(),
          'observacionesOdontologo': observacionesController.text.trim().isEmpty ? null : observacionesController.text.trim(),
          
          // Información médica
          'alergias': alergiasController.text.trim().isEmpty ? null : alergiasController.text.trim(),
          'medicamentosActuales': medicamentosController.text.trim().isEmpty ? null : medicamentosController.text.trim(),
          
          // Seguimiento
          'proximaCita': selectedProximaCita.value,
          'estado': selectedEstado.value == 'completado' ? 'Completado' : (selectedEstado.value == 'pendiente' ? 'Pendiente' : 'Requiere Seguimiento'),
          'costoTratamiento': costo,
          
          // Metadata
          'fechaCreacion': DateTime.now(),
          'fechaActualizacion': null,
          
          // Campos adicionales (compatibilidad)
          'condicionesMedicas': [],
          'embarazo': false,
          'ultimaVisita': '',
          'tratamientosPrevios': [],
          'problemasFrecuentes': [],
          'experienciasNegativas': 'Ninguna',
          'higieneDental': '',
          'habitos': [],
          'alimentacion': '',
          'sintomasReportados': [],
          'asociadoTitular': pacienteData['pacienteNombre'],
        };

        await controller.addNewHistorial(historialData);
      } catch (e) {
        // El controlador ya maneja los errores con snackbars
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
              Navigator.of(context).pop();
              return KeyEventResult.handled;
            } else if (event.logicalKey == LogicalKeyboardKey.enter) {
              createHistorialAction();
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
                Icons.add_circle,
                color: Color(0xFF10B981),
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(
                'Nuevo Historial Clínico',
                style: TextStyle(
                  color: AppTheme.getTextPrimary(context),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(
                'ESC para cancelar • Enter para crear',
                style: TextStyle(
                  color: AppTheme.getTextSecondary(context),
                  fontSize: 12,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: 600,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Mostrar Paciente (solo lectura)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.person, color: const Color(0xFF10B981)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Creando historial para:',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.getTextSecondary(context),
                                ),
                              ),
                              Text(
                                pacienteData['pacienteNombre'],
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.getTextPrimary(context),
                                ),
                              ),
                              Text(
                                '${pacienteData['pacienteRut']} • ${pacienteData['pacienteEdad']} años',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.getTextSecondary(context),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Información de la Consulta
                  Text(
                    'Información de la Consulta',
                    style: TextStyle(
                      color: AppTheme.getTextPrimary(context),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  Row(
                    children: [
                      Expanded(child: Obx(() => _buildDropdown(
                        context,
                        'Tipo de Consulta',
                        ['consulta', 'control', 'urgencia', 'tratamiento'],
                        ['Consulta', 'Control', 'Urgencia', 'Tratamiento'],
                        Icons.medical_services_outlined,
                        selectedTipoConsulta,
                      ))),
                      const SizedBox(width: 16),
                      Expanded(child: Obx(() => _buildDropdown(
                        context,
                        'Odontólogo',
                        ['dr.lopez', 'dr.martinez'],
                        ['Dr. López', 'Dr. Martínez'],
                        Icons.person_outline,
                        selectedOdontologo,
                      ))),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  _buildTextField(context, 'Motivo de Consulta *', Icons.description_outlined, motivoController, maxLines: 2),
                  
                  const SizedBox(height: 24),
                  
                  // Diagnóstico y Tratamiento
                  Text(
                    'Diagnóstico y Tratamiento',
                    style: TextStyle(
                      color: AppTheme.getTextPrimary(context),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  _buildTextField(context, 'Diagnóstico', Icons.local_hospital_outlined, diagnosticoController, maxLines: 2),
                  const SizedBox(height: 16),
                  
                  _buildTextField(context, 'Tratamiento Recomendado', Icons.assignment_outlined, tratamientoRecomendadoController, maxLines: 2),
                  const SizedBox(height: 16),
                  
                  _buildTextField(context, 'Tratamiento Realizado', Icons.medication_outlined, tratamientoRealizadoController, maxLines: 2),
                  const SizedBox(height: 16),
                  
                  _buildTextField(context, 'Diente(s) Tratado(s)', Icons.medical_services, dienteTratadoController),
                  
                  const SizedBox(height: 24),
                  
                  // Información Médica
                  Text(
                    'Información Médica',
                    style: TextStyle(
                      color: AppTheme.getTextPrimary(context),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  _buildTextField(context, 'Alergias', Icons.warning_outlined, alergiasController, maxLines: 2),
                  const SizedBox(height: 16),
                  
                  _buildTextField(context, 'Medicamentos Actuales', Icons.medication_liquid_outlined, medicamentosController, maxLines: 2),
                  
                  const SizedBox(height: 24),
                  
                  // Seguimiento
                  Text(
                    'Seguimiento y Costos',
                    style: TextStyle(
                      color: AppTheme.getTextPrimary(context),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  _buildDatePicker(context, selectedProximaCita, 'Próxima Cita'),
                  const SizedBox(height: 16),
                  
                  _buildTextField(
                    context, 
                    'Costo del Tratamiento', 
                    Icons.attach_money, 
                    costoController,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  
                  Obx(() => _buildDropdown(
                    context,
                    'Estado',
                    ['completado', 'pendiente', 'requiere_seguimiento'],
                    ['Completado', 'Pendiente', 'Requiere Seguimiento'],
                    Icons.flag_outlined,
                    selectedEstado,
                  )),
                  
                  const SizedBox(height: 24),
                  
                  // Observaciones
                  Text(
                    'Observaciones',
                    style: TextStyle(
                      color: AppTheme.getTextPrimary(context),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  _buildTextField(context, 'Notas del Odontólogo', Icons.notes_outlined, observacionesController, maxLines: 3),
                ],
              ),
            ),
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
            ElevatedButton(
              onPressed: createHistorialAction,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Crear Historial'),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildTextField(
    BuildContext context,
    String label,
    IconData icon,
    TextEditingController controller, {
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      inputFormatters: keyboardType == TextInputType.number
          ? [FilteringTextInputFormatter.digitsOnly]
          : null,
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
          initialDate: selectedDate.value ?? DateTime.now().add(const Duration(days: 7)),
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 365)),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: AppTheme.primaryColor,
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
            if (selectedDate.value != null)
              IconButton(
                onPressed: () => selectedDate.value = null,
                icon: Icon(
                  Icons.clear,
                  size: 18,
                  color: AppTheme.getTextSecondary(context),
                ),
                tooltip: 'Quitar fecha',
              ),
          ],
        ),
      ),
    ));
  }

  static Widget _buildDropdown(
    BuildContext context,
    String label,
    List<String> values,
    List<String> labels,
    IconData icon,
    RxString selectedValue,
  ) {
    return SizedBox(
      width: double.infinity,
      child: DropdownButtonFormField<String>(
        initialValue: selectedValue.value,
        items: List.generate(
          values.length,
          (index) => DropdownMenuItem(
            value: values[index],
            child: Text(labels[index]),
          ),
        ),
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