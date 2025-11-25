import 'package:flutter/material.dart';
import 'package:get/get.dart';
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

  void _onTimeSlotTap(DateTime dateWithTime) {
    final now = DateTime.now();

    if (dateWithTime.isBefore(now)) {
      Get.snackbar(
        'Acción no permitida',
        'No puedes agendar una hora en el pasado.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.withValues(alpha: 0.9),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 8,
        duration: const Duration(seconds: 3),
      );
      return; 
    }

    NewReservaDialog.show(
      context,
      preSelectedDate: dateWithTime,
    );
  }

  // === Botón Flotante para VOLVER (si es necesario) o NULO ===
  Widget _buildFloatingActionButtons() {
    // Si necesitas un botón para volver a la vista principal, lo pondrías aquí.
    // Por simplicidad, y siguiendo la estructura anterior, retornamos un widget vacío.
    return const SizedBox.shrink();
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
                    onTimeSlotTap: _onTimeSlotTap, 
                    onViewChanged: (view) => setState(() => selectedView = view),
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
                          onTimeSlotTap: _onTimeSlotTap, 
                          onViewChanged: (view) => setState(() => selectedView = view),
                        ),
                      ),
                    ],
                  ),
          ),
          floatingActionButton: _buildFloatingActionButtons(),
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        );
      },
    );
  }
}