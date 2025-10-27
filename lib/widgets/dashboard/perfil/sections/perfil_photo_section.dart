import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../controllers/auth_controller.dart';
import '../../../../utils/app_theme.dart';

class PerfilPhotoSection extends StatelessWidget {
  const PerfilPhotoSection({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final bool isSmallScreen = screenWidth < 600;
    final bool isVeryShortScreen = screenHeight < 600;

    double avatarSize = isVeryShortScreen ? 80 : (isSmallScreen ? 100 : 120);
    double avatarFontSize = isVeryShortScreen ? 32 : (isSmallScreen ? 40 : 48);
    double titleSize = isVeryShortScreen ? 14 : (isSmallScreen ? 16 : 18);
    double subtitleSize = isVeryShortScreen ? 12 : (isSmallScreen ? 13 : 14);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isVeryShortScreen ? 16 : (isSmallScreen ? 20 : 24)),
      decoration: BoxDecoration(
        color: AppTheme.getSurfaceColor(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.getBorderLight(context),
          width: 1,
        ),
      ),
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
                          onTap: () => _showPhotoOptionsDialog(context, authController),
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

  void _showPhotoOptionsDialog(BuildContext context, AuthController authController) {
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
}