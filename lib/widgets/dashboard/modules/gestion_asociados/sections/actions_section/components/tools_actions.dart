import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../../../controllers/auth_controller.dart';
import '../../../shared/widgets/section_title.dart';
import '../../../shared/widgets/action_button.dart';
import '../../../../../../../controllers/asociados_controller.dart';
import 'package:gestasocia/widgets/dashboard/modules/gestion_asociados/shared/dialogs/generar_codigo_barras_dialog.dart';

class ToolsActions extends StatelessWidget {
  final void Function() onViewHistory;

  const ToolsActions({
    super.key,
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
    final AsociadosController controller = Get.find<AsociadosController>();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle(title: 'Herramientas'),
        const SizedBox(height: 12),
        
        Obx(() {
          final asociado = controller.selectedAsociado.value;
          
          return ActionButton(
            icon: Icons.qr_code_2,
            title: 'Generar Código de Barras',
            subtitle: 'Crear código para identificación',
            color: const Color(0xFF8B5CF6),
            onPressed: () => _executeProtected(() {
              if (asociado != null) {
                GenerarCodigoBarrasDialog.show(
                  context,
                  asociadoId: asociado.id!,
                  nombreCompleto: asociado.nombreCompleto,
                  sap: asociado.sap,
                  rut: asociado.rut,
                  codigoExistente: asociado.codigoBarras,
                );
              }
            }),
          );
        }),
        
        const SizedBox(height: 8),
        
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