import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'package:window_manager/window_manager.dart';
import 'firebase_config.dart';
import 'window_config.dart';
import '../controllers/auth_controller.dart';
import '../controllers/theme_controller.dart';

class AppInitializer {
  
  /// Inicializar toda la aplicación
  static Future<void> initialize() async {
    await _configureDesktop();
    await _configureWindow();
    await _initializeFirebase();
    _initializeControllers();
    await _postInitializationSetup();
  }

  /// Configurar entorno desktop 
  static Future<void> _configureDesktop() async {
    if (!_isDesktop) return;

    try {
      // Inicializar window_manager
      await windowManager.ensureInitialized();
      
      if (kDebugMode) {
        print('Aplicación desktop iniciada con configuración optimizada');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error configurando desktop: $e');
      }
    }
  }

  /// Configurar ventana de escritorio con barra OCULTA (para usar personalizada)
  static Future<void> _configureWindow() async {
    if (!_isDesktop) return;
    
    try {
      await WindowConfig.initialize();
      
      // Configurar con barra oculta para usar la personalizada
      WindowOptions windowOptions = const WindowOptions(
        titleBarStyle: TitleBarStyle.hidden, // ⭐ Ocultar la barra nativa
        skipTaskbar: false,
        backgroundColor: Colors.transparent,
      );
      
      await windowManager.waitUntilReadyToShow(windowOptions, () async {
        await windowManager.show();
        await windowManager.focus();
      });
      
      if (kDebugMode) {
        print('Configuración de ventana completada con barra personalizada');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error configurando ventana: $e');
      }
    }
  }
  
  /// Inicializar Firebase con manejo robusto de errores
  static Future<void> _initializeFirebase() async {
    try {
      //App principal (Auth, Firestore, etc.)
      await Firebase.initializeApp(
        options: FirebaseConfig.webOptions,
        name: '[DEFAULT]',
      );

      //App secundaria (solo Storage)
      await Firebase.initializeApp(
        options: FirebaseConfig.storageOptions,
        name: 'storageApp',
      );

      if (kDebugMode) {
        print('Firebase y StorageApp inicializados correctamente');
      }
    } catch (e) {
      await _handleFirebaseInitializationError(e);
    }
  }

  /// Manejar errores de inicialización de Firebase
  static Future<void> _handleFirebaseInitializationError(dynamic e) async {
    if (kDebugMode) {
      print('Error inicializando Firebase: $e');
    }
    
    if (_isDesktop) {
      if (kDebugMode) {
        print('Continuando en modo desktop con configuración alternativa...');
      }
      
      try {
        await Firebase.initializeApp(
          name: 'desktop-fallback',
          options: FirebaseConfig.webOptions,
        );
        if (kDebugMode) {
          print('Firebase inicializado con configuración alternativa');
        }
      } catch (fallbackError) {
        if (kDebugMode) {
          print('Error en configuración alternativa: $fallbackError');
        }
        if (!kDebugMode) {
          throw Exception('Error crítico inicializando Firebase: $fallbackError');
        }
      }
    } else {
      throw Exception('Error inicializando Firebase: $e');
    }
  }

  /// Inicializar controladores de GetX
  static void _initializeControllers() {
    try {
      Get.put(ThemeController(), permanent: true);
      Get.put(AuthController(), permanent: true);
      if (kDebugMode) {
        print('Controladores inicializados');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error inicializando controladores: $e');
      }
      throw Exception('Error inicializando controladores: $e');
    }
  }

  /// Configuración posterior a la inicialización
  static Future<void> _postInitializationSetup() async {
    if (_isDesktop) {
      try {
        // Configuración específica para desktop
        if (kDebugMode) {
          print('Configuración desktop completada');
        }
      } catch (e) {
        if (kDebugMode) {
          print('Warning configurando desktop: $e');
        }
      }
    }
  }
  
  static bool get _isDesktop {
    if (kIsWeb) return false;
    
    try {
      return !kIsWeb && (
        defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.linux ||
        defaultTargetPlatform == TargetPlatform.macOS
      );
    } catch (e) {
      return false;
    }
  }
}