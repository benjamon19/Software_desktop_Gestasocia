import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../../../utils/app_theme.dart';
import '../../../../../../../controllers/reserva_horas_controller.dart';
import 'calendar_appointment_item.dart';

class CalendarGridMonth extends StatelessWidget {
  final DateTime selectedDate;
  final Function(DateTime) onDateTap;

  const CalendarGridMonth({
    super.key,
    required this.selectedDate,
    required this.onDateTap,
  });

  @override
  Widget build(BuildContext context) {
    final ReservaHorasController controller = Get.isRegistered<ReservaHorasController>()
        ? Get.find<ReservaHorasController>()
        : Get.put(ReservaHorasController());

    final DateTime firstDayOfMonth = DateTime(selectedDate.year, selectedDate.month, 1);
    final int weekdayOffset = firstDayOfMonth.weekday % 7;
    final DateTime firstVisibleDate = firstDayOfMonth.subtract(Duration(days: weekdayOffset));
    //final int daysInMonth = DateTime(selectedDate.year, selectedDate.month + 1, 0).day; // No se usa directamente
    //final int totalCells = weekdayOffset + daysInMonth; // No se usa
    final int totalRows = 6; // Forzar 6 filas para consistencia visual mensual
    final List<DateTime> visibleDays = List.generate(
      totalRows * 7,
      (i) => firstVisibleDate.add(Duration(days: i)),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final double cellWidth = constraints.maxWidth / 7;
        final double rowHeight = constraints.maxHeight / (totalRows + 0.5);

        return Column(
          children: [
            // Encabezado de días
            SizedBox(
              height: rowHeight * 0.5,
              child: _buildWeekHeader(context),
            ),

            Expanded(
              child: Obx(() {
                // Materializar lista para evitar error de GetX
                final allReservas = controller.reservas.toList();

                return GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.zero,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7,
                    childAspectRatio: cellWidth / rowHeight,
                  ),
                  itemCount: visibleDays.length,
                  itemBuilder: (context, index) {
                    final day = visibleDays[index];
                    final bool isToday = _isSameDay(day, DateTime.now());
                    final bool isSelected = _isSameDay(day, selectedDate);
                    final bool isCurrentMonth = day.month == selectedDate.month;

                    // Contar reservas del día (sin filtrar detalles, solo cantidad)
                    final int totalCitas = allReservas.where((r) =>
                        r.fecha.year == day.year &&
                        r.fecha.month == day.month &&
                        r.fecha.day == day.day
                    ).length;

                    return Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => onDateTap(day),
                        mouseCursor: SystemMouseCursors.click, // Cursor de mano en todo el día
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.grey.withValues(alpha: 0.2),
                            ),
                            color: isSelected
                                ? AppTheme.primaryColor.withValues(alpha: 0.08)
                                : Colors.transparent,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Número del día
                              Padding(
                                padding: const EdgeInsets.all(6),
                                child: Align(
                                  alignment: Alignment.topCenter,
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: isToday
                                          ? AppTheme.primaryColor.withValues(alpha: 0.9)
                                          : Colors.transparent,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Text(
                                      "${day.day}",
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                                        color: isToday 
                                            ? Colors.white 
                                            : (isCurrentMonth
                                                ? AppTheme.getTextPrimary(context)
                                                : AppTheme.getTextSecondary(context).withValues(alpha: 0.35)),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              
                              // Indicador de Citas (Bloque único centrado)
                              if (totalCitas > 0)
                                Expanded(
                                  child: Center(
                                    child: CalendarAppointmentItem(
                                      summaryCount: totalCitas, // Solo pasamos la cantidad
                                      viewType: 'month',
                                      onTap: () {
                                        onDateTap(day); // Al tocar, ir al día para ver detalles
                                      },
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        );
      },
    );
  }

  Widget _buildWeekHeader(BuildContext context) {
    const days = ["L", "M", "M", "J", "V", "S", "D"];
    return Row(
      children: days
          .map(
            (d) => Expanded(
              child: Center(
                child: Text(
                  d,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.getTextSecondary(context),
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}