import 'package:flutter/material.dart';
import '../../../../../utils/app_theme.dart';
import 'sections/calendar_sidebar/calendar_sidebar_section.dart';
import 'sections/calendar_main_view/calendar_main_view_section.dart';
import 'shared/dialogs/new_reserva_dialog.dart';

class ReservaDeHorasMainView extends StatefulWidget {
  const ReservaDeHorasMainView({super.key});

  @override
  State<ReservaDeHorasMainView> createState() => _ReservaDeHorasMainViewState();
}

class _ReservaDeHorasMainViewState extends State<ReservaDeHorasMainView> {
  String selectedView = 'day';
  DateTime selectedDate = DateTime.now();

  // Método para abrir el diálogo recibiendo la fecha del grid
  void _onTimeSlotTap(DateTime dateWithTime) {
    NewReservaDialog.show(
      context,
      preSelectedDate: dateWithTime, // Pasamos la fecha con hora
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 850;

        return Scaffold(
          backgroundColor: AppTheme.getBackgroundColor(context),
          body: SafeArea(
            child: isMobile
                ? CalendarMainViewSection(
                    selectedDate: selectedDate,
                    selectedView: selectedView,
                    onDateChanged: (date) => setState(() => selectedDate = date),
                    onTimeSlotTap: _onTimeSlotTap, // Pasamos el callback
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 280),
                        child: CalendarSidebarSection(
                          selectedDate: selectedDate,
                          selectedView: selectedView,
                          onDateSelected: (date) => setState(() => selectedDate = date),
                          onViewChanged: (view) => setState(() => selectedView = view),
                        ),
                      ),
                      Expanded(
                        child: CalendarMainViewSection(
                          selectedDate: selectedDate,
                          selectedView: selectedView,
                          onDateChanged: (date) => setState(() => selectedDate = date),
                          onTimeSlotTap: _onTimeSlotTap, // Pasamos el callback
                        ),
                      ),
                    ],
                  ),
          ),
        );
      },
    );
  }
}