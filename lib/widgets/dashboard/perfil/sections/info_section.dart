import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../controllers/auth_controller.dart';
import '../../../../utils/app_theme.dart';

class PerfilInfoSection extends StatefulWidget {
  const PerfilInfoSection({super.key});

  @override
  State<PerfilInfoSection> createState() => _PerfilInfoSectionState();
}

class _PerfilInfoSectionState extends State<PerfilInfoSection> {
  final AuthController authController = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final bool isSmallScreen = screenWidth < 600;
    final bool isVeryShortScreen = screenHeight < 600;

    double sectionSpacing = isVeryShortScreen ? 16 : (isSmallScreen ? 20 : 24);

    return Obx(() {
      final currentUser = authController.currentUser.value;
      
      if (currentUser == null) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                'Cargando información...',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 16,
                ),
              ),
            ],
          ),
        );
      }

      return SingleChildScrollView(
        child: Column(
          children: [
            // Sección: Información Personal
            _buildSection(
              context,
              title: 'Información Personal',
              icon: Icons.person_outline,
              fields: [
                _FieldData('Nombre Completo', currentUser.nombreCompleto, Icons.badge_outlined),
                _FieldData('RUT', _formatRut(currentUser.rut), Icons.fingerprint_outlined),
                _FieldData('Cargo', _formatRol(currentUser.rol), Icons.work_outline),
              ],
              isSmallScreen: isSmallScreen,
              isVeryShortScreen: isVeryShortScreen,
            ),
            
            SizedBox(height: sectionSpacing),
            
            // Sección: Información de Contacto
            _buildSection(
              context,
              title: 'Información de Contacto',
              icon: Icons.contact_mail_outlined,
              fields: [
                _FieldData('Email', currentUser.email, Icons.email_outlined),
                _FieldData('Teléfono', currentUser.telefono, Icons.phone_outlined),
              ],
              isSmallScreen: isSmallScreen,
              isVeryShortScreen: isVeryShortScreen,
            ),
            
            SizedBox(height: sectionSpacing),
            
            // Sección: Información del Sistema
            _buildSection(
              context,
              title: 'Información del Sistema',
              icon: Icons.settings_outlined,
              fields: [
                _FieldData('Fecha de Registro', _formatDate(currentUser.fechaCreacion), Icons.calendar_today_outlined),
                _FieldData('ID de Usuario', authController.currentUserId ?? 'N/A', Icons.vpn_key_outlined),
              ],
              isSmallScreen: isSmallScreen,
              isVeryShortScreen: isVeryShortScreen,
            ),
          ],
        ),
      );
    });
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required List<_FieldData> fields,
    required bool isSmallScreen,
    required bool isVeryShortScreen,
  }) {
    double titleSize = isVeryShortScreen ? 14 : (isSmallScreen ? 16 : 18);
    double iconTitleSize = isVeryShortScreen ? 20 : (isSmallScreen ? 22 : 24);
    double padding = isVeryShortScreen ? 16 : (isSmallScreen ? 20 : 24);
    double fieldSpacing = isVeryShortScreen ? 12 : 16;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: AppTheme.getSurfaceColor(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.getBorderLight(context),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título de la sección
          Row(
            children: [
              Icon(
                icon,
                size: iconTitleSize,
                color: AppTheme.primaryColor,
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: titleSize,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.getTextPrimary(context),
                ),
              ),
            ],
          ),
          SizedBox(height: isVeryShortScreen ? 16 : 20),
          
          // Campos de la sección
          ...fields.asMap().entries.map((entry) {
            final index = entry.key;
            final field = entry.value;
            return Column(
              children: [
                _buildInfoField(
                  context,
                  field.label,
                  field.value,
                  field.icon,
                  isSmallScreen,
                  isVeryShortScreen,
                ),
                if (index < fields.length - 1)
                  SizedBox(height: fieldSpacing),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildInfoField(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    bool isSmallScreen,
    bool isVeryShortScreen,
  ) {
    double labelSize = isVeryShortScreen ? 12 : (isSmallScreen ? 13 : 14);
    double valueSize = isVeryShortScreen ? 14 : (isSmallScreen ? 15 : 16);
    double padding = isVeryShortScreen ? 12 : (isSmallScreen ? 14 : 16);
    double iconSize = isVeryShortScreen ? 18 : (isSmallScreen ? 20 : 22);
    double iconSpacing = isVeryShortScreen ? 10 : (isSmallScreen ? 12 : 14);
    double labelSpacing = isVeryShortScreen ? 6 : 8;

    return Column(
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
        SizedBox(height: labelSpacing),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(padding),
          decoration: BoxDecoration(
            color: AppTheme.getInputBackground(context).withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppTheme.getBorderLight(context)),
          ),
          child: Row(
            children: [
              Icon(
                icon, 
                size: iconSize, 
                color: AppTheme.primaryColor.withValues(alpha: 0.7),
              ),
              SizedBox(width: iconSpacing),
              Expanded(
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: valueSize,
                    color: AppTheme.getTextPrimary(context),
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatRut(String rut) {
    String cleanRut = rut.replaceAll(RegExp(r'[.-]'), '');
    if (cleanRut.length < 2) return rut;
    
    String numero = cleanRut.substring(0, cleanRut.length - 1);
    String dv = cleanRut.substring(cleanRut.length - 1);
    
    String formatted = '';
    var parts = <String>[];
    for (int i = numero.length; i > 0; i -= 3) {
      int start = i - 3 < 0 ? 0 : i - 3;
      parts.insert(0, numero.substring(start, i));
    }
    formatted = parts.join('.');
    
    return '$formatted-$dv';
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    
    final months = [
      'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
    ];
    
    return '${date.day} de ${months[date.month - 1]} de ${date.year}';
  }

  // Formatear el rol para mostrarlo legible
  String _formatRol(String rol) {
    if (rol.isEmpty) return 'Sin cargo';
    if (rol == 'odontologo') return 'Odontólogo';
    if (rol == 'administrativo') return 'Administrativo';
    return rol.substring(0, 1).toUpperCase() + rol.substring(1);
  }
}

// Clase auxiliar para datos de campo - FUERA de la clase State
class _FieldData {
  final String label;
  final String value;
  final IconData icon;

  _FieldData(this.label, this.value, this.icon);
}