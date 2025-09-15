import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../controllers/auth_controller.dart';
import '../../../../utils/app_theme.dart';

class PerfilInfoSection extends StatelessWidget {
  const PerfilInfoSection({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final bool isSmallScreen = screenWidth < 600;
    final bool isMediumScreen = screenWidth >= 600 && screenWidth < 1000;
    final bool isShortScreen = screenHeight < 700;
    final bool isVeryShortScreen = screenHeight < 600;

    return Obx(() {
      final currentUser = authController.currentUser.value;
      
      if (currentUser == null) {
        return const Center(child: CircularProgressIndicator());
      }

      // Espaciado adaptativo
      double cardSpacing = isVeryShortScreen ? 12 : (isShortScreen ? 16 : 20);

      return SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tarjeta de información personal
            _buildAdaptiveInfoCard(
              context,
              title: 'Información Personal',
              icon: Icons.person_outline,
              isSmallScreen: isSmallScreen,
              isMediumScreen: isMediumScreen,
              isVeryShortScreen: isVeryShortScreen,
              children: [
                _buildAdaptiveInfoRow(
                  context,
                  label: 'Nombre Completo',
                  value: '${currentUser.nombre} ${currentUser.apellido}',
                  icon: Icons.person,
                  isSmallScreen: isSmallScreen,
                  isVeryShortScreen: isVeryShortScreen,
                ),
                _buildAdaptiveInfoRow(
                  context,
                  label: 'Nombre',
                  value: currentUser.nombre,
                  icon: Icons.badge,
                  isSmallScreen: isSmallScreen,
                  isVeryShortScreen: isVeryShortScreen,
                ),
                _buildAdaptiveInfoRow(
                  context,
                  label: 'Apellido',
                  value: currentUser.apellido,
                  icon: Icons.badge_outlined,
                  isSmallScreen: isSmallScreen,
                  isVeryShortScreen: isVeryShortScreen,
                ),
                _buildAdaptiveInfoRow(
                  context,
                  label: 'RUT',
                  value: _formatRut(currentUser.rut),
                  icon: Icons.credit_card,
                  isSmallScreen: isSmallScreen,
                  isVeryShortScreen: isVeryShortScreen,
                ),
              ],
            ),
            
            SizedBox(height: cardSpacing),
            
            // Tarjeta de información de contacto
            _buildAdaptiveInfoCard(
              context,
              title: 'Información de Contacto',
              icon: Icons.contact_mail_outlined,
              isSmallScreen: isSmallScreen,
              isMediumScreen: isMediumScreen,
              isVeryShortScreen: isVeryShortScreen,
              children: [
                _buildAdaptiveInfoRow(
                  context,
                  label: 'Email',
                  value: currentUser.email,
                  icon: Icons.email_outlined,
                  isSmallScreen: isSmallScreen,
                  isVeryShortScreen: isVeryShortScreen,
                ),
                _buildAdaptiveInfoRow(
                  context,
                  label: 'Teléfono',
                  value: currentUser.telefono,
                  icon: Icons.phone_outlined,
                  isSmallScreen: isSmallScreen,
                  isVeryShortScreen: isVeryShortScreen,
                ),
              ],
            ),
            
            SizedBox(height: cardSpacing),
            
            // Tarjeta de información del sistema
            _buildAdaptiveInfoCard(
              context,
              title: 'Información del Sistema',
              icon: Icons.settings_outlined,
              isSmallScreen: isSmallScreen,
              isMediumScreen: isMediumScreen,
              isVeryShortScreen: isVeryShortScreen,
              children: [
                _buildAdaptiveInfoRow(
                  context,
                  label: 'Fecha de Registro',
                  value: _formatDate(currentUser.fechaCreacion),
                  icon: Icons.calendar_today_outlined,
                  isSmallScreen: isSmallScreen,
                  isVeryShortScreen: isVeryShortScreen,
                ),
                _buildAdaptiveInfoRow(
                  context,
                  label: 'ID de Usuario',
                  value: currentUser.id ?? 'N/A',
                  icon: Icons.fingerprint,
                  isSmallScreen: isSmallScreen,
                  isVeryShortScreen: isVeryShortScreen,
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _buildAdaptiveInfoCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required List<Widget> children,
    required bool isSmallScreen,
    required bool isMediumScreen,
    required bool isVeryShortScreen,
  }) {
    // Padding adaptativo
    double headerPadding = isVeryShortScreen ? 12 : (isSmallScreen ? 16 : 20);
    double contentPadding = isVeryShortScreen ? 12 : (isSmallScreen ? 16 : 20);
    double borderRadius = isSmallScreen ? 12 : 16;
    
    // Tamaños de texto adaptativos
    double titleSize = isVeryShortScreen ? 14 : (isSmallScreen ? 16 : 18);
    double iconSize = isVeryShortScreen ? 20 : (isSmallScreen ? 22 : 24);

    if (isVeryShortScreen) {
      // Versión ultra compacta
      return Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppTheme.getSurfaceColor(context),
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(
            color: AppTheme.getBorderLight(context),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header simplificado
            Container(
              padding: EdgeInsets.all(headerPadding),
              child: Row(
                children: [
                  Icon(
                    icon,
                    color: AppTheme.primaryColor,
                    size: iconSize,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: titleSize,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ],
              ),
            ),
            
            // Contenido compacto
            Padding(
              padding: EdgeInsets.fromLTRB(contentPadding, 0, contentPadding, contentPadding),
              child: Column(
                children: children,
              ),
            ),
          ],
        ),
      );
    }

    // Versión normal con header colorido
    return Container(
      width: double.infinity,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header de la tarjeta
          Container(
            padding: EdgeInsets.all(headerPadding),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(borderRadius),
                topRight: Radius.circular(borderRadius),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: AppTheme.primaryColor,
                  size: iconSize,
                ),
                SizedBox(width: isSmallScreen ? 10 : 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: titleSize,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
          ),
          
          // Contenido de la tarjeta
          Padding(
            padding: EdgeInsets.all(contentPadding),
            child: Column(
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdaptiveInfoRow(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
    required bool isSmallScreen,
    required bool isVeryShortScreen,
    Color? valueColor,
  }) {
    // Espaciado y tamaños adaptativos
    double bottomPadding = isVeryShortScreen ? 8 : (isSmallScreen ? 12 : 16);
    double iconContainerSize = isVeryShortScreen ? 32 : (isSmallScreen ? 36 : 40);
    double iconSize = isVeryShortScreen ? 16 : (isSmallScreen ? 18 : 20);
    double horizontalSpacing = isVeryShortScreen ? 10 : (isSmallScreen ? 12 : 16);
    double labelSize = isVeryShortScreen ? 12 : (isSmallScreen ? 13 : 14);
    double valueSize = isVeryShortScreen ? 14 : (isSmallScreen ? 15 : 16);
    double verticalSpacing = isVeryShortScreen ? 2 : 4;

    if (isVeryShortScreen) {
      // Layout horizontal compacto para pantallas muy pequeñas
      return Padding(
        padding: EdgeInsets.only(bottom: bottomPadding),
        child: Row(
          children: [
            Container(
              width: iconContainerSize,
              height: iconContainerSize,
              decoration: BoxDecoration(
                color: AppTheme.getInputBackground(context),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                icon,
                size: iconSize,
                color: AppTheme.getTextSecondary(context),
              ),
            ),
            
            SizedBox(width: horizontalSpacing),
            
            Expanded(
              child: RichText(
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                text: TextSpan(
                  style: TextStyle(
                    fontSize: labelSize,
                    color: AppTheme.getTextPrimary(context),
                  ),
                  children: [
                    TextSpan(
                      text: '$label: ',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: AppTheme.getTextSecondary(context),
                      ),
                    ),
                    TextSpan(
                      text: value,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: valueColor ?? AppTheme.getTextPrimary(context),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Layout vertical normal
    return Padding(
      padding: EdgeInsets.only(bottom: bottomPadding),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: iconContainerSize,
            height: iconContainerSize,
            decoration: BoxDecoration(
              color: AppTheme.getInputBackground(context),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Icon(
                icon,
                size: iconSize,
                color: AppTheme.getTextSecondary(context),
              ),
            ),
          ),
          
          SizedBox(width: horizontalSpacing),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: labelSize,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.getTextSecondary(context),
                  ),
                ),
                SizedBox(height: verticalSpacing),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: valueSize,
                    fontWeight: FontWeight.w600,
                    color: valueColor ?? AppTheme.getTextPrimary(context),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatRut(String rut) {
    // Quitar puntos y guiones existentes
    String cleanRut = rut.replaceAll(RegExp(r'[.-]'), '');
    
    if (cleanRut.length < 8) return rut;
    
    // Separar el dígito verificador
    String numero = cleanRut.substring(0, cleanRut.length - 1);
    String dv = cleanRut.substring(cleanRut.length - 1);
    
    // Formatear con puntos
    String formatted = '';
    for (int i = numero.length; i > 0; i -= 3) {
      int start = i - 3 < 0 ? 0 : i - 3;
      String group = numero.substring(start, i);
      formatted = formatted.isEmpty ? group : '$group.$formatted';
    }
    
    return '$formatted-$dv';
  }

  String _formatDate(DateTime date) {
    final months = [
      'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
    ];
    
    return '${date.day} de ${months[date.month - 1]}, ${date.year}';
  }
}