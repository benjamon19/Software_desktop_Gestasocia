import 'package:flutter/material.dart';
import '../../../../../../../utils/app_theme.dart';
import '../../../../../../../models/reserva_hora.dart';

class CalendarGroupItem extends StatelessWidget {
  final List<ReservaHora> reservas;
  final VoidCallback onTap;

  const CalendarGroupItem({
    super.key,
    required this.reservas,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppTheme.primaryColor;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 1, right: 4),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(4),
            border: Border(
              left: BorderSide(color: color, width: 3),
            ),
          ),
          child: Row(
            children: [
              // Indicador de cantidad
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${reservas.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 11, // más pequeño
                  ),
                ),
              ),
              const SizedBox(width: 6),
              
              Expanded(
                child: Text(
                  'Múltiples Citas',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.getTextPrimary(context),
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              
              Icon(Icons.list, size: 16, color: color.withValues(alpha: 0.8)),
            ],
          ),
        ),
      ),
    );
  }
}