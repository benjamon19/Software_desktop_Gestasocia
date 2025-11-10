import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import '../models/historial_clinico.dart';
import '../controllers/asociados_controller.dart';
import '../controllers/cargas_familiares_controller.dart';

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
  final RxList<HistorialClinico> _allHistoriales = <HistorialClinico>[].obs;
  RxList<HistorialClinico> historiales = <HistorialClinico>[].obs;
  
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
    
    loadHistorialesFromFirebase();
  }

  @override
  void onClose() {
    _debounceTimer?.cancel();
    super.onClose();
  }

  // ========== CARGAR DESDE FIREBASE CON REFERENCIAS ==========

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
          };
        }
      }
    } catch (e) {
      // Error silencioso
    }
    
    return null;
  }
  /// Obtener información del paciente para mostrar en la UI
  Map<String, dynamic> getPacienteInfoForDisplay(HistorialClinico historial) {
    final info = _getPacienteInfo(historial);
    return info ?? {
      'nombre': 'Paciente no encontrado',
      'rut': 'N/A',
      'edad': 0,
      'telefono': '',
      'titularNombre': '',
    };
  }

  // ========== BÚSQUEDA Y FILTROS ==========

  void _applyFilters() {
    List<HistorialClinico> filtered = List.from(_allHistoriales);

    // Filtro por búsqueda (nombre o RUT del paciente)
    if (searchQuery.value.isNotEmpty) {
      final query = searchQuery.value.toLowerCase();
      filtered = filtered.where((historial) {
        final pacienteInfo = _getPacienteInfo(historial);
        if (pacienteInfo == null) return false;
        
        final nombre = pacienteInfo['nombre'].toString().toLowerCase();
        final rut = pacienteInfo['rut'].toString().toLowerCase();
        final rutSinFormato = rut.replaceAll(RegExp(r'[^0-9kK]'), '');
        final querySinFormato = query.replaceAll(RegExp(r'[^0-9kK]'), '');
        
        return nombre.contains(query) || rutSinFormato.contains(querySinFormato);
      }).toList();
    }

    // Filtro por tipo de consulta
    if (selectedFilter.value != 'todos') {
      filtered = filtered.where((h) => h.tipoConsulta == selectedFilter.value).toList();
    }

    // Filtro por estado
    if (selectedStatus.value != 'todos') {
      filtered = filtered.where((h) => h.estado.toLowerCase() == selectedStatus.value).toList();
    }

    // Filtro por odontólogo
    if (selectedOdontologo.value != 'todos') {
      final odontologoNombre = selectedOdontologo.value == 'dr.lopez' ? 'Dr. López' : 'Dr. Martínez';
      filtered = filtered.where((h) => h.odontologo == odontologoNombre).toList();
    }

    // Ordenar por fecha más reciente
    filtered.sort((a, b) => b.fecha.compareTo(a.fecha));
    
    historiales.value = filtered;
  }

  void searchHistorial(String query) {
    searchQuery.value = query;
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

  // ========== NAVEGACIÓN ==========

  void selectHistorial(Map<String, dynamic> historialMap) {
    final historialCompleto = _allHistoriales.firstWhereOrNull(
      (h) => h.id == historialMap['id']
    );
    
    if (historialCompleto != null) {
      selectedHistorial.value = historialCompleto;
      currentView.value = detalleView;
    }
  }

  void backToList() {
    currentView.value = listaView;
    selectedHistorial.value = null;
  }

  // ========== ACCIONES CRUD ==========

  Future<void> addNewHistorial(Map<String, dynamic> historialData) async {
    try {
      isLoading.value = true;
      
      // Validar que exista el paciente
      if (!await _validatePacienteExists(
        historialData['pacienteId'],
        historialData['pacienteTipo'],
      )) {
        throw Exception('El paciente no existe en el sistema');
      }
      
      // Crear el historial limpio (solo con campos del modelo)
      final historialLimpio = HistorialClinico(
        pacienteId: historialData['pacienteId'],
        pacienteTipo: historialData['pacienteTipo'],
        tipoConsulta: historialData['tipoConsulta'],
        odontologo: historialData['odontologo'],
        fecha: historialData['fecha'],
        hora: historialData['hora'],
        motivoPrincipal: historialData['motivoPrincipal'],
        diagnostico: historialData['diagnostico'],
        tratamientoRecomendado: historialData['tratamientoRecomendado'],
        observacionesOdontologo: historialData['observacionesOdontologo'],
        estado: historialData['estado'],
        fechaCreacion: DateTime.now(),
      );
      
      // Guardar en Firestore
      final docRef = await FirebaseFirestore.instance
          .collection('historiales_clinicos')
          .add(historialLimpio.toMap());
      
      // Crear el objeto con ID
      final nuevoHistorial = historialLimpio.copyWith(id: docRef.id);
      
      // Agregar a la lista local
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
        final doc = await FirebaseFirestore.instance
            .collection('asociados')
            .doc(pacienteId)
            .get();
        return doc.exists;
      } else if (pacienteTipo == 'carga') {
        final doc = await FirebaseFirestore.instance
            .collection('cargas_familiares')
            .doc(pacienteId)
            .get();
        return doc.exists;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<void> deleteHistorial() async {
    if (selectedHistorial.value?.id != null) {
      try {
        final id = selectedHistorial.value!.id!;
        
        await FirebaseFirestore.instance
            .collection('historiales_clinicos')
            .doc(id)
            .delete();
        
        _allHistoriales.removeWhere((h) => h.id == id);
        _applyFilters();
        
        _showSuccessSnackbar('Éxito', 'Historial eliminado correctamente');
        
        backToList();
      } catch (e) {
        _showErrorSnackbar('Error', 'No se pudo eliminar el historial');
      }
    }
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

  // ========== CONVERTIR A MAP PARA LA VISTA ==========

  List<Map<String, dynamic>> get filteredHistorial {
    return historiales.map((h) {
      final pacienteInfo = _getPacienteInfo(h);
      return {
        'id': h.id,
        'pacienteId': h.pacienteId,
        'pacienteTipo': h.pacienteTipo,
        'pacienteNombre': pacienteInfo?['nombre'] ?? 'Paciente no encontrado',
        'pacienteRut': pacienteInfo?['rut'] ?? 'N/A',
        'pacienteEdad': pacienteInfo?['edad'] ?? 0,
        'pacienteTelefono': pacienteInfo?['telefono'] ?? '',
        'tipoConsulta': h.tipoConsultaFormateado,
        'odontologo': h.odontologo,
        'fecha': h.fechaFormateada,
        'hora': h.hora,
        'motivoPrincipal': h.motivoPrincipal,
        'diagnostico': h.diagnostico ?? '',
        'tratamientoRecomendado': h.tratamientoRecomendado ?? '',
        'observacionesOdontologo': h.observacionesOdontologo ?? '',
        'estado': h.estadoFormateado,
        'asociadoTitular': pacienteInfo?['titularNombre'] ?? '',
      };
    }).toList();
  }

  // ========== GETTERS ==========

  bool get hasSelectedHistorial => selectedHistorial.value != null;
  bool get isListView => currentView.value == listaView;
  bool get isDetailView => currentView.value == detalleView;
  
  int get totalRegistros => _allHistoriales.length;
  int get filteredCount => historiales.length;
  
  List<Map<String, dynamic>> get historialList {
    return _allHistoriales.map((h) {
      final pacienteInfo = _getPacienteInfo(h);
      return {
        'id': h.id,
        'pacienteNombre': pacienteInfo?['nombre'] ?? 'Desconocido',
        'pacienteRut': pacienteInfo?['rut'] ?? '',
      };
    }).toList();
  }
}