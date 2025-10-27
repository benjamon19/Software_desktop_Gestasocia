import 'dart:io';
import 'dart:async';
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

  // Getter para obtener Auth de la app principal
  FirebaseAuth get _mainAuth => FirebaseAuth.instanceFor(
    app: Firebase.app(),
  );

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
          final user = _mainAuth.currentUser;
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
        final currentFirebaseUser = _mainAuth.currentUser;
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

  // Storage de la app secundaria
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
      _showSuccessSnackbar("Éxito", "Usuario registrado correctamente");
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
      final user = _mainAuth.currentUser;
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

      _showSuccessSnackbar("Éxito", "Sesión iniciada correctamente");
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
      Get.log('=== INICIANDO LOGOUT ===');
      isLoading.value = true;

      // Limpiar sesión persistente
      await _clearPersistentSession();
      
      // Cerrar sesión en Firebase
      await FirebaseService.signOut();
      
      // Limpiar estado local
      firebaseUser.value = null;
      currentUser.value = null;
      
      Get.log('=== LOGOUT COMPLETADO - NAVEGANDO A LOGIN ===');
      Get.offAllNamed('/login');
      
    } catch (e) {
      Get.log('Error en logout: $e');
      _showErrorSnackbar("Error", "No se pudo cerrar sesión correctamente");
    } finally {
      isLoading.value = false;
    }
  }

  // Subir foto de perfil
  Future<bool> uploadProfilePhoto({bool fromCamera = false}) async {
    try {
      isUploadingPhoto.value = true;
      File? imageFile;

      if (fromCamera) {
        // Tomar foto con la cámara
        final picker = ImagePicker();
        final XFile? photo = await picker.pickImage(
          source: ImageSource.camera,
          maxWidth: 1024,
          maxHeight: 1024,
          imageQuality: 85,
        );
        
        if (photo == null) {
          Get.log('Usuario canceló la captura de foto');
          return false;
        }
        
        imageFile = File(photo.path);
        Get.log('Foto capturada: ${photo.path}');
        
      } else {
        // Seleccionar desde archivos
        FilePickerResult? result = await FilePicker.platform.pickFiles(
          type: FileType.image,
          allowMultiple: false,
        );

        if (result == null || result.files.isEmpty) {
          Get.log('Usuario canceló la selección');
          return false;
        }

        final filePath = result.files.first.path;
        if (filePath == null) {
          _showErrorSnackbar("Error", "No se pudo acceder al archivo");
          return false;
        }

        imageFile = File(filePath);
        Get.log('Archivo seleccionado: $filePath');
      }

      // Validar tamaño (máximo 5MB)
      final fileSize = await imageFile.length();
      if (fileSize > 5 * 1024 * 1024) {
        _showErrorSnackbar("Error", "La imagen no debe superar 5MB");
        return false;
      }

      final userId = currentUserId;
      if (userId == null) {
        _showErrorSnackbar("Error", "Usuario no autenticado");
        return false;
      }

      Get.log('=== SUBIENDO FOTO A STORAGE EXTERNO ===');
      
      // Usar el storage externo (app secundaria)
      final storageRef = _externalStorage.ref().child('usuarios/$userId/profile.jpg');
      
      Get.log('Referencia de Storage: ${storageRef.fullPath}');
      Get.log('Bucket: ${storageRef.bucket}');

      final uploadTask = storageRef.putFile(imageFile);

      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        final progress = (snapshot.bytesTransferred / snapshot.totalBytes) * 100;
        Get.log('Progreso de subida: ${progress.toStringAsFixed(2)}%');
      });

      final snapshot = await uploadTask;
      Get.log('Estado de subida: ${snapshot.state}');

      if (snapshot.state == TaskState.success) {
        final downloadUrl = await storageRef.getDownloadURL();
        Get.log('URL de descarga obtenida: $downloadUrl');

        // Actualizar Firestore
        await FirebaseService.updateUser(userId, {'photoUrl': downloadUrl});
        Get.log('Firestore actualizado');

        // Actualizar localmente
        currentUser.value = currentUser.value?.copyWith(photoUrl: downloadUrl);
        currentUser.refresh();

        _showSuccessSnackbar("Éxito", "Foto de perfil actualizada");
        return true;
      } else {
        Get.log('Estado de subida no exitoso: ${snapshot.state}');
        _showErrorSnackbar("Error", "No se pudo completar la subida");
        return false;
      }

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

  // Actualizar teléfono del usuario
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

      _showSuccessSnackbar("Éxito", "Teléfono actualizado correctamente");
      return true;

    } catch (e) {
      Get.log('Error actualizando teléfono: $e');
      _showErrorSnackbar("Error", "No se pudo actualizar el teléfono");
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Cambiar contraseña del usuario
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    Get.log('[1/10] INICIO changePassword');
    
    // Validaciones
    if (currentPassword.isEmpty || newPassword.isEmpty || confirmPassword.isEmpty) {
      Get.log('[2/10] ERROR: Campos vacíos');
      _showErrorSnackbar("Error", "Completa todos los campos");
      return false;
    }
    
    if (newPassword != confirmPassword) {
      Get.log('[2/10] ERROR: Contraseñas no coinciden');
      _showErrorSnackbar("Error", "Las contraseñas no coinciden");
      return false;
    }
    
    if (newPassword.length < 6) {
      Get.log('[2/10] ERROR: Contraseña muy corta');
      _showErrorSnackbar("Error", "La contraseña debe tener al menos 6 caracteres");
      return false;
    }
    
    if (newPassword == currentPassword) {
      Get.log('[2/10] ERROR: Contraseña igual');
      _showErrorSnackbar("Error", "La nueva contraseña debe ser diferente");
      return false;
    }

    Get.log('[2/10] Validaciones pasadas');
    Get.log('[3/10] Obteniendo usuario actual');
    
    // Usar _mainAuth en lugar de .instance
    final user = _mainAuth.currentUser;
    
    if (user == null) {
      Get.log('[4/10] ERROR: No hay usuario');
      _showErrorSnackbar("Error", "Usuario no autenticado");
      return false;
    }

    if (user.email == null) {
      Get.log('[4/10] ERROR: Usuario sin email');
      _showErrorSnackbar("Error", "Usuario no tiene email");
      return false;
    }

    Get.log('[4/10] Usuario encontrado: ${user.email}');
    Get.log('[5/10] Creando credencial para re-autenticación');

    try {
      // Crear credencial
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      
      Get.log('[5/10] Credencial creada');
      Get.log('[6/10] Iniciando re-autenticación con timeout de 15 segundos');
      
      // Agregar timeout de 15 segundos
      await user.reauthenticateWithCredential(credential).timeout(
        Duration(seconds: 15),
        onTimeout: () {
          Get.log('[6/10] TIMEOUT: La re-autenticación tardó más de 15 segundos');
          throw TimeoutException('La operación tardó demasiado tiempo');
        },
      );
      
      Get.log('[6/10] Re-autenticación exitosa');
      Get.log('[7/10] Actualizando contraseña con timeout de 15 segundos');
      
      // Agregar timeout también aquí
      await user.updatePassword(newPassword).timeout(
        Duration(seconds: 15),
        onTimeout: () {
          Get.log('[7/10] TIMEOUT: La actualización tardó más de 15 segundos');
          throw TimeoutException('La operación tardó demasiado tiempo');
        },
      );
      
      Get.log('[7/10] Contraseña actualizada en Firebase');
      Get.log('[8/10] Actualizando SharedPreferences');
      
      // Actualizar SharedPreferences si existe sesión guardada
      try {
        final prefs = await SharedPreferences.getInstance();
        final savedEmail = prefs.getString('user_email');
        if (savedEmail != null) {
          await prefs.setString('user_password', newPassword);
          Get.log('[8/10] SharedPreferences actualizado');
        } else {
          Get.log('[8/10] No hay sesión guardada en SharedPreferences');
        }
      } catch (e) {
        Get.log('[8/10] Error actualizando SharedPreferences (no crítico): $e');
      }
      
      Get.log('[9/10] Proceso completado exitosamente');
      _showSuccessSnackbar("Éxito", "Contraseña actualizada correctamente");
      Get.log('[10/10] FIN - Retornando true');
      
      return true;

    } on TimeoutException catch (e) {
      Get.log('[ERROR] TimeoutException: $e');
      _showErrorSnackbar(
        "Error de Timeout", 
        "La operación tardó demasiado. Verifica tu conexión a internet."
      );
      Get.log('[10/10] FIN - Retornando false (Timeout)');
      return false;
      
    } on FirebaseAuthException catch (e) {
      Get.log('[ERROR] FirebaseAuthException capturada');
      Get.log('Código: ${e.code}');
      Get.log('Mensaje: ${e.message}');
      
      String errorMessage;
      switch (e.code) {
        case 'wrong-password':
        case 'invalid-credential':
          errorMessage = "La contraseña actual es incorrecta";
          break;
        case 'requires-recent-login':
          errorMessage = "Por seguridad, debes iniciar sesión nuevamente";
          break;
        case 'weak-password':
          errorMessage = "La nueva contraseña es demasiado débil";
          break;
        case 'too-many-requests':
          errorMessage = "Demasiados intentos. Intenta más tarde";
          break;
        case 'network-request-failed':
          errorMessage = "Error de red. Verifica tu conexión a internet";
          break;
        default:
          errorMessage = "Error: ${e.message ?? 'Desconocido'}";
      }
      
      _showErrorSnackbar("Error", errorMessage);
      Get.log('[10/10] FIN - Retornando false (FirebaseAuth)');
      return false;
      
    } catch (e, stackTrace) {
      Get.log('[ERROR] Excepción inesperada: $e');
      Get.log('StackTrace: $stackTrace');
      _showErrorSnackbar("Error", "No se pudo cambiar la contraseña");
      Get.log('[10/10] FIN - Retornando false (General)');
      return false;
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

  // Extraer mensaje de error limpio
  String _extractErrorMessage(dynamic error) {
    if (error is Exception) {
      return error.toString().replaceFirst('Exception: ', '');
    }
    return error.toString();
  }

  // Mostrar snackbar de error
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

  // Mostrar snackbar de éxito
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