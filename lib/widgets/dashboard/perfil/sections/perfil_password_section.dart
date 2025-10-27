import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import '../../../../controllers/auth_controller.dart';
import '../../../../utils/app_theme.dart';
import '../../../../services/firebase_service.dart';

class PerfilPasswordSection extends StatefulWidget {
  const PerfilPasswordSection({super.key});

  @override
  State<PerfilPasswordSection> createState() => _PerfilPasswordSectionState();
}

class _PerfilPasswordSectionState extends State<PerfilPasswordSection> {
  final AuthController authController = Get.find<AuthController>();
  
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  
  bool _showCurrentPassword = false;
  bool _showNewPassword = false;
  bool _showConfirmPassword = false;
  bool _isChangingPassword = false;

  @override
  void dispose() {
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
    final bool isVeryShortScreen = screenHeight < 600;

    double titleSize = isVeryShortScreen ? 14 : (isSmallScreen ? 16 : 18);
    double fieldSpacing = isVeryShortScreen ? 12 : (isSmallScreen ? 14 : 16);
    double buttonHeight = isVeryShortScreen ? 36 : (isSmallScreen ? 40 : 44);

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Cambiar Contraseña',
            style: TextStyle(
              fontSize: titleSize,
              fontWeight: FontWeight.w600,
              color: AppTheme.getTextPrimary(context),
            ),
          ),
          SizedBox(height: isVeryShortScreen ? 16 : 20),
          
          // Contraseña actual
          _buildPasswordField(
            context,
            label: 'Contraseña Actual',
            controller: _currentPasswordController,
            isVisible: _showCurrentPassword,
            onToggleVisibility: () => setState(() => _showCurrentPassword = !_showCurrentPassword),
            isSmallScreen: isSmallScreen,
            isVeryShortScreen: isVeryShortScreen,
          ),
          SizedBox(height: fieldSpacing),
          
          // Nueva contraseña
          _buildPasswordField(
            context,
            label: 'Nueva Contraseña',
            controller: _newPasswordController,
            isVisible: _showNewPassword,
            onToggleVisibility: () => setState(() => _showNewPassword = !_showNewPassword),
            isSmallScreen: isSmallScreen,
            isVeryShortScreen: isVeryShortScreen,
          ),
          SizedBox(height: fieldSpacing),
          
          // Confirmar contraseña
          _buildPasswordField(
            context,
            label: 'Confirmar Nueva Contraseña',
            controller: _confirmPasswordController,
            isVisible: _showConfirmPassword,
            onToggleVisibility: () => setState(() => _showConfirmPassword = !_showConfirmPassword),
            isSmallScreen: isSmallScreen,
            isVeryShortScreen: isVeryShortScreen,
          ),
          SizedBox(height: isVeryShortScreen ? 16 : 20),
          
          // Botón cambiar contraseña
          SizedBox(
            width: double.infinity,
            height: buttonHeight,
            child: ElevatedButton(
              onPressed: _isChangingPassword ? null : _changePassword,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: _isChangingPassword
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      'Cambiar Contraseña',
                      style: TextStyle(
                        fontSize: isVeryShortScreen ? 13 : (isSmallScreen ? 14 : 15),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordField(
    BuildContext context, {
    required String label,
    required TextEditingController controller,
    required bool isVisible,
    required VoidCallback onToggleVisibility,
    required bool isSmallScreen,
    required bool isVeryShortScreen,
  }) {
    double labelSize = isVeryShortScreen ? 12 : (isSmallScreen ? 13 : 14);
    double inputSize = isVeryShortScreen ? 14 : (isSmallScreen ? 15 : 16);
    double padding = isVeryShortScreen ? 10 : (isSmallScreen ? 12 : 14);

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
        SizedBox(height: isVeryShortScreen ? 6 : 8),
        TextField(
          controller: controller,
          obscureText: !isVisible,
          style: TextStyle(
            fontSize: inputSize,
            color: AppTheme.getTextPrimary(context),
          ),
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.lock_outline, color: AppTheme.getTextSecondary(context)),
            suffixIcon: IconButton(
              icon: Icon(
                isVisible ? Icons.visibility_off : Icons.visibility,
                color: AppTheme.getTextSecondary(context),
              ),
              onPressed: onToggleVisibility,
            ),
            filled: true,
            fillColor: AppTheme.getInputBackground(context),
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
              borderSide: BorderSide(color: AppTheme.primaryColor, width: 2),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: padding,
              vertical: padding,
            ),
          ),
        ),
      ],
    );
  }

  // MÉTODO ALTERNATIVO - Cambia contraseña sin usar reauthenticateWithCredential
  // En su lugar, cierra sesión, vuelve a iniciar sesión y cambia la contraseña
  Future<void> _changePassword() async {
    debugPrint('==========================================');
    debugPrint('[PASSWORD] INICIO cambio de contrasena');
    debugPrint('==========================================');
    
    // Validaciones
    final currentPassword = _currentPasswordController.text;
    final newPassword = _newPasswordController.text;
    final confirmPassword = _confirmPasswordController.text;
    
    if (currentPassword.isEmpty || newPassword.isEmpty || confirmPassword.isEmpty) {
      _showError("Completa todos los campos");
      return;
    }
    
    if (newPassword != confirmPassword) {
      _showError("Las contraseñas no coinciden");
      return;
    }
    
    if (newPassword.length < 6) {
      _showError("La contraseña debe tener al menos 6 caracteres");
      return;
    }
    
    if (newPassword == currentPassword) {
      _showError("La nueva contraseña debe ser diferente");
      return;
    }

    debugPrint('[PASSWORD] Validaciones OK');
    
    setState(() => _isChangingPassword = true);
    await Future.delayed(Duration(milliseconds: 100));

    try {
      // Obtener instancia de Auth de la app principal
      final FirebaseAuth auth = FirebaseAuth.instanceFor(
        app: Firebase.app(),
      );
      
      final currentUser = auth.currentUser;
      if (currentUser == null || currentUser.email == null) {
        _showError("Usuario no autenticado");
        return;
      }

      final userEmail = currentUser.email!;
      debugPrint('[PASSWORD] Usuario actual: $userEmail');
      
      // PASO 1: Cerrar sesión
      debugPrint('[PASSWORD] Paso 1: Cerrando sesion');
      await auth.signOut();
      debugPrint('[PASSWORD] Sesion cerrada');
      
      // PASO 2: Volver a iniciar sesión con contraseña actual
      debugPrint('[PASSWORD] Paso 2: Iniciando sesion con contrasena actual');
      final UserCredential credential = await auth.signInWithEmailAndPassword(
        email: userEmail,
        password: currentPassword,
      ).timeout(
        Duration(seconds: 20),
        onTimeout: () {
          debugPrint('[PASSWORD] TIMEOUT en login');
          throw TimeoutException('Login tardo demasiado');
        },
      );
      
      debugPrint('[PASSWORD] Login exitoso');
      
      final newUser = credential.user;
      if (newUser == null) {
        throw Exception('No se pudo obtener el usuario');
      }
      
      // PASO 3: Cambiar contraseña
      debugPrint('[PASSWORD] Paso 3: Cambiando contrasena');
      await newUser.updatePassword(newPassword).timeout(
        Duration(seconds: 20),
        onTimeout: () {
          debugPrint('[PASSWORD] TIMEOUT en updatePassword');
          throw TimeoutException('Actualizacion tardo demasiado');
        },
      );
      
      debugPrint('[PASSWORD] Contrasena actualizada');
      
      // PASO 4: Recargar datos del usuario en el controller
      debugPrint('[PASSWORD] Paso 4: Recargando datos del usuario');
      authController.firebaseUser.value = newUser;
      
      // Recargar datos del usuario desde Firestore
      try {
        final usuario = await FirebaseService.getUser(newUser.uid);
        if (usuario != null) {
          authController.currentUser.value = usuario;
          debugPrint('[PASSWORD] Datos del usuario recargados desde Firestore');
        }
      } catch (e) {
        debugPrint('[PASSWORD] Error recargando datos de Firestore: $e');
      }
      
      // PASO 5: Actualizar SharedPreferences si existe
      debugPrint('[PASSWORD] Paso 5: Actualizando SharedPreferences');
      try {
        final prefs = await SharedPreferences.getInstance();
        final savedEmail = prefs.getString('user_email');
        if (savedEmail != null) {
          await prefs.setString('user_password', newPassword);
          debugPrint('[PASSWORD] SharedPreferences actualizado');
        }
      } catch (e) {
        debugPrint('[PASSWORD] Error en SharedPreferences: $e');
      }
      
      debugPrint('[PASSWORD] Proceso completado exitosamente');
      _showSuccess("Contraseña actualizada correctamente");
      
      // Limpiar campos
      if (mounted) {
        _currentPasswordController.clear();
        _newPasswordController.clear();
        _confirmPasswordController.clear();
        setState(() {
          _showCurrentPassword = false;
          _showNewPassword = false;
          _showConfirmPassword = false;
        });
      }
      
    } on TimeoutException catch (e) {
      debugPrint('[PASSWORD] ERROR TimeoutException: $e');
      _showError("La operación tardó demasiado. Verifica tu conexión.");
      
      // Intentar restaurar sesión
      try {
        final auth = FirebaseAuth.instanceFor(app: Firebase.app());
        final userEmail = authController.currentUser.value?.email;
        if (userEmail != null) {
          await auth.signInWithEmailAndPassword(
            email: userEmail,
            password: currentPassword,
          );
          debugPrint('[PASSWORD] Sesion restaurada');
        }
      } catch (e) {
        debugPrint('[PASSWORD] No se pudo restaurar sesion: $e');
      }
      
    } on FirebaseAuthException catch (e) {
      debugPrint('[PASSWORD] ERROR FirebaseAuthException: ${e.code}');
      
      String errorMessage;
      switch (e.code) {
        case 'wrong-password':
        case 'invalid-credential':
          errorMessage = "La contraseña actual es incorrecta";
          break;
        case 'user-not-found':
          errorMessage = "Usuario no encontrado";
          break;
        case 'network-request-failed':
          errorMessage = "Error de red. Verifica tu conexión";
          break;
        default:
          errorMessage = "Error: ${e.message ?? 'Desconocido'}";
      }
      
      _showError(errorMessage);
      
      // Intentar restaurar sesión
      try {
        final auth = FirebaseAuth.instanceFor(app: Firebase.app());
        final userEmail = authController.currentUser.value?.email;
        if (userEmail != null) {
          await auth.signInWithEmailAndPassword(
            email: userEmail,
            password: currentPassword,
          );
          debugPrint('[PASSWORD] Sesion restaurada');
        }
      } catch (e) {
        debugPrint('[PASSWORD] No se pudo restaurar sesion: $e');
      }
      
    } catch (e) {
      debugPrint('[PASSWORD] ERROR General: $e');
      _showError("No se pudo cambiar la contraseña");
      
    } finally {
      if (mounted) {
        setState(() => _isChangingPassword = false);
      }
      debugPrint('==========================================');
      debugPrint('[PASSWORD] FIN cambio de contrasena');
      debugPrint('==========================================');
    }
  }

  void _showError(String message) {
    Get.snackbar(
      "Error",
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Get.theme.colorScheme.error.withValues(alpha: 0.8),
      colorText: Get.theme.colorScheme.onError,
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
      duration: const Duration(seconds: 4),
    );
  }

  void _showSuccess(String message) {
    Get.snackbar(
      "Éxito",
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Get.theme.colorScheme.primary.withValues(alpha: 0.8),
      colorText: Get.theme.colorScheme.onPrimary,
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
      duration: const Duration(seconds: 3),
    );
  }
}