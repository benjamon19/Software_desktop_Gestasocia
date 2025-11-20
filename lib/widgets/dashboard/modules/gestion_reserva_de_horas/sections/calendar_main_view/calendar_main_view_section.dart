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

  @override
  Widget build(BuildContext context) {
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
                // Transición con fade y un ligero slide horizontal
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      // El movimiento es mínimo (0.05) para ser un efecto sutil y rápido
                      begin: const Offset(0.05, 0.0), 
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  ),
                );
              },
              // La clave debe cambiar si la fecha o la vista cambia
              child: KeyedSubtree(
                key: ValueKey('${selectedDate.year}-${selectedDate.month}-${selectedDate.day}-$selectedView'),
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

    // Default a día
    return CalendarGridDay(
      selectedDate: selectedDate,
      onTimeSlotTap: onTimeSlotTap,
    );
  }
}