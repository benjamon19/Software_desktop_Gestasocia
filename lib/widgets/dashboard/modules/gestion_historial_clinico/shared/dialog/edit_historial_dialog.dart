import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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

    // --- CONTROLADORES ---
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

    // --- VARIABLES REACTIVAS ---
    final selectedTipoConsulta = historial.tipoConsulta.obs;
    final selectedEstado = historial.estado.toLowerCase().obs;
    final selectedProximaCita = Rxn<DateTime>(historial.proximaCita);
    
    // Lógica Odontólogos (Igual que en referencia)
    final RxString selectedOdontologo = (historial.odontologo).obs;
    final RxList<Map<String, String>> listaOdontologos = <Map<String, String>>[].obs;
    final RxBool loadingOdontologos = true.obs;
    final isLoading = false.obs;

    // --- CARGAR ODONTÓLOGOS ---
    Future<void> loadOdontologos() async {
      try {
        loadingOdontologos.value = true;
        final snapshot = await FirebaseFirestore.instance
            .collection('usuarios')
            .where('rol', isEqualTo: 'odontologo')
            .get();

        final List<Map<String, String>> odontologos = [];
        for (var doc in snapshot.docs) {
          final data = doc.data();
          final nombre = data['nombre'] ?? '';
          final apellido = data['apellido'] ?? '';
          odontologos.add({
            'value': '$nombre $apellido'.trim(),
            'label': '$nombre $apellido'.trim(),
          });
        }
        listaOdontologos.value = odontologos;

        // Asegurar que el odontólogo actual esté en la lista para no romper el dropdown
        // Si no está (ej: usuario borrado), lo agregamos manualmente para que se vea
        if (selectedOdontologo.value.isNotEmpty) {
          final exists = odontologos.any((item) => item['value'] == selectedOdontologo.value);
          if (!exists) {
            listaOdontologos.add({
              'value': selectedOdontologo.value,
              'label': selectedOdontologo.value,
            });
          }
        }
      } catch (e) {
        debugPrint('Error cargando odontólogos: $e');
      } finally {
        loadingOdontologos.value = false;
      }
    }

    loadOdontologos();

    // --- ACCIÓN ACTUALIZAR ---
    Future<void> updateHistorialAction() async {
      if (motivoController.text.trim().isEmpty) {
        _showError('El motivo de consulta es requerido');
        return;
      }

      Navigator.of(context).pop();

      try {
        isLoading.value = true;
        
        double? costo;
        if (costoController.text.trim().isNotEmpty) {
          String cleanCosto = costoController.text.replaceAll(RegExp(r'[^0-9]'), '');
          costo = double.tryParse(cleanCosto);
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
          'odontologo': selectedOdontologo.value,
          'estado': selectedEstado.value,
          'proximaCita': selectedProximaCita.value,
          'costoTratamiento': costo,
          'fechaActualizacion': DateTime.now(),
        };

        await controller.actualizarHistorial(historial.id!, cambios);
        controller.selectedHistorial.refresh();

      } catch (e) {
        _showError('No se pudo actualizar el historial');
      } finally {
        isLoading.value = false;
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Row(
            children: [
              const Icon(Icons.edit, color: Color(0xFF3B82F6), size: 28),
              const SizedBox(width: 12),
              Text(
                'Editar Historial Clínico',
                style: TextStyle(color: AppTheme.getTextPrimary(context), fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              Text(
                'ESC para cancelar • Enter para actualizar',
                style: TextStyle(color: AppTheme.getTextSecondary(context), fontSize: 12),
              ),
            ],
          ),
          content: SizedBox(
            width: 600,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Info Paciente (Solo lectura)
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
                              Text('Paciente (No editable)', style: TextStyle(fontSize: 12, color: AppTheme.getTextSecondary(context))),
                              Text(historialData['pacienteNombre'], style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.getTextPrimary(context))),
                              Text('${historialData['pacienteRut']} • ${historialData['pacienteEdad']} años', style: TextStyle(fontSize: 12, color: AppTheme.getTextSecondary(context))),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),
                  _sectionTitle(context, 'Información de la Consulta'),
                  
                  Row(
                    children: [
                      Expanded(child: Obx(() => _buildDropdown(
                        context,
                        label: 'Tipo de Consulta',
                        value: selectedTipoConsulta.value,
                        items: [
                          {'value': 'consulta', 'label': 'Consulta'},
                          {'value': 'control', 'label': 'Control'},
                          {'value': 'urgencia', 'label': 'Urgencia'},
                          {'value': 'tratamiento', 'label': 'Tratamiento'},
                        ],
                        icon: Icons.medical_services_outlined,
                        onChanged: (val) { if (val != null) selectedTipoConsulta.value = val; }
                      ))),
                      const SizedBox(width: 16),
                      
                      // Dropdown Odontólogo
                      Expanded(child: Obx(() {
                        if (loadingOdontologos.value) {
                          return Container(
                            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                            decoration: BoxDecoration(
                              border: Border.all(color: AppTheme.getBorderLight(context)),
                              borderRadius: BorderRadius.circular(8),
                              color: AppTheme.getInputBackground(context),
                            ),
                            child: const Row(
                              children: [
                                SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                                SizedBox(width: 8),
                                Text('Cargando...', style: TextStyle(fontSize: 12)),
                              ],
                            ),
                          );
                        }
                        return _buildDropdown(
                          context,
                          label: 'Odontólogo',
                          value: selectedOdontologo.value.isEmpty ? null : selectedOdontologo.value,
                          items: listaOdontologos,
                          icon: Icons.person_outline,
                          onChanged: (val) { if (val != null) selectedOdontologo.value = val; }
                        );
                      })),
                    ],
                  ),
                  const SizedBox(height: 16),

                  _buildTextField(context, 'Motivo de Consulta', Icons.description_outlined, motivoController, 
                    hintText: 'Ej: Dolor agudo...', maxLines: 2, capitalization: TextCapitalization.sentences),

                  const SizedBox(height: 24),
                  _sectionTitle(context, 'Diagnóstico y Tratamiento'),
                  _buildTextField(context, 'Diagnóstico', Icons.local_hospital_outlined, diagnosticoController, 
                    hintText: 'Ej: Caries profunda...', maxLines: 2, capitalization: TextCapitalization.sentences),
                  const SizedBox(height: 16),
                  _buildTextField(context, 'Tratamiento Realizado', Icons.medication_outlined, tratamientoRealizadoController, 
                    hintText: 'Ej: Trepanación...', maxLines: 2, capitalization: TextCapitalization.sentences),
                  const SizedBox(height: 16),
                  _buildTextField(context, 'Diente(s) Tratado(s)', Icons.medical_services, dienteTratadoController,
                    hintText: 'Ej: 14, 2.1', capitalization: TextCapitalization.characters),

                  const SizedBox(height: 24),
                  _sectionTitle(context, 'Información Médica'),
                  _buildTextField(context, 'Alergias', Icons.warning_outlined, alergiasController, 
                    hintText: 'Ej: Penicilina', maxLines: 2, capitalization: TextCapitalization.sentences),
                  const SizedBox(height: 16),
                  _buildTextField(context, 'Medicamentos Actuales', Icons.medication_liquid_outlined, medicamentosController, 
                    hintText: 'Ej: Losartán', maxLines: 2, capitalization: TextCapitalization.sentences),

                  const SizedBox(height: 24),
                  _sectionTitle(context, 'Seguimiento y Costos'),
                  _buildDatePicker(context, selectedProximaCita, 'Próxima Cita'),
                  const SizedBox(height: 16),
                  _buildTextField(context, 'Costo del Tratamiento', Icons.attach_money, costoController,
                    hintText: 'Ej: 25000', keyboardType: TextInputType.number),
                  const SizedBox(height: 16),
                  Obx(() => _buildDropdown(
                    context,
                    label: 'Estado',
                    value: selectedEstado.value,
                    items: [
                      {'value': 'completado', 'label': 'Completado'},
                      {'value': 'pendiente', 'label': 'Pendiente'},
                      {'value': 'requiere_seguimiento', 'label': 'Requiere Seguimiento'},
                    ],
                    icon: Icons.flag_outlined,
                    onChanged: (val) { if (val != null) selectedEstado.value = val; }
                  )),

                  const SizedBox(height: 24),
                  _sectionTitle(context, 'Observaciones'),
                  _buildTextField(context, 'Notas del Odontólogo', Icons.notes_outlined, observacionesController, 
                    hintText: 'Notas internas...', maxLines: 3, capitalization: TextCapitalization.sentences),
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

  // --- WIDGETS AUXILIARES ---

  static Widget _buildTextField(
    BuildContext context, 
    String label, 
    IconData icon, 
    TextEditingController controller, {
    String? hintText,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    TextCapitalization capitalization = TextCapitalization.none,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      textCapitalization: capitalization,
      inputFormatters: keyboardType == TextInputType.number ? [FilteringTextInputFormatter.digitsOnly] : null,
      style: TextStyle(color: AppTheme.getTextPrimary(context)),
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        hintStyle: TextStyle(color: AppTheme.getTextSecondary(context).withValues(alpha: 0.5), fontSize: 13),
        prefixIcon: Icon(icon, color: AppTheme.primaryColor),
        labelStyle: TextStyle(color: AppTheme.getTextSecondary(context)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: AppTheme.getBorderLight(context))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: AppTheme.primaryColor, width: 1.5)),
        filled: true,
        fillColor: AppTheme.getInputBackground(context),
      ),
    );
  }

  static Widget _buildDropdown(
    BuildContext context, {
    required String label,
    required String? value,
    required List<Map<String, String>> items,
    required IconData icon,
    required Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      items: items.map((item) {
        return DropdownMenuItem<String>(
          value: item['value'],
          child: Text(item['label']!, style: TextStyle(color: AppTheme.getTextPrimary(context), fontSize: 15)),
        );
      }).toList(),
      onChanged: onChanged,
      style: TextStyle(color: AppTheme.getTextPrimary(context), fontSize: 15),
      dropdownColor: AppTheme.getSurfaceColor(context),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppTheme.primaryColor, size: 20),
        filled: true,
        fillColor: AppTheme.getInputBackground(context),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: AppTheme.getBorderLight(context))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppTheme.primaryColor, width: 1.5)),
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      ),
    );
  }

  static Widget _buildDatePicker(BuildContext context, Rxn<DateTime> selectedDate, String label) {
    return Obx(() => InkWell(
      onTap: () async {
        final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: selectedDate.value ?? DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime.now().add(const Duration(days: 365)),
          builder: (context, child) => Theme(
            data: Theme.of(context).copyWith(
              colorScheme: Theme.of(context).colorScheme.copyWith(
                primary: AppTheme.primaryColor,
                onPrimary: Colors.white,
                surface: AppTheme.getSurfaceColor(context),
                onSurface: AppTheme.getTextPrimary(context),
              ),
            ),
            child: child!,
          ),
        );
        if (picked != null) selectedDate.value = picked;
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
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
              child: Text(
                selectedDate.value != null
                    ? '${selectedDate.value!.day}/${selectedDate.value!.month}/${selectedDate.value!.year}'
                    : label,
                style: TextStyle(
                  color: selectedDate.value != null ? AppTheme.getTextPrimary(context) : AppTheme.getTextSecondary(context),
                  fontSize: 16,
                ),
              ),
            ),
            if (selectedDate.value != null)
              IconButton(
                onPressed: () => selectedDate.value = null,
                icon: Icon(Icons.clear, size: 18, color: AppTheme.getTextSecondary(context)),
              ),
          ],
        ),
      ),
    ));
  }

  static void _showError(String message) {
    Get.snackbar('Atención', message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.orange.withValues(alpha: 0.8),
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
      duration: const Duration(seconds: 3),
    );
  }

  static Widget _sectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(title, style: TextStyle(color: AppTheme.getTextPrimary(context), fontSize: 16, fontWeight: FontWeight.w600)),
    );
  }
}