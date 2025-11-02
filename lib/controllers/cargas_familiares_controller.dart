import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as dev;
import '../models/carga_familiar.dart';

class CargasFamiliaresController extends GetxController {
  RxBool isLoading = false.obs;
  RxList<Map<String, dynamic>> filteredCargas = <Map<String, dynamic>>[].obs;
  RxList<Map<String, dynamic>> allCargas = <Map<String, dynamic>>[].obs;
  RxList<CargaFamiliar> cargasFamiliares = <CargaFamiliar>[].obs;
  Rxn<Map<String, dynamic>> selectedCargaMap = Rxn<Map<String, dynamic>>();
  Rxn<CargaFamiliar> selectedCarga = Rxn<CargaFamiliar>();
  RxString searchText = ''.obs;

  @override
  void onInit() {
    super.onInit();
    dev.log('INICIANDO CONTROLADOR CARGAS', name: 'CargasFamiliaresController');
    loadCargas();
  }

  Future<void> loadCargas() async {
    try {
      isLoading.value = true;
      dev.log('INTENTANDO CARGAR DE FIRESTORE', name: 'CargasFamiliaresController');

      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('cargas_familiares')
          .get()
          .timeout(const Duration(seconds: 5));

      dev.log('DOCUMENTOS EN FIRESTORE: ${snapshot.docs.length}', name: 'CargasFamiliaresController');

      List<Map<String, dynamic>> cargasReales = [];
      List<CargaFamiliar> cargasModelos = [];
      
      for (var doc in snapshot.docs) {
        try {
          final data = doc.data() as Map<String, dynamic>;
          final carga = CargaFamiliar.fromMap(data, doc.id);

          final Map<String, dynamic> cargaMap = carga.toMap();
          cargaMap['id'] = carga.id;
          cargaMap['edad'] = carga.edad;
          cargaMap['estado'] = carga.estado;
          cargaMap['rutFormateado'] = carga.rutFormateado;
          cargaMap['nombreCompleto'] = carga.nombreCompleto;
          cargaMap['fechaNacimientoFormateada'] = carga.fechaNacimientoFormateada;
          cargaMap['fechaCreacionFormateada'] = carga.fechaCreacionFormateada;

          cargasReales.add(cargaMap);
          cargasModelos.add(carga);

          dev.log('CARGA REAL: ${carga.nombreCompleto}', name: 'CargasFamiliaresController');
        } catch (e) {
          dev.log('ERROR EN DOC ${doc.id}: $e', name: 'CargasFamiliaresController', error: e);
        }
      }

      allCargas.value = cargasReales;
      filteredCargas.value = cargasReales;
      cargasFamiliares.value = cargasModelos;
      
      dev.log('CARGAS REALES CARGADAS: ${cargasReales.length}', name: 'CargasFamiliaresController');
    } catch (e) {
      dev.log('ERROR CONECTANDO FIRESTORE O CARGANDO DATOS: $e', name: 'CargasFamiliaresController', error: e);
      allCargas.value = [];
      filteredCargas.value = [];
      cargasFamiliares.value = [];
    } finally {
      isLoading.value = false;
      dev.log('CARGA FINALIZADA: ${filteredCargas.length} cargas', name: 'CargasFamiliaresController');
    }
  }

  void searchCargas(String query) {
    searchText.value = query;
    dev.log('BUSCANDO: "$query"', name: 'CargasFamiliaresController');

    if (query.isEmpty) {
      filteredCargas.value = allCargas.toList();
      dev.log('BÚSQUEDA VACÍA - MOSTRANDO TODAS: ${filteredCargas.length}', name: 'CargasFamiliaresController');
    } else {
      final queryLower = query.toLowerCase();
      filteredCargas.value = allCargas.where((carga) {
        final nombre = (carga['nombre'] ?? '').toString().toLowerCase();
        final apellido = (carga['apellido'] ?? '').toString().toLowerCase();
        final rut = (carga['rut'] ?? '').toString().toLowerCase();
        final rutFormateado = (carga['rutFormateado'] ?? '').toString().toLowerCase();
        final parentesco = (carga['parentesco'] ?? '').toString().toLowerCase();
        final nombreCompleto = (carga['nombreCompleto'] ?? '').toString().toLowerCase();

        return nombre.contains(queryLower) ||
            apellido.contains(queryLower) ||
            rut.contains(queryLower) ||
            rutFormateado.contains(queryLower) ||
            parentesco.contains(queryLower) ||
            nombreCompleto.contains(queryLower);
      }).toList();

      dev.log('RESULTADOS ENCONTRADOS: ${filteredCargas.length}', name: 'CargasFamiliaresController');
    }
  }

  void clearSearch() {
    searchText.value = '';
    filteredCargas.value = allCargas.toList();
    dev.log('BÚSQUEDA LIMPIADA - MOSTRANDO TODAS: ${filteredCargas.length}', name: 'CargasFamiliaresController');
  }

  void selectCarga(Map<String, dynamic> carga) {
    dev.log('SELECCIONANDO CARGA: ${carga['nombre']}', name: 'CargasFamiliaresController');
    selectedCargaMap.value = carga;
    
    final cargaId = carga['id'];
    if (cargaId != null) {
      final cargaModelo = cargasFamiliares.firstWhereOrNull((c) => c.id == cargaId);
      selectedCarga.value = cargaModelo;
    }
  }

  void backToList() {
    dev.log('VOLVIENDO A LISTA', name: 'CargasFamiliaresController');
    selectedCargaMap.value = null;
    selectedCarga.value = null;
  }

  Future<void> refreshCargas() async {
    dev.log('REFRESCANDO CARGAS', name: 'CargasFamiliaresController');
    await loadCargas();
  }

  void editCarga() {
    if (selectedCarga.value != null) {
      Get.snackbar('Editar', 'Editar: ${selectedCarga.value!.nombreCompleto}');
    }
  }

  void deleteCarga() {}
  void transferCarga() {}
  void generateCarnet() {}
  void updateMedicalInfo() {}
  void viewHistory() {}

  bool get hasSelectedCarga => selectedCarga.value != null;
  bool get isListView => !hasSelectedCarga;
  bool get isDetailView => hasSelectedCarga;
}