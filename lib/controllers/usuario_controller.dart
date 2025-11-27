import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/usuario.dart';

class UsuarioController extends GetxController {
  // Usuario actual en sesión
  Rxn<Usuario> currentUser = Rxn<Usuario>();

  /// Cargar usuario actual desde Firestore usando email o RUT
  Future<void> loadCurrentUser(String emailOrRut) async {
    try {
      QuerySnapshot snapshot;
      
      if (emailOrRut.contains('@')) {
        snapshot = await FirebaseFirestore.instance
            .collection('usuarios')
            .where('email', isEqualTo: emailOrRut.toLowerCase())
            .limit(1)
            .get();
      } else {
        // Buscar por RUT - INTENTAR AMBOS FORMATOS
        
        // Primero intentar con el formato original (con guión)
        snapshot = await FirebaseFirestore.instance
            .collection('usuarios')
            .where('rut', isEqualTo: emailOrRut)
            .limit(1)
            .get();
        
        // Si no encuentra, intentar sin guión
        if (snapshot.docs.isEmpty) {
          final rutLimpio = emailOrRut.replaceAll(RegExp(r'[^0-9kK]'), '');
          
          snapshot = await FirebaseFirestore.instance
              .collection('usuarios')
              .where('rut', isEqualTo: rutLimpio)
              .limit(1)
              .get();
        }
      }
      
      if (snapshot.docs.isNotEmpty) {
        final usuario = Usuario.fromMap(
          snapshot.docs.first.data() as Map<String, dynamic>,
          snapshot.docs.first.id,
        );
        
        currentUser.value = usuario;
      }
    } catch (e) {
      // Error silencioso
    }
  }

  /// Establecer usuario manualmente
  void setCurrentUser(Usuario usuario) {
    currentUser.value = usuario;
  }

  /// Cerrar sesión
  void logout() {
    currentUser.value = null;
  }

  // Getters útiles
  bool get isLoggedIn => currentUser.value != null;
  String get currentUserName => currentUser.value?.nombreCompleto ?? 'Sistema';
  String get currentUserId => currentUser.value?.id ?? 'sistema';
  Usuario? get user => currentUser.value;
}