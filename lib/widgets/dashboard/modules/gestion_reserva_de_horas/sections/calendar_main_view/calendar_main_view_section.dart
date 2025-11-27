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

  DateTime _getAnimationBaseDate(DateTime date, String view) {
    if (view == 'month') {

      return DateTime(date.year, date.month, 1);
    } else if (view == 'week') {

      final int weekday = date.weekday;
      return date.subtract(Duration(days: weekday - 1));
    }

    return date; 
  }

  @override
  Widget build(BuildContext context) {
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
              child: KeyedSubtree(
                key: ValueKey('${animationBaseDate.year}-${animationBaseDate.month}-${animationBaseDate.day}-$selectedView'),
                child: _buildCalendarView(context),
              ),
            ),
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