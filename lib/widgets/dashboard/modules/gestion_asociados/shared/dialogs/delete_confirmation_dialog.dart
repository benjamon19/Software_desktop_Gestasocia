import 'package:flutter/material.dart';
import '../../../../../../utils/app_theme.dart';

class DeleteConfirmationDialog {
  static void show(
    BuildContext context, {
    required Map<String, dynamic> asociado,
    required VoidCallback onConfirm,
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
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '¿Estás seguro de que deseas eliminar al asociado?',
              style: TextStyle(
                color: AppTheme.getTextPrimary(context),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              '${asociado['nombre']} ${asociado['apellido']}',
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
            onPressed: () {
              Navigator.of(context).pop();
              onConfirm();
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