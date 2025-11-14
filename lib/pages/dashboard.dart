import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../controllers/theme_controller.dart';
import '../controllers/dashboard_page_controller.dart';
import '../widgets/dashboard/sidebar_menu.dart';
import '../widgets/dashboard/top_bar.dart';
import '../widgets/dashboard/dashboard_content.dart';
import '../widgets/dashboard/modules/gestion_asociados/asociados_main_view.dart';
import '../widgets/dashboard/modules/gestion_cargas_familiares/cargas_familiares_main_view.dart';
import '../widgets/dashboard/modules/gestion_historial_clinico/historial_clinico_main_view.dart';
import '../widgets/dashboard/modules/gestion_reserva_de_horas/reserva_de_horas_main_view.dart';
import '../widgets/dashboard/configuracion/configuracion_view.dart';
import '../widgets/dashboard/perfil/perfil_view.dart';
import '../utils/dashboard_data.dart';
import '../utils/app_theme.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late final AuthController authController = Get.find<AuthController>();
  late final ThemeController themeController = Get.find<ThemeController>();
  late final DashboardPageController dashboardController = Get.find<DashboardPageController>();
  
  bool isDrawerOpen = true;
  bool isSidebarCollapsed = false;

  void _toggleSidebar() {
    setState(() {
      isSidebarCollapsed = !isSidebarCollapsed;
    });
  }

  String _getCurrentPageTitle() {
    final index = dashboardController.selectedIndex.value;
    if (index == 5) return 'Configuración';
    if (index == 6) return 'Mi Perfil';
    if (index >= 0 && index < DashboardData.menuItems.length) {
      return DashboardData.menuItems[index]['title'] as String;
    }
    return 'Dashboard';
  }

  void _handleNavigateToSection(int index) {
    dashboardController.changeModule(index);
  }

  void _handleItemSelected(int index) {
    dashboardController.changeModule(index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.getBackgroundColor(context),
      body: Row(
        children: [
          Obx(() => SidebarMenu(
            selectedIndex: dashboardController.selectedIndex.value,
            onItemSelected: _handleItemSelected,
            isCollapsed: isSidebarCollapsed,
            onToggleCollapse: _toggleSidebar,
          )),
                     
          Expanded(
            child: Column(
              children: [
                Obx(() => TopBar(
                  isDrawerOpen: isDrawerOpen,
                  isSidebarCollapsed: isSidebarCollapsed,
                  currentPageTitle: _getCurrentPageTitle(),
                  onMenuToggle: () => setState(() => isDrawerOpen = !isDrawerOpen),
                  onSidebarToggle: _toggleSidebar,
                  authController: authController,
                  onNavigateToSection: _handleNavigateToSection,
                )),
                
                Expanded(
                  child: Obx(() => _buildPageContent()),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageContent() {
    switch (dashboardController.selectedIndex.value) {
      case 0:
        return const DashboardContent();
      case 1:
        return const AsociadosMainView();
      case 2:
        return const CargasFamiliaresMainView();
      case 3:
        return const HistorialClinicoMainView();
      case 4:
        return const ReservaDeHorasMainView();
      case 5:
        return const ConfiguracionView();
      case 6:
        return const PerfilView();
      default:
        return const DashboardContent();
    }
  }
}