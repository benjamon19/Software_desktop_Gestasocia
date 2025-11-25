import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../../../utils/app_theme.dart';
import '../../../../../../models/reserva_hora.dart';
import '../../../../../../controllers/reserva_horas_controller.dart';

class EditReservaDialog {
  static void show(
    BuildContext context, {
    required ReservaHora reserva,
    required Future<void> Function(ReservaHora) onSave,
  }) {
    // 1. Obtener controlador para validar disponibilidad
    final ReservaHorasController controller = Get.find<ReservaHorasController>();

    // 2. Parsear hora inicial (String "HH:mm" -> TimeOfDay)
    TimeOfDay initialTime;
    try {
      final parts = reserva.hora.split(':');
      initialTime = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    } catch (e) {
      initialTime = TimeOfDay.now();
    }

    // 3. Controladores y Variables
    final motivoController = TextEditingController(text: reserva.motivo);
    final observacionesController = TextEditingController(text: reserva.observaciones ?? "");
    
    final selectedEstado = reserva.estado.obs;
    final selectedDate = Rx<DateTime>(reserva.fecha);
    final selectedTime = Rx<TimeOfDay>(initialTime);
    final isLoading = false.obs;

    // 4. Acción de Actualizar
    Future<void> updateAction() async {
      // Validación básica
      if (motivoController.text.trim().length < 3) {
        _showError('El motivo es requerido (mínimo 3 caracteres)');
        return;
      }

      // Formatear nueva hora
      final horaFormat = '${selectedTime.value.hour.toString().padLeft(2, '0')}:${selectedTime.value.minute.toString().padLeft(2, '0')}';

      // VALIDACIÓN DE CONFLICTOS (Solo si cambió la fecha o la hora)
      // Si es la misma hora original, no validamos para evitar conflicto con "uno mismo"
      bool horarioCambio = (reserva.fecha.year != selectedDate.value.year || 
                            reserva.fecha.month != selectedDate.value.month ||
                            reserva.fecha.day != selectedDate.value.day ||
                            reserva.hora != horaFormat);

      if (horarioCambio) {
        final error = controller.validarReserva(
          reserva.odontologo, // Mantenemos el mismo odontólogo
          selectedDate.value,
          horaFormat
        );

        if (error != null) {
          Get.snackbar(
            'Horario no disponible',
            error,
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.orange.withValues(alpha: 0.9),
            colorText: Colors.white,
            margin: const EdgeInsets.all(16),
            borderRadius: 8,
            duration: const Duration(seconds: 4),
          );
          return; // Detener guardado
        }
      }

      isLoading.value = true;

      final editada = reserva.copyWith(
        motivo: motivoController.text.trim(),
        observaciones: observacionesController.text.trim(),
        estado: selectedEstado.value,
        fecha: selectedDate.value,
        hora: horaFormat,
      );

      await onSave(editada);
      
      isLoading.value = false;
      if (context.mounted) Navigator.of(context).pop();
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
              if (!isLoading.value) updateAction();
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
              const Icon(Icons.edit_calendar, color: AppTheme.primaryColor, size: 28),
              const SizedBox(width: 12),
              Text(
                "Editar Reserva",
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
                  // Info Paciente (Read Only style)
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
                        Column(
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
                              reserva.pacienteNombre,
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
                  
                  const SizedBox(height: 24),
                  
                  // Datos de la Cita
                  Text(
                    'Detalles de la Cita',
                    style: TextStyle(
                      color: AppTheme.getTextPrimary(context),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      // FECHA
                      Expanded(
                        child: Obx(() => InkWell(
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: selectedDate.value,
                              firstDate: DateTime(2020),
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
                      // HORA
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
                  
                  const SizedBox(height: 16),

                  Obx(() => _buildDropdown(
                    context,
                    "Estado",
                    ["Pendiente", "Confirmada", "Realizada", "Cancelada"],
                    Icons.info_outline,
                    selectedEstado,
                  )),

                  const SizedBox(height: 24),

                  Text(
                    'Información Médica',
                    style: TextStyle(
                      color: AppTheme.getTextPrimary(context),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),

                  _buildTextField(
                    context, 
                    "Motivo", 
                    Icons.description, 
                    motivoController,
                    hintText: "Ej: Dolor muela, Control...",
                    capitalization: TextCapitalization.sentences
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    context, 
                    "Observaciones", 
                    Icons.notes, 
                    observacionesController, 
                    maxLines: 3,
                    hintText: "Notas internas...",
                    capitalization: TextCapitalization.sentences
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: isLoading.value ? null : () => Navigator.of(context).pop(),
              child: Text(
                "Cancelar",
                style: TextStyle(color: AppTheme.getTextSecondary(context)),
              ),
            ),
            Obx(() => ElevatedButton(
                onPressed: isLoading.value ? null : updateAction,
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
                        child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white))
                      )
                    : const Text("Actualizar Reserva"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Helpers ---

  static Widget _buildTextField(
    BuildContext context, 
    String label, 
    IconData icon, 
    TextEditingController c, {
    int maxLines = 1, 
    String? hintText,
    TextCapitalization capitalization = TextCapitalization.none,
  }) {
    return TextField(
      controller: c,
      maxLines: maxLines,
      textCapitalization: capitalization,
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
          borderSide: BorderSide(color: AppTheme.primaryColor, width: 1.5),
        ),
        filled: true,
        fillColor: AppTheme.getInputBackground(context),
      ),
    );
  }

  static Widget _buildDropdown(BuildContext context, String label, List<String> items, IconData icon, RxString selected) {
    // Asegurar valor válido
    if (!items.contains(selected.value)) {
      // Intento inteligente de coincidencia (ej: "pendiente" vs "Pendiente")
      final match = items.firstWhereOrNull((i) => i.toLowerCase() == selected.value.toLowerCase());
      if (match != null) {
        selected.value = match;
      } else {
        selected.value = items.first;
      }
    }
    return DropdownButtonFormField<String>(
      initialValue: selected.value,
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
          borderSide: BorderSide(color: AppTheme.primaryColor, width: 1.5),
        ),
        filled: true,
        fillColor: AppTheme.getInputBackground(context),
      ),
      dropdownColor: AppTheme.getSurfaceColor(context),
      items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: TextStyle(color: AppTheme.getTextPrimary(context))))).toList(),
      onChanged: (v) => selected.value = v!,
    );
  }

  static Widget _buildFakeInput(BuildContext context, {required String label, required String value, required IconData icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16), // Altura consistente con TextFields
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.getBorderLight(context)),
        borderRadius: BorderRadius.circular(8),
        color: AppTheme.getInputBackground(context),
      ),
      child: Row(
        children: [
          Icon(icon, size: 24, color: AppTheme.primaryColor), // Tamaño ajustado al prefixIcon por defecto
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (value.isNotEmpty)
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 11,
                      color: AppTheme.getTextSecondary(context),
                    ),
                  ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
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