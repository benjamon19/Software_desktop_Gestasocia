import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import '../models/asociado.dart';
import '../models/carga_familiar.dart';
import '../controllers/historial_controller.dart';
import '../widgets/dashboard/modules/gestion_asociados/shared/dialogs/new_asociado_dialog.dart';
import '../widgets/dashboard/modules/gestion_asociados/shared/dialogs/edit_asociado_dialog.dart';
import '../widgets/dashboard/modules/gestion_asociados/shared/dialogs/new_carga_familiar_dialog.dart';
import '../widgets/dashboard/modules/gestion_asociados/shared/dialogs/barcode_search_dialog.dart';
import '../widgets/dashboard/modules/gestion_asociados/shared/dialogs/historial_dialog.dart';

class AsociadosController extends GetxController {
  RxBool isLoading = false.obs;
  Rxn<Asociado> selectedAsociado = Rxn<Asociado>();
  RxString searchQuery = ''.obs;

  final RxList<Asociado> _allAsociados = <Asociado>[].obs;
  RxList<Asociado> asociados = <Asociado>[].obs;
  RxList<CargaFamiliar> cargasFamiliares = <CargaFamiliar>[].obs;

  final GlobalKey<State<StatefulWidget>> searchFieldKey = GlobalKey();
  Timer? _debounceTimer;

  @override
  void onInit() {
    super.onInit();
    
    searchQuery.listen((query) {
      if (_debounceTimer == null || !_debounceTimer!.isActive) {
        _debounceTimer?.cancel();
        _debounceTimer = Timer(const Duration(milliseconds: 100), () {
          _filterAsociados(query);
        });
      }
    });
    
    loadAsociados();
    loadAllCargasFamiliares();
  }

  @override
  void onClose() {
    _debounceTimer?.cancel();
    super.onClose();
  }

  // ========== MÉTODOS DE BÚSQUEDA Y FILTRADO ==========

  void _filterAsociados(String query) {
    if (query.isEmpty) {
      asociados.value = List.from(_allAsociados);
      return;
    }

    final queryLower = query.toLowerCase();
    final querySinFormato = query.replaceAll(RegExp(r'[^0-9kK]'), '').toLowerCase();
    
    final filteredList = _allAsociados.where((asociado) {
      final rutSinFormato = asociado.rut.replaceAll(RegExp(r'[^0-9kK]'), '').toLowerCase();
      final nombreCompleto = asociado.nombreCompleto.toLowerCase();
      final email = asociado.email.toLowerCase();
      final sap = (asociado.sap ?? '').toLowerCase();
      
      return rutSinFormato.contains(querySinFormato) || 
             nombreCompleto.contains(queryLower) ||
             email.contains(queryLower) ||
             sap.contains(queryLower);
    }).toList();

    asociados.value = filteredList;
  }

  void onSearchQueryChanged(String query) {
    _debounceTimer?.cancel();
    _filterAsociadosImmediate(query);
  }
  
  void _filterAsociadosImmediate(String query) {
    if (query.isEmpty) {
      asociados.value = List.from(_allAsociados);
      asociados.refresh();
      return;
    }

    final queryLower = query.toLowerCase();
    final querySinFormato = query.replaceAll(RegExp(r'[^0-9kK]'), '').toLowerCase();
    
    final filteredList = _allAsociados.where((asociado) {
      final rutSinFormato = asociado.rut.replaceAll(RegExp(r'[^0-9kK]'), '').toLowerCase();
      final nombreCompleto = asociado.nombreCompleto.toLowerCase();
      final email = asociado.email.toLowerCase();
      final sap = (asociado.sap ?? '').toLowerCase();
      
      return rutSinFormato.contains(querySinFormato) || 
             nombreCompleto.contains(queryLower) ||
             email.contains(queryLower) ||
             sap.contains(queryLower);
    }).toList();

    asociados.value = filteredList;
    asociados.refresh();
  }

  void resetFilter() {
    searchQuery.value = '';
    _filterAsociadosImmediate('');
  }
  
  void clearSearchField() {
    try {
      if (!Get.isRegistered<AsociadosController>()) return;
      
      final dynamic searchField = searchFieldKey.currentState;
      
      if (searchField != null && searchField is State && searchField.mounted) {
        if (searchField.runtimeType.toString().contains('_RutSearchFieldState')) {
          (searchField as dynamic).clearField();
        }
      }
    } catch (e) {
      // Error silencioso
    }
  }

  // ========== GESTIÓN DE ASOCIADOS ==========

  Future<void> loadAsociados() async {
    try {
      isLoading.value = true;
      
      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('asociados')
          .get();
      
      _allAsociados.clear();
      for (var doc in snapshot.docs) {
        final asociado = Asociado.fromMap(
          doc.data() as Map<String, dynamic>, 
          doc.id
        );
        _allAsociados.add(asociado);
      }
      
      _filterAsociados(searchQuery.value);
      
    } catch (e) {
      _showErrorSnackbar("Error", "No se pudieron cargar los asociados: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> createAsociado({
    required String nombre,
    required String apellido,
    required String rut,
    required DateTime fechaNacimiento,
    required String estadoCivil,
    required String email,
    required String telefono,
    required String direccion,
    required String plan,
  }) async {
    try {
      isLoading.value = true;

      if (!Asociado.validarRUT(rut)) {
        _showErrorSnackbar("Error", "RUT inválido. Formato: 12345678-9");
        return false;
      }

      if (!Asociado.validarEmail(email)) {
        _showErrorSnackbar("Error", "Email inválido");
        return false;
      }

      final existingAsociado = _allAsociados.firstWhereOrNull(
        (asociado) => asociado.rut == rut
      );
      
      if (existingAsociado != null) {
        _showErrorSnackbar("Error", "Ya existe un asociado con este RUT");
        return false;
      }

      final ahora = DateTime.now();
      final nuevoAsociado = Asociado(
        nombre: nombre.trim(),
        apellido: apellido.trim(),
        rut: rut.trim(),
        fechaNacimiento: fechaNacimiento,
        estadoCivil: estadoCivil,
        email: email.trim().toLowerCase(),
        telefono: telefono.trim(),
        direccion: direccion.trim(),
        plan: plan,
        fechaCreacion: ahora,
        fechaIngreso: ahora,
        isActive: true,
        ultimaActividad: ahora,
      );

      final docRef = await FirebaseFirestore.instance
          .collection('asociados')
          .add(nuevoAsociado.toMap());

      final asociadoConId = nuevoAsociado.copyWith(id: docRef.id);
      _allAsociados.add(asociadoConId);
      selectedAsociado.value = asociadoConId;
      searchQuery.value = '';

      _showSuccessSnackbar("Éxito", "Asociado creado correctamente");
      
      _registrarCreacion(docRef.id, asociadoConId);
      
      return true;

    } catch (e) {
      _showErrorSnackbar("Error", "No se pudo crear el asociado: ${e.toString()}");
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> searchAsociado(String searchTerm) async {
    if (searchTerm.isEmpty) {
      selectedAsociado.value = null;
      searchQuery.value = '';
      return;
    }
    
    isLoading.value = true;

    try {
      final cleanSearchTerm = searchTerm.trim();
      
      final asociado = _allAsociados.firstWhereOrNull(
        (asociado) {
          if (asociado.sap == cleanSearchTerm) return true;
          if (asociado.rut == cleanSearchTerm) return true;
          if (asociado.rutFormateado == cleanSearchTerm) return true;
          
          final rutSinGuion = asociado.rut.replaceAll('-', '');
          final searchSinGuion = cleanSearchTerm.replaceAll('-', '');
          if (rutSinGuion == searchSinGuion) return true;
          
          if (asociado.codigoBarras == cleanSearchTerm) return true;
          
          return false;
        }
      );

      if (asociado != null) {
        selectedAsociado.value = asociado;
        searchQuery.value = '';
        
        if (cargasFamiliares.isEmpty) {
          await loadAllCargasFamiliares();
        }
        
        _showSuccessSnackbar("Encontrado", "Asociado encontrado: ${asociado.nombreCompleto}");
      } else {
        QuerySnapshot snapshot = await FirebaseFirestore.instance
            .collection('asociados')
            .where('rut', isEqualTo: cleanSearchTerm)
            .limit(1)
            .get();

        if (snapshot.docs.isEmpty) {
          snapshot = await FirebaseFirestore.instance
              .collection('asociados')
              .where('codigoBarras', isEqualTo: cleanSearchTerm)
              .limit(1)
              .get();
        }
        
        if (snapshot.docs.isEmpty) {
          snapshot = await FirebaseFirestore.instance
              .collection('asociados')
              .where('sap', isEqualTo: cleanSearchTerm)
              .limit(1)
              .get();
        }

        if (snapshot.docs.isNotEmpty) {
          final doc = snapshot.docs.first;
          final asociadoEncontrado = Asociado.fromMap(
            doc.data() as Map<String, dynamic>, 
            doc.id
          );
          
          selectedAsociado.value = asociadoEncontrado;
          searchQuery.value = '';
          
          if (!_allAsociados.any((a) => a.id == asociadoEncontrado.id)) {
            _allAsociados.add(asociadoEncontrado);
            _filterAsociados(searchQuery.value);
          }
          
          if (cargasFamiliares.isEmpty) {
            await loadAllCargasFamiliares();
          }
          
          _showSuccessSnackbar("Encontrado", "Asociado encontrado: ${asociadoEncontrado.nombreCompleto}");
        } else {
          selectedAsociado.value = null;
          _showErrorSnackbar("No encontrado", "No se encontró ningún asociado con: $cleanSearchTerm");
        }
      }
    } catch (e) {
      _showErrorSnackbar("Error", "Error al buscar asociado");
      selectedAsociado.value = null;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateAsociado(Asociado asociado) async {
    try {
      isLoading.value = true;

      if (asociado.id == null) {
        _showErrorSnackbar("Error", "No se puede actualizar: ID de asociado no válido");
        return false;
      }

      final asociadoAnterior = _allAsociados.firstWhere((a) => a.id == asociado.id);
      
      final asociadoActualizado = asociado.actualizarActividad();

      await FirebaseFirestore.instance
          .collection('asociados')
          .doc(asociadoActualizado.id)
          .update(asociadoActualizado.toMap());

      final index = _allAsociados.indexWhere((a) => a.id == asociadoActualizado.id);
      if (index != -1) {
        _allAsociados[index] = asociadoActualizado;
        _filterAsociados(searchQuery.value);
      }

      selectedAsociado.value = null;
      await Future.delayed(const Duration(milliseconds: 50));
      selectedAsociado.value = asociadoActualizado;

      _showSuccessSnackbar("Éxito", "Asociado actualizado correctamente");
      
      _registrarEdicion(asociadoAnterior, asociadoActualizado);
      
      return true;

    } catch (e) {
      _showErrorSnackbar("Error", "No se pudo actualizar el asociado");
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> deleteAsociadoById(String id) async {
    try {
      isLoading.value = true;

      await FirebaseFirestore.instance
          .collection('asociados')
          .doc(id)
          .delete();

      _allAsociados.removeWhere((asociado) => asociado.id == id);
      _filterAsociados(searchQuery.value);

      if (selectedAsociado.value?.id == id) {
        selectedAsociado.value = null;
        searchQuery.value = '';
        cargasFamiliares.removeWhere((carga) => carga.asociadoId == id);
      }

      _showSuccessSnackbar("Eliminado", "Asociado eliminado correctamente");
      return true;

    } catch (e) {
      _showErrorSnackbar("Error", "No se pudo eliminar el asociado");
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // ========== CARGAS FAMILIARES ==========

  Future<void> loadAllCargasFamiliares() async {
    try {
      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('cargas_familiares')
          .get();
      
      cargasFamiliares.clear();
      for (var doc in snapshot.docs) {
        final carga = CargaFamiliar.fromMap(
          doc.data() as Map<String, dynamic>, 
          doc.id
        );
        cargasFamiliares.add(carga);
      }
    } catch (e) {
      // Error silencioso
    }
  }

  Future<void> loadCargasFamiliares() async {
    if (cargasFamiliares.isNotEmpty) {
      return;
    }
    await loadAllCargasFamiliares();
  }

  Future<bool> createCargaFamiliar({
    required String nombre,
    required String apellido,
    required String rut,
    required String parentesco,
    required DateTime fechaNacimiento,
  }) async {
    if (selectedAsociado.value?.id == null) {
      _showErrorSnackbar("Error", "No hay asociado seleccionado");
      return false;
    }

    try {
      isLoading.value = true;

      if (!CargaFamiliar.validarRUT(rut)) {
        _showErrorSnackbar("Error", "RUT inválido. Formato: 12345678-9");
        return false;
      }

      final existingCarga = cargasFamiliares.firstWhereOrNull(
        (carga) => carga.rut == rut
      );
      
      if (existingCarga != null) {
        _showErrorSnackbar("Error", "Ya existe una carga familiar con este RUT");
        return false;
      }

      final ahora = DateTime.now();
      final nuevaCarga = CargaFamiliar(
        asociadoId: selectedAsociado.value!.id!,
        nombre: nombre.trim(),
        apellido: apellido.trim(),
        rut: rut.trim(),
        parentesco: parentesco,
        fechaNacimiento: fechaNacimiento,
        fechaCreacion: ahora,
        isActive: true,
        ultimaActividad: ahora,
      );

      final docRef = await FirebaseFirestore.instance
          .collection('cargas_familiares')
          .add(nuevaCarga.toMap());

      final cargaConId = nuevaCarga.copyWith(id: docRef.id);
      cargasFamiliares.add(cargaConId);

      final asociadoActualizado = selectedAsociado.value!.actualizarActividad();
      await FirebaseFirestore.instance
          .collection('asociados')
          .doc(asociadoActualizado.id)
          .update({'ultimaActividad': asociadoActualizado.ultimaActividad});
      
      final index = _allAsociados.indexWhere((a) => a.id == asociadoActualizado.id);
      if (index != -1) {
        _allAsociados[index] = asociadoActualizado;
      }
      selectedAsociado.value = asociadoActualizado;

      _showSuccessSnackbar("Éxito", "Carga familiar agregada correctamente");
      
      _registrarCargaAgregada(selectedAsociado.value!.id!, cargaConId);
      
      return true;

    } catch (e) {
      _showErrorSnackbar("Error", "No se pudo crear la carga familiar: ${e.toString()}");
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // ========== MÉTODOS DE INTERFAZ ==========

  Future<void> biometricSearch() async {
    isLoading.value = true;
    try {
      await Future.delayed(const Duration(seconds: 3));
      if (_allAsociados.isNotEmpty) {
        final primerAsociado = _allAsociados.first;
        await searchAsociado(primerAsociado.rut);
      } else {
        _showErrorSnackbar("Sin datos", "No hay asociados registrados para la búsqueda biométrica");
      }
    } catch (e) {
      _showErrorSnackbar("Error", "Error en búsqueda biométrica");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> qrCodeSearch() async {
    final context = Get.context;
    if (context != null) {
      BarcodeSearchDialog.show(context);
    } else {
      _showErrorSnackbar("Error", "No se pudo abrir el escáner de código de barras");
    }
  }

  void clearSearch() {
    selectedAsociado.value = null;
    searchQuery.value = '';
  }

  void newAsociado() {
    NewAsociadoDialog.show(Get.context!);
  }

  void editAsociado() {
    if (selectedAsociado.value != null) {
      final context = Get.context;
      if (context != null) {
        EditAsociadoDialog.show(context, selectedAsociado.value!);
      } else {
        _showErrorSnackbar("Error", "No se pudo abrir el formulario de edición");
      }
    } else {
      _showErrorSnackbar("Error", "No hay asociado seleccionado para editar");
    }
  }

  void addCarga() {
    if (selectedAsociado.value != null) {
      final context = Get.context;
      if (context != null) {
        NewCargaFamiliarDialog.show(
          context, 
          selectedAsociado.value!.id ?? '',
          selectedAsociado.value!.nombreCompleto,
        );
      } else {
        _showErrorSnackbar("Error", "No se pudo abrir el formulario de carga familiar");
      }
    } else {
      _showErrorSnackbar("Error", "No hay asociado seleccionado para agregar carga familiar");
    }
  }

  void deleteAsociado() {
    if (selectedAsociado.value?.id != null) {
      deleteAsociadoById(selectedAsociado.value!.id!);
    }
  }

  void viewHistory() {
    if (selectedAsociado.value?.id != null) {
      final context = Get.context;
      if (context != null) {
        HistorialDialog.show(
          context,
          asociadoId: selectedAsociado.value!.id!,
          nombreAsociado: selectedAsociado.value!.nombreCompleto,
        );
      } else {
        _showErrorSnackbar('Error', 'No se pudo abrir el historial');
      }
    } else {
      _showErrorSnackbar('Error', 'No hay asociado seleccionado');
    }
  }

  // ========== CÓDIGO DE BARRAS ==========

  Future<bool> updateAsociadoBarcode(String asociadoId, String codigoBarras) async {
    try {
      final asociado = _allAsociados.firstWhereOrNull((a) => a.id == asociadoId);
      if (asociado == null) return false;

      final asociadoActualizado = asociado.copyWith(
        codigoBarras: codigoBarras,
        ultimaActividad: DateTime.now(),
      );

      await FirebaseFirestore.instance
          .collection('asociados')
          .doc(asociadoId)
          .update(asociadoActualizado.toMap());
      
      if (selectedAsociado.value?.id == asociadoId) {
        selectedAsociado.value = asociadoActualizado;
        selectedAsociado.refresh();
      }
      
      final index = asociados.indexWhere((a) => a.id == asociadoId);
      if (index != -1) {
        asociados[index] = asociadoActualizado;
        asociados.refresh();
      }

      final allIndex = _allAsociados.indexWhere((a) => a.id == asociadoId);
      if (allIndex != -1) {
        _allAsociados[allIndex] = asociadoActualizado;
      }
      
      Get.snackbar(
        'Éxito',
        'Código de barras generado correctamente',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF059669).withValues(alpha: 0.8),
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
        margin: const EdgeInsets.all(16),
        borderRadius: 8,
      );
      
      _registrarCodigoBarras(asociadoId, codigoBarras);
      
      return true;
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudo generar el código de barras',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error.withValues(alpha: 0.8),
        colorText: Get.theme.colorScheme.onError,
        margin: const EdgeInsets.all(16),
        borderRadius: 8,
      );
      
      return false;
    }
  }

  // ========== MÉTODOS SAP ==========

  Future<String> _generateUniqueSAP() async {
    String sap = '';
    bool exists = true;
    
    while (exists) {
      sap = (10000 + Random().nextInt(90000)).toString();
      exists = _allAsociados.any((a) => a.sap == sap);
      
      if (!exists) {
        final snapshot = await FirebaseFirestore.instance
            .collection('asociados')
            .where('sap', isEqualTo: sap)
            .limit(1)
            .get();
        
        exists = snapshot.docs.isNotEmpty;
      }
    }
    
    return sap;
  }

  Future<void> generateSAPForAllAsociados() async {
    try {
      isLoading.value = true;
      
      int generated = 0;
      int total = _allAsociados.where((a) => a.sap == null || a.sap!.isEmpty).length;
      
      if (total == 0) {
        _showSuccessSnackbar('Información', 'Todos los asociados ya tienen código SAP');
        return;
      }
      
      Get.snackbar(
        'Generando SAP',
        'Generando códigos para $total asociados...',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
        showProgressIndicator: true,
      );
      
      for (var asociado in _allAsociados) {
        if (asociado.id != null && (asociado.sap == null || asociado.sap!.isEmpty)) {
          final sap = await _generateUniqueSAP();
          
          final asociadoActualizado = asociado.copyWith(
            sap: sap,
            ultimaActividad: DateTime.now(),
          );

          await FirebaseFirestore.instance
              .collection('asociados')
              .doc(asociado.id)
              .update(asociadoActualizado.toMap());
          
          final index = _allAsociados.indexWhere((a) => a.id == asociado.id);
          if (index != -1) {
            _allAsociados[index] = asociadoActualizado;
          }
          
          _registrarSAP(asociado.id!, sap);
          generated++;
        }
      }
      
      _filterAsociados(searchQuery.value);
      
      _showSuccessSnackbar(
        'Completado', 
        'Se generaron $generated códigos SAP correctamente'
      );
      
    } catch (e) {
      _showErrorSnackbar('Error', 'Error al generar códigos SAP masivos');
    } finally {
      isLoading.value = false;
    }
  }

  // ========== HISTORIAL ==========

  void _registrarCreacion(String asociadoId, Asociado asociado) {
    try {
      final historialController = Get.put(HistorialController());
      historialController.registrarCreacion(
        asociadoId: asociadoId,
        asociado: asociado,
      );
    } catch (e) {
      // Error silencioso
    }
  }

  void _registrarEdicion(Asociado asociadoAnterior, Asociado asociadoNuevo) {
    try {
      final historialController = Get.put(HistorialController());
      historialController.registrarEdicion(
        asociadoId: asociadoNuevo.id!,
        asociadoAnterior: asociadoAnterior,
        asociadoNuevo: asociadoNuevo,
      );
    } catch (e) {
      // Error silencioso
    }
  }

  void _registrarCargaAgregada(String asociadoId, CargaFamiliar carga) {
    try {
      final historialController = Get.put(HistorialController());
      historialController.registrarCargaAgregada(
        asociadoId: asociadoId,
        carga: carga,
      );
    } catch (e) {
      // Error silencioso
    }
  }

  void _registrarCodigoBarras(String asociadoId, String codigoBarras) {
    try {
      final historialController = Get.put(HistorialController());
      historialController.registrarCodigoBarrasGenerado(
        asociadoId: asociadoId,
        codigoBarras: codigoBarras,
      );
    } catch (e) {
      // Error silencioso
    }
  }

  void _registrarSAP(String asociadoId, String sap) {
    try {
      final historialController = Get.put(HistorialController());
      historialController.registrarSAPGenerado(
        asociadoId: asociadoId,
        sap: sap,
      );
    } catch (e) {
      // Error silencioso
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
  
  Asociado? getAsociadoById(String asociadoId) {
    return _allAsociados.firstWhereOrNull((asociado) => asociado.id == asociadoId);
  }

  // ========== GETTERS ==========
  bool get hasSelectedAsociado => selectedAsociado.value != null;
  String get currentSearchQuery => searchQuery.value;
  Asociado? get currentAsociado => selectedAsociado.value;
  int get totalAsociados => asociados.length;
  int get totalAllAsociados => _allAsociados.length;
  bool get hasAsociados => asociados.isNotEmpty;
  int get totalCargasFamiliares => cargasFamiliares.length;
  
  int get totalPacientesActivos { 
      final int asociadosActivos = _allAsociados.where((a) => a.estaActivo).length;
      final int cargasActivas = cargasFamiliares.where((c) => c.estaActivo).length;
      return asociadosActivos + cargasActivas;
  }

  // GRÁFICO: Crecimiento de Pacientes (Últimos 6 meses)
  List<int> get patientGrowthLast6Months {
    final now = DateTime.now();
    List<int> counts = [];

    for (int i = 5; i >= 0; i--) {
      // Mes objetivo
      final targetMonth = DateTime(now.year, now.month - i);
      final endOfMonth = DateTime(targetMonth.year, targetMonth.month + 1, 0, 23, 59, 59);
      final asociadosCount = _allAsociados.where((a) => a.fechaIngreso.isBefore(endOfMonth)).length;
      final cargasCount = cargasFamiliares.where((c) => c.fechaCreacion.isBefore(endOfMonth)).length;
      
      counts.add(asociadosCount + cargasCount);
    }
    return counts;
  }
}