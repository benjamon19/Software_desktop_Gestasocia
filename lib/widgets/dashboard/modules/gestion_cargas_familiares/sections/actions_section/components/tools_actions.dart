import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../../../controllers/auth_controller.dart';
import '../../../shared/widgets/section_title.dart';
import '../../../shared/widgets/action_button.dart';

class ToolsActions extends StatelessWidget {
  final VoidCallback onGenerateBarcode;
  final VoidCallback onViewHistory;

  const ToolsActions({
    super.key,
    required this.onGenerateBarcode,
    required this.onViewHistory,
  });

  // --- MÉTODO DE PROTECCIÓN ---
  void _executeProtected(VoidCallback action) {
    final authController = Get.find<AuthController>();
    if (authController.currentUser.value?.rol == 'odontologo') {
      Get.snackbar(
        'Acceso Restringido',
        'No tienes permisos para realizar esta acción.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.withValues(alpha: 0.9),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 8,
        duration: const Duration(seconds: 3),
      );
    } else {
      action();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle(title: 'Herramientas'),
        const SizedBox(height: 12),
        
        ActionButton(
          icon: Icons.qr_code_2,
          title: 'Generar Código de Barras',
          subtitle: 'Crear código para identificación',
          color: const Color(0xFF8B5CF6),
          onPressed: () => _executeProtected(onGenerateBarcode),
        ),
        
        const SizedBox(height: 10),
        
        ActionButton(
          icon: Icons.history,
          title: 'Ver Historial',
          subtitle: 'Historial de cambios y actividad',
          color: const Color(0xFF6B7280),
          onPressed: () => _executeProtected(onViewHistory),
        ),
      ],
    );
  }
}