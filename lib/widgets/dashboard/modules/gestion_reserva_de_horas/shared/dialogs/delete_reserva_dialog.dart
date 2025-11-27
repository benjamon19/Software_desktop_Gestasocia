import 'package:flutter/material.dart';
import '../../../../../../utils/app_theme.dart';
import '../../../../../../models/reserva_hora.dart';

class DeleteReservaDialog {
  static void show(
    BuildContext context, {
    required ReservaHora reserva,
    required Future<void> Function() onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.getSurfaceColor(context),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        icon: const Icon(
          Icons.warning_amber,
          color: Color(0xFFEF4444),
          size: 48,
        ),
        title: Text(
          'Confirmar Eliminación',
          style: TextStyle(
            color: AppTheme.getTextPrimary(context),
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '¿Estás seguro de que deseas eliminar esta reserva?',
              style: TextStyle(
                color: AppTheme.getTextPrimary(context),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              '${reserva.pacienteNombre}\n${reserva.fechaFormateada} • ${reserva.hora}',
              style: TextStyle(
                color: AppTheme.getTextPrimary(context),
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Esta acción no se puede deshacer.',
              style: TextStyle(
                color: Color(0xFFEF4444),
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancelar',
              style: TextStyle(
                color: AppTheme.getTextSecondary(context),
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              await onConfirm();
              if (context.mounted) Navigator.of(context).pop();
            },
            child: const Text(
              'Eliminar',
              style: TextStyle(
                color: Color(0xFFEF4444),
              ),
            ),
          ),
        ],
      ),
    );
  }
}