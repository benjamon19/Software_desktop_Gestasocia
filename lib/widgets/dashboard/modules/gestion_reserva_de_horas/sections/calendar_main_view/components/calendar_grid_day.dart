import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../../../utils/app_theme.dart';
import '../../../../../../../controllers/reserva_horas_controller.dart';
import 'calendar_appointment_item.dart';
import '../../../shared/dialogs/new_reserva_dialog.dart';
import '../../../shared/dialogs/reserva_detail_dialog.dart';

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
          const endHour = 20; // 8 AM a 8 PM -> 12 horas
          const hoursToShow = endHour - startHour;
          const double borderWidth = 0.6;

          // Altura fija para cada celda horaria
          final double cellHeight = constraints.maxHeight / hoursToShow;

          return Obx(() {
            // FIX CRÍTICO: Lectura inmediata de reservas
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
                      
                      // Buscar reserva en esta hora
                      final reservaEnEstaHora = reservasDelDia.firstWhereOrNull((r) {
                        final parts = r.hora.split(':');
                        final horaReserva = int.tryParse(parts[0]);
                        return horaReserva == currentHour;
                      });

                      final DateTime slotTime = DateTime(
                        selectedDate.year,
                        selectedDate.month,
                        selectedDate.day,
                        currentHour,
                      );

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
                        child: reservaEnEstaHora != null
                            ? CalendarAppointmentItem(
                                reserva: reservaEnEstaHora,
                                viewType: 'day',
                                onTap: () {
                                  // Mostrar diálogo de detalle al hacer clic en la reserva
                                  ReservaDetailDialog.show(context, reservaEnEstaHora);
                                },
                              )
                            : Material( // Material para soportar InkWell sobre fondo transparente
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () {
                                    NewReservaDialog.show(
                                      context, 
                                      preSelectedDate: slotTime
                                    );
                                  },
                                  mouseCursor: SystemMouseCursors.click, // Cursor de mano explícito
                                  child: Container(), // Ocupa todo el espacio disponible
                                ),
                              ),
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