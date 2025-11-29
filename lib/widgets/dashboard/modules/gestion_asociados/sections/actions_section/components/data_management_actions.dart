import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../../../controllers/auth_controller.dart';
import '../../../shared/widgets/section_title.dart';
import '../../../shared/widgets/action_button.dart';

class DataManagementActions extends StatelessWidget {
  final VoidCallback onEdit;
  final VoidCallback onAddCarga;

  const DataManagementActions({
    super.key,
    required this.onEdit,
    required this.onAddCarga,
  });

  // --- MÉTODO DE SEGURIDAD ---
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
        const SectionTitle(title: 'Gestión de Datos'),
        const SizedBox(height: 12),
        
        ActionButton(
          icon: Icons.edit,
          title: 'Editar Información',
          subtitle: 'Modificar datos del asociado',
          color: const Color(0xFF3B82F6),
          onPressed: () => _executeProtected(onEdit),
        ),
        
        const SizedBox(height: 8),
        
        ActionButton(
          icon: Icons.person_add,
          title: 'Agregar Carga Familiar',
          subtitle: 'Añadir nueva carga familiar',
          color: const Color(0xFF10B981),
          onPressed: () => _executeProtected(onAddCarga),
        ),
      ],
    );
  }
}