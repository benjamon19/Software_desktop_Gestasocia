import 'dart:io';
import 'dart:async';
import 'dart:math';
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
import '../controllers/asociados_controller.dart';
import '../controllers/cargas_familiares_controller.dart';
import '../controllers/historial_clinico_controller.dart';
import '../controllers/dashboard_page_controller.dart';

class AuthController extends GetxController {
  Rxn<User> firebaseUser = Rxn<User>();
  Rxn<Usuario> currentUser = Rxn<Usuario>();
  RxBool isLoading = false.obs;
  RxBool isUploadingPhoto = false.obs;

  FirebaseAuth get _mainAuth => FirebaseAuth.instanceFor(
        app: Firebase.app(),
      );

  @override
  void onInit() {
    super.onInit();
    Get.log('=== INICIANDO AUTH CONTROLLER ===');
    _checkPersistentSession();
  }

  Future<void> logout() async {
    try {
      isLoading.value = true;
      
      try {
        if (Get.isRegistered<AsociadosController>()) {
          Get.find<AsociadosController>().resetState();
        }
        if (Get.isRegistered<CargasFamiliaresController>()) {
          Get.find<CargasFamiliaresController>().resetState();
        }
        if (Get.isRegistered<HistorialClinicoController>()) {
          Get.find<HistorialClinicoController>().resetState();
        }
        if (Get.isRegistered<DashboardPageController>()) {
          Get.find<DashboardPageController>().changeModule(0); 
        }
      } catch (e) {
        // Ignorar errores de limpieza
      }

      await _clearPersistentSession();
      await FirebaseService.signOut();
      firebaseUser.value = null;
      currentUser.value = null;
      
      Get.offAllNamed('/login');
    } catch (e) {
      _showErrorSnackbar("Error", "No se pudo cerrar sesión correctamente");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _checkPersistentSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedEmail = prefs.getString('user_email');
      final savedPassword = prefs.getString('user_password');

      if (savedEmail != null && savedPassword != null) {
        Get.log('=== SESIÓN PERSISTENTE ENCONTRADA - AUTO LOGIN ===');
        isLoading.value = true;

        try {
          await FirebaseService.signInWithEmailAndPassword(
            email: savedEmail,
            password: savedPassword,
          );

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
          await _clearPersistentSession();
        } finally {
          isLoading.value = false;
        }
      } else {
        Get.log('=== NO HAY SESIÓN PERSISTENTE ===');
        final currentFirebaseUser = _mainAuth.currentUser;
        if (currentFirebaseUser != null) {
          Get.log('=== CERRANDO SESIÓN DE FIREBASE (NO PERSISTENTE) ===');
          await FirebaseService.signOut();
        }
      }
    } catch (e) {
      Get.log('Error verificando sesión persistente: $e');
      await _clearPersistentSession();
      await FirebaseService.signOut();
    }
  }

  FirebaseStorage get _externalStorage => FirebaseStorage.instanceFor(
        app: Firebase.app('storageApp'),
        bucket: 'gestasocia-bucket-4b6ea.firebasestorage.app',
      );

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

  Future<String?> register({
    required String email,
    required String password,
    required String nombre,
    required String apellido,
    required String telefono,
    required String rut,
    required String rol,
  }) async {
    try {
      Get.log('=== INICIANDO PROCESO DE REGISTRO ===');
      isLoading.value = true;

      if (!Usuario.validarRUT(rut)) {
        _showErrorSnackbar("Error", "RUT inválido. Formato: 12345678-9");
        return null;
      }

      if (rol != 'administrativo' && rol != 'odontologo') {
        _showErrorSnackbar("Error", "Rol no permitido. Solo 'administrativo' u 'odontologo'.");
        return null;
      }

      final String codigoUnico = _generarCodigoUnico();
      final DateTime ahora = DateTime.now();

      UserCredential result = await FirebaseService.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      Usuario nuevoUsuario = Usuario(
        nombre: nombre,
        apellido: apellido,
        email: email,
        telefono: telefono,
        rut: rut,
        rol: rol,
        codigoUnico: codigoUnico,
        fechaCreacion: ahora,
        fechaActualizacionCodigo: ahora,
      );

      await FirebaseService.saveUser(result.user!.uid, nuevoUsuario);

      try {
        await FirebaseService.createUserWithEmailAndPassword(
          email: '$rut@rut.local',
          password: password,
        );
        Get.log('Usuario RUT creado: $rut@rut.local');
      } catch (e) {
        Get.log('No se pudo crear usuario RUT (puede que ya exista): $e');
      }

      Get.log('=== REGISTRO COMPLETADO EXITOSAMENTE ===');
      _showSuccessSnackbar("Éxito", "Usuario registrado correctamente");
      return codigoUnico;

    } catch (e) {
      Get.log('=== ERROR EN REGISTRO COMPLETO ===');
      Get.log('Error: $e');
      String errorMessage = _extractErrorMessage(e);
      _showErrorSnackbar("Error de Registro", errorMessage);
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> login(String input, String password, {bool rememberMe = false}) async {
    try {
      Get.log('LOGIN - Input: "$input", Remember: $rememberMe');
      isLoading.value = true;

      if (input.trim().isEmpty || password.isEmpty) {
        _showErrorSnackbar("Error", "Completa todos los campos");
        return false;
      }

      String emailParaLogin = input.trim();

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

      await FirebaseService.signInWithEmailAndPassword(
        email: emailParaLogin,
        password: password,
      );

      final user = _mainAuth.currentUser;
      if (user != null) {
        await _loadUserData(user.uid);
        firebaseUser.value = user;

        if (rememberMe) {
          await _savePersistentSession(emailParaLogin, password);
          Get.log('=== SESIÓN GUARDADA PARA RECORDAR (ESCRITORIO) ===');
        } else {
          await _clearPersistentSession();
          Get.log('=== SESIÓN TEMPORAL (NO RECORDAR) ===');
        }

        return true;
      }

      return false;

    } catch (e) {
      Get.log('ERROR LOGIN: $e');
      String errorMessage = _extractErrorMessage(e);
      _showErrorSnackbar("Error de Login", errorMessage);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<String?> validateCodigoUnico(String uid, String codigoIngresado) async {
    try {
      Usuario? usuario = await FirebaseService.getUser(uid);
      if (usuario == null) {
        Get.log('ERROR: Usuario no encontrado');
        return null;
      }

      Get.log('=== VALIDANDO CÓDIGO ÚNICO ===');
      Get.log('Usuario: ${usuario.nombreCompleto}');
      Get.log('Código ingresado: $codigoIngresado');
      Get.log('Código almacenado: ${usuario.codigoUnico}');
      
      DateTime fechaReferencia = usuario.fechaActualizacionCodigo ?? usuario.fechaCreacion;
      Get.log('Fecha de última actualización del código: $fechaReferencia');
      
      // Calcular la fecha límite (60 días desde la última actualización)
      DateTime limite = fechaReferencia.add(const Duration(days: 60));
      DateTime ahora = DateTime.now();
      
      Get.log('Fecha actual: $ahora');
      Get.log('Fecha límite (60 días): $limite');
      Get.log('Días transcurridos: ${ahora.difference(fechaReferencia).inDays}');

      // Verificar si el código ha expirado (más de 60 días)
      if (ahora.isAfter(limite)) {
        Get.log('CÓDIGO EXPIRADO - Generando nuevo código');
        String nuevoCodigo = _generarCodigoUnico();
        
        // Actualizar tanto el código como la fecha de actualización
        await FirebaseService.updateUser(uid, {
          'codigoUnico': nuevoCodigo,
          'fechaActualizacionCodigo': ahora,
        });
        
        Get.log('Nuevo código generado: $nuevoCodigo');
        Get.log('Fecha de actualización guardada: $ahora');
        
        await _loadUserData(uid);
        return nuevoCodigo;
      }

      // Verificar si el código ingresado es correcto
      if (usuario.codigoUnico == codigoIngresado) {
        Get.log('CÓDIGO CORRECTO');
        return ''; // Código válido
      }
      
      Get.log('CÓDIGO INCORRECTO');
      return null;

    } catch (e) {
      Get.log('ERROR validando código único: $e');
      return null;
    }
  }

  String _generarCodigoUnico() {
    return (1000 + Random().nextInt(9000)).toString();
  }

  Future<bool> uploadProfilePhoto({bool fromCamera = false}) async {
    try {
      isUploadingPhoto.value = true;
      File? imageFile;

      if (fromCamera) {
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
        await FirebaseService.updateUser(userId, {'photoUrl': downloadUrl});
        Get.log('Firestore actualizado');
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
      switch (e.code) {
        case 'unauthorized':
          _showErrorSnackbar("Permiso Denegado", "No tienes permiso para subir fotos. Contacta al administrador.");
          break;
        case 'canceled':
          Get.log('Upload cancelado por el usuario');
          return false;
        case 'unknown':
          _showErrorSnackbar("Error Desconocido", "Error: ${e.message ?? 'Desconocido'}");
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
          _showErrorSnackbar("Error de Storage", "Código: ${e.code}\n${e.message ?? 'Error desconocido'}");
      }
      return false;
    } catch (e, stackTrace) {
      Get.log('Error subiendo foto: $e');
      Get.log('Stack trace: $stackTrace');
      _showErrorSnackbar("Error", "No se pudo subir la foto: ${e.toString()}");
      return false;
    } finally {
      isUploadingPhoto.value = false;
    }
  }

  Future<bool> updatePhone(String newPhone) async {
    try {
      if (newPhone.trim().isEmpty) {
        _showErrorSnackbar("Error", "El teléfono no puede estar vacío");
        return false;
      }
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
      await FirebaseService.updateUser(userId, {'telefono': newPhone});
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

  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
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

    final user = _mainAuth.currentUser;
    if (user == null || user.email == null) {
      _showErrorSnackbar("Error", "Usuario no autenticado o sin email");
      return false;
    }

    try {
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );

      await user.reauthenticateWithCredential(credential).timeout(Duration(seconds: 15));
      await user.updatePassword(newPassword).timeout(Duration(seconds: 15));

      try {
        final prefs = await SharedPreferences.getInstance();
        final savedEmail = prefs.getString('user_email');
        if (savedEmail != null) {
          await prefs.setString('user_password', newPassword);
        }
      } catch (e) {
        Get.log('Error actualizando SharedPreferences (no crítico): $e');
      }

      _showSuccessSnackbar("Éxito", "Contraseña actualizada correctamente");
      return true;

    } on TimeoutException {
      _showErrorSnackbar("Error de Timeout", "La operación tardó demasiado. Verifica tu conexión a internet.");
      return false;
    } on FirebaseAuthException catch (e) {
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
      return false;
    } catch (e, stackTrace) {
      Get.log('Excepción inesperada: $e');
      Get.log('StackTrace: $stackTrace');
      _showErrorSnackbar("Error", "No se pudo cambiar la contraseña");
      return false;
    }
  }

  Future<void> _savePersistentSession(String email, String password) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_email', email);
      await prefs.setString('user_password', password);
    } catch (e) {
      Get.log('Error guardando sesión persistente: $e');
    }
  }

  Future<void> _clearPersistentSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user_email');
      await prefs.remove('user_password');
    } catch (e) {
      Get.log('Error limpiando sesión persistente: $e');
    }
  }

  String _extractErrorMessage(dynamic error) {
    if (error is Exception) {
      return error.toString().replaceFirst('Exception: ', '');
    }
    return error.toString();
  }

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

  bool get isSignedIn => firebaseUser.value != null;
  String? get currentUserId => FirebaseService.currentUserId;
  String get userDisplayName => currentUser.value?.nombreCompleto ?? 'Usuario';
  String get userEmail => currentUser.value?.email ?? '';
  String? get userPhotoUrl => currentUser.value?.photoUrl;
}