import 'dart:async';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'debug_logger.dart';

class FirebaseDesktopWrapper {
  static bool get isDesktop => Platform.isWindows || Platform.isLinux || Platform.isMacOS;

  /// Wrapper para Firebase Auth con manejo de warnings
  static FirebaseAuth get auth {
    try {
      return FirebaseAuth.instance;
    } catch (e) {
      if (isDesktop && kDebugMode) {
        DebugLogger.log('Warning Firebase Auth en desktop: $e');
        return FirebaseAuth.instance;
      }
      rethrow;
    }
  }

  static FirebaseFirestore get firestore {
    try {
      return FirebaseFirestore.instance;
    } catch (e) {
      if (isDesktop && kDebugMode) {
        DebugLogger.log('Warning Firestore en desktop: $e');
        return FirebaseFirestore.instance;
      }
      rethrow;
    }
  }

  static Stream<User?> get authStateChanges {
    if (isDesktop) {
      return auth.authStateChanges().handleError((error) {
        if (kDebugMode) {
          DebugLogger.log('Error en authStateChanges (desktop): $error');
        }
        return null;
      });
    }
    return auth.authStateChanges();
  }

  static Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final result = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (isDesktop) {
        DebugLogger.log('Login exitoso en desktop para: $email');
      }
      
      return result;
    } catch (e) {
      if (isDesktop && kDebugMode) {
        DebugLogger.log('Error de login en desktop: $e', error: e);
      }
      rethrow;
    }
  }

  static Future<UserCredential> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final result = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (isDesktop) {
        DebugLogger.log('Registro exitoso en desktop para: $email');
      }
      
      return result;
    } catch (e) {
      if (isDesktop && kDebugMode) {
        DebugLogger.log('Error de registro en desktop: $e', error: e);
      }
      rethrow;
    }
  }

  static Future<void> signOut() async {
    try {
      await auth.signOut();
      
      if (isDesktop) {
        DebugLogger.log('Logout exitoso en desktop');
      }
    } catch (e) {
      if (isDesktop && kDebugMode) {
        DebugLogger.log('Error de logout en desktop: $e', error: e);
      }
      rethrow;
    }
  }

  static DocumentReference doc(String path) {
    try {
      return firestore.doc(path);
    } catch (e) {
      if (isDesktop && kDebugMode) {
        DebugLogger.log('Warning Firestore doc en desktop: $e');
      }
      rethrow;
    }
  }

  static CollectionReference collection(String path) {
    try {
      return firestore.collection(path);
    } catch (e) {
      if (isDesktop && kDebugMode) {
        DebugLogger.log('Warning Firestore collection en desktop: $e');
      }
      rethrow;
    }
  }

  static Future<void> configureForDesktop() async {
    if (!isDesktop) return;

    try {

      if (kDebugMode) {
        DebugLogger.log('Configurando Firebase para plataforma desktop');
        
        await firestore.enableNetwork();
        
        DebugLogger.log('Firebase configurado para desktop');
      }
    } catch (e) {
      if (kDebugMode) {
        DebugLogger.log('Error configurando Firebase para desktop: $e');
      }
    }
  }

  static Map<String, dynamic> getPlatformInfo() {
    return {
      'platform': Platform.operatingSystem,
      'isDesktop': isDesktop,
      'isDebugMode': kDebugMode,
      'version': Platform.version,
    };
  }
}