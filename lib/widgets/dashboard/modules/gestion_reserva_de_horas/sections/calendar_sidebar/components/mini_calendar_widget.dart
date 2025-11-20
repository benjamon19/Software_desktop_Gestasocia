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
    final now = DateTime.now();
    
    // FIX ERRORES: Declaramos firstDayOfMonth para que sea accesible.
    final DateTime firstDayOfMonth = DateTime(displayYear, displayMonth, 1); 

    // Cálculo de días visibles
    final int totalRows = 6; 
    // Cálculo de offset (Sunday=0, Monday=1, ..., Saturday=6).
    // Si es domingo (7), 7 % 7 = 0. Si es lunes (1), 1 % 7 = 1.
    final int weekdayOffset = firstDayOfMonth.weekday % 7; 
    final DateTime firstVisibleDate = firstDayOfMonth.subtract(Duration(days: weekdayOffset)); 
    final List<DateTime> visibleDays = List.generate(
      totalRows * 7,
      (i) => firstVisibleDate.add(Duration(days: i)),
    );

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.getBorderLight(context)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // === Encabezado (mes y año) ===
          Container(
            padding: const EdgeInsets.symmetric(vertical: 6),
            alignment: Alignment.center,
            child: Text(
              '${_monthName(displayMonth)} $displayYear',
              style: TextStyle(
                fontSize: 13, 
                fontWeight: FontWeight.w600,
                color: AppTheme.getTextPrimary(context),
              ),
            ),
          ),
          
          // === Días de la semana (D, L, M, X...) ===
          Wrap(
            spacing: 0,
            runSpacing: 0,
            // Empieza en Domingo (D) para la estética de Google Calendar
            children: ['D', 'L', 'M', 'X', 'J', 'V', 'S'].map((day) { 
              return SizedBox(
                width: 28, 
                height: 28, 
                child: Center(
                  child: Text(
                    day,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.getTextSecondary(context),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          
          // === Días del mes (ENVUELTO EN ANIMATED SWITCHER) ===
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
            child: KeyedSubtree(
              key: ValueKey('$displayYear-$displayMonth'),
              child: Wrap(
                spacing: 0,
                runSpacing: 0,
                children: List.generate(visibleDays.length, (index) {
                  final day = visibleDays[index];
                  final bool isToday = _isSameDay(day, now);
                  final bool isSelected = _isSameDay(day, selectedDate);
                  final bool isCurrentMonth = day.month == displayMonth;

                  // Ocultar los días de relleno al final si no son del mes
                  if (index >= 35 && day.month != displayMonth) {
                      return const SizedBox(width: 28, height: 28);
                  }
                  
                  return SizedBox(
                    width: 28,
                    height: 28,
                    child: InkWell(
                      onTap: () => onDateSelected(day),
                      borderRadius: BorderRadius.circular(14),
                      child: Center(
                        child: Container(
                          width: 24, 
                          height: 24, 
                          decoration: BoxDecoration(
                            // Fondo sólido para el seleccionado
                            color: isSelected
                                ? AppTheme.primaryColor
                                : isToday
                                    ? AppTheme.primaryColor.withValues(alpha: 0.2)
                                    : Colors.transparent,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              "${day.day}",
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: isToday || isSelected ? FontWeight.w600 : FontWeight.normal,
                                color: isSelected
                                    ? Colors.white
                                    : (isCurrentMonth
                                        ? AppTheme.getTextPrimary(context)
                                        : AppTheme.getTextSecondary(context).withValues(alpha: 0.35)), // Opacidad para días fuera del mes actual
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
          const SizedBox(height: 8), 
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