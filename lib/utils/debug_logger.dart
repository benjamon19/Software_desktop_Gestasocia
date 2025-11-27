import 'dart:developer' as developer;
import 'dart:io';
import 'package:flutter/foundation.dart';

class DebugLogger {
  static bool _suppressFirebaseWarnings = true;

  static void setSuppressFirebaseWarnings(bool suppress) {
    _suppressFirebaseWarnings = suppress;
  }

  static void log(String message, {
    String? name,
    Object? error,
    StackTrace? stackTrace,
    int level = 0,
  }) {
    if (_suppressFirebaseWarnings && 
        kDebugMode && 
        (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
      
      const firebaseWarningPatterns = [
        'firebase_auth_plugin/auth-state',
        'firebase_auth_plugin/id-token',
        'plugins.flutter.io/firebase_firestore',
        'non-platform thread',
        'Platform channel messages must be sent on the platform thread',
      ];

      bool isFirebaseWarning = firebaseWarningPatterns.any(
        (pattern) => message.toLowerCase().contains(pattern.toLowerCase())
      );

      if (isFirebaseWarning) {
        if (kDebugMode) {
          developer.log(
            '[SUPPRESSED FIREBASE WARNING] $message',
            name: name ?? 'FirebaseDesktop',
            level: 100, // Nivel muy bajo
          );
        }
        return;
      }
    }

    developer.log(
      message,
      name: name ?? 'App',
      error: error,
      stackTrace: stackTrace,
      level: level,
    );
  }
}

extension LogExtension on String {
  void logInfo() => DebugLogger.log(this, level: 800);
  void logWarning() => DebugLogger.log(this, level: 900);
  void logError() => DebugLogger.log(this, level: 1000);
}