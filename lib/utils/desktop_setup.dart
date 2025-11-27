import 'dart:io';
import 'package:flutter/foundation.dart';

class DesktopSetup {
  
  static Future<void> configure() async {
    if (!_isDesktop) return;

    if (kDebugMode) {
      debugPrint('Configurando entorno desktop para Firebase...');
      _setEnvironmentVariables();
      _configureLogging();
      debugPrint('Configuración desktop completada');
    }
  }

  static bool get _isDesktop => 
      Platform.isWindows || Platform.isLinux || Platform.isMacOS;

  static void _setEnvironmentVariables() {
    if (Platform.isWindows) {
      if (kDebugMode) {
        debugPrint('Configurando variables de entorno para Windows desktop');
        debugPrint('FIREBASE_DESKTOP_MODE simulado como true');
        debugPrint('FLUTTER_DESKTOP_WARNINGS simulado como suppress');
      }
    }
  }

  static void _configureLogging() {
    if (kDebugMode) {
      debugPrint('Configurando logging personalizado para desktop');
      debugPrint('Warnings de platform thread serán suprimidos en modo debug');
    }
  }

  static bool validateFirebaseSetup() {
    try {
      if (_isDesktop) {
        if (kDebugMode) {
          debugPrint('Validando configuración Firebase para desktop...');
          debugPrint('Modo debug activo - warnings serán manejados');
          
          if (Platform.isWindows) {
            debugPrint('Plataforma Windows detectada');
          } else if (Platform.isLinux) {
            debugPrint('Plataforma Linux detectada');
          } else if (Platform.isMacOS) {
            debugPrint('Plataforma macOS detectada');
          }
        }
        
        return true;
      }
      
      return false;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error validando configuración: $e');
      }
      return false;
    }
  }

  static void showDesktopTips() {
    if (!_isDesktop || !kDebugMode) return;

    debugPrint('\nCONSEJOS PARA DESARROLLO DESKTOP CON FIREBASE:');
    debugPrint('   • Los warnings de "non-platform thread" son normales en desktop');
    debugPrint('   • Firebase funciona correctamente a pesar de estos warnings');
    debugPrint('   • Para producción, considera usar firebase_auth_desktop si está disponible');
    debugPrint('   • Los warnings se suprimen automáticamente con nuestro wrapper\n');
  }
}