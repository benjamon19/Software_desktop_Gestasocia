import 'package:flutter/material.dart';
import '../../../../../../../utils/app_theme.dart';
import '../../../../../../../models/reserva_hora.dart';

class CalendarAppointmentItem extends StatelessWidget {
  final ReservaHora? reserva;
  final int? summaryCount;
  final String viewType; // 'day', 'week', 'month'
  final VoidCallback? onTap;

  const CalendarAppointmentItem({
    super.key,
    this.reserva,
    this.summaryCount,
    required this.viewType,
    this.onTap,
  });

  Color _getStatusColor(String? estado) {
    if (summaryCount != null) return AppTheme.primaryColor;
    switch (estado?.toLowerCase()) {
      case 'confirmada': return const Color(0xFF10B981); // Verde
      case 'cancelada': return const Color(0xFFEF4444); // Rojo
      case 'realizada': return const Color(0xFF8B5CF6); // Púrpura
      case 'pendiente':
      default: return const Color(0xFFF59E0B); // Naranja
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getStatusColor(reserva?.estado);
    
    Widget content;
    
    switch (viewType) {
      case 'day':
        content = _buildDayItem(context, color);
        break;
      case 'week':
        content = _buildWeekItem(context, color);
        break;
      case 'month':
        content = _buildMonthBlockItem(context);
        break;
      default:
        content = const SizedBox();
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: content,
      ),
    );
  }

  // === VISTA DÍA (Hora | Nombre | RUT | Odontólogo | Ícono) ===
  Widget _buildDayItem(BuildContext context, Color color) {
    final bool isAsociado = reserva?.pacienteTipo.toLowerCase() == 'asociado';
    final Color typeColor = isAsociado 
        ? const Color(0xFF3B82F6) 
        : const Color(0xFF10B981);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 2, right: 4),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
        border: Border(
          left: BorderSide(color: color, width: 4),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Hora
          Text(
            reserva?.hora ?? '',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppTheme.getTextPrimary(context),
            ),
          ),
          const SizedBox(width: 8),

          // Separador vertical
          Container(
            width: 1,
            height: 14,
            color: AppTheme.getTextSecondary(context).withValues(alpha: 0.3),
          ),
          const SizedBox(width: 8),

          // Contenido central: Nombre, RUT, Odontólogo
          Expanded(
            child: Row(
              children: [
                Flexible(
                  flex: 3,
                  child: Text(
                    reserva?.pacienteNombre ?? '',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.getTextPrimary(context),
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                const SizedBox(width: 8),

                Text(
                  reserva?.pacienteRut ?? '',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.normal,
                    color: AppTheme.getTextSecondary(context),
                  ),
                ),
                const SizedBox(width: 8),

                Text(
                  '|',
                  style: TextStyle(
                    fontSize: 10, 
                    color: AppTheme.getTextSecondary(context).withValues(alpha: 0.3)
                  ),
                ),
                const SizedBox(width: 8),

                Flexible(
                  flex: 2,
                  child: Text(
                    reserva?.odontologo ?? '',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppTheme.getTextSecondary(context),
                      fontStyle: FontStyle.italic,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Ícono de tipo de paciente
          Tooltip(
            message: isAsociado ? 'Asociado' : 'Carga Familiar',
            child: Icon(
              isAsociado ? Icons.person : Icons.family_restroom,
              size: 16,
              color: typeColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekItem(BuildContext context, Color color) {
    final String nombre = reserva?.pacienteNombre ?? '';
    final bool isAsociado = reserva?.pacienteTipo.toLowerCase() == 'asociado';
    
    final Color typeColor = isAsociado 
        ? const Color(0xFF3B82F6) 
        : const Color(0xFF10B981);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 1, right: 2),
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(4),
        border: Border(left: BorderSide(color: color, width: 3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  reserva?.hora ?? '',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.getTextPrimary(context),
                    height: 1.0,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  nombre,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.getTextPrimary(context),
                    height: 1.0,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 4),
          Icon(
            isAsociado ? Icons.person : Icons.family_restroom,
            size: 14,
            color: typeColor,
          ),
        ],
      ),
    );
  }

  Widget _buildMonthBlockItem(BuildContext context) {
    if (summaryCount == null || summaryCount == 0) return const SizedBox();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark 
        ? const Color(0xFF40444B) 
        : const Color(0xFFEDF2F7);
        
    final borderColor = isDark
        ? const Color(0xFF5865F2).withValues(alpha: 0.3)
        : const Color(0xFFCBD5E0); 

    final texto = summaryCount == 1 ? 'Cita' : 'Citas';

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: borderColor),
      ),
      child: Center(
        child: Text(
          '$summaryCount $texto',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppTheme.getTextPrimary(context),
            letterSpacing: 0.3,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}