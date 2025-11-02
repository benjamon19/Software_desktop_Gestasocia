import 'package:flutter/material.dart';
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
          onPressed: onGenerateBarcode,
        ),
        
        const SizedBox(height: 10),
        
        ActionButton(
          icon: Icons.history,
          title: 'Ver Historial',
          subtitle: 'Historial de cambios y actividad',
          color: const Color(0xFF6B7280),
          onPressed: onViewHistory,
        ),
      ],
    );
  }
}