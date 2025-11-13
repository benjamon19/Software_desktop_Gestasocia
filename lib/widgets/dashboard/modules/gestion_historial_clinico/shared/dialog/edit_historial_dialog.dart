import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../../../../utils/app_theme.dart';
import '../../../../../../controllers/historial_clinico_controller.dart';

class EditHistorialDialog {
  static void show(BuildContext context, Map<String, dynamic> historialData) {
    final HistorialClinicoController controller = Get.find<HistorialClinicoController>();

    final historial = controller.selectedHistorial.value;
    if (historial == null || historial.id != historialData['id']) {
      Get.snackbar('Error', 'Inconsistencia de datos: historial no coincide');
      return;
    }

    // Controladores de texto
    final motivoController = TextEditingController(text: historial.motivoPrincipal);
    final diagnosticoController = TextEditingController(text: historial.diagnostico ?? '');
    final tratamientoRealizadoController = TextEditingController(text: historial.tratamientoRealizado ?? '');
    final dienteTratadoController = TextEditingController(text: historial.dienteTratado ?? '');
    final observacionesController = TextEditingController(text: historial.observacionesOdontologo ?? '');
    final alergiasController = TextEditingController(text: historial.alergias ?? '');
    final medicamentosController = TextEditingController(text: historial.medicamentosActuales ?? '');
    final costoController = TextEditingController(
      text: historial.costoTratamiento != null ? historial.costoTratamiento.toString() : '',
    );

    // Variables observables
    final selectedTipoConsulta = historial.tipoConsulta.obs;
    final selectedOdontologo = (historial.odontologo == 'Dr. López' ? 'dr.lopez' : 'dr.martinez').obs;
    final selectedEstado = historial.estado.toLowerCase().obs;
    final selectedProximaCita = Rxn<DateTime>(historial.proximaCita);

    Future<void> updateHistorialAction() async {
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
        double? costo;
        if (costoController.text.trim().isNotEmpty) {
          costo = double.tryParse(costoController.text.trim());
        }

        final cambios = {
          'motivoPrincipal': motivoController.text.trim(),
          'diagnostico': diagnosticoController.text.trim().isEmpty ? null : diagnosticoController.text.trim(),
          'tratamientoRealizado': tratamientoRealizadoController.text.trim().isEmpty ? null : tratamientoRealizadoController.text.trim(),
          'dienteTratado': dienteTratadoController.text.trim().isEmpty ? null : dienteTratadoController.text.trim(),
          'observacionesOdontologo': observacionesController.text.trim().isEmpty ? null : observacionesController.text.trim(),
          'alergias': alergiasController.text.trim().isEmpty ? null : alergiasController.text.trim(),
          'medicamentosActuales': medicamentosController.text.trim().isEmpty ? null : medicamentosController.text.trim(),
          'tipoConsulta': selectedTipoConsulta.value,
          'odontologo': selectedOdontologo.value == 'dr.lopez' ? 'Dr. López' : 'Dr. Martínez',
          'estado': selectedEstado.value,
          'proximaCita': selectedProximaCita.value,
          'costoTratamiento': costo,
          'fechaActualizacion': DateTime.now(),
        };

        await controller.actualizarHistorial(historial.id!, cambios);
        controller.selectedHistorial.refresh();

      } catch (e) {
        Get.snackbar(
          'Error',
          'No se pudo actualizar el historial',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withValues(alpha: 0.8),
          colorText: Colors.white,
        );
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
              Navigator.of(context).pop();
              return KeyEventResult.handled;
            } else if (event.logicalKey == LogicalKeyboardKey.enter) {
              updateHistorialAction();
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
              const Icon(Icons.edit, color: Color(0xFF3B82F6), size: 28),
              const SizedBox(width: 12),
              Text(
                'Editar Historial Clínico',
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
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: 600,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Mostrar Paciente (no editable)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.getInputBackground(context),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppTheme.getBorderLight(context)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.person, color: AppTheme.primaryColor),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Paciente (No editable)',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.getTextSecondary(context),
                                ),
                              ),
                              Text(
                                historialData['pacienteNombre'],
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.getTextPrimary(context),
                                ),
                              ),
                              Text(
                                '${historialData['pacienteRut']} • ${historialData['pacienteEdad']} años',
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
                  _sectionTitle(context, 'Información de la Consulta'),
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

                  _buildTextField(context, 'Motivo de Consulta', Icons.description_outlined, motivoController, maxLines: 2),

                  const SizedBox(height: 24),

                  _sectionTitle(context, 'Diagnóstico y Tratamiento'),
                  _buildTextField(context, 'Diagnóstico', Icons.local_hospital_outlined, diagnosticoController, maxLines: 2),
                  const SizedBox(height: 16),
                  _buildTextField(context, 'Tratamiento Realizado', Icons.medication_outlined, tratamientoRealizadoController, maxLines: 2),
                  const SizedBox(height: 16),
                  _buildTextField(context, 'Diente(s) Tratado(s)', Icons.medical_services, dienteTratadoController),

                  const SizedBox(height: 24),

                  _sectionTitle(context, 'Información Médica'),
                  _buildTextField(context, 'Alergias', Icons.warning_outlined, alergiasController, maxLines: 2),
                  const SizedBox(height: 16),
                  _buildTextField(context, 'Medicamentos Actuales', Icons.medication_liquid_outlined, medicamentosController, maxLines: 2),

                  const SizedBox(height: 24),

                  _sectionTitle(context, 'Seguimiento y Costos'),
                  _buildDatePicker(context, selectedProximaCita, 'Próxima Cita'),
                  const SizedBox(height: 16),
                  _buildTextField(context, 'Costo del Tratamiento', Icons.attach_money, costoController,
                      keyboardType: TextInputType.number),
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

                  _sectionTitle(context, 'Observaciones'),
                  _buildTextField(context, 'Notas del Odontólogo', Icons.notes_outlined, observacionesController, maxLines: 3),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancelar', style: TextStyle(color: AppTheme.getTextSecondary(context))),
            ),
            ElevatedButton(
              onPressed: updateHistorialAction,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Guardar Cambios'),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _sectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: TextStyle(
          color: AppTheme.getTextPrimary(context),
          fontSize: 16,
          fontWeight: FontWeight.w600,
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
                icon: Icon(Icons.clear, size: 18, color: AppTheme.getTextSecondary(context)),
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
          if (value != null) selectedValue.value = value;
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
