import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; 
import '../../../../../../utils/app_theme.dart';
import '../../../../../../controllers/reserva_horas_controller.dart';
import '../../../../../../models/reserva_hora.dart';
import '../../../gestion_historial_clinico/shared/dialog/select_asociado_dialog.dart';

class NewReservaDialog {
  static void show(BuildContext context, {DateTime? preSelectedDate}) {
    
    final ReservaHorasController controller = Get.isRegistered<ReservaHorasController>()
        ? Get.find<ReservaHorasController>()
        : Get.put(ReservaHorasController());

    // Variables reactivas
    final selectedPaciente = Rxn<Map<String, dynamic>>();
    final RxString selectedOdontologo = ''.obs; 
    final RxList<Map<String, String>> listaOdontologos = <Map<String, String>>[].obs;
    final RxBool loadingOdontologos = true.obs;

    final motivoController = TextEditingController();
    final isLoading = false.obs;
    
    // Fecha y hora inicial
    final DateTime initialDate = preSelectedDate ?? DateTime.now();
    final selectedDate = Rx<DateTime>(initialDate);
    final selectedTime = Rx<TimeOfDay>(TimeOfDay.fromDateTime(initialDate));

    // Cargar odontólogos
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
            'id': doc.id,
            'nombreCompleto': '$nombre $apellido'.trim(),
          });
        }
        listaOdontologos.value = odontologos;
        if (odontologos.length == 1) {
          selectedOdontologo.value = odontologos.first['nombreCompleto']!;
        }
      } catch (e) {
        debugPrint('Error cargando odontólogos: $e');
      } finally {
        loadingOdontologos.value = false;
      }
    }

    loadOdontologos();

    // Guardar Reserva (CON VALIDACIÓN)
    Future<void> saveReserva() async {
      if (selectedPaciente.value == null) {
        _showError('Debes seleccionar un paciente');
        return;
      }
      if (selectedOdontologo.value.isEmpty) {
        _showError('Debes seleccionar un odontólogo');
        return;
      }
      if (motivoController.text.trim().isEmpty) {
        _showError('Debes ingresar un motivo');
        return;
      }

      // Formatear hora (HH:mm)
      final horaFormat = '${selectedTime.value.hour.toString().padLeft(2, '0')}:${selectedTime.value.minute.toString().padLeft(2, '0')}';

      // === NUEVA VALIDACIÓN: HORARIO Y DISPONIBILIDAD ===
      final error = controller.validarReserva(
        selectedOdontologo.value,
        selectedDate.value,
        horaFormat
      );

      if (error != null) {
        Get.snackbar(
          'No disponible',
          error,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange.withValues(alpha: 0.9),
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
          borderRadius: 8,
          duration: const Duration(seconds: 4),
          icon: const Icon(Icons.event_busy, color: Colors.white),
        );
        return; // Detener guardado
      }
      // ==================================================

      isLoading.value = true;

      final fechaCompleta = DateTime(
        selectedDate.value.year,
        selectedDate.value.month,
        selectedDate.value.day,
        selectedTime.value.hour,
        selectedTime.value.minute,
      );

      final nuevaReserva = ReservaHora(
        pacienteId: selectedPaciente.value!['id'],
        pacienteNombre: selectedPaciente.value!['nombre'],
        pacienteTipo: selectedPaciente.value!['tipo'],
        pacienteRut: selectedPaciente.value!['rut'],
        odontologo: selectedOdontologo.value,
        fecha: fechaCompleta,
        hora: horaFormat,
        motivo: motivoController.text.trim(),
        fechaCreacion: DateTime.now(),
        estado: 'pendiente',
      );

      final success = await controller.createReserva(nuevaReserva);
      isLoading.value = false;

      if (success && context.mounted) {
        Navigator.of(context).pop();
      }
    }

    // Selección de Paciente
    Future<void> pickPaciente() async {
      final result = await SelectPacienteDialog.show(context);
      if (result != null) {
        selectedPaciente.value = result;
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
              if (!isLoading.value) saveReserva();
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
              const Icon(Icons.calendar_month, color: AppTheme.primaryColor, size: 28),
              const SizedBox(width: 12),
              Text(
                'Nueva Reserva',
                style: TextStyle(
                  color: AppTheme.getTextPrimary(context),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(
                'ESC cancelar • Enter guardar',
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
                  // Paciente (Input fake)
                  Obx(() => InkWell(
                    onTap: pickPaciente,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: AppTheme.getBorderLight(context)
                        ),
                        borderRadius: BorderRadius.circular(8),
                        color: AppTheme.getInputBackground(context),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            selectedPaciente.value == null ? Icons.person_search : Icons.person,
                            color: AppTheme.primaryColor,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (selectedPaciente.value != null)
                                  Text(
                                    'Paciente',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: AppTheme.getTextSecondary(context),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                Text(
                                  selectedPaciente.value?['nombre'] ?? 'Seleccionar paciente...',
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: selectedPaciente.value == null 
                                        ? AppTheme.getTextSecondary(context) 
                                        : AppTheme.getTextPrimary(context),
                                    fontWeight: selectedPaciente.value != null ? FontWeight.w500 : FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.arrow_drop_down, color: Colors.grey),
                        ],
                      ),
                    ),
                  )),

                  const SizedBox(height: 20),

                  // Fecha y Hora
                  Row(
                    children: [
                      Expanded(
                        child: Obx(() => InkWell(
                          onTap: () async {
                            final now = DateTime.now();
                            final initialDateForPicker = selectedDate.value.isBefore(now) 
                                ? now 
                                : selectedDate.value;

                            final picked = await showDatePicker(
                              context: context,
                              initialDate: initialDateForPicker,
                              firstDate: now,
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
                            if (picked != null) selectedDate.value = picked;
                          },
                          child: _buildFakeInput(
                            context, 
                            label: 'Fecha',
                            value: DateFormat('dd/MM/yyyy').format(selectedDate.value),
                            icon: Icons.calendar_today,
                          ),
                        )),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Obx(() => InkWell(
                          onTap: () async {
                            final picked = await showTimePicker(
                              context: context,
                              initialTime: selectedTime.value,
                              builder: (context, child) {
                                return Theme(
                                  data: Theme.of(context).copyWith(
                                    colorScheme: Theme.of(context).colorScheme.copyWith(
                                      primary: AppTheme.primaryColor,
                                      onPrimary: Colors.white,
                                      surface: AppTheme.getSurfaceColor(context),
                                      onSurface: AppTheme.getTextPrimary(context),
                                    ),
                                    timePickerTheme: TimePickerThemeData(
                                      backgroundColor: AppTheme.getSurfaceColor(context),
                                      hourMinuteTextColor: AppTheme.getTextPrimary(context),
                                      dayPeriodTextColor: AppTheme.getTextSecondary(context),
                                      dialHandColor: AppTheme.primaryColor,
                                      dialBackgroundColor: AppTheme.getInputBackground(context),
                                    ),
                                  ),
                                  child: child!,
                                );
                              },
                            );
                            if (picked != null) selectedTime.value = picked;
                          },
                          child: _buildFakeInput(
                            context, 
                            label: 'Hora',
                            value: selectedTime.value.format(context),
                            icon: Icons.access_time,
                          ),
                        )),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Odontólogo (Dropdown dinámico)
                  Obx(() {
                    if (loadingOdontologos.value) {
                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppTheme.getBorderLight(context)),
                          borderRadius: BorderRadius.circular(8),
                          color: AppTheme.getInputBackground(context),
                        ),
                        child: const Row(
                          children: [
                            SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                            SizedBox(width: 12),
                            Text('Cargando odontólogos...'),
                          ],
                        ),
                      );
                    }
                    
                    return _buildDropdown(
                      context,
                      label: 'Odontólogo',
                      value: selectedOdontologo.value.isEmpty ? null : selectedOdontologo.value,
                      items: listaOdontologos.map((o) => {
                        'value': o['nombreCompleto']!,
                        'label': o['nombreCompleto']!
                      }).toList(),
                      icon: Icons.medical_services_outlined,
                      onChanged: (val) {
                        if (val != null) selectedOdontologo.value = val;
                      },
                    );
                  }),

                  const SizedBox(height: 20),

                  // Motivo
                  _buildTextField(
                    context,
                    label: 'Motivo de Consulta',
                    icon: Icons.description_outlined,
                    controller: motivoController,
                    maxLines: 2,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancelar',
                style: TextStyle(color: AppTheme.getTextSecondary(context)),
              ),
            ),
            Obx(() => ElevatedButton(
              onPressed: isLoading.value ? null : saveReserva,
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
                  : const Text('Agendar'),
            )),
          ],
        ),
      ),
    );
  }

  static Widget _buildTextField(
    BuildContext context, {
    required String label,
    required IconData icon,
    required TextEditingController controller,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: TextStyle(color: AppTheme.getTextPrimary(context), fontSize: 15),
      cursorColor: AppTheme.primaryColor,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppTheme.primaryColor, size: 20),
        filled: true,
        fillColor: AppTheme.getInputBackground(context),
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
          borderSide: const BorderSide(color: AppTheme.primaryColor, width: 1.5),
        ),
        labelStyle: TextStyle(
          color: AppTheme.getTextSecondary(context),
          fontSize: 14,
        ),
        floatingLabelStyle: TextStyle(
          color: AppTheme.getTextSecondary(context),
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
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
          child: Text(
            item['label']!,
            style: TextStyle(
              color: AppTheme.getTextPrimary(context),
              fontSize: 15,
            ),
          ),
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
          borderSide: const BorderSide(color: AppTheme.primaryColor, width: 1.5),
        ),
        labelStyle: TextStyle(
          color: AppTheme.getTextSecondary(context),
          fontSize: 14,
        ),
        floatingLabelStyle: TextStyle(
          color: AppTheme.getTextSecondary(context),
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      ),
    );
  }

  static Widget _buildFakeInput(BuildContext context, {required String label, required String value, required IconData icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.getBorderLight(context)),
        borderRadius: BorderRadius.circular(8),
        color: AppTheme.getInputBackground(context),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppTheme.primaryColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: AppTheme.getTextSecondary(context),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 15,
                    color: AppTheme.getTextPrimary(context),
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_drop_down, color: Colors.grey),
        ],
      ),
    );
  }

  static void _showError(String message) {
    Get.snackbar(
      'Atención',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.orange.withValues(alpha: 0.8),
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
      duration: const Duration(seconds: 3),
    );
  }
}