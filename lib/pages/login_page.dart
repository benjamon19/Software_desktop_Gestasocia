import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../utils/app_theme.dart';
import '../../widgets/shared_widgets.dart';
import '../../widgets/theme_toggle_button.dart';
import '../../dialog/codigo_input_dialog.dart';
import '../../dialog/nuevo_codigo_dialog.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  
  bool isPasswordVisible = false;
  bool rememberMe = false;

  final AuthController authController = Get.find<AuthController>();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: KeyboardListener(
        focusNode: FocusNode(),
        onKeyEvent: (event) {
          if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.enter) {
            if (!authController.isLoading.value) {
              _handleLogin();
            }
          }
        },
        child: Stack(
          children: [
            Container(
              color: AppTheme.backgroundColor,
              child: Row(
                children: [
                  LeftPanel(
                    title: 'GestAsocia',
                    subtitle: 'Sistema de Gestión de Asociados',
                    features: const [
                      FeatureItem(icon: Icons.people_outline, text: 'Gestión completa de asociados'),
                      FeatureItem(icon: Icons.family_restroom, text: 'Control de cargas familiares'),
                      FeatureItem(icon: Icons.calendar_today, text: 'Sistema de reservas médicas'),
                    ],
                  ),
                  Expanded(
                    flex: 4,
                    child: Container(
                      color: AppTheme.getSurfaceColor(context),
                      child: Center(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(40),
                          child: Container(
                            constraints: const BoxConstraints(maxWidth: 400),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const SizedBox(height: 32),
                                Text('Bienvenido', style: AppTheme.getHeadingMedium(context)),
                                const SizedBox(height: 8),
                                Text('Ingresa a tu cuenta para continuar', style: AppTheme.getBodyMedium(context)),
                                const SizedBox(height: 32),
                                AppTextField(
                                  controller: emailController,
                                  label: 'RUT o Correo electrónico',
                                  hint: 'Ej: 12345678-9 o ejemplo@correo.com',
                                  icon: Icons.person_outline,
                                  keyboardType: TextInputType.text,
                                ),
                                const SizedBox(height: 24),
                                AppTextField(
                                  controller: passwordController,
                                  label: 'Contraseña',
                                  hint: '••••••••',
                                  icon: Icons.lock_outline,
                                  obscureText: !isPasswordVisible,
                                  suffixIcon: IconButton(
                                    onPressed: () => setState(() => isPasswordVisible = !isPasswordVisible),
                                    icon: Icon(
                                      isPasswordVisible ? Icons.visibility_off : Icons.visibility, 
                                      size: 20,
                                      color: AppTheme.getTextSecondary(context),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Checkbox(
                                      value: rememberMe,
                                      onChanged: (value) => setState(() => rememberMe = value ?? false),
                                    ),
                                    Text('Recordarme', style: AppTheme.getBodyMedium(context)),
                                  ],
                                ),
                                const SizedBox(height: 32),
                                Obx(() => ElevatedButton(
                                  onPressed: authController.isLoading.value ? null : _handleLogin,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.primaryColor,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  child: authController.isLoading.value
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                        ),
                                      )
                                    : const Text('Iniciar Sesión', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                                )),
                                const SizedBox(height: 32),
                                Row(
                                  children: [
                                    Expanded(child: Divider(color: AppTheme.getBorderLight(context))),
                                    const SizedBox(width: 16),
                                    Text('o', style: AppTheme.getBodyMedium(context)),
                                    const SizedBox(width: 16),
                                    Expanded(child: Divider(color: AppTheme.getBorderLight(context))),
                                  ],
                                ),
                                const SizedBox(height: 32),
                                
                                Center(
                                  child: Text.rich(
                                    TextSpan(
                                      text: '¿No tienes una cuenta? ',
                                      style: AppTheme.getBodyMedium(context),
                                      children: [
                                        TextSpan(
                                          text: 'Contacta a administración',
                                          style: TextStyle(
                                            color: AppTheme.primaryColor,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const ThemeToggleButton(),
          ],
        ),
      ),
    );
  }

  Future<void> _handleLogin() async {
    String emailOrRut = emailController.text.trim();
    String password = passwordController.text;

    if (emailOrRut.isEmpty || password.isEmpty) {
      Get.snackbar('Error', 'Completa todos los campos');
      return;
    }

    bool authSuccess = await authController.login(emailOrRut, password, rememberMe: rememberMe);
    
    if (authSuccess) {
      final userId = authController.currentUserId;
      if (userId != null) {
        _showCodigoInputDialog(userId);
      }
    }
  }

  void _showCodigoInputDialog(String userId) {
    CodigoInputDialog.show(
      context,
      onConfirm: (codigo) async {
        if (codigo.isEmpty) {
          Get.snackbar('Error', 'El código no puede estar vacío');
          _showCodigoInputDialog(userId);
          return;
        }

        String? resultado = await authController.validateCodigoUnico(userId, codigo);
        
        if (resultado == '') {
          Get.snackbar(
            'Éxito',
            'Sesión iniciada correctamente',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Get.theme.colorScheme.primary.withValues(alpha: 0.8),
            colorText: Get.theme.colorScheme.onPrimary,
            margin: const EdgeInsets.all(16),
            borderRadius: 8,
            duration: const Duration(seconds: 3),
          );
          Get.offAllNamed('/dashboard');
        } else if (resultado != null) {
          _showNuevoCodigoDialog(resultado);
        } else {
          Get.snackbar(
            'Error',
            'Código incorrecto. Verifica e intenta nuevamente.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Get.theme.colorScheme.error.withValues(alpha: 0.8),
            colorText: Get.theme.colorScheme.onError,
            margin: const EdgeInsets.all(16),
            borderRadius: 8,
            duration: const Duration(seconds: 4),
          );
          _showCodigoInputDialog(userId);
        }
      },
      onCancel: () {
        authController.logout();
      },
    );
  }

  void _showNuevoCodigoDialog(String nuevoCodigo) {
    NuevoCodigoDialog.show(
      context,
      nuevoCodigo,
      onClose: () {
        Get.snackbar(
          'Éxito',
          'Sesión iniciada correctamente',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Get.theme.colorScheme.primary.withValues(alpha: 0.8),
          colorText: Get.theme.colorScheme.onPrimary,
          margin: const EdgeInsets.all(16),
          borderRadius: 8,
          duration: const Duration(seconds: 3),
        );
        Get.offAllNamed('/dashboard');
      },
    );
  }
}