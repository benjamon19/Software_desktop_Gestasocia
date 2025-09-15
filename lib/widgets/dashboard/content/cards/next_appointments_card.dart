import 'package:flutter/material.dart';
import '../../../../utils/app_theme.dart';

class NextAppointmentsCard extends StatelessWidget {
  const NextAppointmentsCard({super.key});

  // Datos ficticios de próximas citas
  final List<AppointmentData> _upcomingAppointments = const [
    AppointmentData(time: "09:30", patient: "Ana García", treatment: "Limpieza dental"),
    AppointmentData(time: "10:15", patient: "Carlos López", treatment: "Empaste"),
    AppointmentData(time: "11:00", patient: "María Silva", treatment: "Revisión"),
    AppointmentData(time: "11:45", patient: "Roberto Díaz", treatment: "Extracción"),
    AppointmentData(time: "14:30", patient: "Pedro Ruiz", treatment: "Ortodoncia"),
    AppointmentData(time: "15:15", patient: "Laura Moreno", treatment: "Blanqueamiento"),
    AppointmentData(time: "16:00", patient: "José Martín", treatment: "Implante"),
    AppointmentData(time: "16:45", patient: "Carmen Vega", treatment: "Endodoncia"),
    AppointmentData(time: "17:30", patient: "Antonio Ruiz", treatment: "Limpieza"),
    AppointmentData(time: "18:15", patient: "Isabel Romero", treatment: "Consulta"),
  ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final bool isSmallScreen = screenWidth < 600;
    final bool isMediumScreen = screenWidth >= 600 && screenWidth < 1000;
    final bool isShortScreen = screenHeight < 700;
    final bool isVeryShortScreen = screenHeight < 600;
    
    // Padding adaptativo según espacio disponible
    double cardPadding = isVeryShortScreen ? 8 : (isShortScreen ? 10 : (isSmallScreen ? 12 : 16));
    double headerSpacing = isVeryShortScreen ? 4 : (isShortScreen ? 6 : (isSmallScreen ? 8 : 12));
    double footerSpacing = isVeryShortScreen ? 3 : (isShortScreen ? 4 : (isSmallScreen ? 6 : 8));
    
    return Container(
      padding: EdgeInsets.all(cardPadding),
      decoration: BoxDecoration(
        color: AppTheme.getSurfaceColor(context),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).brightness == Brightness.dark 
                ? Colors.black.withValues(alpha: 0.3) 
                : Colors.grey.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header que se adapta al espacio
          _buildAdaptiveHeader(context, isSmallScreen, isMediumScreen, isVeryShortScreen),
          
          SizedBox(height: headerSpacing),
          
          // Lista que se expande según el espacio disponible
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: _upcomingAppointments.length,
              itemBuilder: (context, index) {
                return _buildAdaptiveAppointmentItem(
                  context, 
                  _upcomingAppointments[index],
                  isSmallScreen,
                  isMediumScreen,
                  isVeryShortScreen,
                );
              },
            ),
          ),
          
          SizedBox(height: footerSpacing),
          
          // Footer adaptativo - se oculta en pantallas muy pequeñas
          if (!isVeryShortScreen)
            _buildAdaptiveFooter(context, isSmallScreen),
        ],
      ),
    );
  }

  Widget _buildAdaptiveHeader(BuildContext context, bool isSmallScreen, bool isMediumScreen, bool isVeryShortScreen) {
    if (isVeryShortScreen) {
      // Header ultra compacto para pantallas muy pequeñas
      return Row(
        children: [
          Text(
            'Citas',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppTheme.getTextPrimary(context),
            ),
          ),
          const Spacer(),
          Text(
            '${_upcomingAppointments.length}',
            style: TextStyle(
              fontSize: 10,
              color: AppTheme.getTextSecondary(context),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      );
    }
    
    // Header normal para pantallas con más espacio
    return Row(
      children: [
        Text(
          isSmallScreen ? 'Próximas Citas' : 'Próximas Citas',
          style: TextStyle(
            fontSize: isSmallScreen ? 14 : (isMediumScreen ? 15 : 16),
            fontWeight: FontWeight.w600,
            color: AppTheme.getTextPrimary(context),
          ),
        ),
        const Spacer(),
        Text(
          '${_upcomingAppointments.length}',
          style: TextStyle(
            fontSize: isSmallScreen ? 11 : 12,
            color: AppTheme.getTextSecondary(context),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildAdaptiveFooter(BuildContext context, bool isSmallScreen) {
    return Align(
      alignment: Alignment.centerRight,
      child: GestureDetector(
        onTap: () {},
        child: Text(
          isSmallScreen ? 'Ver más →' : 'Ver todas →',
          style: TextStyle(
            fontSize: isSmallScreen ? 10 : 11,
            color: const Color(0xFF3B82F6),
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildAdaptiveAppointmentItem(
    BuildContext context, 
    AppointmentData appointment,
    bool isSmallScreen,
    bool isMediumScreen,
    bool isVeryShortScreen,
  ) {
    // Espaciado vertical adaptativo
    double verticalPadding = isVeryShortScreen ? 2 : (isSmallScreen ? 3 : 4);
    
    // Ancho de la columna de hora según espacio disponible
    double timeColumnWidth = isVeryShortScreen ? 35 : (isSmallScreen ? 40 : 45);
    
    // Tamaño de texto adaptativo
    double timeSize = isVeryShortScreen ? 10 : (isSmallScreen ? 11 : 12);
    double contentSize = isVeryShortScreen ? 10 : (isSmallScreen ? 11 : 12);
    
    // Espaciado horizontal adaptativo
    double horizontalSpacing = isVeryShortScreen ? 6 : (isSmallScreen ? 8 : 12);
    
    return Padding(
      padding: EdgeInsets.symmetric(vertical: verticalPadding),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hora compacta con ancho adaptativo
          Container(
            width: timeColumnWidth,
            child: Text(
              appointment.time,
              style: TextStyle(
                fontSize: timeSize,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF3B82F6),
              ),
            ),
          ),
          
          SizedBox(width: horizontalSpacing),
          
          // Contenido adaptativo según espacio
          Expanded(
            child: _buildAdaptiveContent(
              context,
              appointment,
              contentSize,
              isMediumScreen,
              isVeryShortScreen,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdaptiveContent(
    BuildContext context,
    AppointmentData appointment,
    double fontSize,
    bool isMediumScreen,
    bool isVeryShortScreen,
  ) {
    if (isVeryShortScreen) {
      // Ultra compacto: solo nombre del paciente
      return Text(
        appointment.patient,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w500,
          color: AppTheme.getTextPrimary(context),
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    } else if (isMediumScreen) {
      // Pantalla mediana: dos líneas separadas
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            appointment.patient,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w500,
              color: AppTheme.getTextPrimary(context),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            appointment.treatment,
            style: TextStyle(
              fontSize: fontSize - 1,
              color: AppTheme.getTextSecondary(context),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      );
    } else {
      // Pantalla normal: una línea con separador
      return RichText(
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        text: TextSpan(
          style: TextStyle(
            fontSize: fontSize,
            color: AppTheme.getTextPrimary(context),
          ),
          children: [
            TextSpan(
              text: appointment.patient,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            TextSpan(
              text: ' • ${appointment.treatment}',
              style: TextStyle(
                color: AppTheme.getTextSecondary(context),
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
      );
    }
  }
}

class AppointmentData {
  final String time;
  final String patient;
  final String treatment;

  const AppointmentData({
    required this.time,
    required this.patient,
    required this.treatment,
  });
}