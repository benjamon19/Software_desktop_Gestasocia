import 'package:flutter/material.dart';
import 'components/calendar_header.dart';
import 'components/calendar_grid_week.dart';
import 'components/calendar_grid_day.dart';
import 'components/calendar_grid_month.dart';

class CalendarMainViewSection extends StatelessWidget {
  final DateTime selectedDate;
  final String selectedView;
  final Function(DateTime) onDateChanged;

  const CalendarMainViewSection({
    super.key,
    required this.selectedDate,
    required this.selectedView,
    required this.onDateChanged,
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
            child: _buildCalendarView(context),
          ),
        ),
      ],
    );
  }

  Widget _buildCalendarView(BuildContext context) {
    switch (selectedView) {
      case 'day':
        return CalendarGridDay(
          selectedDate: selectedDate,
          onTimeSlotTap: (dt) => onDateChanged(dt),
        );

      case 'month':
        return CalendarGridMonth(
          selectedDate: selectedDate,
          onDateTap: onDateChanged,
        );

      case 'week':
      default:
        return CalendarGridWeek(
          selectedDate: selectedDate,
          onTimeSlotTap: (dt) => onDateChanged(dt),
          onDateTap: onDateChanged,
        );
    }
  }
}
