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
        borderRadius: BorderRadius.circular(8), // ligeramente menos redondeado
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // === Encabezado (mes y año) ===
          Container(
            padding: const EdgeInsets.symmetric(vertical: 6), // menos padding
            alignment: Alignment.center,
            child: Text(
              '${_monthName(displayMonth)} $displayYear',
              style: TextStyle(
                fontSize: 13, // antes: implícito ~14-16
                fontWeight: FontWeight.w600,
                color: AppTheme.getTextPrimary(context),
              ),
            ),
          ),
          // === Días de la semana (L, M, X...) ===
          Wrap(
            spacing: 0,
            runSpacing: 0,
            children: ['L', 'M', 'X', 'J', 'V', 'S', 'D'].map((day) {
              return SizedBox(
                width: 28, // antes: 32
                height: 28, // antes: 32
                child: Center(
                  child: Text(
                    day,
                    style: TextStyle(
                      fontSize: 10, // antes: 11
                      fontWeight: FontWeight.w600,
                      color: AppTheme.getTextSecondary(context),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          // === Días del mes ===
          Wrap(
            spacing: 0,
            runSpacing: 0,
            children: List.generate(42, (index) {
              final dayNumber = index - firstWeekday + 2;
              if (dayNumber < 1 || dayNumber > daysInMonth) {
                return const SizedBox(width: 28, height: 28); // antes: 32
              }

              final date = DateTime(displayYear, displayMonth, dayNumber);
              final isToday = _isSameDay(date, now);
              final isSelected = _isSameDay(date, selectedDate);

              return SizedBox(
                width: 28,
                height: 28,
                child: InkWell(
                  onTap: () => onDateSelected(date),
                  borderRadius: BorderRadius.circular(14),
                  child: Center(
                    child: Container(
                      width: 24, // antes: 28
                      height: 24, // antes: 28
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
                            fontSize: 11, // antes: 12
                            fontWeight: isToday || isSelected ? FontWeight.w600 : FontWeight.normal,
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