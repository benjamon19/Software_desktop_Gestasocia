import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../../../../utils/app_theme.dart';
import '../../../../../../models/reserva_hora.dart';

class EditReservaDialog {
  static void show(
    BuildContext context, {
    required ReservaHora reserva,
    required Future<void> Function(ReservaHora) onSave,
  }) {
    // Controladores
    final motivoController = TextEditingController(text: reserva.motivo);
    final observacionesController = TextEditingController(text: reserva.observaciones ?? "");
    final selectedHora = TextEditingController(text: reserva.hora);

    // Reactivos
    final selectedEstado = reserva.estado.obs;
    final selectedFecha = Rxn<DateTime>(reserva.fecha);
    final isLoading = false.obs;

    Future<void> updateAction() async {
      if (motivoController.text.trim().isEmpty) {
        Get.snackbar(
          "Error", 
          "El motivo es requerido",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent.withValues(alpha: 0.8),
          colorText: Colors.white,
        );
        return;
      }

      isLoading.value = true;

      final editada = reserva.copyWith(
        motivo: motivoController.text.trim(),
        observaciones: observacionesController.text.trim(),
        estado: selectedEstado.value,
        fecha: selectedFecha.value ?? reserva.fecha,
        hora: selectedHora.text.trim(),
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
              // Usamos primaryColor para Reservas, o puedes usar el azul (0xFF3B82F6) si prefieres
              Icon(Icons.edit_calendar, color: AppTheme.primaryColor, size: 28),
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

                  Obx(() => _buildDropdown(
                    context,
                    "Estado",
                    ["Pendiente", "Confirmada", "Realizada", "Cancelada"],
                    Icons.info_outline,
                    selectedEstado,
                  )),
                  
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(child: _buildDatePicker(context, selectedFecha)),
                      const SizedBox(width: 16),
                      Expanded(child: _buildTextField(context, "Hora", Icons.access_time, selectedHora)),
                    ],
                  ),

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

                  _buildTextField(context, "Motivo", Icons.description, motivoController),
                  const SizedBox(height: 16),
                  _buildTextField(context, "Observaciones", Icons.notes, observacionesController, maxLines: 3),
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

  // --- Helpers (Estilo AppTheme + OutlineInputBorder) ---

  static Widget _buildTextField(BuildContext context, String label, IconData icon, TextEditingController c, {int maxLines = 1}) {
    return TextField(
      controller: c,
      maxLines: maxLines,
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

  static Widget _buildDropdown(BuildContext context, String label, List<String> items, IconData icon, RxString selected) {
    if (!items.contains(selected.value)) {
      selected.value = items.first;
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
          borderSide: BorderSide(color: AppTheme.primaryColor, width: 1),
        ),
      ),
      dropdownColor: AppTheme.getSurfaceColor(context),
      items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
      onChanged: (v) => selected.value = v!,
    );
  }

  static Widget _buildDatePicker(BuildContext context, Rxn<DateTime> selectedDate) {
    return Obx(() => InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: selectedDate.value ?? DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
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
        if (picked != null) selectedDate.value = picked;
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
                selectedDate.value == null
                    ? "Seleccionar fecha"
                    : "${selectedDate.value!.day}/${selectedDate.value!.month}/${selectedDate.value!.year}",
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
}