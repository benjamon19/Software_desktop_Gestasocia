import 'package:flutter/material.dart';
import '../../../shared/widgets/section_title.dart';
import '../../../shared/widgets/action_button.dart';

class DataManagementActions extends StatelessWidget {
  final VoidCallback onEdit;
  final VoidCallback onTransfer;

  const DataManagementActions({
    super.key,
    required this.onEdit,
    required this.onTransfer,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle(title: 'Gestión de Carga'),
        const SizedBox(height: 12),
        
        ActionButton(
          icon: Icons.edit,
          title: 'Editar Información',
          subtitle: 'Modificar datos de la carga',
          color: const Color(0xFF3B82F6),
          onPressed: onEdit,
        ),
        
        const SizedBox(height: 8),
        
        ActionButton(
          icon: Icons.swap_horiz,
          title: 'Transferir Carga',
          subtitle: 'Mover a otro asociado',
          color: const Color(0xFF8B5CF6),
          onPressed: onTransfer,
        ),
      ],
    );
  }
}