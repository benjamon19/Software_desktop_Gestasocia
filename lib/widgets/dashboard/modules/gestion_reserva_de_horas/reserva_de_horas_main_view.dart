import 'package:flutter/material.dart';
import '../../../../../utils/app_theme.dart';
import 'sections/calendar_sidebar/calendar_sidebar_section.dart';
import 'sections/calendar_main_view/calendar_main_view_section.dart';

class ReservaDeHorasMainView extends StatefulWidget {
  const ReservaDeHorasMainView({super.key});

  @override
  State<ReservaDeHorasMainView> createState() => _ReservaDeHorasMainViewState();
}

class _ReservaDeHorasMainViewState extends State<ReservaDeHorasMainView> {
  String selectedView = 'week';
  DateTime selectedDate = DateTime.now();

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
                        ),
                      ),
                    ],
                  ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              // Acción futura
            },
            backgroundColor: AppTheme.primaryColor,
            child: const Icon(Icons.event, color: Colors.white),
          ),
        );
      },
    );
  }
}