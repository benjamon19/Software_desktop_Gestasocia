import 'dart:io';
import 'dart:async';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_core/firebase_core.dart';
import '../models/historial_clinico.dart';
import '../controllers/asociados_controller.dart';
import '../controllers/cargas_familiares_controller.dart';
import '../controllers/auth_controller.dart'; 

class HistorialClinicoController extends GetxController {
  // Estados de vista
  static const int listaView = 0;
  static const int detalleView = 1;

  // Variables observables
  RxBool isLoading = false.obs;
  RxInt currentView = listaView.obs;
  RxString searchQuery = ''.obs;
  RxString selectedFilter = 'todos'.obs;
  RxString selectedStatus = 'todos'.obs;
  RxString selectedOdontologo = 'todos'.obs;

  // Datos
  Rxn<HistorialClinico> selectedHistorial = Rxn<HistorialClinico>();
  RxString selectedPacienteNombre = ''.obs;
  final RxList<HistorialClinico> _allHistoriales = <HistorialClinico>[].obs;
  RxList<HistorialClinico> historiales = <HistorialClinico>[].obs;

  RxMap<String, dynamic> datosPacientePreCargados = <String, dynamic>{}.obs;

  Timer? _debounceTimer;

  @override
  void onInit() {
    super.onInit();

    searchQuery.listen((query) {
      if (_debounceTimer == null || !_debounceTimer!.isActive) {
        _debounceTimer?.cancel();
        _debounceTimer = Timer(const Duration(milliseconds: 100), () {
          _applyFilters();
        });
      }
    });

    try {
      final authController = Get.find<AuthController>();
      ever(authController.currentUser, (_) {
        _applyFilters();
      });
    } catch (e) {
      Get.log('Error vinculando AuthController: $e');
    }

    loadHistorialesFromFirebase();
  }

  @override
  void onClose() {
    _debounceTimer?.cancel();
    super.onClose();
  }

  // =========================================================================
  // === GETTERS DINÁMICOS PARA DASHBOARD (KPIs y Listas) ===
  // =========================================================================

  int get totalNuevosHistorialesMes {
    final DateTime fechaLimite = DateTime.now().subtract(const Duration(days: 365));
    
    return historiales.where((historial) {
      return historial.fechaCreacion.isAfter(fechaLimite);
    }).length;
  }

  int get totalUrgencias {
    return urgenciasPendientes.length;
  }

  List<HistorialClinico> get urgenciasPendientes {
    return historiales.where((h) {
      final isUrgencia = h.tipoConsulta.toLowerCase() == 'urgencia';
      return isUrgencia;
    }).toList()
    ..sort((a, b) => a.fecha.compareTo(b.fecha));
  }

  Map<String, int> get tratamientosPorTipo {
    final Map<String, int> counts = {};
    for (var h in historiales) { 
      final t = h.tratamientoRealizado?.trim();
      if (t != null && t.isNotEmpty) {
        final formatted = t.length > 1 
            ? t[0].toUpperCase() + t.substring(1).toLowerCase() 
            : t.toUpperCase();
        counts[formatted] = (counts[formatted] ?? 0) + 1;
      }
    }
    return counts;
  }

  Future<void> loadHistorialesFromFirebase() async {
    try {
      isLoading.value = true;

      final snapshot = await FirebaseFirestore.instance
          .collection('historiales_clinicos')
          .orderBy('fecha', descending: true)
          .get();

      _allHistoriales.clear();

      for (var doc in snapshot.docs) {
        final historial = HistorialClinico.fromMap(
          doc.data(),
          doc.id,
        );
        _allHistoriales.add(historial);
      }

      _applyFilters();
    } catch (e) {
      _showErrorSnackbar('Error', 'No se pudieron cargar los historiales clínicos: $e');
      _allHistoriales.clear();
      historiales.clear();
    } finally {
      isLoading.value = false;
    }
  }

  // ========== OBTENER INFO DEL PACIENTE ==========
  Map<String, dynamic>? _getPacienteInfo(HistorialClinico historial) {
    try {
      if (historial.pacienteTipo == 'asociado') {
        final asociadosController = Get.find<AsociadosController>();
        final asociado = asociadosController.getAsociadoById(historial.pacienteId);

        if (asociado != null) {
          return {
            'nombre': asociado.nombreCompleto,
            'rut': asociado.rutFormateado,
            'edad': asociado.edad,
            'telefono': asociado.telefono,
            'titularNombre': asociado.nombreCompleto,
            'sap': asociado.sap,
          };
        }
      } else if (historial.pacienteTipo == 'carga') {
        final cargasController = Get.find<CargasFamiliaresController>();
        final carga = cargasController.getCargaById(historial.pacienteId);

        if (carga != null) {
          final asociadosController = Get.find<AsociadosController>();
          final asociado = asociadosController.getAsociadoById(carga.asociadoId);

          return {
            'nombre': carga.nombreCompleto,
            'rut': carga.rutFormateado,
            'edad': carga.edad,
            'telefono': carga.telefono ?? '',
            'titularNombre': asociado?.nombreCompleto ?? 'Desconocido',
            'sap': asociado?.sap,
          };
        }
      }
    } catch (e) {
      // Error silencioso
    }

    return null;
  }

  Map<String, dynamic> getPacienteInfoForDisplay(HistorialClinico historial) {
    final info = _getPacienteInfo(historial);
    return info ?? {
      'nombre': 'Paciente no encontrado',
      'rut': 'N/A',
      'edad': 0,
      'telefono': '',
      'titularNombre': '',
      'sap': null,
    };
  }

  // ========== BÚSQUEDA Y FILTROS ==========

  void _applyFilters() {

    final authController = Get.find<AuthController>();
    final currentUser = authController.currentUser.value;

    if (currentUser == null) {
      historiales.clear();
      return;
    }

    List<HistorialClinico> filtered = List.from(_allHistoriales);

    // --- LOGICA DE SEGURIDAD PARA ODONTÓLOGOS ---
    try {
      if (currentUser.rol == 'odontologo') {
        filtered = filtered.where((h) {
          if (h.tipoConsulta.toLowerCase() == 'urgencia' && 
              ['pendiente', 'requiere_seguimiento'].contains(h.estado.toLowerCase())) {
            return true;
          }

          if (h.odontologoId != null && h.odontologoId == currentUser.id) {
            return true;
          }

          if (h.odontologoId == null && h.odontologo == currentUser.nombreCompleto) {
            return true;
          }
          return false;
        }).toList();
      }
    } catch (e) {
      // Error silencioso
      historiales.clear();
      return;
    }

    if (searchQuery.value.isNotEmpty) {
      final query = searchQuery.value.trim();
      final querySinFormato = query.replaceAll(RegExp(r'[^0-9kK]'), '');

      filtered = filtered.where((historial) {
        try {
          final info = _getPacienteInfo(historial);
          if (info != null) {
             final nombre = info['nombre'].toString().toLowerCase();
             final rut = info['rut'].toString().replaceAll(RegExp(r'[^0-9kK]'), '');
             return nombre.contains(query.toLowerCase()) || rut.contains(querySinFormato);
          }
          return false;
        } catch (e) {
          return false;
        }
      }).toList();
    }

    if (selectedFilter.value != 'todos') {
      filtered = filtered.where((h) => h.tipoConsulta == selectedFilter.value).toList();
    }

    if (selectedStatus.value != 'todos') {
      filtered = filtered.where((h) => h.estado.toLowerCase() == selectedStatus.value).toList();
    }
    
    if (selectedOdontologo.value != 'todos') {
      filtered = filtered.where((h) => h.odontologo == selectedOdontologo.value).toList();
    }

    filtered.sort((a, b) => b.fecha.compareTo(a.fecha));

    historiales.value = filtered;
    
    historiales.refresh();
  }

  // ========== HELPERS ==========

  void _showErrorSnackbar(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Get.theme.colorScheme.error.withValues(alpha: 0.8),
      colorText: Get.theme.colorScheme.onError,
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
      duration: const Duration(seconds: 3),
    );
  }

  // ========== OPTIMIZACIÓN DE RENDIMIENTO ==========

  List<HistorialClinico> get filteredHistorialList {
    return historiales;
  }

  Map<String, dynamic> toDisplayMap(HistorialClinico h) {
    final info = _getPacienteInfo(h);
    return {
      'id': h.id,
      'pacienteId': h.pacienteId,
      'pacienteTipo': h.pacienteTipo,
      'pacienteNombre': info?['nombre'] ?? 'Paciente no encontrado',
      'pacienteRut': info?['rut'] ?? 'N/A',
      'pacienteEdad': info?['edad'] ?? 0,
      'pacienteTelefono': info?['telefono'] ?? '',
      'pacienteSap': info?['sap'],
      'tipoConsulta': h.tipoConsultaFormateado,
      'odontologo': h.odontologo,
      'odontologoId': h.odontologoId,
      'fecha': h.fechaFormateada,
      'hora': h.hora,
      'motivoPrincipal': h.motivoPrincipal,
      'diagnostico': h.diagnostico ?? '',
      'tratamientoRealizado': h.tratamientoRealizado ?? '',
      'tratamiento': h.tratamientoRealizado ?? '',
      'dienteTratado': h.dienteTratado ?? '',
      'observacionesOdontologo': h.observacionesOdontologo ?? '',
      'observaciones': h.observacionesOdontologo ?? '',
      'alergias': h.alergias ?? '',
      'medicamentosActuales': h.medicamentosActuales ?? '',
      'proximaCita': h.proximaCitaFormateada,
      'estado': h.estadoFormateado,
      'costoTratamiento': h.costoTratamiento,
      'imagenUrl': h.imagenUrl ?? '',
      'asociadoTitular': info?['titularNombre'] ?? '',
    };
  }
  
  void searchHistorial(String query) {
    searchQuery.value = query;
  }

  Future<void> searchHistorialExacto(String searchTerm) async {
    if (searchTerm.isEmpty) return;

    isLoading.value = true;

    try {
      searchHistorial(searchTerm);

      await Future.delayed(const Duration(milliseconds: 150));

      if (historiales.isNotEmpty) {
        showDetailView(historiales.first);
        clearSearch();

        _showSuccessSnackbar(
          'Encontrado',
          historiales.length == 1
              ? 'Historial encontrado'
              : 'Se encontraron historiales',
        );
      } else {
        _showErrorSnackbar(
          'No encontrado',
          'No se encontraron historiales con: $searchTerm',
        );
      }
    } catch (e) {
      _showErrorSnackbar('Error', 'Error al buscar historial clínico');
    } finally {
      isLoading.value = false;
    }
  }

  void clearSearch() {
    searchQuery.value = '';
    _applyFilters();
  }

  void setFilter(String filter) {
    selectedFilter.value = filter;
    _applyFilters();
  }

  void setStatus(String status) {
    selectedStatus.value = status;
    _applyFilters();
  }

  void setOdontologo(String odontologo) {
    selectedOdontologo.value = odontologo;
    _applyFilters();
  }

  // ========== NAVEGACIÓN ENTRE VISTAS ==========

  void selectHistorial(Map<String, dynamic> historialMap) {
    final historialCompleto = _allHistoriales.firstWhereOrNull(
      (h) => h.id == historialMap['id'],
    );

    if (historialCompleto != null) {
      showDetailView(historialCompleto);
    }
  }

  void showDetailView(HistorialClinico historial) {
    selectedHistorial.value = historial;

    final pacienteInfo = _getPacienteInfo(historial);
    selectedPacienteNombre.value = pacienteInfo?['nombre'] ?? 'Paciente no encontrado';

    currentView.value = detalleView;
  }

  void showListView() {
    selectedHistorial.value = null;
    selectedPacienteNombre.value = '';
    currentView.value = listaView;
  }

  // ==================== MÉTODO PARA SUBIR IMAGEN AL HISTORIAL ====================

  Future<bool> uploadImagenHistorial(String historialId, File imageFile) async {
    try {
      Get.log('=== INICIANDO SUBIDA DE IMAGEN AL HISTORIAL $historialId ===');

      final historial = await FirebaseFirestore.instance
          .collection('historiales_clinicos')
          .doc(historialId)
          .get();

      if (!historial.exists) {
        _showErrorSnackbar('Error', 'Historial no encontrado');
        return false;
      }

      final fileSize = await imageFile.length();
      if (fileSize > 10 * 1024 * 1024) {
        _showErrorSnackbar('Error', 'La imagen no debe superar 10MB');
        return false;
      }

      final storageRef = FirebaseStorage.instanceFor(
        app: Firebase.app('storageApp'),
        bucket: 'gestasocia-bucket-4b6ea.firebasestorage.app',
      ).ref().child('historiales/$historialId/imagen.jpg');

      final uploadTask = storageRef.putFile(imageFile);

      final snapshot = await uploadTask;

      if (snapshot.state == TaskState.success) {
        final downloadUrl = await storageRef.getDownloadURL();

        await FirebaseFirestore.instance
            .collection('historiales_clinicos')
            .doc(historialId)
            .update({
          'imagenUrl': downloadUrl,
          'fechaActualizacion': DateTime.now(),
        });

        if (selectedHistorial.value?.id == historialId) {
          final historialActualizado = selectedHistorial.value!.copyWith(
            imagenUrl: downloadUrl,
          );
          selectedHistorial.value = historialActualizado;
          selectedHistorial.refresh();

          final index = historiales.indexWhere((h) => h.id == historialId);
          if (index != -1) {
            historiales[index] = historialActualizado;
            historiales.refresh();
          }
        }

        _showSuccessSnackbar('Éxito', 'Imagen subida correctamente');
        return true;
      } else {
        _showErrorSnackbar('Error', 'No se pudo completar la subida');
        return false;
      }
    } catch (e) {
      _showErrorSnackbar('Error', 'No se pudo subir la imagen: ${e.toString()}');
      return false;
    }
  }

  // ========== ACCIONES CRUD ==========

  Future<void> addNewHistorial(Map<String, dynamic> historialData) async {
    try {
      isLoading.value = true;

      if (!await _validatePacienteExists(
        historialData['pacienteId'],
        historialData['pacienteTipo'],
      )) {
        throw Exception('El paciente no existe en el sistema');
      }

      String? odontoId = historialData['odontologoId'];
      try {
        final authController = Get.find<AuthController>();
        final currentUser = authController.currentUser.value;
        
        if (odontoId == null && currentUser != null) {
          if (historialData['odontologo'] == currentUser.nombreCompleto) {
            odontoId = currentUser.id;
          } else if (currentUser.rol == 'odontologo') {

             odontoId = currentUser.id;
             historialData['odontologo'] = currentUser.nombreCompleto;
          }
        }
      } catch (e) {
        Get.log('No se pudo asignar ID de odontólogo automáticamente: $e');
      }
      // ---------------------------------------------

      final historialLimpio = HistorialClinico(
        pacienteId: historialData['pacienteId'],
        pacienteTipo: historialData['pacienteTipo'],
        tipoConsulta: historialData['tipoConsulta'],
        odontologo: historialData['odontologo'],
        odontologoId: odontoId,
        fecha: historialData['fecha'],
        hora: historialData['hora'],
        motivoPrincipal: historialData['motivoPrincipal'],
        diagnostico: historialData['diagnostico'],
        tratamientoRealizado: historialData['tratamientoRealizado'],
        dienteTratado: historialData['dienteTratado'],
        observacionesOdontologo: historialData['observacionesOdontologo'],
        alergias: historialData['alergias'],
        medicamentosActuales: historialData['medicamentosActuales'],
        proximaCita: historialData['proximaCita'],
        estado: historialData['estado'],
        costoTratamiento: historialData['costoTratamiento'],
        imagenUrl: historialData['imagenUrl'],
        fechaCreacion: DateTime.now(),
      );

      final docRef = await FirebaseFirestore.instance
          .collection('historiales_clinicos')
          .add(historialLimpio.toMap());

      final nuevoHistorial = historialLimpio.copyWith(id: docRef.id);

      _allHistoriales.insert(0, nuevoHistorial);
      _applyFilters();

      _showSuccessSnackbar('Éxito', 'Historial clínico creado correctamente');
    } catch (e) {
      _showErrorSnackbar('Error', 'No se pudo crear el historial: $e');
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> _validatePacienteExists(String pacienteId, String pacienteTipo) async {
    try {
      if (pacienteTipo == 'asociado') {
        final doc = await FirebaseFirestore.instance.collection('asociados').doc(pacienteId).get();
        return doc.exists;
      } else if (pacienteTipo == 'carga') {
        final doc = await FirebaseFirestore.instance.collection('cargas_familiares').doc(pacienteId).get();
        return doc.exists;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<void> deleteHistorialCompleto(String historialId) async {
    if (historialId.isEmpty) return;

    try {
      isLoading.value = true;

      final historialEliminar =
          _allHistoriales.firstWhere((h) => h.id == historialId, orElse: () => throw Exception('Historial no encontrado'));

      if (historialEliminar.imagenUrl != null && historialEliminar.imagenUrl!.isNotEmpty) {

        try {
           final ref = FirebaseStorage.instance.refFromURL(historialEliminar.imagenUrl!);
           await ref.delete();
        } catch (e) {
           Get.log('Nota: Error al intentar borrar imagen (puede no existir): $e');
        }
      }

      await FirebaseFirestore.instance.collection('historiales_clinicos').doc(historialId).delete();

      _allHistoriales.removeWhere((h) => h.id == historialId);
      _applyFilters();

      if (selectedHistorial.value?.id == historialId) {
        showListView();
      }

      _showSuccessSnackbar('Éxito', 'Historial eliminado correctamente');
    } catch (e) {
      _showErrorSnackbar('Error', 'No se pudo eliminar el historial: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> eliminarHistorialPorId(String id) async {
    await deleteHistorialCompleto(id);
  }

  Future<void> actualizarHistorial(String historialId, Map<String, dynamic> cambios) async {
    try {
      isLoading.value = true;

      await FirebaseFirestore.instance
          .collection('historiales_clinicos')
          .doc(historialId)
          .update(cambios);

      final index = _allHistoriales.indexWhere((h) => h.id == historialId);
      if (index != -1) {
        final historialActual = _allHistoriales[index];
        final historialActualizado = historialActual.copyWith(
          motivoPrincipal: cambios['motivoPrincipal'] as String? ?? historialActual.motivoPrincipal,
          diagnostico: cambios['diagnostico'] as String?,
          tratamientoRealizado: cambios['tratamientoRealizado'] as String?,
          dienteTratado: cambios['dienteTratado'] as String?,
          observacionesOdontologo: cambios['observacionesOdontologo'] as String?,
          alergias: cambios['alergias'] as String?,
          medicamentosActuales: cambios['medicamentosActuales'] as String?,
          tipoConsulta: cambios['tipoConsulta'] as String? ?? historialActual.tipoConsulta,
          odontologo: cambios['odontologo'] as String? ?? historialActual.odontologo,
          estado: cambios['estado'] as String? ?? historialActual.estado,
          proximaCita: cambios['proximaCita'] as DateTime?,
          costoTratamiento: cambios['costoTratamiento'] as double?,
          fechaActualizacion: cambios['fechaActualizacion'] as DateTime? ?? historialActual.fechaActualizacion,
        );

        _allHistoriales[index] = historialActualizado;
        _applyFilters();

        if (selectedHistorial.value?.id == historialId) {
          selectedHistorial.value = null;
          Future.microtask(() {
            selectedHistorial.value = historialActualizado;
          });
        }
      }

      _showSuccessSnackbar('Éxito', 'Historial actualizado correctamente');
    } catch (e) {
      _showErrorSnackbar('Error', 'No se pudo actualizar: $e');
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  void precargarDatosPaciente({
    required String rut,
    required String nombre,
    required String? telefono,
    required String? email,
    required String tipo,
    required String pacienteId,
  }) {
    datosPacientePreCargados.value = {
      'rut': rut,
      'nombre': nombre,
      'telefono': telefono,
      'email': email,
      'tipo': tipo,
      'pacienteId': pacienteId,
    };
  }
  
  // ========== EXPORTACIÓN ==========
  Map<String, dynamic>? get currentHistorial {
    final historial = selectedHistorial.value;
    if (historial == null) return null;
    return toDisplayMap(historial);
  }

  bool get canExport => selectedHistorial.value != null;

  // ========== GETTERS ==========
  bool get hasSelectedHistorial => selectedHistorial.value != null;
  bool get isListView => currentView.value == listaView;
  bool get isDetailView => currentView.value == detalleView;

  int get totalRegistros => _allHistoriales.length;
  int get filteredCount => historiales.length;

  RxList<HistorialClinico> get allHistoriales => _allHistoriales;
}