import 'package:flutter/material.dart';
import '../../../../utils/app_theme.dart';

class TreatmentAlertCard extends StatelessWidget {
  const TreatmentAlertCard({super.key});

  // Datos ficticios de Urgencias
  final List<TreatmentAlert> _alerts = const [
    TreatmentAlert(patient: "Juan Pérez", message: "Revisión post-cirugía pendiente", daysOverdue: 2),
    TreatmentAlert(patient: "Elena Torres", message: "Ajuste de ortodoncia vencido", daysOverdue: 5),
    TreatmentAlert(patient: "Miguel Santos", message: "Limpieza semestral programada", daysOverdue: 1),
    TreatmentAlert(patient: "Laura Martín", message: "Control de implante", daysOverdue: 3),
    TreatmentAlert(patient: "Ana Ruiz", message: "Seguimiento endodoncia", daysOverdue: 4),
    TreatmentAlert(patient: "Carlos Vega", message: "Retirar puntos de sutura", daysOverdue: 1),
    TreatmentAlert(patient: "Sofia López", message: "Revisión de prótesis", daysOverdue: 6),
    TreatmentAlert(patient: "Diego Mora", message: "Control de brackets", daysOverdue: 2),
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
              itemCount: _alerts.length,
              itemBuilder: (context, index) {
                return _buildAdaptiveAlertItem(
                  context, 
                  _alerts[index],
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
            'Alertas',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppTheme.getTextPrimary(context),
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
            decoration: BoxDecoration(
              color: const Color(0xFFEF4444).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${_alerts.length}',
              style: const TextStyle(
                fontSize: 9,
                color: Color(0xFFEF4444),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      );
    }
    
    // Header normal para pantallas con más espacio
    return Row(
      children: [
        Text(
          isSmallScreen ? 'Alertas Pendientes' : 'Alertas Pendientes',
          style: TextStyle(
            fontSize: isSmallScreen ? 14 : (isMediumScreen ? 15 : 16),
            fontWeight: FontWeight.w600,
            color: AppTheme.getTextPrimary(context),
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: const Color(0xFFEF4444).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            '${_alerts.length}',
            style: TextStyle(
              fontSize: isSmallScreen ? 10 : 11,
              color: const Color(0xFFEF4444),
              fontWeight: FontWeight.w600,
            ),
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

  Widget _buildAdaptiveAlertItem(
    BuildContext context, 
    TreatmentAlert alert,
    bool isSmallScreen,
    bool isMediumScreen,
    bool isVeryShortScreen,
  ) {
    // Color según urgencia
    Color urgencyColor = alert.daysOverdue > 3 
        ? const Color(0xFFEF4444)  // Rojo para más de 3 días
        : const Color(0xFFF59E0B); // Amarillo para menos días
    
    // Espaciado vertical adaptativo
    double verticalPadding = isVeryShortScreen ? 2 : (isSmallScreen ? 3 : 4);
    
    // Ancho de la columna de días según espacio disponible
    double daysColumnWidth = isVeryShortScreen ? 30 : (isSmallScreen ? 35 : 40);
    
    // Tamaño de texto adaptativo
    double daysSize = isVeryShortScreen ? 9 : (isSmallScreen ? 10 : 11);
    double contentSize = isVeryShortScreen ? 10 : (isSmallScreen ? 11 : 12);
    
    // Espaciado horizontal adaptativo
    double horizontalSpacing = isVeryShortScreen ? 6 : (isSmallScreen ? 8 : 12);
    
    return Padding(
      padding: EdgeInsets.symmetric(vertical: verticalPadding),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Días vencidos con color de urgencia
          SizedBox(
            width: daysColumnWidth,
            child: Text(
              '${alert.daysOverdue}d',
              style: TextStyle(
                fontSize: daysSize,
                fontWeight: FontWeight.w700,
                color: urgencyColor,
              ),
            ),
          ),
          
          SizedBox(width: horizontalSpacing),
          
          // Contenido adaptativo según espacio
          Expanded(
            child: _buildAdaptiveAlertContent(
              context,
              alert,
              contentSize,
              isMediumScreen,
              isVeryShortScreen,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdaptiveAlertContent(
    BuildContext context,
    TreatmentAlert alert,
    double fontSize,
    bool isMediumScreen,
    bool isVeryShortScreen,
  ) {
    if (isVeryShortScreen) {
      // Ultra compacto: solo nombre del paciente
      return Text(
        alert.patient,
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
            alert.patient,
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
            alert.message,
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
              text: alert.patient,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            TextSpan(
              text: ' • ${alert.message}',
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

class TreatmentAlert {
  final String patient;
  final String message;
  final int daysOverdue;

  const TreatmentAlert({
    required this.patient,
    required this.message,
    required this.daysOverdue,
  });
}