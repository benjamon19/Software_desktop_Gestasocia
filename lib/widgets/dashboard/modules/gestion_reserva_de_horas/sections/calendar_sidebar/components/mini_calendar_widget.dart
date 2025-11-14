import 'package:flutter/material.dart';
import '../../../../../../../utils/app_theme.dart';

class MiniCalendarWidget extends StatelessWidget {
  final DateTime selectedDate;
  final Function(DateTime) onDateSelected;

  const MiniCalendarWidget({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    final displayYear = selectedDate.year;
    final displayMonth = selectedDate.month;
    final daysInMonth = DateTime(displayYear, displayMonth + 1, 0).day;
    final firstWeekday = DateTime(displayYear, displayMonth, 1).weekday;

    final now = DateTime.now();

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.getBorderLight(context)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            alignment: Alignment.center,
            child: Text(
              '${_monthName(displayMonth)} $displayYear',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: AppTheme.getTextPrimary(context),
              ),
            ),
          ),
          Wrap(
            spacing: 0,
            runSpacing: 0,
            children: ['L', 'M', 'X', 'J', 'V', 'S', 'D'].map((day) {
              return SizedBox(
                width: 32,
                height: 32,
                child: Center(
                  child: Text(
                    day,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.getTextSecondary(context),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          Wrap(
            spacing: 0,
            runSpacing: 0,
            children: List.generate(42, (index) {
              final dayNumber = index - firstWeekday + 2;
              if (dayNumber < 1 || dayNumber > daysInMonth) {
                return const SizedBox(width: 32, height: 32);
              }

              final date = DateTime(displayYear, displayMonth, dayNumber);
              final isToday = _isSameDay(date, now);
              final isSelected = _isSameDay(date, selectedDate);

              return SizedBox(
                width: 32,
                height: 32,
                child: InkWell(
                  onTap: () => onDateSelected(date),
                  child: Center(
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppTheme.primaryColor
                            : isToday
                                ? AppTheme.primaryColor.withValues(alpha: 0.2)
                                : Colors.transparent,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '$dayNumber',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isToday || isSelected ? FontWeight.w600 : null,
                            color: isSelected
                                ? Colors.white
                                : AppTheme.getTextPrimary(context),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  String _monthName(int month) {
    final names = [
      'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
    ];
    return names[month - 1];
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}