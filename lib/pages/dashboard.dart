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
  final AuthController authController = Get.find<AuthController>();
  final ThemeController themeController = Get.find<ThemeController>();
  final DashboardPageController dashboardController = Get.find<DashboardPageController>();
  
  bool isDrawerOpen = true;
  bool isSidebarCollapsed = false;

  void _toggleSidebar() {
    setState(() {
      isSidebarCollapsed = !isSidebarCollapsed;
    });
  }

  String _getCurrentPageTitle() {
    switch (dashboardController.selectedIndex.value) {
      case 0:
        return DashboardData.menuItems[0]['title'];
      case 1:
        return DashboardData.menuItems[1]['title'];
      case 2:
        return DashboardData.menuItems[2]['title'];
      case 3:
        return DashboardData.menuItems[3]['title'];
      case 4:
        return DashboardData.menuItems[4]['title'];
      case 5:
        return 'Configuración';
      case 6:
        return 'Mi Perfil';
      default:
        return DashboardData.menuItems[0]['title'];
    }
  }

  void _handleNavigateToSection(int index) {
    debugPrint('Dashboard recibió navegación a index: $index');
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
                  child: Obx(() => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOutCubic,
                    child: _buildPageContent(),
                  )),
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
        return _buildPlaceholderView(
          title: 'Reserva de Horas',
          icon: Icons.schedule_outlined,
          description: 'Sistema de reservas médicas\n(Próximamente)',
        );
      case 5:
        return const ConfiguracionView();
      case 6:
        return const PerfilView();
      default:
        return const DashboardContent();
    }
  }

  Widget _buildPlaceholderView({
    required String title,
    required IconData icon,
    required String description,
  }) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 80,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 30),
            Text(
              title,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppTheme.getTextPrimary(context),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              description,
              style: TextStyle(
                fontSize: 16,
                color: AppTheme.getTextSecondary(context),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () => dashboardController.changeModule(0),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Volver al Dashboard',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}