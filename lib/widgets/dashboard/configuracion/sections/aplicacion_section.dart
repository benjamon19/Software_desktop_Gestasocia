import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../controllers/configuracion_controller.dart';
import '../../../../../utils/app_theme.dart';

class AplicacionSection extends StatelessWidget {
  const AplicacionSection({super.key});

  @override
  Widget build(BuildContext context) {
    final ConfiguracionController controller = Get.find<ConfiguracionController>();
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final bool isSmallScreen = screenWidth < 600;
    final bool isMediumScreen = screenWidth >= 600 && screenWidth < 1000;
    // Removida variable isShortScreen no utilizada
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
            _buildAdaptiveBasicSettings(context, controller, isSmallScreen, isVeryShortScreen),
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
              Icons.tune_outlined,
              color: AppTheme.primaryColor,
              size: iconSize,
            ),
          ),
          SizedBox(width: iconSpacing),
          Expanded(
            child: Text(
              'Configuración de Aplicación',
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
            Icons.tune_outlined,
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
                'Configuración de Aplicación',
                style: TextStyle(
                  fontSize: titleSize,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.getTextPrimary(context),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                isSmallScreen 
                    ? 'Personaliza el comportamiento'
                    : 'Personaliza el comportamiento básico',
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

  Widget _buildAdaptiveBasicSettings(BuildContext context, ConfiguracionController controller, bool isSmallScreen, bool isVeryShortScreen) {
    double settingsSpacing = isVeryShortScreen ? 12 : 16;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Autoguardado
        Obx(() => _buildAdaptiveSwitchTile(
          context,
          'Autoguardado',
          'Guarda automáticamente los cambios en formularios',
          Icons.save_outlined,
          controller.autoSave.value,
          (value) => controller.toggleAutoSave(value),
          isSmallScreen,
          isVeryShortScreen,
        )),
        
        SizedBox(height: settingsSpacing),
        
        // Confirmaciones
        Obx(() => _buildAdaptiveSwitchTile(
          context,
          'Confirmar eliminaciones',
          'Solicita confirmación antes de eliminar registros',
          Icons.delete_outline,
          controller.confirmActions.value,
          (value) => controller.toggleConfirmActions(value),
          isSmallScreen,
          isVeryShortScreen,
        )),
        
        SizedBox(height: settingsSpacing),
        
        // Formato de fecha - Corregido: removido el parámetro isVeryShortScreen extra
        _buildAdaptiveDateFormatTile(context, controller, isSmallScreen),
      ],
    );
  }

  Widget _buildAdaptiveSwitchTile(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    bool value,
    Function(bool) onChanged,
    bool isSmallScreen,
    bool isVeryShortScreen,
  ) {
    double padding = isVeryShortScreen ? 12 : 16;
    double iconContainerSize = isVeryShortScreen ? 32 : 40;
    double iconSize = isVeryShortScreen ? 16 : 20;
    double iconSpacing = isVeryShortScreen ? 10 : (isSmallScreen ? 12 : 16);
    double titleSize = isVeryShortScreen ? 14 : 16;
    double subtitleSize = isVeryShortScreen ? 12 : 14;

    if (isVeryShortScreen) {
      // Versión horizontal compacta
      return Container(
        padding: EdgeInsets.all(padding),
        decoration: BoxDecoration(
          color: AppTheme.getInputBackground(context),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppTheme.getBorderLight(context)),
        ),
        child: Row(
          children: [
            Container(
              width: iconContainerSize,
              height: iconContainerSize,
              decoration: BoxDecoration(
                color: value 
                    ? AppTheme.primaryColor.withValues(alpha: 0.1)
                    : AppTheme.getTextSecondary(context).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                icon,
                color: value 
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
                  color: AppTheme.getTextPrimary(context),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Switch(
              value: value,
              onChanged: onChanged,
              activeThumbColor: AppTheme.primaryColor,
            ),
          ],
        ),
      );
    }

    // Versión vertical normal
    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: AppTheme.getInputBackground(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.getBorderLight(context)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(isSmallScreen ? 6 : 8),
            decoration: BoxDecoration(
              color: value 
                  ? AppTheme.primaryColor.withValues(alpha: 0.1)
                  : AppTheme.getTextSecondary(context).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: value 
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
                    color: AppTheme.getTextPrimary(context),
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
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppTheme.primaryColor,
          ),
        ],
      ),
    );
  }

  Widget _buildAdaptiveDateFormatTile(BuildContext context, ConfiguracionController controller, bool isSmallScreen) {
    double padding = isSmallScreen ? 14 : 16;
    double iconContainerSize = isSmallScreen ? 36 : 40;
    double iconSize = isSmallScreen ? 18 : 20;
    double iconSpacing = isSmallScreen ? 12 : 16;
    double titleSize = isSmallScreen ? 15 : 16;
    double subtitleSize = isSmallScreen ? 13 : 14;
    double fieldSpacing = isSmallScreen ? 14 : 16;

    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: AppTheme.getInputBackground(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.getBorderLight(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: iconContainerSize,
                height: iconContainerSize,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.calendar_today_outlined,
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
                      'Formato de Fecha',
                      style: TextStyle(
                        fontSize: titleSize,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.getTextPrimary(context),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isSmallScreen 
                          ? 'Cómo se muestran las fechas'
                          : 'Cómo se muestran las fechas en el sistema',
                      style: TextStyle(
                        fontSize: subtitleSize,
                        color: AppTheme.getTextSecondary(context),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: fieldSpacing),
          Obx(() => DropdownButtonFormField<String>(
            // Cambio de 'value' por 'initialValue' para corregir la deprecación
            initialValue: controller.dateFormat.value,
            decoration: InputDecoration(
              filled: true,
              fillColor: AppTheme.getSurfaceColor(context),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppTheme.getBorderLight(context)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppTheme.getBorderLight(context)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? 10 : 12, 
                vertical: isSmallScreen ? 8 : 10,
              ),
            ),
            style: TextStyle(
              color: AppTheme.getTextPrimary(context),
              fontSize: isSmallScreen ? 13 : 14,
            ),
            dropdownColor: AppTheme.getSurfaceColor(context),
            items: [
              DropdownMenuItem(
                value: 'dd/mm/yyyy', 
                child: Text(
                  'DD/MM/AAAA (28/06/2025)',
                  style: TextStyle(fontSize: isSmallScreen ? 13 : 14),
                ),
              ),
              DropdownMenuItem(
                value: 'mm/dd/yyyy', 
                child: Text(
                  'MM/DD/AAAA (06/28/2025)',
                  style: TextStyle(fontSize: isSmallScreen ? 13 : 14),
                ),
              ),
              DropdownMenuItem(
                value: 'yyyy-mm-dd', 
                child: Text(
                  'AAAA-MM-DD (2025-06-28)',
                  style: TextStyle(fontSize: isSmallScreen ? 13 : 14),
                ),
              ),
            ],
            onChanged: (value) {
              if (value != null) {
                controller.changeDateFormat(value);
              }
            },
          )),
        ],
      ),
    );
  }
}