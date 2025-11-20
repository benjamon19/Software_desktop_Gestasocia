import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../utils/dashboard_data.dart';
import '../../utils/app_theme.dart';
import '../../controllers/auth_controller.dart';
import '../../utils/app_routes.dart';

class SidebarMenu extends StatefulWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;
  final bool isCollapsed;
  final VoidCallback onToggleCollapse;

  const SidebarMenu({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
    required this.isCollapsed,
    required this.onToggleCollapse,
  });

  @override
  State<SidebarMenu> createState() => _SidebarMenuState();
}

class _SidebarMenuState extends State<SidebarMenu>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _widthAnimation;
  late Animation<double> _fadeAnimation;

  // Controlador para verificar el rol del usuario
  final AuthController _authController = Get.find<AuthController>();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _widthAnimation = Tween<double>(
      begin: 210.0,
      end: 65.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
    ));

    if (widget.isCollapsed) {
      _animationController.value = 1.0;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final screenWidth = MediaQuery.of(context).size.width;
    final bool isSmallScreen = screenWidth < 600;
    final bool isVerySmallScreen = screenWidth < 480;

    double expandedWidth = isVerySmallScreen ? 180 : (isSmallScreen ? 200 : 210);
    double collapsedWidth = isVerySmallScreen ? 55 : (isSmallScreen ? 60 : 65);

    _widthAnimation = Tween<double>(
      begin: expandedWidth,
      end: collapsedWidth,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOutCubic,
    ));
  }

  @override
  void didUpdateWidget(SidebarMenu oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isCollapsed != oldWidget.isCollapsed) {
      if (widget.isCollapsed) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Container(
          width: _widthAnimation.value,
          decoration: BoxDecoration(
            color: AppTheme.getSurfaceColor(context),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.black.withValues(alpha: 0.25)
                    : const Color(0x14000000),
                blurRadius: 8,
                offset: const Offset(2, 0),
              ),
            ],
          ),
          child: Column(
            children: [
              // Logo Section
              _buildLogoSection(context),
              Divider(height: 1, color: AppTheme.getBorderLight(context)),

              // Menu Items
              Expanded(
                child: ListView.builder(
                  padding: _getAdaptivePadding(context),
                  itemCount: DashboardData.menuItems.length,
                  itemBuilder: (context, index) {
                    return _buildMenuItem(context, index);
                  },
                ),
              ),

              // === BOTÓN SOLO PARA ADMIN ===
              Obx(() {
                final user = _authController.currentUser.value;
                
                // LÓGICA CORREGIDA:
                // 1. Obtenemos el rol y lo pasamos a minúsculas y quitamos espacios.
                final String userRole = user?.rol.trim().toLowerCase() ?? '';
                
                // 2. Comparamos EXACTAMENTE con 'admin'.
                // Esto acepta: 'Admin', 'ADMIN', 'admin'.
                // Esto RECHAZA: 'administrativo', 'odontologo'.
                final bool isAdmin = userRole == 'admin';

                if (!isAdmin) return const SizedBox.shrink();

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Divisor sutil para separar las acciones de admin
                    Divider(height: 1, color: AppTheme.getBorderLight(context).withValues(alpha: 0.5)),
                    Padding(
                      padding: _getAdaptivePadding(context), // Mismo padding que la lista
                      child: _buildAdminRegisterButton(context),
                    ),
                    const SizedBox(height: 8),
                  ],
                );
              }),
            ],
          ),
        );
      },
    );
  }

  EdgeInsets _getAdaptivePadding(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final bool isVeryShortScreen = screenHeight < 600;
    return EdgeInsets.symmetric(vertical: isVeryShortScreen ? 6 : 8);
  }

  Widget _buildLogoSection(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final bool isSmallScreen = screenWidth < 600;
    final bool isVerySmallScreen = screenWidth < 480;
    final bool isVeryShortScreen = screenHeight < 600;

    double logoHeight = isVeryShortScreen ? 60 : (isSmallScreen ? 68 : 76);
    double logoPadding = isVerySmallScreen ? 10 : (isSmallScreen ? 12 : 15);
    double logoSize = isVerySmallScreen ? 26 : (isSmallScreen ? 30 : 34);
    double fontSize = isVerySmallScreen ? 16 : (isSmallScreen ? 18 : 20);
    double logoMargin = isVerySmallScreen ? 8 : 10;

    return Container(
      height: logoHeight,
      padding: EdgeInsets.all(logoPadding),
      child: Row(
        children: [
          Image.asset(
            'assets/images/gestasocia_icon.png',
            width: logoSize,
            height: logoSize,
          ),
          if (!widget.isCollapsed)
            Expanded(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Container(
                  margin: EdgeInsets.only(left: logoMargin),
                  child: Text(
                    'GestAsocia',
                    style: TextStyle(
                      color: AppTheme.getTextPrimary(context),
                      fontSize: fontSize,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.clip,
                    maxLines: 1,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, int index) {
    final item = DashboardData.menuItems[index];
    final isSelected = widget.selectedIndex == index;

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final bool isSmallScreen = screenWidth < 600;
    final bool isVerySmallScreen = screenWidth < 480;
    final bool isVeryShortScreen = screenHeight < 600;

    double menuItemHeight = isVeryShortScreen ? 40 : (isSmallScreen ? 44 : 48);
    double horizontalMargin = isVerySmallScreen ? 6 : (isSmallScreen ? 8 : 10);
    double verticalMargin = isVeryShortScreen ? 2 : 3;
    double horizontalPadding = isVerySmallScreen ? 10 : (isSmallScreen ? 12 : 14);
    double iconSize = isVerySmallScreen ? 15 : 17;
    double fontSize = isVerySmallScreen ? 12 : (isSmallScreen ? 13 : 14);
    double textMargin = isVerySmallScreen ? 8 : (isSmallScreen ? 10 : 12);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: horizontalMargin, vertical: verticalMargin),
      decoration: BoxDecoration(
        color: isSelected
            ? AppTheme.primaryColor.withValues(alpha: 0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () => widget.onItemSelected(index),
          child: Container(
            height: menuItemHeight,
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 2),
            child: Row(
              children: [
                Icon(
                  item['icon'],
                  color: isSelected
                      ? AppTheme.primaryColor
                      : AppTheme.getTextSecondary(context),
                  size: iconSize,
                ),
                if (!widget.isCollapsed)
                  Expanded(
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Container(
                        margin: EdgeInsets.only(left: textMargin),
                        child: Text(
                          item['title'],
                          style: TextStyle(
                            color: isSelected
                                ? AppTheme.primaryColor
                                : AppTheme.getTextPrimary(context),
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.normal,
                            fontSize: fontSize,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAdminRegisterButton(BuildContext context) {
    // Usamos EXACTAMENTE las mismas variables de dimensión que _buildMenuItem
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final bool isSmallScreen = screenWidth < 600;
    final bool isVerySmallScreen = screenWidth < 480;
    final bool isVeryShortScreen = screenHeight < 600;

    double menuItemHeight = isVeryShortScreen ? 40 : (isSmallScreen ? 44 : 48);
    double horizontalMargin = isVerySmallScreen ? 6 : (isSmallScreen ? 8 : 10);
    double verticalMargin = isVeryShortScreen ? 2 : 3;
    double horizontalPadding = isVerySmallScreen ? 10 : (isSmallScreen ? 12 : 14);
    double iconSize = isVerySmallScreen ? 15 : 17;
    double fontSize = isVerySmallScreen ? 12 : (isSmallScreen ? 13 : 14);
    double textMargin = isVerySmallScreen ? 8 : (isSmallScreen ? 10 : 12);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: horizontalMargin, vertical: verticalMargin),
      decoration: BoxDecoration(
        color: Colors.transparent, // Fondo transparente (Igual que ítems no seleccionados)
        borderRadius: BorderRadius.circular(8),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          // AQUÍ ESTÁ EL CAMBIO CLAVE: Efectos de interacción en Morado Suave
          splashColor: Colors.purple.withValues(alpha: 0.15),
          highlightColor: Colors.purple.withValues(alpha: 0.1),
          hoverColor: Colors.purple.withValues(alpha: 0.05),
          onTap: () {
            Get.toNamed(AppRoutes.register);
          },
          child: Container(
            height: menuItemHeight,
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 2),
            child: Row(
              children: [
                Icon(
                  Icons.person_add_alt_1_outlined, // Ícono similar al estilo outline de los demás
                  // Color gris del tema (Igual que ítems no seleccionados)
                  color: AppTheme.getTextSecondary(context),
                  size: iconSize,
                ),
                if (!widget.isCollapsed)
                  Expanded(
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Container(
                        margin: EdgeInsets.only(left: textMargin),
                        child: Text(
                          'Agregar Usuario',
                          style: TextStyle(
                            // Color de texto principal del tema (Igual que ítems no seleccionados)
                            color: AppTheme.getTextPrimary(context),
                            fontWeight: FontWeight.normal,
                            fontSize: fontSize,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}