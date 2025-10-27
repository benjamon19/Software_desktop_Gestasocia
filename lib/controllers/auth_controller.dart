import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import '../models/usuario.dart';
import '../services/firebase_service.dart';
import 'package:firebase_core/firebase_core.dart';

class AuthController extends GetxController {
  // Variables observables
  Rxn<User> firebaseUser = Rxn<User>();
  Rxn<Usuario> currentUser = Rxn<Usuario>();
  RxBool isLoading = false.obs;
  RxBool isUploadingPhoto = false.obs;

  @override
  void onInit() {
    super.onInit();
    Get.log('=== INICIALIZANDO AUTH CONTROLLER ===');
    
    // NO escuchar cambios automáticos de Firebase Auth
    // Solo verificar sesión persistente al inicio
    _checkPersistentSession();
  }

  // Verificar si hay una sesión guardada
  Future<void> _checkPersistentSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedEmail = prefs.getString('user_email');
      final savedPassword = prefs.getString('user_password');
      
      if (savedEmail != null && savedPassword != null) {
        Get.log('=== SESIÓN PERSISTENTE ENCONTRADA - AUTO LOGIN ===');
        isLoading.value = true;
        
        try {
          // Auto-login con credenciales guardadas
          await FirebaseService.signInWithEmailAndPassword(
            email: savedEmail,
            password: savedPassword,
          );
          
          // Cargar datos del usuario
          final user = FirebaseAuth.instance.currentUser;
          if (user != null) {
            await _loadUserData(user.uid);
            
            if (currentUser.value != null) {
              firebaseUser.value = user;
              Get.log('=== NAVEGANDO A DASHBOARD (AUTO LOGIN) ===');
              Get.offAllNamed('/dashboard');
            }
          }
        } catch (e) {
          Get.log('Error en auto-login: $e');
          // Limpiar credenciales corruptas
          await _clearPersistentSession();
        } finally {
          isLoading.value = false;
        }
      } else {
        Get.log('=== NO HAY SESIÓN PERSISTENTE - VERIFICAR USUARIO ACTUAL ===');
        // Si no hay sesión persistente pero hay usuario en Firebase, cerrarlo
        final currentFirebaseUser = FirebaseAuth.instance.currentUser;
        if (currentFirebaseUser != null) {
          Get.log('=== CERRANDO SESIÓN DE FIREBASE (NO PERSISTENTE) ===');
          await FirebaseService.signOut();
        }
      }
    } catch (e) {
      Get.log('Error verificando sesión persistente: $e');
      // Limpiar datos corruptos y cerrar cualquier sesión
      await _clearPersistentSession();
      await FirebaseService.signOut();
    }
  }

  FirebaseStorage get _externalStorage => FirebaseStorage.instanceFor(
      app: Firebase.app('storageApp'),
      bucket: 'gestasocia-bucket-4b6ea.firebasestorage.app',
    );

  // Cargar datos del usuario
  Future<void> _loadUserData(String uid) async {
    try {
      Get.log('=== CARGANDO DATOS DEL USUARIO ===');
      Usuario? usuario = await FirebaseService.getUser(uid);
      currentUser.value = usuario;
      Get.log('=== DATOS CARGADOS: ${usuario?.nombreCompleto} ===');
    } catch (e) {
      Get.log('=== ERROR CARGANDO DATOS ===');
      Get.log('Error: $e');
      _showErrorSnackbar("Error", "No se pudieron cargar los datos del usuario");
    }
  }

  // Registro de usuario - CON SOPORTE PARA RUT COMO LOGIN
  Future<bool> register({
    required String email,
    required String password,
    required String nombre,
    required String apellido,
    required String telefono,
    required String rut,
  }) async {
    try {
      Get.log('=== INICIANDO PROCESO DE REGISTRO ===');
      isLoading.value = true;

      // Validar RUT
      if (!Usuario.validarRUT(rut)) {
        _showErrorSnackbar("Error", "RUT inválido. Formato: 12345678-9");
        return false;
      }

      // Paso 1: Crear usuario principal con email
      Get.log('=== PASO 1: CREANDO AUTH CON EMAIL ===');
      UserCredential result = await FirebaseService.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Paso 2: Crear objeto Usuario
      Get.log('=== PASO 2: CREANDO OBJETO USUARIO ===');
      Usuario nuevoUsuario = Usuario(
        nombre: nombre,
        apellido: apellido,
        email: email,
        telefono: telefono,
        rut: rut,
        fechaCreacion: DateTime.now(),
      );

      // Paso 3: Guardar en Firestore
      Get.log('=== PASO 3: GUARDANDO EN FIRESTORE ===');
      await FirebaseService.saveUser(result.user!.uid, nuevoUsuario);

      // Paso 4: Crear entrada adicional para login con RUT
      Get.log('=== PASO 4: CREANDO ENTRADA PARA LOGIN CON RUT ===');
      try {
        await FirebaseService.createUserWithEmailAndPassword(
          email: '$rut@rut.local',
          password: password,
        );
        Get.log('Usuario RUT creado: $rut@rut.local');
      } catch (e) {
        Get.log('No se pudo crear usuario RUT (puede que ya exista): $e');
        // No es crítico si falla
      }

      Get.log('=== REGISTRO COMPLETADO EXITOSAMENTE ===');
      _showSuccessSnackbar("¡Éxito!", "Usuario registrado correctamente");
      return true;

    } catch (e) {
      Get.log('=== ERROR EN REGISTRO COMPLETO ===');
      Get.log('Error: $e');
      
      String errorMessage = _extractErrorMessage(e);
      _showErrorSnackbar("Error de Registro", errorMessage);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Login de usuario - MODIFICADO PARA MANEJAR "RECORDARME"
  Future<bool> login(String input, String password, {bool rememberMe = false}) async {
    try {
      Get.log('LOGIN - Input: "$input", Remember: $rememberMe');
      isLoading.value = true;

      if (input.trim().isEmpty || password.isEmpty) {
        _showErrorSnackbar("Error", "Completa todos los campos");
        return false;
      }

      String emailParaLogin = input.trim();

      // Si NO tiene @ (es RUT), buscar el email en Firestore
      if (!input.contains('@')) {
        Get.log('Es RUT, buscando email en Firestore...');
        
        final usuarios = await FirebaseService.getCollection('usuarios');
        
        for (var doc in usuarios.docs) {
          final userData = doc.data() as Map<String, dynamic>;
          if (userData['rut'] == input) {
            emailParaLogin = userData['email'];
            Get.log('Email encontrado: $emailParaLogin');
            break;
          }
        }
        
        if (emailParaLogin == input) {
          _showErrorSnackbar("Error", "No se encontró cuenta con RUT: $input");
          return false;
        }
      }

      Get.log('Haciendo login con email: $emailParaLogin');

      await FirebaseService.signInWithEmailAndPassword(
        email: emailParaLogin,
        password: password,
      );

      // Cargar datos del usuario
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await _loadUserData(user.uid);
        firebaseUser.value = user;
        
        // SOLO guardar credenciales si marcó "Recordarme"
        if (rememberMe) {
          await _savePersistentSession(emailParaLogin, password);
          Get.log('=== SESIÓN GUARDADA PARA RECORDAR ===');
        } else {
          // Asegurar que no hay sesión persistente guardada
          await _clearPersistentSession();
          Get.log('=== SESIÓN TEMPORAL (NO RECORDAR) ===');
        }

        // Navegar al dashboard
        Get.offAllNamed('/dashboard');
      }

      _showSuccessSnackbar("¡Éxito!", "Sesión iniciada correctamente");
      return true;

    } catch (e) {
      Get.log('ERROR LOGIN: $e');
      String errorMessage = _extractErrorMessage(e);
      _showErrorSnackbar("Error de Login", errorMessage);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Cerrar sesión
  Future<void> logout() async {
    try {
      // SIEMPRE limpiar la sesión persistente al cerrar sesión
      await _clearPersistentSession();
      
      // Limpiar variables locales
      firebaseUser.value = null;
      currentUser.value = null;
      
      await FirebaseService.signOut();
      _showSuccessSnackbar("Sesión cerrada", "Has cerrado sesión correctamente");
      Get.offAllNamed('/login');
    } catch (e) {
      String errorMessage = _extractErrorMessage(e);
      _showErrorSnackbar("Error", "Error al cerrar sesión: $errorMessage");
    }
  }

  // ========== NUEVAS FUNCIONALIDADES ==========

  /// Subir foto de perfil - VERSIÓN MEJORADA
  Future<bool> uploadProfilePhoto({required bool fromCamera}) async {
    try {
      Get.log('=== INICIANDO SUBIDA DE FOTO ===');
      isUploadingPhoto.value = true;

      // Verificar que el usuario esté autenticado
      final userId = currentUserId;
      if (userId == null) {
        _showErrorSnackbar("Error", "Usuario no autenticado");
        return false;
      }

      // Obtener imagen
      File? imageFile;

      if (fromCamera) {
        // Tomar foto con la cámara
        final ImagePicker picker = ImagePicker();
        final XFile? photo = await picker.pickImage(
          source: ImageSource.camera,
          maxWidth: 1024,
          maxHeight: 1024,
          imageQuality: 85,
        );

        if (photo == null) {
          Get.log('Usuario canceló la toma de foto');
          return false;
        }

        imageFile = File(photo.path);
      } else {
        // Seleccionar archivo de imagen
        FilePickerResult? result = await FilePicker.platform.pickFiles(
          type: FileType.image,
          allowMultiple: false,
        );

        if (result == null || result.files.isEmpty) {
          Get.log('Usuario canceló la selección de archivo');
          return false;
        }

        final path = result.files.single.path;
        if (path == null) {
          _showErrorSnackbar("Error", "No se pudo obtener la ruta del archivo");
          return false;
        }

        imageFile = File(path);
      }

      // Validar que el archivo existe
      if (!await imageFile.exists()) {
        _showErrorSnackbar("Error", "El archivo no existe");
        return false;
      }

      // Validar tamaño del archivo (máximo 5MB)
      final fileSize = await imageFile.length();
      Get.log('Tamaño del archivo: ${fileSize / 1024 / 1024} MB');
      
      if (fileSize > 5 * 1024 * 1024) {
        _showErrorSnackbar("Error", "La imagen es muy grande. Máximo 5MB");
        return false;
      }

      if (fileSize == 0) {
        _showErrorSnackbar("Error", "El archivo está vacío");
        return false;
      }

      Get.log('Subiendo imagen para usuario: $userId');

      // Crear referencia a Firebase Storage con timestamp para evitar caché
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final storageRef = _externalStorage
          .ref()
          .child('profile_photos/$userId-$timestamp.jpg');

      Get.log('Ruta de storage: ${storageRef.fullPath}');

      // Configurar metadata
      final metadata = SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {
          'uploadedBy': userId,
          'uploadedAt': DateTime.now().toIso8601String(),
        },
      );

      // Subir archivo con manejo de errores mejorado
      try {
        Get.log('Iniciando upload...');
        final uploadTask = storageRef.putFile(imageFile, metadata);
        
        // Monitorear progreso
        uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
          final progress = (snapshot.bytesTransferred / snapshot.totalBytes) * 100;
          Get.log('Progreso: ${progress.toStringAsFixed(2)}%');
        });

        final snapshot = await uploadTask;
        Get.log('Upload completado, obteniendo URL...');

        // Obtener URL de descarga
        final downloadUrl = await snapshot.ref.getDownloadURL();
        Get.log('URL obtenida: $downloadUrl');

        // Actualizar en Firestore
        Get.log('Actualizando Firestore...');
        await FirebaseService.updateUser(userId, {'photoUrl': downloadUrl});

        // Actualizar localmente
        currentUser.value = currentUser.value?.copyWith(photoUrl: downloadUrl);
        currentUser.refresh();

        Get.log('=== FOTO SUBIDA EXITOSAMENTE ===');
        _showSuccessSnackbar("¡Éxito!", "Foto de perfil actualizada");
        return true;

      } on FirebaseException catch (e) {
        Get.log('Firebase Error: ${e.code} - ${e.message}');
        
        // Manejo de errores específicos de Firebase Storage
        switch (e.code) {
          case 'unauthorized':
            _showErrorSnackbar(
              "Permiso Denegado", 
              "No tienes permiso para subir fotos. Contacta al administrador."
            );
            break;
          case 'canceled':
            Get.log('Upload cancelado por el usuario');
            return false;
          case 'unknown':
            _showErrorSnackbar(
              "Error Desconocido", 
              "Error: ${e.message ?? 'Desconocido'}"
            );
            break;
          case 'object-not-found':
            _showErrorSnackbar("Error", "No se encontró el archivo");
            break;
          case 'bucket-not-found':
            _showErrorSnackbar("Error", "Configuración de Storage incorrecta");
            break;
          case 'quota-exceeded':
            _showErrorSnackbar("Error", "Se excedió la cuota de almacenamiento");
            break;
          default:
            _showErrorSnackbar(
              "Error de Storage", 
              "Código: ${e.code}\n${e.message ?? 'Error desconocido'}"
            );
        }
        return false;
      }

    } catch (e, stackTrace) {
      Get.log('Error subiendo foto: $e');
      Get.log('Stack trace: $stackTrace');
      _showErrorSnackbar(
        "Error", 
        "No se pudo subir la foto: ${e.toString()}"
      );
      return false;
    } finally {
      isUploadingPhoto.value = false;
    }
  }

  // [RESTO DE MÉTODOS - updatePhone, changePassword, etc.]

  /// Actualizar teléfono del usuario
  Future<bool> updatePhone(String newPhone) async {
    try {
      if (newPhone.trim().isEmpty) {
        _showErrorSnackbar("Error", "El teléfono no puede estar vacío");
        return false;
      }

      // Validar formato (puede ajustarse según necesidades)
      if (newPhone.length < 8) {
        _showErrorSnackbar("Error", "Formato de teléfono inválido");
        return false;
      }

      final userId = currentUserId;
      if (userId == null) {
        _showErrorSnackbar("Error", "Usuario no autenticado");
        return false;
      }

      isLoading.value = true;

      // Actualizar en Firestore
      await FirebaseService.updateUser(userId, {'telefono': newPhone});

      // Actualizar localmente
      currentUser.value = currentUser.value?.copyWith(telefono: newPhone);
      currentUser.refresh();

      _showSuccessSnackbar("¡Éxito!", "Teléfono actualizado correctamente");
      return true;

    } catch (e) {
      Get.log('Error actualizando teléfono: $e');
      _showErrorSnackbar("Error", "No se pudo actualizar el teléfono");
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Cambiar contraseña del usuario
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      // Validaciones
      if (currentPassword.isEmpty || newPassword.isEmpty || confirmPassword.isEmpty) {
        _showErrorSnackbar("Error", "Completa todos los campos");
        return false;
      }

      if (newPassword != confirmPassword) {
        _showErrorSnackbar("Error", "Las contraseñas no coinciden");
        return false;
      }

      if (newPassword.length < 6) {
        _showErrorSnackbar("Error", "La contraseña debe tener al menos 6 caracteres");
        return false;
      }

      if (newPassword == currentPassword) {
        _showErrorSnackbar("Error", "La nueva contraseña debe ser diferente");
        return false;
      }

      final user = FirebaseAuth.instance.currentUser;
      if (user == null || user.email == null) {
        _showErrorSnackbar("Error", "Usuario no autenticado");
        return false;
      }

      isLoading.value = true;

      // Re-autenticar usuario con contraseña actual
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );

      try {
        await user.reauthenticateWithCredential(credential);
      } catch (e) {
        _showErrorSnackbar("Error", "La contraseña actual es incorrecta");
        return false;
      }

      // Cambiar contraseña
      await user.updatePassword(newPassword);

      // Actualizar sesión persistente si existe
      final prefs = await SharedPreferences.getInstance();
      final savedEmail = prefs.getString('user_email');
      if (savedEmail != null) {
        await prefs.setString('user_password', newPassword);
      }

      _showSuccessSnackbar("¡Éxito!", "Contraseña actualizada correctamente");
      return true;

    } catch (e) {
      Get.log('Error cambiando contraseña: $e');
      _showErrorSnackbar("Error", "No se pudo cambiar la contraseña: ${e.toString()}");
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Guardar sesión persistente
  Future<void> _savePersistentSession(String email, String password) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_email', email);
      await prefs.setString('user_password', password);
    } catch (e) {
      Get.log('Error guardando sesión persistente: $e');
    }
  }

  // Limpiar sesión persistente
  Future<void> _clearPersistentSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user_email');
      await prefs.remove('user_password');
    } catch (e) {
      Get.log('Error limpiando sesión persistente: $e');
    }
  }

  // ========== HELPERS PARA MANEJO DE ERRORES ==========

  /// Extraer mensaje de error limpio
  String _extractErrorMessage(dynamic error) {
    if (error is Exception) {
      return error.toString().replaceFirst('Exception: ', '');
    }
    return error.toString();
  }

  /// Mostrar snackbar de error
  void _showErrorSnackbar(String title, String message) {
    Get.snackbar(
      title, 
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Get.theme.colorScheme.error.withValues(alpha: 0.8),
      colorText: Get.theme.colorScheme.onError,
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
      duration: const Duration(seconds: 4),
    );
  }

  /// Mostrar snackbar de éxito
  void _showSuccessSnackbar(String title, String message) {
    Get.snackbar(
      title, 
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Get.theme.colorScheme.primary.withValues(alpha: 0.8),
      colorText: Get.theme.colorScheme.onPrimary,
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
      duration: const Duration(seconds: 3),
    );
  }

  // Getters útiles
  bool get isSignedIn => firebaseUser.value != null;
  String? get currentUserId => FirebaseService.currentUserId;
  String get userDisplayName => currentUser.value?.nombreCompleto ?? 'Usuario';
  String get userEmail => currentUser.value?.email ?? '';
  String? get userPhotoUrl => currentUser.value?.photoUrl;
}