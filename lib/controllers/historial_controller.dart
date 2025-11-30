import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/historial_cambio.dart';
import '../models/asociado.dart';
import '../models/carga_familiar.dart';
import 'auth_controller.dart'; 

class HistorialController extends GetxController {
  RxList<HistorialCambio> historialCambios = <HistorialCambio>[].obs;
  RxBool isLoading = false.obs;

  static const int diasRetencion = 30;

  @override
  void onInit() {
    super.onInit();
    _limpiarHistorialAntiguo();
  }

  /// Registrar creación de asociado
  Future<void> registrarCreacion({
    required String asociadoId,
    required Asociado asociado,
  }) async {
    await registrarCambio(
      asociadoId: asociadoId,
      tipoAccion: 'creacion',
      descripcion: 'Asociado creado',
      datosAdicionales: {
        'nombreCompleto': asociado.nombreCompleto,
        'rut': asociado.rutFormateado,
        'email': asociado.email,
        'plan': asociado.plan,
      },
    );
  }

  Future<void> registrarEdicion({
    required String asociadoId,
    required Asociado asociadoAnterior,
    required Asociado asociadoNuevo,
  }) async {
    Map<String, dynamic> valoresAnteriores = {};
    Map<String, dynamic> valoresNuevos = {};
    List<String> camposModificados = [];

    if (asociadoAnterior.nombre != asociadoNuevo.nombre) {
      valoresAnteriores['nombre'] = asociadoAnterior.nombre;
      valoresNuevos['nombre'] = asociadoNuevo.nombre;
      camposModificados.add('Nombre');
    }
    
    if (asociadoAnterior.apellido != asociadoNuevo.apellido) {
      valoresAnteriores['apellido'] = asociadoAnterior.apellido;
      valoresNuevos['apellido'] = asociadoNuevo.apellido;
      camposModificados.add('Apellido');
    }
    
    if (asociadoAnterior.email != asociadoNuevo.email) {
      valoresAnteriores['email'] = asociadoAnterior.email;
      valoresNuevos['email'] = asociadoNuevo.email;
      camposModificados.add('Email');
    }
    
    if (asociadoAnterior.telefono != asociadoNuevo.telefono) {
      valoresAnteriores['telefono'] = asociadoAnterior.telefono;
      valoresNuevos['telefono'] = asociadoNuevo.telefono;
      camposModificados.add('Teléfono');
    }
    
    if (asociadoAnterior.direccion != asociadoNuevo.direccion) {
      valoresAnteriores['direccion'] = asociadoAnterior.direccion;
      valoresNuevos['direccion'] = asociadoNuevo.direccion;
      camposModificados.add('Dirección');
    }
    
    if (asociadoAnterior.estadoCivil != asociadoNuevo.estadoCivil) {
      valoresAnteriores['estadoCivil'] = asociadoAnterior.estadoCivil;
      valoresNuevos['estadoCivil'] = asociadoNuevo.estadoCivil;
      camposModificados.add('Estado Civil');
    }
    
    if (asociadoAnterior.plan != asociadoNuevo.plan) {
      valoresAnteriores['plan'] = asociadoAnterior.plan;
      valoresNuevos['plan'] = asociadoNuevo.plan;
      camposModificados.add('Plan');
    }
    
    if (asociadoAnterior.fechaNacimiento != asociadoNuevo.fechaNacimiento) {
      valoresAnteriores['fechaNacimiento'] = 
          '${asociadoAnterior.fechaNacimiento.day}/${asociadoAnterior.fechaNacimiento.month}/${asociadoAnterior.fechaNacimiento.year}';
      valoresNuevos['fechaNacimiento'] = 
          '${asociadoNuevo.fechaNacimiento.day}/${asociadoNuevo.fechaNacimiento.month}/${asociadoNuevo.fechaNacimiento.year}';
      camposModificados.add('Fecha de Nacimiento');
    }

    String descripcion = camposModificados.isNotEmpty
        ? 'Modificados: ${camposModificados.join(", ")}'
        : 'Información actualizada';

    await registrarCambio(
      asociadoId: asociadoId,
      tipoAccion: 'edicion',
      descripcion: descripcion,
      valoresAnteriores: valoresAnteriores,
      valoresNuevos: valoresNuevos,
    );
  }

  /// Registrar adición de carga familiar
  Future<void> registrarCargaAgregada({
    required String asociadoId,
    required CargaFamiliar carga,
  }) async {
    await registrarCambio(
      asociadoId: asociadoId,
      tipoAccion: 'agregoCarga',
      descripcion: 'Carga familiar agregada',
      datosAdicionales: {
        'nombreCompleto': carga.nombreCompleto,
        'rut': carga.rutFormateado,
        'parentesco': carga.parentesco,
        'edad': carga.edad,
      },
    );
  }

  /// Registrar eliminación de carga familiar
  Future<void> registrarCargaEliminada({
    required String asociadoId,
    required CargaFamiliar carga,
  }) async {
    await registrarCambio(
      asociadoId: asociadoId,
      tipoAccion: 'eliminoCarga',
      descripcion: 'Carga familiar eliminada',
      datosAdicionales: {
        'nombreCompleto': carga.nombreCompleto,
        'rut': carga.rutFormateado,
        'parentesco': carga.parentesco,
      },
    );
  }

  /// Registrar edición de carga familiar
  Future<void> registrarCargaEditada({
    required String asociadoId,
    required CargaFamiliar cargaAnterior,
    required CargaFamiliar cargaNueva,
  }) async {
    Map<String, dynamic> valoresAnteriores = {};
    Map<String, dynamic> valoresNuevos = {};
    List<String> camposModificados = [];

    if (cargaAnterior.nombre != cargaNueva.nombre) {
      valoresAnteriores['nombre'] = cargaAnterior.nombre;
      valoresNuevos['nombre'] = cargaNueva.nombre;
      camposModificados.add('Nombre');
    }
    
    if (cargaAnterior.apellido != cargaNueva.apellido) {
      valoresAnteriores['apellido'] = cargaAnterior.apellido;
      valoresNuevos['apellido'] = cargaNueva.apellido;
      camposModificados.add('Apellido');
    }
    
    if (cargaAnterior.parentesco != cargaNueva.parentesco) {
      valoresAnteriores['parentesco'] = cargaAnterior.parentesco;
      valoresNuevos['parentesco'] = cargaNueva.parentesco;
      camposModificados.add('Parentesco');
    }

    String descripcion = 'Carga familiar editada: ${cargaNueva.nombreCompleto}';
    if (camposModificados.isNotEmpty) {
      descripcion += ' (${camposModificados.join(", ")})';
    }

    await registrarCambio(
      asociadoId: asociadoId,
      tipoAccion: 'editoCarga',
      descripcion: descripcion,
      valoresAnteriores: valoresAnteriores,
      valoresNuevos: valoresNuevos,
      datosAdicionales: {
        'cargaId': cargaNueva.id,
        'nombreCompleto': cargaNueva.nombreCompleto,
      },
    );
  }

  /// Registrar generación de código de barras
  Future<void> registrarCodigoBarrasGenerado({
    required String asociadoId,
    required String codigoBarras,
  }) async {
    await registrarCambio(
      asociadoId: asociadoId,
      tipoAccion: 'generoBarras',
      descripcion: 'Código de barras generado',
      datosAdicionales: {
        'codigoBarras': codigoBarras,
      },
    );
  }

  /// Registrar generación de código SAP
  Future<void> registrarSAPGenerado({
    required String asociadoId,
    required String sap,
  }) async {
    await registrarCambio(
      asociadoId: asociadoId,
      tipoAccion: 'generoSAP',
      descripcion: 'Código SAP generado',
      datosAdicionales: {
        'sap': sap,
      },
    );
  }

  /// Registrar exportación de datos
  Future<void> registrarExportacion({
    required String asociadoId,
    required String formato,
    String? nombreArchivo,
  }) async {
    await registrarCambio(
      asociadoId: asociadoId,
      tipoAccion: 'exportoDatos',
      descripcion: 'Datos exportados a $formato',
      datosAdicionales: {
        'formato': formato,
        if (nombreArchivo != null) 'archivo': nombreArchivo,
      },
    );
  }

  /// Método base para registrar cualquier cambio
  Future<void> registrarCambio({
    required String asociadoId,
    required String tipoAccion,
    required String descripcion,
    Map<String, dynamic>? valoresAnteriores,
    Map<String, dynamic>? valoresNuevos,
    Map<String, dynamic>? datosAdicionales,
  }) async {
    try {
      String usuarioId = 'sistema';
      String usuarioNombre = 'Sistema';

      if (Get.isRegistered<AuthController>()) {
        final authController = Get.find<AuthController>();
        if (authController.currentUser.value != null) {
          usuarioId = authController.currentUserId ?? 'sistema';
          usuarioNombre = authController.userDisplayName; 
        }
      }

      final cambio = HistorialCambio(
        asociadoId: asociadoId,
        usuarioId: usuarioId,
        usuarioNombre: usuarioNombre,
        tipoAccion: tipoAccion,
        descripcion: descripcion,
        valoresAnteriores: valoresAnteriores,
        valoresNuevos: valoresNuevos,
        datosAdicionales: datosAdicionales,
        fechaHora: DateTime.now(),
      );

      await FirebaseFirestore.instance
          .collection('historial_cambios')
          .add(cambio.toMap());

    } catch (e) {
      debugPrint('Error registrando cambio en historial: $e');
    }
  }

  /// Cargar historial de un asociado específico
  Future<void> cargarHistorialAsociado(String asociadoId) async {
    try {
      isLoading.value = true;
      
      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('historial_cambios')
          .where('asociadoId', isEqualTo: asociadoId)
          .get();

      historialCambios.clear();
      
      List<HistorialCambio> cambiosList = [];
      for (var doc in snapshot.docs) {
        final cambio = HistorialCambio.fromMap(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
        cambiosList.add(cambio);
      }
      
      cambiosList.sort((a, b) => b.fechaHora.compareTo(a.fechaHora));
      historialCambios.addAll(cambiosList);

    } catch (e) {
      debugPrint('Error cargando historial: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _limpiarHistorialAntiguo() async {
    try {
      final fechaLimite = DateTime.now().subtract(Duration(days: diasRetencion));
      
      // === CORRECCIÓN DE ESTABILIDAD ===

      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('historial_cambios')
          .where('fechaHora', isLessThan: fechaLimite)
          .limit(400)
          .get();

      if (snapshot.docs.isEmpty) return;

      final batch = FirebaseFirestore.instance.batch();
      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      
      await batch.commit();
      
    } catch (e) {
      debugPrint('Error limpiando historial antiguo: $e');
    }
  }

  /// Limpiar historial de un asociado específico
  Future<bool> limpiarHistorialAsociado(String asociadoId) async {
    try {
      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('historial_cambios')
          .where('asociadoId', isEqualTo: asociadoId)
          .get();

      final batch = FirebaseFirestore.instance.batch();
      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      
      await batch.commit();
      historialCambios.clear();
      
      return true;
    } catch (e) {
      debugPrint('Error limpiando historial del asociado: $e');
      return false;
    }
  }

  int get totalCambios => historialCambios.length;
  bool get tieneCambios => historialCambios.isNotEmpty;
}