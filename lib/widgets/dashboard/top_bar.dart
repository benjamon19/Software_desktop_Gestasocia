import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../utils/dashboard_data.dart';
import '../../utils/app_theme.dart';

class TopBar extends StatelessWidget {
  final bool isDrawerOpen;
  final bool isSidebarCollapsed;
  final String currentPageTitle;
  final VoidCallback onMenuToggle;
  final VoidCallback onSidebarToggle;
  final AuthController authController;
  final Function(int)? onNavigateToSection;

  const TopBar({
    super.key,
    required this.isDrawerOpen,
    required this.isSidebarCollapsed,
    required this.currentPageTitle,
    required this.onMenuToggle,
    required this.onSidebarToggle,
    required this.authController,
    this.onNavigateToSection,
  });

  // Helper para formatear el rol
  String _formatRol(String rol) {
    if (rol.isEmpty) return 'Sin cargo';
    if (rol == 'odontologo') return 'Odontólogo';
    if (rol == 'administrativo') return 'Administrativo';
    return rol.substring(0, 1).toUpperCase() + rol.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final bool isSmallScreen = screenWidth < 600;
    final bool isMediumScreen = screenWidth >= 600 && screenWidth < 1000;
    final bool isVeryShortScreen = screenHeight < 600;
    
    // Adaptamos la altura según el tamaño de pantalla
    double topBarHeight = isVeryShortScreen ? 60 : (isSmallScreen ? 65 : 70);
    double horizontalPadding = isSmallScreen ? 16 : 25;
    
    return Container(
      height: topBarHeight,
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      decoration: BoxDecoration(
        color: AppTheme.getSurfaceColor(context),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).brightness == Brightness.dark 
                ? Colors.black.withValues(alpha: 0.3)
                : Colors.grey.withValues(alpha: 0.08),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              isSidebarCollapsed ? Icons.menu : Icons.menu_open,
              color: AppTheme.getTextPrimary(context),
              size: isSmallScreen ? 20 : 24,
            ),
            onPressed: onSidebarToggle,
            tooltip: isSidebarCollapsed ? 'Expandir menú' : 'Contraer menú',
          ),
          SizedBox(width: isSmallScreen ? 12 : 20),
          
          // Page Title - Adaptativo
          Expanded(
            child: Text(
              currentPageTitle,
              style: TextStyle(
                fontSize: isVeryShortScreen ? 16 : (isSmallScreen ? 18 : 20),
                fontWeight: FontWeight.w600,
                color: AppTheme.getTextPrimary(context),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          
          if (!isSmallScreen) ...[
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: isMediumScreen ? 12 : 16, 
                vertical: isVeryShortScreen ? 6 : 8,
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark 
                    ? AppTheme.darkSurfaceColor.withValues(alpha: 0.8)
                    : AppTheme.backgroundColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today_outlined, 
                    size: isVeryShortScreen ? 14 : 16, 
                    color: AppTheme.getTextSecondary(context),
                  ),
                  SizedBox(width: isVeryShortScreen ? 6 : 8),
                  Text(
                    DashboardData.getFormattedDate(),
                    style: TextStyle(
                      color: AppTheme.getTextSecondary(context),
                      fontSize: isVeryShortScreen ? 12 : 14,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: isMediumScreen ? 12 : 20),
          ] else ...[
            const SizedBox(width: 8),
          ],
          
          _buildUserMenu(context, isSmallScreen, isVeryShortScreen),
        ],
      ),
    );
  }

  Widget _buildUserMenu(BuildContext context, bool isSmallScreen, bool isVeryShortScreen) {
    return PopupMenuButton<String>(
      offset: Offset(0, isVeryShortScreen ? 40 : 45),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isSmallScreen ? 8 : 12, 
          vertical: isVeryShortScreen ? 4 : 6,
        ),
        decoration: BoxDecoration(
          border: Border.all(color: AppTheme.getBorderLight(context)),
          borderRadius: BorderRadius.circular(25),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Obx(() {
              final photoUrl = authController.userPhotoUrl;
              return CircleAvatar(
                radius: isVeryShortScreen ? 15 : (isSmallScreen ? 16 : 18),
                backgroundColor: AppTheme.primaryColor,
                backgroundImage: photoUrl != null
                    ? NetworkImage(photoUrl)
                    : null,
                child: photoUrl == null
                    ? Text(
                        authController.userDisplayName.isNotEmpty 
                            ? authController.userDisplayName[0].toUpperCase() 
                            : 'U',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: isVeryShortScreen ? 12 : (isSmallScreen ? 13 : 14),
                        ),
                      )
                    : null,
              );
            }),
            if (!isSmallScreen) ...[
              SizedBox(width: isVeryShortScreen ? 8 : 10),
              Obx(() {
                final rol = authController.currentUser.value?.rol ?? '';
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      authController.userDisplayName,
                      style: TextStyle(
                        color: AppTheme.getTextPrimary(context),
                        fontWeight: FontWeight.w600,
                        fontSize: isVeryShortScreen ? 12 : 14,
                      ),
                    ),
                    Text(
                      _formatRol(rol),
                      style: TextStyle(
                        color: AppTheme.getTextSecondary(context),
                        fontSize: isVeryShortScreen ? 10 : 12,
                      ),
                    ),
                  ],
                );
              }),
              SizedBox(width: isVeryShortScreen ? 6 : 8),
            ],
            
            Icon(
              Icons.arrow_drop_down, 
              color: AppTheme.getTextSecondary(context),
              size: isSmallScreen ? 18 : 20,
            ),
          ],
        ),
      ),
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'profile',
          child: Row(
            children: [
              Icon(
                Icons.person_outline, 
                color: AppTheme.getTextPrimary(context), 
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(
                'Mi Perfil',
                style: TextStyle(color: AppTheme.getTextPrimary(context)),
              ),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'settings',
          child: Row(
            children: [
              Icon(
                Icons.settings_outlined, 
                color: AppTheme.getTextPrimary(context), 
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(
                'Configuración',
                style: TextStyle(color: AppTheme.getTextPrimary(context)),
              ),
            ],
          ),
        ),
        PopupMenuItem(
          enabled: false,
          height: 1,
          child: Divider(
            height: 1,
            thickness: 0.5,
            color: AppTheme.getBorderLight(context).withValues(alpha: 0.3),
          ),
        ),
        const PopupMenuItem(
          value: 'logout',
          child: Row(
            children: [
              Icon(Icons.logout, color: Color(0xFFEF4444), size: 20),
              SizedBox(width: 12),
              Text('Cerrar Sesión', style: TextStyle(color: Color(0xFFEF4444))),
            ],
          ),
        ),
      ],
      onSelected: (value) => _handleMenuAction(value, context),
    );
  }

  void _handleMenuAction(String value, BuildContext context) {
    switch (value) {
      case 'profile':
        if (onNavigateToSection != null) {
          onNavigateToSection!(6);
        }
        break;
      case 'settings':
        if (onNavigateToSection != null) {
          onNavigateToSection!(5);
        }
        break;
      case 'logout':
        _showLogoutDialog(context);
        break;
    }
  }

  void _showLogoutDialog(BuildContext context) {
    Get.dialog(
      AlertDialog(
        backgroundColor: AppTheme.getSurfaceColor(context),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        title: Text(
          'Cerrar Sesión',
          style: TextStyle(color: AppTheme.getTextPrimary(context)),
        ),
        content: Text(
          '¿Estás seguro de que deseas cerrar sesión?',
          style: TextStyle(color: AppTheme.getTextSecondary(context)),
        ),
        actions: [
          TextButton(
            child: Text(
              'Cancelar', 
              style: TextStyle(color: AppTheme.getTextSecondary(context)),
            ),
            onPressed: () => Get.back(),
          ),
          TextButton(
            child: const Text(
              'Cerrar Sesión', 
              style: TextStyle(color: Color(0xFFEF4444)),
            ),
            onPressed: () {
              Get.back();
              authController.logout();
            },
          ),
        ],
      ),
    );
  }
}