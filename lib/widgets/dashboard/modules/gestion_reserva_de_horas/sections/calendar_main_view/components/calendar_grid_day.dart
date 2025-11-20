import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../../../utils/app_theme.dart';
import '../../../../../../../controllers/reserva_horas_controller.dart';
import 'calendar_appointment_item.dart';
import 'calendar_group_item.dart'; 
import '../../../shared/dialogs/reserva_detail_dialog.dart';
import '../../../shared/dialogs/multi_reserva_dialog.dart'; 

class CalendarGridDay extends StatelessWidget {
  final DateTime selectedDate;
  final Function(DateTime) onTimeSlotTap;

  const CalendarGridDay({
    super.key,
    required this.selectedDate,
    required this.onTimeSlotTap,
  });

  @override
  Widget build(BuildContext context) {
    final ReservaHorasController controller = Get.isRegistered<ReservaHorasController>()
        ? Get.find<ReservaHorasController>()
        : Get.put(ReservaHorasController());

    return Container(
      color: AppTheme.getBackgroundColor(context),
      child: LayoutBuilder(
        builder: (context, constraints) {
          const startHour = 8;
          const endHour = 20; 
          const hoursToShow = endHour - startHour;
          const double borderWidth = 0.6;

          // CORRECCIÓN DE ALTURA: No restar bordes para evitar el desfase de píxeles
          final double cellHeight = constraints.maxHeight / hoursToShow;

          return Obx(() {
            final allReservas = controller.reservas.toList();

            final reservasDelDia = allReservas.where((r) =>
              r.fecha.year == selectedDate.year &&
              r.fecha.month == selectedDate.month &&
              r.fecha.day == selectedDate.day
            ).toList();

            return Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Columna de horas
                SizedBox(
                  width: 60,
                  child: Column(
                    children: List.generate(hoursToShow, (index) {
                      final hour = startHour + index;
                      final time = hour <= 12 ? '$hour AM' : '${hour - 12} PM';
                      return Container(
                        height: cellHeight,
                        padding: const EdgeInsets.only(right: 8, top: 4),
                        alignment: Alignment.topRight,
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: Colors.grey.withValues(alpha: 0.35),
                              width: borderWidth,
                            ),
                            right: BorderSide(
                              color: Colors.grey.withValues(alpha: 0.25),
                              width: borderWidth,
                            ),
                          ),
                        ),
                        child: Text(
                          time,
                          style: TextStyle(
                            fontSize: 11,
                            color: AppTheme.getTextSecondary(context),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                // Grid de slots horarios
                Expanded(
                  child: Column(
                    children: List.generate(hoursToShow, (index) {
                      final currentHour = startHour + index;
                      
                      // Buscar TODAS las reservas en esta hora
                      final reservasEnEstaHora = reservasDelDia.where((r) {
                        final parts = r.hora.split(':');
                        final horaReserva = int.tryParse(parts[0]);
                        return horaReserva == currentHour;
                      }).toList();

                      final DateTime slotTime = DateTime(
                        selectedDate.year,
                        selectedDate.month,
                        selectedDate.day,
                        currentHour,
                      );

                      // Decidir qué widget mostrar
                      Widget contentWidget;
                      
                      if (reservasEnEstaHora.isEmpty) {
                        // Caso 0: Vacío -> Botón transparente
                        contentWidget = Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => onTimeSlotTap(slotTime),
                            mouseCursor: SystemMouseCursors.click,
                            child: Container(),
                          ),
                        );
                      } else if (reservasEnEstaHora.length == 1) {
                        // Caso 1: Una sola reserva -> Detalle normal
                        final reserva = reservasEnEstaHora.first;
                        contentWidget = CalendarAppointmentItem(
                          reserva: reserva,
                          viewType: 'day',
                          onTap: () {
                            ReservaDetailDialog.show(context, reserva);
                          },
                        );
                      } else {
                        // Caso 2+: Múltiples reservas -> Grupo
                        contentWidget = CalendarGroupItem(
                          reservas: reservasEnEstaHora,
                          onTap: () {
                            MultiReservaDialog.show(
                              context, 
                              reservasEnEstaHora, 
                              '${currentHour.toString().padLeft(2, '0')}:00'
                            );
                          },
                        );
                      }

                      return Container(
                        height: cellHeight,
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: Colors.grey.withValues(alpha: 0.3),
                              width: borderWidth,
                            ),
                            right: BorderSide(
                              color: Colors.grey.withValues(alpha: 0.2),
                              width: borderWidth,
                            ),
                          ),
                        ),
                        child: contentWidget,
                      );
                    }),
                  ),
                ),
              ],
            );
          });
        },
      ),
    );
  }
}