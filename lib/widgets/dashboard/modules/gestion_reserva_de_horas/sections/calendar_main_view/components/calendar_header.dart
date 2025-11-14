import 'package:flutter/material.dart';
import '../../../../../../../utils/app_theme.dart';
import 'package:intl/intl.dart';

class CalendarHeader extends StatelessWidget {
  final DateTime selectedDate;
  final String selectedView;
  final Function(DateTime) onDateChanged;

  const CalendarHeader({
    super.key,
    required this.selectedDate,
    required this.selectedView,
    required this.onDateChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: AppTheme.getSurfaceColor(context),
      child: Row(
        children: [
          Text(
            _getTitle(),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.getTextPrimary(context),
            ),
          ),
          const Spacer(),
          Row(
            children: [
              IconButton(
                onPressed: () => onDateChanged(_previousDate()),
                icon: const Icon(Icons.chevron_left),
                color: AppTheme.getTextPrimary(context),
              ),
              IconButton(
                onPressed: () => onDateChanged(_nextDate()),
                icon: const Icon(Icons.chevron_right),
                color: AppTheme.getTextPrimary(context),
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                onPressed: () => onDateChanged(DateTime.now()),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  side: BorderSide(color: AppTheme.primaryColor),
                ),
                child: Text(
                  'Hoy',
                  style: TextStyle(color: AppTheme.primaryColor),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getTitle() {
    switch (selectedView) {
      case 'day':
        return DateFormat('EEEE, d \'de\' MMMM \'de\' yyyy', 'es').format(selectedDate);
      case 'month':
        return DateFormat('MMMM yyyy', 'es').format(selectedDate);
      case 'week':
        final start = _getStartOfWeek(selectedDate);
        final end = start.add(const Duration(days: 6));
        if (start.month == end.month) {
          return '${start.day} - ${end.day} de ${DateFormat('MMMM', 'es').format(end)} ${end.year}';
        } else {
          return '${start.day} de ${DateFormat('MMM', 'es').format(start)} - ${end.day} de ${DateFormat('MMM', 'es').format(end)} ${end.year}';
        }
      default:
        return '';
    }
  }

  DateTime _getStartOfWeek(DateTime date) => date.subtract(Duration(days: date.weekday - 1));

  DateTime _previousDate() {
    switch (selectedView) {
      case 'day': return selectedDate.subtract(const Duration(days: 1));
      case 'week': return selectedDate.subtract(const Duration(days: 7));
      case 'month': return DateTime(selectedDate.year, selectedDate.month - 1, 1);
      default: return selectedDate;
    }
  }

  DateTime _nextDate() {
    switch (selectedView) {
      case 'day': return selectedDate.add(const Duration(days: 1));
      case 'week': return selectedDate.add(const Duration(days: 7));
      case 'month': return DateTime(selectedDate.year, selectedDate.month + 1, 1);
      default: return selectedDate;
    }
  }
}