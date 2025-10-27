import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../controllers/auth_controller.dart';
import '../../../../utils/app_theme.dart';

class PerfilEditSection extends StatefulWidget {
  const PerfilEditSection({super.key});

  @override
  State<PerfilEditSection> createState() => _PerfilEditSectionState();
}

class _PerfilEditSectionState extends State<PerfilEditSection> {
  final AuthController authController = Get.find<AuthController>();
  
  // Controladores para los campos editables
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  
  // Visibilidad de contraseñas
  bool _showCurrentPassword = false;
  bool _showNewPassword = false;
  bool _showConfirmPassword = false;

  @override
  void initState() {
    super.initState();
    // Inicializar teléfono actual
    _phoneController.text = authController.currentUser.value?.telefono ?? '';
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final bool isSmallScreen = screenWidth < 600;
    final bool isMediumScreen = screenWidth >= 600 && screenWidth < 1000;
    final bool isShortScreen = screenHeight < 700;
    final bool isVeryShortScreen = screenHeight < 600;

    return Obx(() {
      final currentUser = authController.currentUser.value;
      
      if (currentUser == null) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              SizedBox(height: isSmallScreen ? 12 : 16),
              Text(
                'Cargando información...',
                style: TextStyle(
                  color: AppTheme.getTextSecondary(context),
                  fontSize: isSmallScreen ? 14 : 16,
                ),
              ),
            ],
          ),
        );
      }

      // Espaciado adaptativo
      double cardSpacing = isVeryShortScreen ? 12 : (isShortScreen ? 16 : 20);

      return SingleChildScrollView(
        child: Column(
          children: [
            _buildAdaptivePhotoSection(context, authController, isSmallScreen, isMediumScreen, isVeryShortScreen),
            SizedBox(height: cardSpacing),
            _buildAdaptiveEditableInfoCard(context, currentUser, isSmallScreen, isMediumScreen, isVeryShortScreen),
            SizedBox(height: cardSpacing),
            _buildAdaptivePasswordCard(context, isSmallScreen, isMediumScreen, isVeryShortScreen),
          ],
        ),
      );
    });
  }

  Widget _buildAdaptivePhotoSection(
    BuildContext context, 
    AuthController authController, 
    bool isSmallScreen, 
    bool isMediumScreen, 
    bool isVeryShortScreen
  ) {
    double avatarSize = isVeryShortScreen ? 80 : (isSmallScreen ? 100 : 120);
    double avatarFontSize = isVeryShortScreen ? 32 : (isSmallScreen ? 40 : 48);
    double titleSize = isVeryShortScreen ? 14 : (isSmallScreen ? 16 : 18);
    double subtitleSize = isVeryShortScreen ? 12 : (isSmallScreen ? 13 : 14);

    return _buildAdaptiveCard(
      context,
      isSmallScreen: isSmallScreen,
      isVeryShortScreen: isVeryShortScreen,
      child: Column(
        children: [
          Text(
            isVeryShortScreen ? 'Foto' : 'Foto de Perfil',
            style: TextStyle(
              fontSize: titleSize,
              fontWeight: FontWeight.w600,
              color: AppTheme.getTextPrimary(context),
            ),
          ),
          SizedBox(height: isVeryShortScreen ? 12 : 20),
          
          Obx(() {
            final isUploading = authController.isUploadingPhoto.value;
            final photoUrl = authController.userPhotoUrl;
            
            return Stack(
              children: [
                // Avatar con foto o iniciales
                Container(
                  width: avatarSize,
                  height: avatarSize,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppTheme.getBorderLight(context),
                      width: isSmallScreen ? 3 : 4,
                    ),
                    image: photoUrl != null
                        ? DecorationImage(
                            image: NetworkImage(photoUrl),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: photoUrl == null
                      ? Center(
                          child: Text(
                            authController.userDisplayName.isNotEmpty
                                ? authController.userDisplayName[0].toUpperCase()
                                : 'U',
                            style: TextStyle(
                              fontSize: avatarFontSize,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        )
                      : null,
                ),
                
                // Loading overlay
                if (isUploading)
                  Container(
                    width: avatarSize,
                    height: avatarSize,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                  ),
                
                // Botón de cámara
                if (!isUploading)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: isVeryShortScreen ? 28 : (isSmallScreen ? 32 : 36),
                      height: isVeryShortScreen ? 28 : (isSmallScreen ? 32 : 36),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppTheme.getSurfaceColor(context),
                          width: isSmallScreen ? 2 : 3,
                        ),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => _showPhotoOptionsDialog(context),
                          borderRadius: BorderRadius.circular(18),
                          child: Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: isVeryShortScreen ? 14 : (isSmallScreen ? 16 : 18),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            );
          }),
          
          if (!isVeryShortScreen) ...[
            SizedBox(height: isSmallScreen ? 12 : 16),
            Text(
              'Haz clic en el ícono para cambiar tu foto',
              style: TextStyle(
                fontSize: subtitleSize,
                color: AppTheme.getTextSecondary(context),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAdaptiveEditableInfoCard(
    BuildContext context, 
    dynamic currentUser, 
    bool isSmallScreen, 
    bool isMediumScreen, 
    bool isVeryShortScreen
  ) {
    double fieldSpacing = isVeryShortScreen ? 12 : (isSmallScreen ? 14 : 16);

    return _buildAdaptiveCardWithHeader(
      context,
      icon: Icons.edit_outlined,
      title: isVeryShortScreen ? 'Info Editable' : 'Información Editable',
      color: AppTheme.primaryColor,
      isSmallScreen: isSmallScreen,
      isVeryShortScreen: isVeryShortScreen,
      child: Column(
        children: [
          // Campo de teléfono editable
          _buildEditablePhoneField(context, isSmallScreen, isVeryShortScreen),
          
          SizedBox(height: fieldSpacing),
          
          // Email (no editable)
          _buildAdaptiveField(
            context, 
            'Email', 
            currentUser.email, 
            Icons.email_outlined,
            isSmallScreen: isSmallScreen,
            isVeryShortScreen: isVeryShortScreen,
          ),
          
          SizedBox(height: fieldSpacing),
          
          // RUT (no editable)
          _buildAdaptiveField(
            context, 
            'RUT', 
            _formatRut(currentUser.rut), 
            Icons.credit_card_outlined,
            isSmallScreen: isSmallScreen,
            isVeryShortScreen: isVeryShortScreen,
          ),
        ],
      ),
    );
  }

  Widget _buildEditablePhoneField(BuildContext context, bool isSmallScreen, bool isVeryShortScreen) {
    double labelSize = isVeryShortScreen ? 12 : (isSmallScreen ? 13 : 14);
    double labelSpacing = isVeryShortScreen ? 6 : 8;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Teléfono',
          style: TextStyle(
            fontSize: labelSize,
            fontWeight: FontWeight.w500,
            color: AppTheme.getTextSecondary(context),
          ),
        ),
        SizedBox(height: labelSpacing),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                style: TextStyle(
                  color: AppTheme.getTextPrimary(context),
                  fontSize: isVeryShortScreen ? 14 : 16,
                ),
                decoration: InputDecoration(
                  prefixIcon: Icon(
                    Icons.phone_outlined,
                    size: isVeryShortScreen ? 18 : 20,
                    color: AppTheme.getTextSecondary(context),
                  ),
                  filled: true,
                  fillColor: AppTheme.getInputBackground(context),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: isVeryShortScreen ? 12 : 16,
                    vertical: isVeryShortScreen ? 12 : 16,
                  ),
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
                ),
              ),
            ),
            SizedBox(width: isVeryShortScreen ? 8 : 12),
            Obx(() {
              final isLoading = authController.isLoading.value;
              
              return ElevatedButton(
                onPressed: isLoading ? null : _updatePhone,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF059669),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: isVeryShortScreen ? 12 : 16,
                    vertical: isVeryShortScreen ? 12 : 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: isLoading
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Icon(Icons.save, size: isVeryShortScreen ? 18 : 20),
              );
            }),
          ],
        ),
      ],
    );
  }

  Widget _buildAdaptivePasswordCard(
    BuildContext context, 
    bool isSmallScreen, 
    bool isMediumScreen, 
    bool isVeryShortScreen
  ) {
    double fieldSpacing = isVeryShortScreen ? 12 : (isSmallScreen ? 14 : 16);
    double buttonSpacing = isVeryShortScreen ? 16 : 20;

    return _buildAdaptiveCardWithHeader(
      context,
      icon: Icons.lock_outlined,
      title: isVeryShortScreen ? 'Contraseña' : 'Cambiar Contraseña',
      color: const Color(0xFFF59E0B),
      isSmallScreen: isSmallScreen,
      isVeryShortScreen: isVeryShortScreen,
      child: Column(
        children: [
          _buildPasswordField(
            context, 
            'Contraseña Actual', 
            _currentPasswordController,
            _showCurrentPassword,
            () => setState(() => _showCurrentPassword = !_showCurrentPassword),
            isSmallScreen, 
            isVeryShortScreen,
          ),
          SizedBox(height: fieldSpacing),
          _buildPasswordField(
            context, 
            'Nueva Contraseña', 
            _newPasswordController,
            _showNewPassword,
            () => setState(() => _showNewPassword = !_showNewPassword),
            isSmallScreen, 
            isVeryShortScreen,
          ),
          SizedBox(height: fieldSpacing),
          _buildPasswordField(
            context, 
            'Confirmar Contraseña', 
            _confirmPasswordController,
            _showConfirmPassword,
            () => setState(() => _showConfirmPassword = !_showConfirmPassword),
            isSmallScreen, 
            isVeryShortScreen,
          ),
          SizedBox(height: buttonSpacing),
          _buildChangePasswordButton(context, isSmallScreen, isVeryShortScreen),
        ],
      ),
    );
  }

  Widget _buildPasswordField(
    BuildContext context, 
    String label,
    TextEditingController controller,
    bool showPassword,
    VoidCallback toggleVisibility,
    bool isSmallScreen, 
    bool isVeryShortScreen
  ) {
    double labelSize = isVeryShortScreen ? 12 : (isSmallScreen ? 13 : 14);
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
        TextFormField(
          controller: controller,
          obscureText: !showPassword,
          style: TextStyle(
            color: AppTheme.getTextPrimary(context),
            fontSize: isVeryShortScreen ? 14 : 16,
          ),
          decoration: InputDecoration(
            prefixIcon: Icon(
              Icons.lock_outline, 
              size: isVeryShortScreen ? 18 : 20, 
              color: AppTheme.getTextSecondary(context),
            ),
            suffixIcon: IconButton(
              icon: Icon(
                showPassword ? Icons.visibility : Icons.visibility_off,
                size: isVeryShortScreen ? 18 : 20,
                color: AppTheme.getTextSecondary(context),
              ),
              onPressed: toggleVisibility,
            ),
            filled: true,
            fillColor: AppTheme.getInputBackground(context),
            contentPadding: EdgeInsets.symmetric(
              horizontal: isVeryShortScreen ? 12 : 16,
              vertical: isVeryShortScreen ? 12 : 16,
            ),
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
          ),
        ),
      ],
    );
  }

  Widget _buildChangePasswordButton(BuildContext context, bool isSmallScreen, bool isVeryShortScreen) {
    double buttonPadding = isVeryShortScreen ? 12 : (isSmallScreen ? 14 : 16);
    double fontSize = isVeryShortScreen ? 14 : (isSmallScreen ? 15 : 16);
    double iconSize = isVeryShortScreen ? 16 : (isSmallScreen ? 18 : 20);

    return Obx(() {
      final isLoading = authController.isLoading.value;
      
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: isLoading ? null : _changePassword,
          icon: isLoading
              ? SizedBox(
                  width: iconSize,
                  height: iconSize,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Icon(Icons.save, size: iconSize),
          label: Text(
            isLoading ? 'Guardando...' : (isVeryShortScreen ? 'Guardar' : 'Guardar Cambios'),
            style: TextStyle(fontSize: fontSize),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFF59E0B),
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(vertical: buttonPadding),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      );
    });
  }

  // Dialogs y métodos de acción continúan en el siguiente mensaje...

  Widget _buildAdaptiveCard(
    BuildContext context, {
    required Widget child,
    required bool isSmallScreen,
    required bool isVeryShortScreen,
  }) {
    double padding = isVeryShortScreen ? 16 : (isSmallScreen ? 20 : 24);
    double borderRadius = isSmallScreen ? 12 : 16;

    if (isVeryShortScreen) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(padding),
        decoration: BoxDecoration(
          color: AppTheme.getSurfaceColor(context),
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(
            color: AppTheme.getBorderLight(context),
            width: 1,
          ),
        ),
        child: child,
      );
    }

    return Container(
      width: double.infinity,
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

  Widget _buildAdaptiveCardWithHeader(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Color color,
    required Widget child,
    required bool isSmallScreen,
    required bool isVeryShortScreen,
  }) {
    double headerPadding = isVeryShortScreen ? 12 : (isSmallScreen ? 16 : 20);
    double contentPadding = isVeryShortScreen ? 12 : (isSmallScreen ? 16 : 20);
    double borderRadius = isSmallScreen ? 12 : 16;
    double titleSize = isVeryShortScreen ? 14 : (isSmallScreen ? 16 : 18);
    double iconSize = isVeryShortScreen ? 20 : (isSmallScreen ? 22 : 24);
    double iconSpacing = isVeryShortScreen ? 8 : (isSmallScreen ? 10 : 12);

    if (isVeryShortScreen) {
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
          children: [
            Container(
              padding: EdgeInsets.all(headerPadding),
              child: Row(
                children: [
                  Icon(icon, color: color, size: iconSize),
                  SizedBox(width: iconSpacing),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: titleSize,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(contentPadding, 0, contentPadding, contentPadding),
              child: child,
            ),
          ],
        ),
      );
    }

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
        children: [
          Container(
            padding: EdgeInsets.all(headerPadding),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(borderRadius),
                topRight: Radius.circular(borderRadius),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: color, size: iconSize),
                SizedBox(width: iconSpacing),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: titleSize,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(contentPadding),
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _buildAdaptiveField(
    BuildContext context, 
    String label, 
    String value, 
    IconData icon, {
    required bool isSmallScreen,
    required bool isVeryShortScreen,
  }) {
    double labelSize = isVeryShortScreen ? 12 : (isSmallScreen ? 13 : 14);
    double valueSize = isVeryShortScreen ? 14 : (isSmallScreen ? 15 : 16);
    double padding = isVeryShortScreen ? 12 : (isSmallScreen ? 14 : 16);
    double iconSize = isVeryShortScreen ? 16 : (isSmallScreen ? 18 : 20);
    double iconSpacing = isVeryShortScreen ? 8 : (isSmallScreen ? 10 : 12);
    double labelSpacing = isVeryShortScreen ? 6 : 8;

    if (isVeryShortScreen) {
      return Row(
        children: [
          Container(
            padding: EdgeInsets.all(padding - 4),
            decoration: BoxDecoration(
              color: AppTheme.getInputBackground(context).withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, size: iconSize, color: AppTheme.getTextSecondary(context)),
          ),
          SizedBox(width: iconSpacing),
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
                      color: AppTheme.getTextSecondary(context),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Icon(Icons.lock_outline, size: 14, color: AppTheme.getTextSecondary(context)),
        ],
      );
    }

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
              Icon(icon, size: iconSize, color: AppTheme.getTextSecondary(context)),
              SizedBox(width: iconSpacing),
              Expanded(
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: valueSize,
                    color: AppTheme.getTextSecondary(context),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(Icons.lock_outline, size: 16, color: AppTheme.getTextSecondary(context)),
            ],
          ),
        ),
      ],
    );
  }

  // ========== MÉTODOS DE ACCIÓN ==========

  void _showPhotoOptionsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.getSurfaceColor(context),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: Row(
          children: [
            Icon(
              Icons.add_a_photo,
              color: AppTheme.primaryColor,
              size: 28,
            ),
            const SizedBox(width: 12),
            Text(
              'Cambiar Foto',
              style: TextStyle(
                color: AppTheme.getTextPrimary(context),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Color(0xFF3B82F6)),
              title: Text(
                'Tomar Foto',
                style: TextStyle(color: AppTheme.getTextPrimary(context)),
              ),
              onTap: () {
                Navigator.of(context).pop();
                authController.uploadProfilePhoto(fromCamera: true);
              },
            ),
            ListTile(
              leading: const Icon(Icons.folder, color: Color(0xFF10B981)),
              title: Text(
                'Desde Archivo',
                style: TextStyle(color: AppTheme.getTextPrimary(context)),
              ),
              onTap: () {
                Navigator.of(context).pop();
                authController.uploadProfilePhoto(fromCamera: false);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _updatePhone() async {
    final newPhone = _phoneController.text.trim();
    final success = await authController.updatePhone(newPhone);
    
    if (success) {
      // Ya se muestra el SnackBar en el controller
    }
  }

  Future<void> _changePassword() async {
    final success = await authController.changePassword(
      currentPassword: _currentPasswordController.text,
      newPassword: _newPasswordController.text,
      confirmPassword: _confirmPasswordController.text,
    );
    
    if (success) {
      // Limpiar campos
      _currentPasswordController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();
    }
  }

  String _formatRut(String rut) {
    String cleanRut = rut.replaceAll(RegExp(r'[.-]'), '');
    if (cleanRut.length < 8) return rut;
    
    String numero = cleanRut.substring(0, cleanRut.length - 1);
    String dv = cleanRut.substring(cleanRut.length - 1);
    
    String formatted = '';
    for (int i = numero.length; i > 0; i -= 3) {
      int start = i - 3 < 0 ? 0 : i - 3;
      String group = numero.substring(start, i);
      formatted = formatted.isEmpty ? group : '$group.$formatted';
    }
    
    return '$formatted-$dv';
  }
}