import 'package:flutter/material.dart';

import 'components/calendar_header.dart';
import 'components/calendar_grid_day.dart';
import 'components/calendar_grid_week.dart';
import 'components/calendar_grid_month.dart';

class CalendarMainViewSection extends StatelessWidget {
  final DateTime selectedDate;
  final String selectedView;
  final Function(DateTime) onDateChanged;
  final Function(DateTime) onTimeSlotTap;
  final Function(String) onViewChanged; 

  const CalendarMainViewSection({
    super.key,
    required this.selectedDate,
    required this.selectedView,
    required this.onDateChanged,
    required this.onTimeSlotTap,
    required this.onViewChanged,
  });

  // Helper para obtener la fecha clave que define el contenido visible
  DateTime _getAnimationBaseDate(DateTime date, String view) {
    if (view == 'month') {
      // Clave basada en el inicio del mes (Día 1)
      return DateTime(date.year, date.month, 1);
    } else if (view == 'week') {
      // Clave basada en el inicio de la semana (Lunes). 
      // Si seleccionas Miércoles o Viernes de la misma semana, la clave NO cambia.
      // Dart: weekday=1(Mon), ..., weekday=7(Sun)
      final int weekday = date.weekday;
      return date.subtract(Duration(days: weekday - 1));
    }
    // Para 'day' o cualquier otra vista, la fecha completa es la clave
    return date; 
  }

  @override
  Widget build(BuildContext context) {
    // Calcular la fecha base para la clave de animación
    final DateTime animationBaseDate = _getAnimationBaseDate(selectedDate, selectedView);

    return Column(
      children: [
        CalendarHeader(
          selectedDate: selectedDate,
          selectedView: selectedView,
          onDateChanged: onDateChanged,
        ),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            // === ANIMATION IMPLEMENTATION ===
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250), 
              switchInCurve: Curves.easeOut,
              switchOutCurve: Curves.easeIn,
              transitionBuilder: (Widget child, Animation<double> animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0.05, 0.0), 
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  ),
                );
              },
              // La clave ahora usa la fecha base (inicio de semana/mes), 
              // impidiendo la animación al seleccionar un día dentro del rango visible.
              child: KeyedSubtree(
                key: ValueKey('${animationBaseDate.year}-${animationBaseDate.month}-${animationBaseDate.day}-$selectedView'),
                child: _buildCalendarView(context),
              ),
            ),
            // === END ANIMATION ===
          ),
        ),
      ],
    );
  }

  Widget _buildCalendarView(BuildContext context) {
    if (selectedView == 'day') {
      return CalendarGridDay(
        selectedDate: selectedDate,
        onTimeSlotTap: onTimeSlotTap,
      );
    }

    if (selectedView == 'month') {
      return CalendarGridMonth(
        selectedDate: selectedDate,
        onDateTap: onDateChanged,
        onViewChanged: onViewChanged, 
      );
    }

    if (selectedView == 'week') {
      return CalendarGridWeek(
        selectedDate: selectedDate,
        onDateTap: onDateChanged,
        onTimeSlotTap: onTimeSlotTap,
      );
    }

    return CalendarGridDay(
      selectedDate: selectedDate,
      onTimeSlotTap: onTimeSlotTap,
    );
  }
}