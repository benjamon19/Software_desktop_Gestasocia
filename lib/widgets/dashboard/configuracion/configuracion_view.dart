import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/configuracion_controller.dart';
import '../../../utils/app_theme.dart';
import 'sections/tema_section.dart';
import 'sections/aplicacion_section.dart';
import 'sections/sistema_section.dart';

class ConfiguracionView extends StatelessWidget {
  const ConfiguracionView({super.key});

  @override
  Widget build(BuildContext context) {
    final ConfiguracionController controller = Get.put(ConfiguracionController());
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final bool isSmallScreen = screenWidth < 600;
    final bool isMediumScreen = screenWidth >= 600 && screenWidth < 1000;
    final bool isShortScreen = screenHeight < 700;
    final bool isVeryShortScreen = screenHeight < 600;
    
    // Padding adaptativo
    double containerPadding = isVeryShortScreen ? 16 : (isShortScreen ? 20 : (isSmallScreen ? 24 : 30));
    double sectionSpacing = isVeryShortScreen ? 16 : (isShortScreen ? 20 : 30);
    double tabSpacing = isVeryShortScreen ? 12 : (isShortScreen ? 16 : 20);
    
    return Container(
      padding: EdgeInsets.all(containerPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAdaptiveHeader(context, isSmallScreen, isMediumScreen, isVeryShortScreen),
          SizedBox(height: sectionSpacing),
          _buildAdaptiveTabSelector(context, controller, isSmallScreen, isVeryShortScreen),
          SizedBox(height: tabSpacing),
          Expanded(
            child: Obx(() => _buildCurrentSection(controller)),
          ),
        ],
      ),
    );
  }

  Widget _buildAdaptiveHeader(BuildContext context, bool isSmallScreen, bool isMediumScreen, bool isVeryShortScreen) {
    double titleSize = isVeryShortScreen ? 20 : (isSmallScreen ? 24 : 28);
    double subtitleSize = isVeryShortScreen ? 13 : (isSmallScreen ? 14 : 16);
    double headerSpacing = isVeryShortScreen ? 4 : 8;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Configuración',
          style: TextStyle(
            fontSize: titleSize,
            fontWeight: FontWeight.bold,
            color: AppTheme.getTextPrimary(context),
          ),
        ),
        if (!isVeryShortScreen) ...[
          SizedBox(height: headerSpacing),
          Text(
            isSmallScreen 
                ? 'Personaliza la aplicación'
                : 'Personaliza la aplicación según tus preferencias',
            style: TextStyle(
              fontSize: subtitleSize,
              color: AppTheme.getTextSecondary(context),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildAdaptiveTabSelector(BuildContext context, ConfiguracionController controller, bool isSmallScreen, bool isVeryShortScreen) {
    double tabPadding = isVeryShortScreen ? 4 : 6;

    return Container(
      padding: EdgeInsets.all(tabPadding),
      decoration: BoxDecoration(
        color: AppTheme.getInputBackground(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.getBorderLight(context),
        ),
      ),
      child: Obx(() => isVeryShortScreen 
          ? _buildCompactTabs(context, controller)
          : _buildNormalTabs(context, controller, isSmallScreen)
      ),
    );
  }

  Widget _buildCompactTabs(BuildContext context, ConfiguracionController controller) {
    final tabs = [
      {'id': 'tema', 'icon': Icons.palette_outlined},
      {'id': 'aplicacion', 'icon': Icons.tune_outlined},
      {'id': 'sistema', 'icon': Icons.info_outline},
    ];

    return Row(
      children: tabs.map((tab) {
        final isSelected = controller.selectedSection.value == tab['id'];
        
        return Expanded(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => controller.selectSection(tab['id'] as String),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected 
                      ? AppTheme.primaryColor 
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  tab['icon'] as IconData,
                  size: 18,
                  color: isSelected 
                      ? Colors.white 
                      : AppTheme.getTextSecondary(context),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildNormalTabs(BuildContext context, ConfiguracionController controller, bool isSmallScreen) {
    final tabs = [
      {'id': 'tema', 'title': 'Tema', 'icon': Icons.palette_outlined},
      {'id': 'aplicacion', 'title': 'Aplicación', 'icon': Icons.tune_outlined},
      {'id': 'sistema', 'title': 'Sistema', 'icon': Icons.info_outline},
    ];

    return Row(
      children: tabs.map((tab) {
        return Expanded(
          child: _buildAdaptiveTab(
            context,
            controller,
            tab['id'] as String,
            tab['title'] as String,
            tab['icon'] as IconData,
            isSmallScreen,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAdaptiveTab(
    BuildContext context,
    ConfiguracionController controller,
    String sectionId,
    String title,
    IconData icon,
    bool isSmallScreen,
  ) {
    final isSelected = controller.selectedSection.value == sectionId;
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => controller.selectSection(sectionId),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: EdgeInsets.symmetric(
            vertical: isSmallScreen ? 10 : 12, 
            horizontal: isSmallScreen ? 12 : 16,
          ),
          decoration: BoxDecoration(
            color: isSelected 
                ? AppTheme.primaryColor 
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: isSmallScreen ? 18 : 20,
                color: isSelected 
                    ? Colors.white 
                    : AppTheme.getTextSecondary(context),
              ),
              SizedBox(width: isSmallScreen ? 6 : 8),
              Flexible(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: isSmallScreen ? 12 : 14,
                    fontWeight: FontWeight.w600,
                    color: isSelected 
                        ? Colors.white 
                        : AppTheme.getTextPrimary(context),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentSection(ConfiguracionController controller) {
    switch (controller.selectedSection.value) {
      case 'tema':
        return const TemaSection();
      case 'aplicacion':
        return const AplicacionSection();
      case 'sistema':
        return const SistemaSection();
      default:
        return const TemaSection();
    }
  }
}