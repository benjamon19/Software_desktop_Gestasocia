// lib/widgets/dashboard/modules/gestion_cargas_familiares/sections/pending_actions_section/pending_actions_section.dart
import 'package:flutter/material.dart';
import '../../../../../../utils/app_theme.dart';
import 'components/pending_action_item.dart';

class PendingActionsSection extends StatelessWidget {
  const PendingActionsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.getSurfaceColor(context),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).brightness == Brightness.dark 
                ? Colors.black.withValues(alpha: 0.3)
                : Colors.grey.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16), 
                topRight: Radius.circular(16)
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.pending_actions, color: AppTheme.primaryColor, size: 24),
                const SizedBox(width: 12),
                Text(
                  'Acciones Pendientes',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryColor,
                  ),
                ),
                const Spacer(),
                Text(
                  '8 pendientes',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.getTextSecondary(context),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                PendingActionItem(
                  title: 'Validar Documentos',
                  subtitle: '5 cargas requieren validación de documentos',
                  icon: Icons.description,
                  color: const Color(0xFF3B82F6),
                  count: 5,
                  onTap: () {},
                ),
                const SizedBox(height: 12),
                PendingActionItem(
                  title: 'Renovación de Carnets',
                  subtitle: '3 carnets vencen en los próximos 15 días',
                  icon: Icons.badge,
                  color: const Color(0xFFF59E0B),
                  count: 3,
                  onTap: () {},
                ),
                const SizedBox(height: 12),
                PendingActionItem(
                  title: 'Actualizaciones Médicas',
                  subtitle: '7 cargas sin información médica actualizada',
                  icon: Icons.medical_services,
                  color: const Color(0xFF10B981),
                  count: 7,
                  onTap: () {},
                ),
                const SizedBox(height: 12),
                PendingActionItem(
                  title: 'Transferencias Pendientes',
                  subtitle: '2 solicitudes de transferencia por aprobar',
                  icon: Icons.swap_horiz,
                  color: const Color(0xFF8B5CF6),
                  count: 2,
                  onTap: () {},
                ),
                const SizedBox(height: 12),
                PendingActionItem(
                  title: 'Contactos de Emergencia',
                  subtitle: '4 cargas sin contacto de emergencia',
                  icon: Icons.contact_emergency,
                  color: const Color(0xFFEF4444),
                  count: 4,
                  onTap: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}