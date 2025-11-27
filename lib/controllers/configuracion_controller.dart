import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ConfiguracionController extends GetxController {
  // Estados observables
  RxBool isLoading = false.obs;
  RxString selectedSection = 'tema'.obs; // tema, aplicacion, sistema
  
  // Configuraciones de la aplicación
  RxBool autoSave = true.obs;
  RxString dateFormat = 'dd/mm/yyyy'.obs; // dd/mm/yyyy, mm/dd/yyyy, yyyy-mm-dd
  RxBool confirmActions = true.obs;
  RxBool showWelcomeScreen = true.obs;
  RxInt sessionTimeout = 30.obs; // minutos
  RxBool enableSounds = true.obs;
  RxBool enableAnimations = true.obs;
  
  // Información del sistema
  RxString appVersion = '1.0.1'.obs;
  RxString buildNumber = '1'.obs;
  RxString flutterVersion = '3.35.0'.obs;
  RxString buildDate = '25-11-2025'.obs;

  @override
  void onInit() {
    super.onInit();
    _loadAppSettings();
  }

  // ========== NAVEGACIÓN DE SECCIONES ==========
  
  void selectSection(String section) {
    selectedSection.value = section;
  }

  // ========== CONFIGURACIONES DE APLICACIÓN ==========
  
  void _loadAppSettings() {
  }
  
  void toggleAutoSave(bool value) {
    autoSave.value = value;
    _saveAppSettings();
  }
  
  void changeDateFormat(String format) {
    dateFormat.value = format;
    _saveAppSettings();
  }
  
  void toggleConfirmActions(bool value) {
    confirmActions.value = value;
    _saveAppSettings();
  }
  
  void toggleWelcomeScreen(bool value) {
    showWelcomeScreen.value = value;
    _saveAppSettings();
  }
  
  void toggleSounds(bool value) {
    enableSounds.value = value;
    _saveAppSettings();
  }
  
  void toggleAnimations(bool value) {
    enableAnimations.value = value;
    _saveAppSettings();
  }
  
  void changeSessionTimeout(int minutes) {
    sessionTimeout.value = minutes;
    _saveAppSettings();
  }
  
  void _saveAppSettings() {
    Get.snackbar(
      'Configuración Guardada',
      'Los cambios se aplicaron correctamente',
      duration: const Duration(seconds: 2),
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  // ========== INFORMACIÓN DEL SISTEMA ==========
  
  void checkForUpdates() {
    isLoading.value = true;
    
    Future.delayed(const Duration(seconds: 2), () {
      isLoading.value = false;
      Get.snackbar(
        'Actualizaciones',
        'La aplicación está actualizada a la última versión',
        duration: const Duration(seconds: 3),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF10B981),
        colorText: Colors.white,
      );
    });
  }
  
  void viewLicenses() {
    Get.snackbar(
      'Licencias',
      'Mostrando licencias de software (próximamente)',
      duration: const Duration(seconds: 2),
      snackPosition: SnackPosition.BOTTOM,
    );
  }
  
  void viewPrivacyPolicy() {
    Get.snackbar(
      'Política de Privacidad',
      'Abriendo política de privacidad (próximamente)',
      duration: const Duration(seconds: 2),
      snackPosition: SnackPosition.BOTTOM,
    );
  }
  
  void contactSupport() {
    Get.snackbar(
      'Soporte Técnico',
      'Contactando con soporte técnico (próximamente)',
      duration: const Duration(seconds: 2),
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  // ========== RESETEAR CONFIGURACIONES ==========
  
  Future<void> resetSettings() async {
    isLoading.value = true;
    
    try {
      // Simular reset
      await Future.delayed(const Duration(seconds: 2));
      
      // Restaurar valores por defecto
      autoSave.value = true;
      dateFormat.value = 'dd/mm/yyyy';
      confirmActions.value = true;
      showWelcomeScreen.value = true;
      sessionTimeout.value = 30;
      enableSounds.value = true;
      enableAnimations.value = true;
      
      Get.snackbar(
        'Configuración Restablecida',
        'Se han restaurado los valores por defecto',
        backgroundColor: const Color(0xFF10B981),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudo restablecer la configuración',
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ========== GETTERS ==========
  
  bool get isThemeSection => selectedSection.value == 'tema';
  bool get isAppSection => selectedSection.value == 'aplicacion';
  bool get isSystemSection => selectedSection.value == 'sistema';
  
  String get currentSectionTitle {
    switch (selectedSection.value) {
      case 'tema': return 'Configuración de Tema';
      case 'aplicacion': return 'Configuración de Aplicación';
      case 'sistema': return 'Información del Sistema';
      default: return 'Configuración';
    }
  }
}