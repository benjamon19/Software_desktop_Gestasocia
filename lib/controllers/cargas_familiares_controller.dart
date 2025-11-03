import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import '../models/carga_familiar.dart';
import '../widgets/dashboard/modules/gestion_cargas_familiares/shared/dialogs/edit_carga_dialog.dart';
import '../widgets/dashboard/modules/gestion_cargas_familiares/shared/dialogs/transfer_carga_dialog.dart';

class CargasFamiliaresController extends GetxController {
  // ==================== ESTADO ====================
  final RxList<CargaFamiliar> _allCargasFamiliares = <CargaFamiliar>[].obs;
  RxList<CargaFamiliar> cargasFamiliares = <CargaFamiliar>[].obs;
  final RxList<Map<String, dynamic>> filteredCargas = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> allCargas = <Map<String, dynamic>>[].obs;
  final Rxn<CargaFamiliar> selectedCarga = Rxn<CargaFamiliar>();
  final RxBool isLoading = false.obs;
  final RxString searchText = ''.obs;
  final TextEditingController searchController = TextEditingController();
  Timer? _debounceTimer;

  // ==================== GETTERS ====================
  bool get hasSelectedCarga => selectedCarga.value != null;
  bool get hasCargas => cargasFamiliares.isNotEmpty;
  CargaFamiliar? get currentCarga => selectedCarga.value;
  int get totalAllCargas => allCargas.length;
  int get totalCargas => cargasFamiliares.length;
  int get totalCargasActivas => _allCargasFamiliares.where((c) => c.estaActivo).length;

  // ==================== INICIALIZACIÓN ====================
  @override
  void onInit() {
    super.onInit();

    searchText.listen((query) {
      if (_debounceTimer == null || !_debounceTimer!.isActive) {
        _debounceTimer?.cancel();
        _debounceTimer = Timer(const Duration(milliseconds: 100), () {
          _filterCargas();
        });
      }
    });

    searchController.addListener(() {
      searchText.value = searchController.text;
    });

    loadCargas();
  }

  @override
  void onClose() {
    _debounceTimer?.cancel();
    searchController.dispose();
    super.onClose();
  }

  // ==================== CARGA DE DATOS ====================
  Future<void> loadCargas() async {
    try {
      isLoading.value = true;

      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('cargas_familiares')
          .get();

      _allCargasFamiliares.clear();
      cargasFamiliares.clear();

      for (var doc in snapshot.docs) {
        final carga = CargaFamiliar.fromMap(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
        _allCargasFamiliares.add(carga);
        cargasFamiliares.add(carga);
      }

      _updateCargasLists();
    } catch (e) {
      debugPrint('Error al cargar cargas familiares: $e');
      _showErrorSnackbar("Error", "No se pudieron cargar las cargas familiares");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshCargas() async {
    await loadCargas();
    _showSuccessSnackbar('Actualizado', 'Lista de cargas actualizada');
  }

  // ==================== CONVERSIÓN Y ACTUALIZACIÓN ====================
  void _updateCargasLists() {
    final cargasMap = cargasFamiliares.map((carga) => _cargaToMap(carga)).toList();
    allCargas.value = cargasMap;
    filteredCargas.value = cargasMap;
  }

  Map<String, dynamic> _cargaToMap(CargaFamiliar carga) {
    return {
      'id': carga.id,
      'nombre': carga.nombre,
      'apellido': carga.apellido,
      'nombreCompleto': carga.nombreCompleto,
      'rut': carga.rut,
      'rutFormateado': carga.rutFormateado,
      'parentesco': carga.parentesco,
      'fechaNacimiento': carga.fechaNacimientoFormateada,
      'fechaCreacion': carga.fechaCreacionFormateada,
      'edad': carga.edad,
      'estado': carga.estado,
      'isActive': carga.isActive,
      'asociadoId': carga.asociadoId,
      'codigoBarras': carga.codigoBarras,
      'sap': carga.sap,
      'email': carga.email,
      'telefono': carga.telefono,
      'direccion': carga.direccion,
    };
  }

  // ==================== BÚSQUEDA Y FILTRADO ====================
  void _filterCargas() {
    // ========== AQUÍ IMPLEMENTAR BÚSQUEDA ==========
  }

  void clearSearchField() {
    // ========== AQUÍ IMPLEMENTAR BÚSQUEDA ==========
  }

  void resetFilter() {
    // ========== AQUÍ IMPLEMENTAR BÚSQUEDA ==========
  }

  // ==================== BÚSQUEDA EXACTA ====================
  Future<void> searchCargas(String searchTerm) async {
    // ========== AQUÍ IMPLEMENTAR BÚSQUEDA ==========
  }

  Future<void> _searchCargaByRut(String rut) async {
    // ========== AQUÍ IMPLEMENTAR BÚSQUEDA ==========
  }

  Future<void> _searchCargasBySAP(String sap) async {
    // ========== AQUÍ IMPLEMENTAR BÚSQUEDA ==========
  }

  Future<void> _filterCargasByAsociadoId(String asociadoId, String sap) async {
    // ========== AQUÍ IMPLEMENTAR BÚSQUEDA ==========
  }

  void clearSearch() {
    // ========== AQUÍ IMPLEMENTAR BÚSQUEDA ==========
  }

  // ==================== NAVEGACIÓN ====================
  void selectCarga(Map<String, dynamic> cargaMap) {
    final carga = cargasFamiliares.firstWhereOrNull(
      (c) => c.id == cargaMap['id'],
    );

    if (carga != null) {
      selectedCarga.value = carga;
      searchText.value = '';
    }
  }

  void backToList() {
    selectedCarga.value = null;
    resetFilter();
    clearSearchField();
  }

  // ==================== ACCIONES CRUD ====================
  void editCarga() {
    if (selectedCarga.value == null) {
      _showErrorSnackbar('Error', 'No hay carga seleccionada');
      return;
    }

    final context = Get.context;
    if (context != null) {
      EditCargaDialog.show(context, selectedCarga.value!);
    } else {
      _showErrorSnackbar("Error", "No se pudo abrir el formulario de edición");
    }
  }

  Future<bool> updateCarga(CargaFamiliar cargaActualizada) async {
    try {
      isLoading.value = true;

      if (cargaActualizada.id == null) {
        _showErrorSnackbar("Error", "No se puede actualizar: ID de carga no válido");
        return false;
      }

      final cargaConActividad = cargaActualizada.actualizarActividad();

      await FirebaseFirestore.instance
          .collection('cargas_familiares')
          .doc(cargaConActividad.id)
          .update(cargaConActividad.toMap());

      final index = _allCargasFamiliares.indexWhere((c) => c.id == cargaConActividad.id);
      if (index != -1) {
        _allCargasFamiliares[index] = cargaConActividad;
        cargasFamiliares[index] = cargaConActividad;
      }

      _updateCargasLists();

      selectedCarga.value = null;
      await Future.delayed(const Duration(milliseconds: 50));
      selectedCarga.value = cargaConActividad;

      _showSuccessSnackbar("Éxito!", "Carga familiar actualizada correctamente");

      return true;
    } catch (e) {
      debugPrint('Error al actualizar carga: $e');
      _showErrorSnackbar("Error", "No se pudo actualizar la carga familiar");
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteCarga() async {
    if (selectedCarga.value?.id == null) {
      _showErrorSnackbar('Error', 'No hay carga seleccionada');
      return;
    }

    try {
      isLoading.value = true;

      final cargaId = selectedCarga.value!.id!;

      await FirebaseFirestore.instance
          .collection('cargas_familiares')
          .doc(cargaId)
          .delete();

      _allCargasFamiliares.removeWhere((c) => c.id == cargaId);
      cargasFamiliares.removeWhere((c) => c.id == cargaId);

      _updateCargasLists();

      selectedCarga.value = null;
      searchText.value = '';

      _showSuccessSnackbar('Eliminado', 'Carga familiar eliminada correctamente');
    } catch (e) {
      debugPrint('Error al eliminar carga: $e');
      _showErrorSnackbar('Error', 'No se pudo eliminar la carga familiar');
    } finally {
      isLoading.value = false;
    }
  }

  // ==================== MÉTODOS DE INTERFAZ ====================
  void transferCarga() {
    if (selectedCarga.value == null) {
      _showErrorSnackbar('Error', 'No hay carga seleccionada');
      return;
    }

    final context = Get.context;
    if (context != null) {
      TransferCargaDialog.show(context, selectedCarga.value!);
    } else {
      _showErrorSnackbar('Error', 'No se pudo abrir el diálogo de transferencia');
    }
  }

  void generateCarnet() {
    if (selectedCarga.value == null) {
      _showErrorSnackbar('Error', 'No hay carga seleccionada');
      return;
    }

    _showInfoSnackbar('Información', 'Funcionalidad en desarrollo');
  }

  void viewHistory() {
    if (selectedCarga.value == null) {
      _showErrorSnackbar('Error', 'No hay carga seleccionada');
      return;
    }

    _showInfoSnackbar('Información', 'Funcionalidad en desarrollo');
  }

  void updateMedicalInfo() {
    if (selectedCarga.value == null) {
      _showErrorSnackbar('Error', 'No hay carga seleccionada');
      return;
    }

    _showInfoSnackbar('Información', 'Funcionalidad en desarrollo');
  }

  // ==================== HELPERS ====================
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
      backgroundColor: const Color(0xFF10B981).withValues(alpha: 0.8),
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );
  }

  void _showInfoSnackbar(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF10B981).withValues(alpha: 0.8),
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }
}
