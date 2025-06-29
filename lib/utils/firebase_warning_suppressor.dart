// lib/utils/firebase_warning_suppressor.dart
import 'dart:io';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';

/// Clase específica para suprimir warnings de Firebase en desktop
class FirebaseWarningSuppressor {
  static bool _isEnabled = false;
  static final List<String> _suppressedPatterns = [
    'firebase_auth_plugin/auth-state',
    'firebase_auth_plugin/id-token',
    'plugins.flutter.io/firebase_firestore',
    'non-platform thread',
    'Platform channel messages must be sent on the platform thread',
    'shell.cc',
    'firebase_auth_plugin',
  ];

  /// Habilitar la supresión de warnings en desktop
  static void enable() {
    if (!_isDesktop || !kDebugMode) return;
    
    _isEnabled = true;
    
    if (kDebugMode) {
      debugPrint('Firebase Warning Suppressor habilitado para desktop');
      debugPrint('Patterns suprimidos: ${_suppressedPatterns.length} tipos');
    }
  }

  /// Deshabilitar la supresión
  static void disable() {
    _isEnabled = false;
    if (kDebugMode) {
      debugPrint('Firebase Warning Suppressor deshabilitado');
    }
  }

  /// Verificar si un mensaje debe ser suprimido
  static bool shouldSuppressMessage(String message) {
    if (!_isEnabled || !_isDesktop) return false;

    final messageLower = message.toLowerCase();
    return _suppressedPatterns.any(
      (pattern) => messageLower.contains(pattern.toLowerCase())
    );
  }

  /// Log personalizado que puede suprimir warnings específicos
  static void logIfNotSuppressed(String message, {
    String? name,
    Object? error,
    StackTrace? stackTrace,
    int level = 0,
  }) {
    if (shouldSuppressMessage(message)) {
      // Solo log en nivel muy bajo para debugging
      if (kDebugMode && kIsWeb == false) {
        developer.log(
          '[SUPPRESSED] $message',
          name: 'FirebaseDesktop',
          level: 50, // Nivel muy bajo
        );
      }
      return;
    }

    // Para mensajes no suprimidos, usar logging normal
    developer.log(
      message,
      name: name ?? 'App',
      error: error,
      stackTrace: stackTrace,
      level: level,
    );
  }

  /// Verificar si estamos en desktop
  static bool get _isDesktop => 
      Platform.isWindows || Platform.isLinux || Platform.isMacOS;

  /// Obtener estadísticas de supresión
  static Map<String, dynamic> getStats() {
    return {
      'enabled': _isEnabled,
      'platform': Platform.operatingSystem,
      'isDesktop': _isDesktop,
      'patternsCount': _suppressedPatterns.length,
      'patterns': _suppressedPatterns,
    };
  }

  /// Configurar supresión específica para Firebase Auth
  static void configureForFirebaseAuth() {
    if (!_isDesktop) return;

    enable();
    
    if (kDebugMode) {
      debugPrint('Configuración específica para Firebase Auth en desktop');
      debugPrint('Los siguientes warnings serán suprimidos:');
      debugPrint('  - firebase_auth_plugin/auth-state warnings');
      debugPrint('  - firebase_auth_plugin/id-token warnings');
      debugPrint('  - platform thread warnings');
    }
  }

  /// Mensaje informativo sobre los warnings
  static void showWarningInfo() {
    if (!_isDesktop || !kDebugMode) return;

    debugPrint('\n=== INFORMACIÓN SOBRE WARNINGS FIREBASE ===');
    debugPrint('Los warnings de "non-platform thread" que estás viendo son:');
    debugPrint('• NORMALES en aplicaciones Flutter desktop');
    debugPrint('• NO CRÍTICOS - la aplicación funciona correctamente');
    debugPrint('• ESPERADOS hasta que FlutterFire mejore el soporte desktop');
    debugPrint('• SUPRIMIDOS en esta configuración para reducir ruido');
    debugPrint('===============================================\n');
  }
}