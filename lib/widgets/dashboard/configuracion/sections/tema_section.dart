import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../controllers/theme_controller.dart';
import '../../../../../utils/app_theme.dart';

class TemaSection extends StatelessWidget {
  const TemaSection({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeController themeController = Get.find<ThemeController>();
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final bool isSmallScreen = screenWidth < 600;
    final bool isMediumScreen = screenWidth >= 600 && screenWidth < 1000;
    final bool isShortScreen = screenHeight < 700;
    final bool isVeryShortScreen = screenHeight < 600;
    
    return SingleChildScrollView(
      child: _buildAdaptiveContainer(
        context,
        isSmallScreen: isSmallScreen,
        isVeryShortScreen: isVeryShortScreen,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAdaptiveSectionHeader(context, isSmallScreen, isMediumScreen, isVeryShortScreen),
            SizedBox(height: isVeryShortScreen ? 16 : 24),
            _buildAdaptiveThemeOptions(context, themeController, isSmallScreen, isVeryShortScreen),
            SizedBox(height: isVeryShortScreen ? 12 : (isShortScreen ? 16 : 20)),
            // Vista previa SIEMPRE visible
            _buildAdaptivePreviewCard(context, isSmallScreen, isVeryShortScreen),
            // Espacio adicional al final para scroll completo
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildAdaptiveContainer(BuildContext context, {required Widget child, required bool isSmallScreen, required bool isVeryShortScreen}) {
    double padding = isVeryShortScreen ? 16 : (isSmallScreen ? 20 : 24);
    double borderRadius = isSmallScreen ? 12 : 16;

    if (isVeryShortScreen) {
      return Container(
        padding: EdgeInsets.all(padding),
        decoration: BoxDecoration(
          color: AppTheme.getSurfaceColor(context),
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(color: AppTheme.getBorderLight(context)),
        ),
        child: child,
      );
    }

    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: AppTheme.getSurfaceColor(context),
        borderRadius: BorderRadius.circular(borderRadius),
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
      child: child,
    );
  }

  Widget _buildAdaptiveSectionHeader(BuildContext context, bool isSmallScreen, bool isMediumScreen, bool isVeryShortScreen) {
    double iconSize = isVeryShortScreen ? 20 : (isSmallScreen ? 22 : 24);
    double iconPadding = isVeryShortScreen ? 8 : (isSmallScreen ? 10 : 12);
    double iconSpacing = isVeryShortScreen ? 10 : (isSmallScreen ? 12 : 16);
    double titleSize = isVeryShortScreen ? 16 : (isSmallScreen ? 18 : 20);
    double subtitleSize = isVeryShortScreen ? 12 : (isSmallScreen ? 13 : 14);

    if (isVeryShortScreen) {
      return Row(
        children: [
          Container(
            padding: EdgeInsets.all(iconPadding),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.palette_outlined,
              color: AppTheme.primaryColor,
              size: iconSize,
            ),
          ),
          SizedBox(width: iconSpacing),
          Expanded(
            child: Text(
              'Configuración de Tema',
              style: TextStyle(
                fontSize: titleSize,
                fontWeight: FontWeight.bold,
                color: AppTheme.getTextPrimary(context),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      );
    }

    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(iconPadding),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.palette_outlined,
            color: AppTheme.primaryColor,
            size: iconSize,
          ),
        ),
        SizedBox(width: iconSpacing),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Configuración de Tema',
                style: TextStyle(
                  fontSize: titleSize,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.getTextPrimary(context),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                isSmallScreen 
                    ? 'Personaliza la apariencia'
                    : 'Personaliza la apariencia de la aplicación',
                style: TextStyle(
                  fontSize: subtitleSize,
                  color: AppTheme.getTextSecondary(context),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAdaptiveThemeOptions(BuildContext context, ThemeController themeController, bool isSmallScreen, bool isVeryShortScreen) {
    double titleSize = isVeryShortScreen ? 14 : 16;
    double spacing = isVeryShortScreen ? 10 : (isSmallScreen ? 12 : 16);
    double optionSpacing = isVeryShortScreen ? 8 : 12;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Modo de Tema',
          style: TextStyle(
            fontSize: titleSize,
            fontWeight: FontWeight.w600,
            color: AppTheme.getTextPrimary(context),
          ),
        ),
        SizedBox(height: spacing),
        
        Obx(() => Column(
          children: [
            _buildAdaptiveThemeOption(
              context,
              themeController,
              ThemeController.systemTheme,
              'Automático (Sistema)',
              'Sigue la configuración del sistema',
              Icons.brightness_auto,
              isSmallScreen,
              isVeryShortScreen,
            ),
            SizedBox(height: optionSpacing),
            _buildAdaptiveThemeOption(
              context,
              themeController,
              ThemeController.lightTheme,
              'Modo Claro',
              'Interfaz con colores claros',
              Icons.light_mode,
              isSmallScreen,
              isVeryShortScreen,
            ),
            SizedBox(height: optionSpacing),
            _buildAdaptiveThemeOption(
              context,
              themeController,
              ThemeController.darkTheme,
              'Modo Oscuro',
              'Interfaz con colores oscuros',
              Icons.dark_mode,
              isSmallScreen,
              isVeryShortScreen,
            ),
          ],
        )),
      ],
    );
  }

  Widget _buildAdaptiveThemeOption(
    BuildContext context,
    ThemeController themeController,
    int themeValue,
    String title,
    String subtitle,
    IconData icon,
    bool isSmallScreen,
    bool isVeryShortScreen,
  ) {
    final isSelected = themeController.currentTheme.value == themeValue;
    
    double padding = isVeryShortScreen ? 12 : 16;
    double iconContainerSize = isVeryShortScreen ? 32 : 40;
    double iconSize = isVeryShortScreen ? 16 : 20;
    double iconSpacing = isVeryShortScreen ? 10 : (isSmallScreen ? 12 : 16);
    double titleSize = isVeryShortScreen ? 14 : 16;
    double subtitleSize = isVeryShortScreen ? 12 : 14;
    double checkIconSize = isVeryShortScreen ? 20 : 24;

    if (isVeryShortScreen) {
      // Versión horizontal compacta
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => themeController.changeTheme(themeValue),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: EdgeInsets.all(padding),
            decoration: BoxDecoration(
              color: isSelected 
                  ? AppTheme.primaryColor.withValues(alpha: 0.1)
                  : AppTheme.getInputBackground(context),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected 
                    ? AppTheme.primaryColor 
                    : AppTheme.getBorderLight(context),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: iconContainerSize,
                  height: iconContainerSize,
                  decoration: BoxDecoration(
                    color: isSelected 
                        ? AppTheme.primaryColor.withValues(alpha: 0.2)
                        : AppTheme.getTextSecondary(context).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(
                    icon,
                    color: isSelected 
                        ? AppTheme.primaryColor 
                        : AppTheme.getTextSecondary(context),
                    size: iconSize,
                  ),
                ),
                SizedBox(width: iconSpacing),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: titleSize,
                      fontWeight: FontWeight.w600,
                      color: isSelected 
                          ? AppTheme.primaryColor 
                          : AppTheme.getTextPrimary(context),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (isSelected)
                  Icon(
                    Icons.check_circle,
                    color: AppTheme.primaryColor,
                    size: checkIconSize,
                  ),
              ],
            ),
          ),
        ),
      );
    }

    // Versión vertical normal
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => themeController.changeTheme(themeValue),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.all(padding),
          decoration: BoxDecoration(
            color: isSelected 
                ? AppTheme.primaryColor.withValues(alpha: 0.1)
                : AppTheme.getInputBackground(context),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected 
                  ? AppTheme.primaryColor 
                  : AppTheme.getBorderLight(context),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(isSmallScreen ? 6 : 8),
                decoration: BoxDecoration(
                  color: isSelected 
                      ? AppTheme.primaryColor.withValues(alpha: 0.2)
                      : AppTheme.getTextSecondary(context).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: isSelected 
                      ? AppTheme.primaryColor 
                      : AppTheme.getTextSecondary(context),
                  size: iconSize,
                ),
              ),
              SizedBox(width: iconSpacing),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: titleSize,
                        fontWeight: FontWeight.w600,
                        color: isSelected 
                            ? AppTheme.primaryColor 
                            : AppTheme.getTextPrimary(context),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: subtitleSize,
                        color: AppTheme.getTextSecondary(context),
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: AppTheme.primaryColor,
                  size: checkIconSize,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAdaptivePreviewCard(BuildContext context, bool isSmallScreen, bool isVeryShortScreen) {
    double padding = isVeryShortScreen ? 12 : (isSmallScreen ? 16 : 20);
    double titleSize = isVeryShortScreen ? 12 : (isSmallScreen ? 14 : 16);
    double previewPadding = isVeryShortScreen ? 8 : (isSmallScreen ? 12 : 16);
    double iconSpacing = isVeryShortScreen ? 4 : (isSmallScreen ? 6 : 8);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: AppTheme.getInputBackground(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.getBorderLight(context),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.visibility_outlined,
                color: AppTheme.getTextSecondary(context),
                size: isVeryShortScreen ? 16 : (isSmallScreen ? 18 : 20),
              ),
              SizedBox(width: iconSpacing),
              Text(
                isVeryShortScreen ? 'Preview' : (isSmallScreen ? 'Vista Previa' : 'Vista Previa del Tema'),
                style: TextStyle(
                  fontSize: titleSize,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.getTextPrimary(context),
                ),
              ),
            ],
          ),
          SizedBox(height: isVeryShortScreen ? 8 : (isSmallScreen ? 12 : 16)),
          
          // Mini preview card adaptativo
          Container(
            padding: EdgeInsets.all(previewPadding),
            decoration: BoxDecoration(
              color: AppTheme.getSurfaceColor(context),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).brightness == Brightness.dark 
                      ? Colors.black.withValues(alpha: 0.3)
                      : Colors.grey.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: isVeryShortScreen ? 24 : (isSmallScreen ? 32 : 40),
                  height: isVeryShortScreen ? 24 : (isSmallScreen ? 32 : 40),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                    borderRadius: BorderRadius.circular(isVeryShortScreen ? 4 : 8),
                  ),
                  child: Icon(
                    Icons.person,
                    color: Colors.white,
                    size: isVeryShortScreen ? 14 : (isSmallScreen ? 18 : 24),
                  ),
                ),
                SizedBox(width: isVeryShortScreen ? 6 : (isSmallScreen ? 8 : 12)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isVeryShortScreen ? 'Ejemplo' : 'Elemento de ejemplo',
                        style: TextStyle(
                          fontSize: isVeryShortScreen ? 11 : (isSmallScreen ? 12 : 14),
                          fontWeight: FontWeight.w600,
                          color: AppTheme.getTextPrimary(context),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (!isVeryShortScreen) ...[
                        const SizedBox(height: 2),
                        Text(
                          'Así se ve el texto secundario',
                          style: TextStyle(
                            fontSize: isSmallScreen ? 10 : 12,
                            color: AppTheme.getTextSecondary(context),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                if (!isVeryShortScreen)
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isSmallScreen ? 6 : 8, 
                      vertical: isSmallScreen ? 2 : 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}