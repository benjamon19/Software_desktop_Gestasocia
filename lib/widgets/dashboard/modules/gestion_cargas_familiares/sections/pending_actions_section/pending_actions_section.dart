import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../../../utils/app_theme.dart';

class PendingActionsSection extends StatelessWidget {
  const PendingActionsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isSmallScreen = screenWidth < 600;
    final bool isVerySmall = screenWidth < 400;
    
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.getSurfaceColor(context),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).brightness == Brightness.dark 
                ? Colors.black.withValues(alpha: 0.3)
                : Colors.grey.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header compacto
          Padding(
            padding: EdgeInsets.all(isVerySmall ? 12 : (isSmallScreen ? 14 : 16)),
            child: Row(
              children: [
                Icon(
                  Icons.pending_actions_outlined, 
                  color: AppTheme.primaryColor, 
                  size: isVerySmall ? 16 : (isSmallScreen ? 18 : 20)
                ),
                SizedBox(width: isVerySmall ? 8 : 12),
                Expanded(
                  child: Text(
                    isVerySmall ? 'Pendientes' : 'Acciones Pendientes',
                    style: TextStyle(
                      fontSize: isVerySmall ? 14 : (isSmallScreen ? 15 : 16),
                      fontWeight: FontWeight.w600,
                      color: AppTheme.getTextPrimary(context),
                    ),
                  ),
                ),
                Text(
                  isVerySmall ? '8' : '8 pendientes',
                  style: TextStyle(
                    fontSize: isVerySmall ? 11 : (isSmallScreen ? 12 : 13),
                    color: AppTheme.getTextSecondary(context),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          
          // Línea divisoria sutil
          Container(
            height: 1,
            margin: EdgeInsets.symmetric(horizontal: isVerySmall ? 12 : 16),
            color: AppTheme.getTextSecondary(context).withValues(alpha: 0.1),
          ),
          
          // Lista de acciones compacta
          Expanded(
            child: ListView(
              padding: EdgeInsets.all(isVerySmall ? 12 : (isSmallScreen ? 14 : 16)),
              children: [
                _buildActionItem(
                  context: context,
                  title: 'Validar Documentos',
                  subtitle: isVerySmall ? '5 cargas' : '5 cargas requieren validación',
                  icon: Icons.description_outlined,
                  count: 5,
                  isSmallScreen: isSmallScreen,
                  isVerySmall: isVerySmall,
                  onTap: () {},
                ),
                SizedBox(height: isVerySmall ? 8 : 10),
                _buildActionItem(
                  context: context,
                  title: 'Renovación Carnets',
                  subtitle: isVerySmall ? '3 carnets' : '3 carnets vencen pronto',
                  icon: Icons.badge_outlined,
                  count: 3,
                  isSmallScreen: isSmallScreen,
                  isVerySmall: isVerySmall,
                  onTap: () {},
                ),
                SizedBox(height: isVerySmall ? 8 : 10),
                _buildActionItem(
                  context: context,
                  title: 'Info Médica',
                  subtitle: isVerySmall ? '7 cargas' : '7 cargas sin actualizar',
                  icon: Icons.medical_services_outlined,
                  count: 7,
                  isSmallScreen: isSmallScreen,
                  isVerySmall: isVerySmall,
                  onTap: () {},
                ),
                SizedBox(height: isVerySmall ? 8 : 10),
                _buildActionItem(
                  context: context,
                  title: 'Transferencias',
                  subtitle: isVerySmall ? '2 por aprobar' : '2 solicitudes por aprobar',
                  icon: Icons.swap_horiz_outlined,
                  count: 2,
                  isSmallScreen: isSmallScreen,
                  isVerySmall: isVerySmall,
                  onTap: () {},
                ),
                SizedBox(height: isVerySmall ? 8 : 10),
                _buildActionItem(
                  context: context,
                  title: 'Contactos',
                  subtitle: isVerySmall ? '4 sin contacto' : '4 cargas sin contacto',
                  icon: Icons.contact_emergency_outlined,
                  count: 4,
                  isSmallScreen: isSmallScreen,
                  isVerySmall: isVerySmall,
                  onTap: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionItem({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required int count,
    required bool isSmallScreen,
    required bool isVerySmall,
    required VoidCallback onTap,
  }) {
    final hovered = false.obs;

    return ObxValue<RxBool>(
      (hover) => InkWell(
        onTap: onTap,
        onHover: (value) => hover.value = value,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: EdgeInsets.all(isVerySmall ? 8 : (isSmallScreen ? 10 : 12)),
          decoration: BoxDecoration(
            color: hover.value
                ? AppTheme.primaryColor.withAlpha(10)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              // Icono compacto
              Container(
                width: isVerySmall ? 28 : (isSmallScreen ? 32 : 36),
                height: isVerySmall ? 28 : (isSmallScreen ? 32 : 36),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  icon,
                  color: AppTheme.primaryColor,
                  size: isVerySmall ? 14 : (isSmallScreen ? 16 : 18),
                ),
              ),
              
              SizedBox(width: isVerySmall ? 8 : (isSmallScreen ? 10 : 12)),
              
              // Contenido
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: isVerySmall ? 12 : (isSmallScreen ? 13 : 14),
                        fontWeight: FontWeight.w500,
                        color: AppTheme.getTextPrimary(context),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (!isVerySmall) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: isSmallScreen ? 10 : 11,
                          color: AppTheme.getTextSecondary(context),
                          height: 1.2,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              
              SizedBox(width: isVerySmall ? 6 : 8),
              
              // Contador compacto
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isVerySmall ? 6 : 8, 
                  vertical: isVerySmall ? 2 : 4
                ),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor,
                  borderRadius: BorderRadius.circular(isVerySmall ? 8 : 12),
                ),
                child: Text(
                  count.toString(),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isVerySmall ? 10 : (isSmallScreen ? 11 : 12),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              
              SizedBox(width: isVerySmall ? 4 : 6),
              
              if (!isVerySmall)
                Icon(
                  Icons.chevron_right,
                  size: isSmallScreen ? 14 : 16,
                  color: AppTheme.getTextSecondary(context),
                ),
            ],
          ),
        ),
      ),
      hovered,
    );
  }
}