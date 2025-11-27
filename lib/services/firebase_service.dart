import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../models/usuario.dart';

class FirebaseService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ========== AUTHENTICATION ==========
  
  /// Stream para escuchar cambios de autenticación
  static Stream<User?> get authStateChanges => _auth.authStateChanges();
  
  /// Usuario actual de Firebase Auth
  static User? get currentUser => _auth.currentUser;
  
  /// UID del usuario actual
  static String? get currentUserId => _auth.currentUser?.uid;
  
  /// Crear cuenta con email y password
  static Future<UserCredential> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      Get.log('=== INICIANDO REGISTRO ===');
      Get.log('Email: $email');
      Get.log('Password length: ${password.length}');
      
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      Get.log('=== REGISTRO AUTH EXITOSO ===');
      Get.log('UID: ${result.user?.uid}');
      
      return result;
    } catch (e) {
      Get.log('=== ERROR EN REGISTRO AUTH ===');
      Get.log('Error: $e');
      throw _handleAuthException(e);
    }
  }
  
  /// Iniciar sesión con email y password
  static Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      Get.log('=== INICIANDO LOGIN ===');
      Get.log('Email: $email');
      
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      Get.log('=== LOGIN EXITOSO ===');
      Get.log('UID: ${result.user?.uid}');
      
      return result;
    } catch (e) {
      Get.log('=== ERROR EN LOGIN ===');
      Get.log('Error: $e');
      throw _handleAuthException(e);
    }
  }
  
  /// Cerrar sesión
  static Future<void> signOut() async {
    try {
      await _auth.signOut();
      Get.log('=== LOGOUT EXITOSO ===');
    } catch (e) {
      Get.log('=== ERROR EN LOGOUT ===');
      Get.log('Error: $e');
      throw Exception('Error cerrando sesión: ${e.toString()}');
    }
  }

  // ========== FIRESTORE - USUARIOS ==========
  
  /// Guardar datos del usuario en Firestore
  static Future<void> saveUser(String uid, Usuario usuario) async {
    try {
      Get.log('=== GUARDANDO USUARIO EN FIRESTORE ===');
      Get.log('UID: $uid');
      Get.log('Datos: ${usuario.toMap()}');
      
      await _firestore
          .collection('usuarios')
          .doc(uid)
          .set(usuario.toMap());
          
      Get.log('=== USUARIO GUARDADO EXITOSAMENTE ===');
    } catch (e) {
      Get.log('=== ERROR GUARDANDO USUARIO ===');
      Get.log('Error: $e');
      throw Exception('Error guardando usuario: ${e.toString()}');
    }
  }
  
  /// Obtener datos del usuario desde Firestore
  static Future<Usuario?> getUser(String uid) async {
    try {
      Get.log('=== OBTENIENDO USUARIO DE FIRESTORE ===');
      Get.log('UID: $uid');
      
      DocumentSnapshot doc = await _firestore
          .collection('usuarios')
          .doc(uid)
          .get();
          
      if (doc.exists) {
        Get.log('=== USUARIO ENCONTRADO ===');
        Usuario usuario = Usuario.fromMap(doc.data() as Map<String, dynamic>, doc.id);
        Get.log('Usuario: ${usuario.nombreCompleto}');
        return usuario;
      } else {
        Get.log('=== USUARIO NO ENCONTRADO ===');
        return null;
      }
    } catch (e) {
      Get.log('=== ERROR OBTENIENDO USUARIO ===');
      Get.log('Error: $e');
      throw Exception('Error obteniendo usuario: ${e.toString()}');
    }
  }
  
  /// Actualizar datos del usuario
  static Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    try {
      Get.log('=== ACTUALIZANDO USUARIO ===');
      Get.log('UID: $uid');
      Get.log('Datos: $data');
      
      await _firestore
          .collection('usuarios')
          .doc(uid)
          .update(data);
          
      Get.log('=== USUARIO ACTUALIZADO ===');
    } catch (e) {
      Get.log('=== ERROR ACTUALIZANDO USUARIO ===');
      Get.log('Error: $e');
      throw Exception('Error actualizando usuario: ${e.toString()}');
    }
  }
  
  /// Eliminar usuario
  static Future<void> deactivateUser(String uid) async {
    try {
      await _firestore
          .collection('usuarios')
          .doc(uid)
          .update({'isActive': false});
    } catch (e) {
      throw Exception('Error desactivando usuario: ${e.toString()}');
    }
  }

  // ========== FIRESTORE ==========
  
  /// Crear documento en cualquier colección
  static Future<DocumentReference> createDocument({
    required String collection,
    required Map<String, dynamic> data,
  }) async {
    try {
      return await _firestore.collection(collection).add(data);
    } catch (e) {
      throw Exception('Error creando documento: ${e.toString()}');
    }
  }
  
  /// Obtener documento por ID
  static Future<DocumentSnapshot> getDocument({
    required String collection,
    required String docId,
  }) async {
    try {
      return await _firestore.collection(collection).doc(docId).get();
    } catch (e) {
      throw Exception('Error obteniendo documento: ${e.toString()}');
    }
  }
  
  /// Obtener colección completa
  static Future<QuerySnapshot> getCollection(String collection) async {
    try {
      return await _firestore.collection(collection).get();
    } catch (e) {
      throw Exception('Error obteniendo colección: ${e.toString()}');
    }
  }
  
  /// Stream para escuchar cambios en una colección
  static Stream<QuerySnapshot> streamCollection(String collection) {
    return _firestore.collection(collection).snapshots();
  }
  
  /// Convertir errores de Firebase a mensajes amigables
  static Exception _handleAuthException(dynamic e) {
    Get.log('=== ERROR FIREBASE DETALLADO ===');
    Get.log('Tipo: ${e.runtimeType}');
    
    String message = 'Error inesperado';
    
    if (e is FirebaseAuthException) {
      Get.log('Código: ${e.code}');
      Get.log('Mensaje: ${e.message}');
      
      switch (e.code) {
        case 'user-not-found':
          message = 'Usuario no encontrado';
          break;
        case 'wrong-password':
          message = 'Contraseña incorrecta';
          break;
        case 'email-already-in-use':
          message = 'El email ya está registrado';
          break;
        case 'weak-password':
          message = 'La contraseña es muy débil (mínimo 6 caracteres)';
          break;
        case 'invalid-email':
          message = 'Email inválido';
          break;
        case 'user-disabled':
          message = 'Usuario deshabilitado';
          break;
        case 'too-many-requests':
          message = 'Demasiados intentos. Intenta más tarde';
          break;
        case 'operation-not-allowed':
          message = 'Operación no permitida. Verifica la configuración de Firebase';
          break;
        case 'invalid-credential':
          message = 'Credenciales inválidas';
          break;
        case 'network-request-failed':
          message = 'Error de conexión. Verifica tu internet';
          break;
        default:
          message = 'Error de autenticación: ${e.message ?? e.code}';
      }
    } else if (e is FirebaseException) {
      Get.log('Código Firebase: ${e.code}');
      Get.log('Mensaje Firebase: ${e.message}');
      message = 'Error de Firebase: ${e.message ?? e.code}';
    } else {
      Get.log('Error genérico: ${e.toString()}');
      message = 'Error inesperado: ${e.toString()}';
    }
    
    Get.log('Mensaje final: $message');
    Get.log('===============================');
    
    // Retornar Exception en lugar de String
    return Exception(message);
  }
}