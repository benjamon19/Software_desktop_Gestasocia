import 'package:get/get.dart';
import '../services/firebase_service.dart';

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
  Rxn<Map<String, dynamic>> selectedHistorial = Rxn<Map<String, dynamic>>();
  RxList<Map<String, dynamic>> historialList = <Map<String, dynamic>>[].obs;
  RxList<Map<String, dynamic>> filteredHistorial = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadHistorialesFromFirebase();
  }

  // ========== CARGAR DESDE FIREBASE ==========

  Future<void> loadHistorialesFromFirebase() async {
    try {
      isLoading.value = true;
      
      final snapshot = await FirebaseService.getCollection('historiales_clinicos');
      
      List<Map<String, dynamic>> loadedHistoriales = [];
      
      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        
        // Convertir Timestamp a String
        if (data['fecha'] != null && data['fecha'] is! String) {
          final fecha = data['fecha'].toDate();
          data['fecha'] = '${fecha.day.toString().padLeft(2, '0')}/${fecha.month.toString().padLeft(2, '0')}/${fecha.year}';
        }
        
        if (data['hora'] == null) {
          data['hora'] = '00:00';
        }
        
        loadedHistoriales.add(data);
      }
      
      // Ordenar por fecha (más recientes primero)
      loadedHistoriales.sort((a, b) {
        try {
          final fechaA = _parseDate(a['fecha']);
          final fechaB = _parseDate(b['fecha']);
          return fechaB.compareTo(fechaA);
        } catch (e) {
          return 0;
        }
      });
      
      historialList.value = loadedHistoriales;
      _applyFilters();
      
    } catch (e) {
      Get.log('Error cargando historiales: $e');
      Get.snackbar(
        'Error',
        'No se pudieron cargar los historiales clínicos',
        snackPosition: SnackPosition.BOTTOM,
      );
      historialList.value = [];
      filteredHistorial.value = [];
    } finally {
      isLoading.value = false;
    }
  }

  DateTime _parseDate(String? fechaStr) {
    if (fechaStr == null) return DateTime.now();
    
    try {
      final parts = fechaStr.split('/');
      if (parts.length == 3) {
        return DateTime(
          int.parse(parts[2]), // año
          int.parse(parts[1]), // mes
          int.parse(parts[0]), // día
        );
      }
    } catch (e) {
      Get.log('Error parsing date: $fechaStr');
    }
    
    return DateTime.now();
  }

  // ========== NAVEGACIÓN ==========

  void selectHistorial(Map<String, dynamic> historial) {
    selectedHistorial.value = historial;
    currentView.value = detalleView;
  }

  void backToList() {
    currentView.value = listaView;
    selectedHistorial.value = null;
  }

  void clearSearch() {
    searchQuery.value = '';
    _applyFilters();
  }

  // ========== BÚSQUEDA Y FILTROS ==========

  void searchHistorial(String query) {
    searchQuery.value = query;
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

  void _applyFilters() {
    List<Map<String, dynamic>> filtered = List.from(historialList);

    // Filtro por búsqueda (nombre o RUT)
    if (searchQuery.value.isNotEmpty) {
      filtered = filtered.where((historial) {
        final nombre = (historial['pacienteNombre'] ?? '').toString().toLowerCase();
        final rut = (historial['pacienteRut'] ?? '').toString().toLowerCase();
        final query = searchQuery.value.toLowerCase();
        
        return nombre.contains(query) || rut.contains(query);
      }).toList();
    }

    // Filtro por tipo de consulta
    if (selectedFilter.value != 'todos') {
      filtered = filtered.where((historial) => 
        (historial['tipoConsulta'] ?? '').toLowerCase() == selectedFilter.value.toLowerCase()
      ).toList();
    }

    // Filtro por estado
    if (selectedStatus.value != 'todos') {
      filtered = filtered.where((historial) => 
        (historial['estado'] ?? '').toLowerCase() == selectedStatus.value.toLowerCase()
      ).toList();
    }

    // Filtro por odontólogo
    if (selectedOdontologo.value != 'todos') {
      filtered = filtered.where((historial) => 
        (historial['odontologo'] ?? '').toLowerCase().contains(selectedOdontologo.value.toLowerCase())
      ).toList();
    }

    filteredHistorial.value = filtered;
  }

  // ========== ACCIONES CRUD ==========

  Future<void> addNewHistorial(Map<String, dynamic> historialData) async {
    try {
      isLoading.value = true;
      
      historialData['fechaCreacion'] = DateTime.now();
      
      await FirebaseService.createDocument(
        collection: 'historiales_clinicos',
        data: historialData,
      );
      
      await loadHistorialesFromFirebase();
    } catch (e) {
      Get.log('Error guardando historial: $e');
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteHistorial() async {
    if (selectedHistorial.value != null) {
      try {
        final id = selectedHistorial.value!['id'];
        
        await FirebaseService.getDocument(
          collection: 'historiales_clinicos',
          docId: id,
        ).then((doc) async {
          await doc.reference.delete();
        });
        
        Get.snackbar('Éxito', 'Historial eliminado correctamente');
        
        backToList();
        await loadHistorialesFromFirebase();
      } catch (e) {
        Get.snackbar('Error', 'No se pudo eliminar el historial');
      }
    }
  }

  // ========== GETTERS ==========

  bool get hasSelectedHistorial => selectedHistorial.value != null;
  bool get isListView => currentView.value == listaView;
  bool get isDetailView => currentView.value == detalleView;
  
  int get totalRegistros => historialList.length;
  int get filteredCount => filteredHistorial.length;
}