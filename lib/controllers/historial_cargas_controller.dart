import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/historial_carga_cambio.dart';
import '../models/carga_familiar.dart';
import 'usuario_controller.dart';

class HistorialCargasController extends GetxController {
  RxList<HistorialCargaCambio> historialCambios = <HistorialCargaCambio>[].obs;
  RxBool isLoading = false.obs;

  static const int diasRetencion = 30;

  @override
  void onInit() {
    super.onInit();
    _limpiarHistorialAntiguo();
  }

  /// Registrar creación de carga familiar
  Future<void> registrarCreacion({
    required String cargaFamiliarId,
    required String asociadoId,
    required CargaFamiliar carga,
  }) async {
    await registrarCambio(
      cargaFamiliarId: cargaFamiliarId,
      asociadoId: asociadoId,
      tipoAccion: 'creacion',
      descripcion: 'Carga familiar creada',
      datosAdicionales: {
        'nombreCompleto': carga.nombreCompleto,
        'rut': carga.rutFormateado,
        'parentesco': carga.parentesco,
        'edad': carga.edad,
      },
    );
  }

  /// Registrar edición de carga familiar (con comparación de cambios)
  Future<void> registrarEdicion({
    required String cargaFamiliarId,
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
    
    if (cargaAnterior.fechaNacimiento != cargaNueva.fechaNacimiento) {
      valoresAnteriores['fechaNacimiento'] = 
          '${cargaAnterior.fechaNacimiento.day}/${cargaAnterior.fechaNacimiento.month}/${cargaAnterior.fechaNacimiento.year}';
      valoresNuevos['fechaNacimiento'] = 
          '${cargaNueva.fechaNacimiento.day}/${cargaNueva.fechaNacimiento.month}/${cargaNueva.fechaNacimiento.year}';
      camposModificados.add('Fecha de Nacimiento');
    }

    String descripcion = camposModificados.isNotEmpty
        ? 'Modificados: ${camposModificados.join(", ")}'
        : 'Información actualizada';

    await registrarCambio(
      cargaFamiliarId: cargaFamiliarId,
      asociadoId: asociadoId,
      tipoAccion: 'edicion',
      descripcion: descripcion,
      valoresAnteriores: valoresAnteriores,
      valoresNuevos: valoresNuevos,
    );
  }

  /// Registrar eliminación de carga familiar
  Future<void> registrarEliminacion({
    required String cargaFamiliarId,
    required String asociadoId,
    required CargaFamiliar carga,
  }) async {
    await registrarCambio(
      cargaFamiliarId: cargaFamiliarId,
      asociadoId: asociadoId,
      tipoAccion: 'eliminacion',
      descripcion: 'Carga familiar eliminada',
      datosAdicionales: {
        'nombreCompleto': carga.nombreCompleto,
        'rut': carga.rutFormateado,
        'parentesco': carga.parentesco,
      },
    );
  }

  /// Registrar activación de carga familiar
  Future<void> registrarActivacion({
    required String cargaFamiliarId,
    required String asociadoId,
    required String nombreCompleto,
  }) async {
    await registrarCambio(
      cargaFamiliarId: cargaFamiliarId,
      asociadoId: asociadoId,
      tipoAccion: 'activacion',
      descripcion: 'Carga familiar activada',
      datosAdicionales: {
        'nombreCompleto': nombreCompleto,
      },
    );
  }

  /// Registrar desactivación de carga familiar
  Future<void> registrarDesactivacion({
    required String cargaFamiliarId,
    required String asociadoId,
    required String nombreCompleto,
  }) async {
    await registrarCambio(
      cargaFamiliarId: cargaFamiliarId,
      asociadoId: asociadoId,
      tipoAccion: 'desactivacion',
      descripcion: 'Carga familiar desactivada',
      datosAdicionales: {
        'nombreCompleto': nombreCompleto,
      },
    );
  }

  /// Método base para registrar cualquier cambio
  Future<void> registrarCambio({
    required String cargaFamiliarId,
    required String asociadoId,
    required String tipoAccion,
    required String descripcion,
    Map<String, dynamic>? valoresAnteriores,
    Map<String, dynamic>? valoresNuevos,
    Map<String, dynamic>? datosAdicionales,
  }) async {
    try {
      final usuarioController = Get.find<UsuarioController>();
      
      String usuarioId = usuarioController.currentUserId;
      String usuarioNombre = usuarioController.currentUserName;

      final cambio = HistorialCargaCambio(
        cargaFamiliarId: cargaFamiliarId,
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
          .collection('historial_cargas_cambios')
          .add(cambio.toMap());

    } catch (e) {
      debugPrint('Error registrando cambio en historial de carga: $e');
    }
  }

  /// Cargar historial de una carga familiar específica
  Future<void> cargarHistorialCarga(String cargaFamiliarId) async {
    try {
      isLoading.value = true;
      
      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('historial_cargas_cambios')
          .where('cargaFamiliarId', isEqualTo: cargaFamiliarId)
          .get();

      historialCambios.clear();
      
      List<HistorialCargaCambio> cambiosList = [];
      for (var doc in snapshot.docs) {
        final cambio = HistorialCargaCambio.fromMap(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
        cambiosList.add(cambio);
      }
      
      // Ordenar de más reciente a más antiguo
      cambiosList.sort((a, b) => b.fechaHora.compareTo(a.fechaHora));
      historialCambios.addAll(cambiosList);

    } catch (e) {
      debugPrint('Error cargando historial de carga: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Limpiar historial más antiguo que 30 días
  Future<void> _limpiarHistorialAntiguo() async {
    try {
      final fechaLimite = DateTime.now().subtract(Duration(days: diasRetencion));
      
      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('historial_cargas_cambios')
          .where('fechaHora', isLessThan: fechaLimite)
          .get();

      final batch = FirebaseFirestore.instance.batch();
      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      
      if (snapshot.docs.isNotEmpty) {
        await batch.commit();
      }
    } catch (e) {
      debugPrint('Error limpiando historial antiguo de cargas: $e');
    }
  }

  /// Limpiar historial de una carga familiar específica
  Future<bool> limpiarHistorialCarga(String cargaFamiliarId) async {
    try {
      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('historial_cargas_cambios')
          .where('cargaFamiliarId', isEqualTo: cargaFamiliarId)
          .get();

      final batch = FirebaseFirestore.instance.batch();
      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      
      await batch.commit();
      historialCambios.clear();
      
      return true;
    } catch (e) {
      debugPrint('Error limpiando historial de la carga: $e');
      return false;
    }
  }

  // Getters útiles
  int get totalCambios => historialCambios.length;
  bool get tieneCambios => historialCambios.isNotEmpty;
}