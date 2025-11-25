import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../services/auth_helper.dart';
import '../../utils/app_theme.dart';
import '../../utils/terms_and_conditions_dialog.dart';
import '../../widgets/interactive_link.dart';
import '../../widgets/shared_widgets.dart';
import '../dialog/codigo_unico_dialog.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // --- VARIABLES Y CONTROLADORES (Lógica robusta del Código 1) ---
  final nombreController = TextEditingController();
  final apellidoController = TextEditingController();
  final rutController = TextEditingController();
  final emailController = TextEditingController();
  final telefonoController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  String selectedRol = 'Odontólogo';

  bool isPasswordVisible = false;
  bool isConfirmPasswordVisible = false;
  bool acceptTerms = false;

  final AuthController authController = Get.find<AuthController>();

  @override
  void dispose() {
    nombreController.dispose();
    apellidoController.dispose();
    rutController.dispose();
    emailController.dispose();
    telefonoController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  void _formatRut(String text) {
    String clean = text.replaceAll(RegExp(r'[^0-9kK]'), '').toLowerCase();

    if (clean.isEmpty) {
      rutController.value = const TextEditingValue(text: '');
      return;
    }

    if (clean.length > 9) {
      clean = clean.substring(0, 9);
    }

    String formatted;
    if (clean.length <= 7) {
      formatted = clean;
    } else if (clean.length == 8) {
      formatted = '${clean.substring(0, 7)}-${clean.substring(7)}';
    } else {
      formatted = '${clean.substring(0, 8)}-${clean.substring(8)}';
    }

    rutController.value = TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  @override
  Widget build(BuildContext context) {
    // --- ESTÉTICA VISUAL (Layout limpio del Código 2) ---
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final bool isSmallScreen = screenWidth < 600;
    final bool isVeryShortScreen = screenHeight < 600;

    double cardPadding = isVeryShortScreen ? 16 : (isSmallScreen ? 20 : 24);
    double borderRadius = isSmallScreen ? 12 : 16;

    return Scaffold(
      backgroundColor: AppTheme.getSurfaceColor(context),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(40),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // AVISO DE SEGURIDAD
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.security, color: Colors.orange),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Por términos de seguridad, la creación de usuarios se realiza exclusivamente desde este panel administrativo.',
                          style: TextStyle(
                            color: AppTheme.getTextPrimary(context),
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // CARTA PRINCIPAL
                Container(
                  padding: EdgeInsets.all(cardPadding),
                  decoration: isVeryShortScreen
                      ? BoxDecoration(
                          color: AppTheme.getSurfaceColor(context),
                          borderRadius: BorderRadius.circular(borderRadius),
                          border: Border.all(color: AppTheme.getBorderLight(context)),
                        )
                      : BoxDecoration(
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
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text('Crear Cuenta', style: AppTheme.getHeadingMedium(context)),
                      const SizedBox(height: 8),
                      Text('Completa los datos para registrar un nuevo usuario',
                          style: AppTheme.getBodyMedium(context)),
                      const SizedBox(height: 32),

                      const SectionHeader(icon: Icons.person, title: 'Información Personal'),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: AppTextField(
                              controller: nombreController,
                              label: 'Nombre',
                              hint: 'Tu nombre',
                              icon: Icons.person_outline,
                              keyboardType: TextInputType.name,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: AppTextField(
                              controller: apellidoController,
                              label: 'Apellido',
                              hint: 'Tu apellido',
                              icon: Icons.person_outline,
                              keyboardType: TextInputType.name,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      AppTextField(
                        controller: rutController,
                        label: 'RUT',
                        hint: '12345678-9',
                        icon: Icons.badge_outlined,
                        onChanged: _formatRut,
                        keyboardType: TextInputType.text,
                      ),
                      const SizedBox(height: 20),

                      DropdownButtonFormField<String>(
                        initialValue: selectedRol,
                        decoration: InputDecoration(
                          labelText: 'Cargo',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          filled: true,
                          fillColor: AppTheme.getInputBackground(context),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'Odontólogo', child: Text('Odontólogo')),
                          DropdownMenuItem(value: 'Administrativo', child: Text('Administrativo')),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => selectedRol = value);
                          }
                        },
                      ),
                      const SizedBox(height: 32),

                      const SectionHeader(icon: Icons.contact_mail, title: 'Comunicación'),
                      const SizedBox(height: 16),
                      AppTextField(
                        controller: emailController,
                        label: 'Correo electrónico',
                        hint: 'tu@correo.com',
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 20),
                      AppTextField(
                        controller: telefonoController,
                        label: 'Teléfono',
                        hint: '9 1234 5678',
                        icon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      ),
                      const SizedBox(height: 32),

                      const SectionHeader(icon: Icons.security, title: 'Seguridad'),
                      const SizedBox(height: 16),
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
                      const SizedBox(height: 20),
                      AppTextField(
                        controller: confirmPasswordController,
                        label: 'Confirmar Contraseña',
                        hint: '••••••••',
                        icon: Icons.lock_outline,
                        obscureText: !isConfirmPasswordVisible,
                        suffixIcon: IconButton(
                          onPressed: () => setState(
                              () => isConfirmPasswordVisible = !isConfirmPasswordVisible),
                          icon: Icon(
                            isConfirmPasswordVisible ? Icons.visibility_off : Icons.visibility,
                            size: 20,
                            color: AppTheme.getTextSecondary(context),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Checkbox(
                            value: acceptTerms,
                            activeColor: AppTheme.primaryColor,
                            onChanged: (value) => setState(() => acceptTerms = value ?? false),
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          const SizedBox(width: 4),
                          InteractiveLink(
                            text: 'Acepto los términos y condiciones de uso',
                            onTap: () => TermsAndConditionsDialog.show(context),
                          ),
                        ],
                      ),

                      const SizedBox(height: 32),

                      // --- BOTÓN CON ESTILO DEL CÓDIGO 2 ---
                      // Sin overrides de color 'disabled'. Se verá sutil/transparente.
                      Obx(() => ElevatedButton(
                            onPressed: authController.isLoading.value || !acceptTerms
                                ? null
                                : _handleRegister,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryColor,
                              foregroundColor: Colors.white,
                              // NOTA: Se eliminaron las líneas disabledBackgroundColor
                              // para usar el estilo nativo (sutil) del Código 2.
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
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
                                : const Text('Registrar Usuario',
                                    style: TextStyle(
                                        fontSize: 16, fontWeight: FontWeight.w600)),
                          )),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      floatingActionButton: FloatingActionButton(
        mini: true,
        onPressed: () => Get.back(),
        backgroundColor: Colors.grey[600],
        foregroundColor: Colors.white,
        tooltip: 'Volver',
        child: const Icon(Icons.arrow_back, size: 20),
      ),
    );
  }

  // --- LÓGICA DE REGISTRO (Validaciones Robustas del Código 1) ---
  Future<void> _handleRegister() async {
    // 1. Validaciones Anti-tontos locales (estrictas)
    if (nombreController.text.trim().length < 2) {
      _snackError('El nombre es muy corto');
      return;
    }
    if (apellidoController.text.trim().length < 2) {
      _snackError('El apellido es muy corto');
      return;
    }
    if (rutController.text.trim().length < 8) {
      _snackError('RUT inválido');
      return;
    }
    if (!GetUtils.isEmail(emailController.text.trim())) {
      _snackError('Correo electrónico inválido');
      return;
    }
    if (passwordController.text.length < 6) {
      _snackError('La contraseña debe tener al menos 6 caracteres');
      return;
    }
    if (passwordController.text != confirmPasswordController.text) {
      _snackError('Las contraseñas no coinciden');
      return;
    }

    // 2. Validación cruzada del Helper
    String? error = AuthHelper.validateRegisterFields(
      nombre: nombreController.text.trim(),
      apellido: apellidoController.text.trim(),
      rut: rutController.text.trim(),
      email: emailController.text.trim(),
      telefono: telefonoController.text.trim(),
      password: passwordController.text,
      confirmPassword: confirmPasswordController.text,
    );

    if (error != null) {
      _snackError(error);
      return;
    }

    // 3. Envío al controlador
    String rolValue = selectedRol == 'Odontólogo' ? 'odontologo' : 'administrativo';

    String? codigoUnico = await authController.register(
      email: emailController.text.trim(),
      password: passwordController.text,
      nombre: nombreController.text.trim(),
      apellido: apellidoController.text.trim(),
      telefono: telefonoController.text.trim(),
      rut: rutController.text.trim(),
      rol: rolValue,
    );

    if (codigoUnico != null) {
      _clearFields();

      if (mounted) {
        CodigoUnicoDialog.show(
          context,
          codigoUnico,
          onClose: () {
            Get.back(); // Volver al dashboard al terminar
          },
        );
      }
    }
  }

  // Snackbar personalizado (Más bonito que el default de Get)
  void _snackError(String msg) {
    Get.snackbar(
      'Atención',
      msg,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.orange.withValues(alpha: 0.9),
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
      duration: const Duration(seconds: 3),
    );
  }

  void _clearFields() {
    nombreController.clear();
    apellidoController.clear();
    rutController.clear();
    emailController.clear();
    telefonoController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
    setState(() {
      selectedRol = 'Odontólogo';
      isPasswordVisible = false;
      isConfirmPasswordVisible = false;
      acceptTerms = false;
    });
  }
}