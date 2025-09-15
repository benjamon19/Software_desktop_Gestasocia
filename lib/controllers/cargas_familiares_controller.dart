import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CargasFamiliaresController extends GetxController {
  // Estados de vista
  static const int listaView = 0;
  static const int detalleView = 1;

  // Variables observables
  RxBool isLoading = false.obs;
  RxInt currentView = listaView.obs;
  RxString searchQuery = ''.obs;
  RxString selectedFilter = 'todos'.obs;
  RxString selectedStatus = 'activas'.obs;

  // Datos
  Rxn<Map<String, dynamic>> selectedCarga = Rxn<Map<String, dynamic>>();
  RxList<Map<String, dynamic>> cargasList = <Map<String, dynamic>>[].obs;
  RxList<Map<String, dynamic>> filteredCargas = <Map<String, dynamic>>[].obs;

  // Control de diálogo
  final _isDialogOpen = true;

  @override
  void onInit() {
    super.onInit();
    _loadSampleData();
  }

  // ========== NAVEGACIÓN ==========
  void selectCarga(Map<String, dynamic> carga) {
    selectedCarga.value = carga;
    currentView.value = detalleView;
  }

  void backToList() {
    currentView.value = listaView;
    selectedCarga.value = null;
  }

  void clearSearch() {
    searchQuery.value = '';
    _applyFilters();
  }

  // ========== BÚSQUEDA ==========
  void searchCargas(String query) {
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

  void _applyFilters() {
    List<Map<String, dynamic>> filtered = List.from(cargasList);

    if (searchQuery.value.isNotEmpty) {
      final query = searchQuery.value.toLowerCase();
      filtered = filtered.where((carga) {
        final nombre = '${carga['nombre']} ${carga['apellido']}'.toLowerCase();
        final rut = carga['rut'].toString().toLowerCase();
        final titular = carga['titular'].toString().toLowerCase();
        return nombre.contains(query) || rut.contains(query) || titular.contains(query);
      }).toList();
    }

    if (selectedFilter.value != 'todos') {
      final filter = selectedFilter.value.toLowerCase();
      filtered = filtered.where((carga) =>
          carga['parentesco'].toLowerCase() == filter).toList();
    }

    if (selectedStatus.value == 'activas') {
      filtered = filtered.where((carga) => carga['estado'] == 'Activa').toList();
    } else if (selectedStatus.value == 'inactivas') {
      filtered = filtered.where((carga) => carga['estado'] != 'Activa').toList();
    }

    filteredCargas.value = filtered;
  }

  // ========== CRUD ==========
  Future<void> refreshCargas() async {
    isLoading.value = true;
    
    // Simular carga de datos
    await Future.delayed(const Duration(milliseconds: 800));
    
    // Recargar datos (en caso real sería desde API/BD)
    _loadSampleData();
    
    isLoading.value = false;
    
    Get.snackbar(
      'Actualizado',
      'Lista de cargas familiares actualizada',
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }

  Future<void> addNewCarga() async {
    if (_isDialogOpen) return;

    final context = Get.context;
    if (context == null) {
      Get.snackbar(
        'Error',
        'No se puede abrir el formulario. Intente nuevamente.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

  }

  void editCarga() {
    if (selectedCarga.value != null) {
      Get.snackbar('Editar', 'Función para editar: ${selectedCarga.value!['nombre']}');
    }
  }

  void deleteCarga() {
    if (selectedCarga.value != null) {
      Get.snackbar('Eliminar', 'Función para eliminar: ${selectedCarga.value!['nombre']}');
    }
  }

  void transferCarga() {
    if (selectedCarga.value != null) {
      Get.snackbar('Transferir', 'Función para transferir: ${selectedCarga.value!['nombre']}');
    }
  }

  void generateCarnet() {
    if (selectedCarga.value != null) {
      Get.snackbar('Carnet', 'Generar carnet para: ${selectedCarga.value!['nombre']}');
    }
  }

  void updateMedicalInfo() {
    if (selectedCarga.value != null) {
      Get.snackbar('Médico', 'Actualizar info médica: ${selectedCarga.value!['nombre']}');
    }
  }

  void viewHistory() {
    if (selectedCarga.value != null) {
      Get.snackbar('Historial', 'Ver historial de: ${selectedCarga.value!['nombre']}');
    }
  }

  // ========== DATOS SIMULADOS ==========
  void _loadSampleData() {
    cargasList.value = [
      {
        'id': '1',
        'nombre': 'María Elena',
        'apellido': 'González Pérez',
        'rut': '12345678-9',
        'parentesco': 'Hija',
        'fechaNacimiento': '15/05/2015',
        'edad': 9,
        'estado': 'Activa',
        'plan': 'VIP',
        'titular': 'Juan Carlos González',
        'titularRut': '87654321-0',
        'telefono': '+56 9 1234 5678',
        'email': 'juan.gonzalez@email.com',
        'direccion': 'Av. Principal 123, Santiago',
        'fechaIngreso': '01/03/2020',
        'ultimaVisita': '20/06/2025',
        'proximaCita': '20/07/2025',
        'alertas': ['Control pendiente'],
        'documentos': {
          'certificadoNacimiento': true,
          'autorizacionMenor': true,
          'fichaIngreso': true,
        },
        'contactoEmergencia': {
          'nombre': 'Ana María Pérez',
          'telefono': '+56 9 8765 4321',
          'relacion': 'Abuela'
        }
      },
      {
        'id': '2',
        'nombre': 'Carlos Alberto',
        'apellido': 'González Martínez',
        'rut': '98765432-1',
        'parentesco': 'Padre',
        'fechaNacimiento': '28/07/1952',
        'edad': 72,
        'estado': 'Activa',
        'plan': 'Senior',
        'titular': 'Juan Carlos González',
        'titularRut': '87654321-0',
        'telefono': '+56 9 1234 5678',
        'email': 'juan.gonzalez@email.com',
        'direccion': 'Av. Principal 123, Santiago',
        'fechaIngreso': '15/01/2021',
        'ultimaVisita': '02/06/2025',
        'proximaCita': '25/06/2025',
        'alertas': ['Tratamiento activo', 'Documentos por vencer'],
        'documentos': {
          'cedula': true,
          'certificadoMedico': false,
          'fichaIngreso': true,
        },
        'contactoEmergencia': {
          'nombre': 'Elena Martínez',
          'telefono': '+56 9 5555 4444',
          'relacion': 'Esposa'
        }
      },
      {
        'id': '3',
        'nombre': 'Ana Patricia',
        'apellido': 'González López',
        'rut': '76543210-9',
        'parentesco': 'Cónyuge',
        'fechaNacimiento': '22/11/1987',
        'edad': 37,
        'estado': 'Activa',
        'plan': 'Familiar',
        'titular': 'Juan Carlos González',
        'titularRut': '87654321-0',
        'telefono': '+56 9 1234 5678',
        'email': 'ana.gonzalez@email.com',
        'direccion': 'Av. Principal 123, Santiago',
        'fechaIngreso': '01/03/2020',
        'ultimaVisita': '25/05/2025',
        'proximaCita': '15/08/2025',
        'alertas': [],
        'documentos': {
          'cedula': true,
          'certificadoMatrimonio': true,
          'fichaIngreso': true,
        },
        'contactoEmergencia': {
          'nombre': 'María López',
          'telefono': '+56 9 3333 2222',
          'relacion': 'Madre'
        }
      },
      {
        'id': '4',
        'nombre': 'Diego Andrés',
        'apellido': 'González López',
        'rut': '23456789-1',
        'parentesco': 'Hijo',
        'fechaNacimiento': '03/03/2018',
        'edad': 7,
        'estado': 'Activa',
        'plan': 'Infantil',
        'titular': 'Juan Carlos González',
        'titularRut': '87654321-0',
        'telefono': '+56 9 1234 5678',
        'email': 'juan.gonzalez@email.com',
        'direccion': 'Av. Principal 123, Santiago',
        'fechaIngreso': '01/03/2020',
        'ultimaVisita': '15/06/2025',
        'proximaCita': '15/09/2025',
        'alertas': [],
        'documentos': {
          'certificadoNacimiento': true,
          'autorizacionMenor': true,
          'fichaIngreso': true,
        },
        'contactoEmergencia': {
          'nombre': 'Ana Patricia González',
          'telefono': '+56 9 1234 5678',
          'relacion': 'Madre'
        }
      },
      {
        'id': '5',
        'nombre': 'Roberto Luis',
        'apellido': 'Martínez Silva',
        'rut': '34567890-2',
        'parentesco': 'Hijo',
        'fechaNacimiento': '10/12/2010',
        'edad': 14,
        'estado': 'Suspendida',
        'plan': 'Básico',
        'titular': 'Luis Martínez Rojas',
        'titularRut': '11223344-5',
        'telefono': '+56 9 9999 8888',
        'email': 'luis.martinez@email.com',
        'direccion': 'Calle Secundaria 456, Valparaíso',
        'fechaIngreso': '10/08/2022',
        'ultimaVisita': '01/04/2025',
        'proximaCita': null,
        'alertas': ['Estado suspendido', 'Documentos incompletos'],
        'documentos': {
          'certificadoNacimiento': true,
          'autorizacionMenor': false,
          'fichaIngreso': false,
        },
        'contactoEmergencia': {
          'nombre': 'Carmen Silva',
          'telefono': '+56 9 7777 6666',
          'relacion': 'Madre'
        }
      },
    ];

    _applyFilters();
  }

  // ========== GETTERS ==========
  bool get hasSelectedCarga => selectedCarga.value != null;
  bool get isListView => currentView.value == listaView;
  bool get isDetailView => currentView.value == detalleView;
  bool get hasSearchQuery => searchQuery.value.isNotEmpty;

  int get totalCargas => cargasList.length;
  int get cargasActivas => cargasList.where((c) => c['estado'] == 'Activa').length;
  int get filteredCount => filteredCargas.length;
}