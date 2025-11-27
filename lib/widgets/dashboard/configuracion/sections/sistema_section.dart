import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../controllers/configuracion_controller.dart';
import '../../../../../utils/app_theme.dart';

class SistemaSection extends StatelessWidget {
  const SistemaSection({super.key});

  @override
  Widget build(BuildContext context) {
    final ConfiguracionController controller = Get.find<ConfiguracionController>();
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final bool isSmallScreen = screenWidth < 600;
    final bool isMediumScreen = screenWidth >= 600 && screenWidth < 1000;
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
            _buildAdaptiveSystemInfo(context, controller, isSmallScreen, isVeryShortScreen),
            SizedBox(height: isVeryShortScreen ? 16 : 24),
            _buildAdaptiveSystemActions(context, controller, isSmallScreen, isVeryShortScreen),
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
              Icons.info_outline,
              color: AppTheme.primaryColor,
              size: iconSize,
            ),
          ),
          SizedBox(width: iconSpacing),
          Expanded(
            child: Text(
              'Información del Sistema',
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
            Icons.info_outline,
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
                'Información del Sistema',
                style: TextStyle(
                  fontSize: titleSize,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.getTextPrimary(context),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                isSmallScreen 
                    ? 'Detalles de la aplicación'
                    : 'Detalles de la aplicación y sistema',
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

  Widget _buildAdaptiveSystemInfo(BuildContext context, ConfiguracionController controller, bool isSmallScreen, bool isVeryShortScreen) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Obx(() => _buildAdaptiveInfoCard(
          context,
          isSmallScreen ? 'Información de App' : 'Información de la Aplicación',
          [
            _buildAdaptiveInfoRow('Versión', controller.appVersion.value, isVeryShortScreen),
            _buildAdaptiveInfoRow('Build', controller.buildNumber.value, isVeryShortScreen),
            _buildAdaptiveInfoRow('Flutter', controller.flutterVersion.value, isVeryShortScreen),
            _buildAdaptiveInfoRow('Fecha de Build', controller.buildDate.value, isVeryShortScreen),
          ],
          Icons.apps_outlined,
          isSmallScreen,
          isVeryShortScreen,
        )),
      ],
    );
  }

  Widget _buildAdaptiveSystemActions(BuildContext context, ConfiguracionController controller, bool isSmallScreen, bool isVeryShortScreen) {
    double titleSize = isVeryShortScreen ? 14 : 16;
    double actionSpacing = isVeryShortScreen ? 8 : 12;
    double rowSpacing = isVeryShortScreen ? 8 : 12;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isVeryShortScreen ? 'Acciones' : 'Acciones del Sistema',
          style: TextStyle(
            fontSize: titleSize,
            fontWeight: FontWeight.w600,
            color: AppTheme.getTextPrimary(context),
          ),
        ),
        SizedBox(height: isVeryShortScreen ? 12 : 16),
        
        Row(
          children: [
            Expanded(
              child: _buildAdaptiveActionButton(
                context,
                isSmallScreen || isVeryShortScreen ? 'Actualizaciones' : 'Buscar Actualizaciones',
                Icons.system_update_outlined,
                const Color(0xFF10B981),
                () => controller.checkForUpdates(),
                isSmallScreen,
                isVeryShortScreen,
              ),
            ),
            SizedBox(width: actionSpacing),
            Expanded(
              child: _buildAdaptiveActionButton(
                context,
                isSmallScreen || isVeryShortScreen ? 'Licencias' : 'Ver Licencias',
                Icons.description_outlined,
                const Color(0xFF6B7280),
                () => controller.viewLicenses(),
                isSmallScreen,
                isVeryShortScreen,
              ),
            ),
          ],
        ),
        
        SizedBox(height: rowSpacing),
        
        Row(
          children: [
            Expanded(
              child: _buildAdaptiveActionButton(
                context,
                isSmallScreen || isVeryShortScreen ? 'Privacidad' : 'Política de Privacidad',
                Icons.privacy_tip_outlined,
                const Color(0xFF8B5CF6),
                () => controller.viewPrivacyPolicy(),
                isSmallScreen,
                isVeryShortScreen,
              ),
            ),
            SizedBox(width: actionSpacing),
            Expanded(
              child: _buildAdaptiveActionButton(
                context,
                isSmallScreen || isVeryShortScreen ? 'Soporte' : 'Soporte Técnico',
                Icons.support_agent_outlined,
                const Color(0xFF3B82F6),
                () => controller.contactSupport(),
                isSmallScreen,
                isVeryShortScreen,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAdaptiveInfoCard(
    BuildContext context,
    String title,
    List<Widget> children,
    IconData icon,
    bool isSmallScreen,
    bool isVeryShortScreen,
  ) {
    double padding = isVeryShortScreen ? 12 : (isSmallScreen ? 16 : 20);
    double titleSize = isVeryShortScreen ? 14 : 16;
    double iconSize = isVeryShortScreen ? 16 : 20;
    double iconPadding = isVeryShortScreen ? 6 : 8;
    double iconSpacing = isVeryShortScreen ? 8 : 12;
    double contentSpacing = isVeryShortScreen ? 12 : 16;

    return Container(
      width: double.infinity,
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
                padding: EdgeInsets.all(iconPadding),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  icon,
                  color: AppTheme.primaryColor,
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
            ],
          ),
          SizedBox(height: contentSpacing),
          ...children,
        ],
      ),
    );
  }

  Widget _buildAdaptiveInfoRow(String label, String value, bool isVeryShortScreen) {
    double fontSize = isVeryShortScreen ? 12 : 14;
    double bottomPadding = isVeryShortScreen ? 6 : 8;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomPadding),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontSize: fontSize,
                color: AppTheme.getTextSecondary(Get.context!),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.w600,
                color: AppTheme.getTextPrimary(Get.context!),
              ),
              textAlign: TextAlign.end,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdaptiveActionButton(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onPressed,
    bool isSmallScreen,
    bool isVeryShortScreen,
  ) {
    double padding = isVeryShortScreen ? 12 : (isSmallScreen ? 14 : 16);
    double iconSize = isVeryShortScreen ? 20 : (isSmallScreen ? 22 : 24);
    double titleSize = isVeryShortScreen ? 12 : (isSmallScreen ? 13 : 14);
    double iconSpacing = isVeryShortScreen ? 6 : 8;

    return Obx(() {
      final ConfiguracionController controller = Get.find<ConfiguracionController>();
      final isLoading = controller.isLoading.value;
      
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: double.infinity, // Ancho completo
            padding: EdgeInsets.symmetric(
              vertical: padding,
              horizontal: padding,
            ),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                if (isLoading && title.contains('Actualizaciones'))
                  SizedBox(
                    width: iconSize,
                    height: iconSize,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                    ),
                  )
                else
                  Icon(
                    icon,
                    color: color,
                    size: iconSize,
                  ),
                SizedBox(width: iconSpacing),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: titleSize,
                      fontWeight: FontWeight.w600,
                      color: color,
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
    });
  }
}