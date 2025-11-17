import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../services/auth_helper.dart';
import '../../utils/app_theme.dart';
import '../../utils/terms_and_conditions_dialog.dart';
import '../../widgets/interactive_link.dart';
import '../../widgets/shared_widgets.dart';
import '../../widgets/theme_toggle_button.dart';
import '../dialog/codigo_unico_dialog.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
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
    return Scaffold(
      body: Stack(
        children: [
          Container(
            color: AppTheme.backgroundColor,
            child: Row(
              children: [
                LeftPanel(
                  title: 'GestAsocia',
                  subtitle: 'Sistema de Gestión de Asociados',
                  features: const [
                    FeatureItem(icon: Icons.person_add_outlined, text: 'Registro rápido y seguro'),
                    FeatureItem(icon: Icons.security, text: 'Protección de datos garantizada'),
                    FeatureItem(icon: Icons.verified_user, text: 'Verificación automática'),
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
                              Text('Crear Cuenta', style: AppTheme.getHeadingMedium(context)),
                              const SizedBox(height: 8),
                              Text('Completa los datos para registrarte', style: AppTheme.getBodyMedium(context)),
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
                                  labelText: 'Rol',
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
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
                                  onPressed: () => setState(() => isConfirmPasswordVisible = !isConfirmPasswordVisible),
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
                              Obx(() => ElevatedButton(
                                onPressed: authController.isLoading.value || !acceptTerms ? null : _handleRegister,
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
                                    : const Text('Registrarse', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
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
                                child: InteractiveLink(
                                  text: '¿Ya tienes una cuenta? Inicia Sesión',
                                  onTap: () => Get.back(),
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
    );
  }

  Future<void> _handleRegister() async {
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
      Get.snackbar('Error', error);
      return;
    }

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
      
      // Mostrar el diálogo y al cerrarlo, volver al login
      if (mounted) {
        CodigoUnicoDialog.show(
          context,
          codigoUnico,
          onClose: () {
            // Volver a la página de login
            Get.back();
          },
        );
      }
    }
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
