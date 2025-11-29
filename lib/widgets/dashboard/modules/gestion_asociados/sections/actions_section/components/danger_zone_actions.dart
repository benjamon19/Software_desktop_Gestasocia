import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../../../controllers/auth_controller.dart';
import '../../../../../../../utils/app_theme.dart';
import '../../../shared/widgets/section_title.dart';
import '../../../shared/dialogs/delete_confirmation_dialog.dart';

class DangerZoneActions extends StatelessWidget {
  final Map<String, dynamic> asociado;
  final VoidCallback onDelete;

  const DangerZoneActions({
    super.key,
    required this.asociado,
    required this.onDelete,
  });

  void _showDeleteConfirmation(BuildContext context) {
    // --- VERIFICACIÓN DE SEGURIDAD ---
    final authController = Get.find<AuthController>();
    if (authController.currentUser.value?.rol == 'odontologo') {
      Get.snackbar(
        'Acceso Denegado',
        'No tienes permisos para eliminar registros.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.9),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 8,
        duration: const Duration(seconds: 3),
      );
      return;
    }

    DeleteConfirmationDialog.show(
      context,
      asociado: asociado,
      onConfirm: onDelete,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle(title: 'Zona de Peligro'),
        const SizedBox(height: 12),
        
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFEF4444).withValues(alpha: 0.05),
            border: Border.all(
              color: const Color(0xFFEF4444).withValues(alpha: 0.2),
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.warning_amber,
                    color: Color(0xFFEF4444),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Eliminar Asociado',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFEF4444),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Esta acción no se puede deshacer. Se eliminarán todos los datos del asociado y sus cargas familiares.',
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.getTextSecondary(context),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _showDeleteConfirmation(context),
                  icon: const Icon(
                    Icons.delete_outline,
                    size: 18,
                    color: Color(0xFFEF4444),
                  ),
                  label: const Text(
                    'Eliminar Asociado',
                    style: TextStyle(
                      color: Color(0xFFEF4444),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFEF4444)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}