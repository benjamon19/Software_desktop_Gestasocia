import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../../../../utils/app_theme.dart';
import '../../../../../../models/reserva_hora.dart';
import '../../../../../../controllers/reserva_horas_controller.dart';
import 'delete_reserva_dialog.dart';
import 'edit_reserva_dialog.dart';

class ReservaDetailDialog {
  static const double dialogWidth = 550.0; 
  static void show(BuildContext context, ReservaHora reserva) {
    final ReservaHorasController controller = Get.find<ReservaHorasController>();
    
    final selectedEstado = reserva.estado.obs;
    final isLoading = false.obs;

    Future<void> quickUpdateAction() async {
      if (isLoading.value) return;
      isLoading.value = true;

      final reservaActualizada = reserva.copyWith(
        estado: selectedEstado.value,
      );

      final success = await controller.updateReserva(reservaActualizada);
      isLoading.value = false;

      if (success && context.mounted) {
        Navigator.of(context).pop(); 
      }
    }

    Future<void> deleteReservaAction() async {
      if (reserva.id == null) return;

      DeleteReservaDialog.show(
        context,
        reserva: reserva,
        onConfirm: () async {
          await controller.deleteReserva(reserva.id!);
          if (context.mounted) Navigator.of(context).pop();
        },
      );
    }

    Future<void> fullEditAction() async {
      EditReservaDialog.show(
        context,
        reserva: reserva,
        onSave: (reservaEditada) async {
          final success = await controller.updateReserva(reservaEditada);
          if (success && context.mounted) {
             Navigator.of(context).pop(); 
          }
        },
      );
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
              if (!isLoading.value) quickUpdateAction();
              return KeyEventResult.handled;
            }
          }
          return KeyEventResult.ignored;
        },
        child: AlertDialog(
          backgroundColor: AppTheme.getSurfaceColor(context),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          
          // TÍTULO
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.calendar_today, color: AppTheme.primaryColor, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Detalle de Reserva',
                      style: TextStyle(
                        color: AppTheme.getTextPrimary(context),
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${reserva.fechaFormateada} • ${reserva.hora}',
                      style: TextStyle(
                        color: AppTheme.getTextSecondary(context),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Text(
                'ESC volver • Enter guardar',
                style: TextStyle(
                  color: AppTheme.getTextSecondary(context),
                  fontSize: 12,
                ),
              ),
            ],
          ),

          // CONTENIDO (Aquí se aplica el ancho controlado por la variable)
          content: SizedBox(
            width: dialogWidth, // <--- AQUI SE USA LA VARIABLE
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Obx(() => _buildDropdown(
                        context, 'Estado Actual',
                        ['Pendiente', 'Confirmada', 'Realizada', 'Cancelada'],
                        Icons.info_outline, selectedEstado, isLoading,
                      )),

                  const SizedBox(height: 24),
                  
                  _buildSectionTitle(context, 'Información del Paciente'),
                  const SizedBox(height: 8),
                  _buildInfoCard(context, [
                    _buildInfoRow(context, 'Nombre', reserva.pacienteNombre, Icons.person),
                    const SizedBox(height: 8),
                    _buildInfoRow(context, 'RUT', reserva.pacienteRut, Icons.badge),
                    const SizedBox(height: 8),
                    _buildInfoRow(context, 'Tipo', reserva.pacienteTipo.capitalizeFirst ?? '', Icons.category),
                  ]),

                  const SizedBox(height: 24),
                  
                  _buildSectionTitle(context, 'Detalles de la Cita'),
                  const SizedBox(height: 8),
                  _buildInfoCard(context, [
                    _buildInfoRow(context, 'Odontólogo', reserva.odontologo, Icons.medical_services),
                    const SizedBox(height: 8),
                    _buildInfoRow(context, 'Motivo', reserva.motivo, Icons.description),
                    if (reserva.observaciones != null && reserva.observaciones!.isNotEmpty) ...[
                       const SizedBox(height: 8),
                       const Divider(height: 16),
                       _buildInfoRow(context, 'Observaciones', reserva.observaciones!, Icons.notes),
                    ]
                  ]),
                ],
              ),
            ),
          ),

          // ACCIONES
          actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          actions: [
            // Usamos un SizedBox con el mismo ancho que el contenido para mantener consistencia
            SizedBox(
              width: dialogWidth, 
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center, // ALINEACION VERTICAL CENTRADA
                children: [
                  // Botón Eliminar
                  if (!isLoading.value)
                    TextButton(
                      onPressed: deleteReservaAction,
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Eliminar'),
                    ),
                  
                  const Spacer(), // Empuja los siguientes botones a la derecha

                  TextButton(
                    onPressed: isLoading.value ? null : fullEditAction,
                    child: Text('Editar Todo', style: TextStyle(color: AppTheme.primaryColor)),
                  ),

                  const SizedBox(width: 4),

                  TextButton(
                    onPressed: isLoading.value ? null : () => Navigator.of(context).pop(),
                    child: Text('Cerrar', style: TextStyle(color: AppTheme.getTextSecondary(context))),
                  ),

                  const SizedBox(width: 8),

                  Obx(() => ElevatedButton(
                      onPressed: isLoading.value ? null : quickUpdateAction,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        elevation: 0,
                      ),
                      child: isLoading.value
                          ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Text('Guardar'),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  // --- Helpers ---

  static Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(title, style: TextStyle(color: AppTheme.getTextPrimary(context), fontWeight: FontWeight.w600, fontSize: 15));
  }

  static Widget _buildInfoCard(BuildContext context, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.getInputBackground(context),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.getBorderLight(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  static Widget _buildInfoRow(BuildContext context, String label, String value, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppTheme.getTextSecondary(context)),
        const SizedBox(width: 12),
        SizedBox(width: 90, child: Text(label, style: TextStyle(color: AppTheme.getTextSecondary(context), fontWeight: FontWeight.w500, fontSize: 13))),
        Expanded(child: Text(value, style: TextStyle(color: AppTheme.getTextPrimary(context), fontWeight: FontWeight.w500, fontSize: 13))),
      ],
    );
  }

  static Widget _buildDropdown(BuildContext context, String label, List<String> items, IconData icon, RxString selectedValue, RxBool isLoading) {
    return DropdownButtonFormField<String>(
      initialValue: items.contains(selectedValue.value) ? selectedValue.value : items.first,
      items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
      onChanged: isLoading.value ? null : (value) { if (value != null) selectedValue.value = value; },
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppTheme.primaryColor),
        labelStyle: TextStyle(color: AppTheme.getTextSecondary(context)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: AppTheme.getBorderLight(context))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: AppTheme.getBorderLight(context))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: AppTheme.primaryColor, width: 1)),
      ),
      dropdownColor: AppTheme.getSurfaceColor(context),
    );
  }
}