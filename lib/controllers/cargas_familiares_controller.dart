import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import '../models/carga_familiar.dart';
import '../models/asociado.dart';
import '../models/transferencia_solicitud.dart';
import '../controllers/historial_cargas_controller.dart';
import '../widgets/dashboard/modules/gestion_cargas_familiares/shared/dialogs/edit_carga_dialog.dart';
import '../widgets/dashboard/modules/gestion_cargas_familiares/shared/dialogs/transfer_carga_dialog.dart';
import '../widgets/dashboard/modules/gestion_cargas_familiares/shared/dialogs/barcode_search_dialog.dart';
import '../widgets/dashboard/modules/gestion_cargas_familiares/shared/dialogs/generar_codigo_barras_carga_dialog.dart';
import '../widgets/dashboard/modules/gestion_cargas_familiares/shared/dialogs/historial_carga_dialog.dart';

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
  final GlobalKey<State<StatefulWidget>> searchFieldKey = GlobalKey();
  Timer? _debounceTimer;
  
  // Cache de SAPs de asociados
  final Map<String, String> _asociadosSapCache = {};
  
  // Lista de solicitudes de transferencia
  final RxList<TransferenciaSolicitud> solicitudesTransferencia = <TransferenciaSolicitud>[].obs;

  // ==================== GETTERS ====================
  bool get hasSelectedCarga => selectedCarga.value != null;
  bool get hasCargas => cargasFamiliares.isNotEmpty;
  CargaFamiliar? get currentCarga => selectedCarga.value;
  int get totalAllCargas => allCargas.length;
  int get totalCargas => cargasFamiliares.length;
  int get totalCargasActivas => _allCargasFamiliares.where((c) => c.estaActivo).length;
  int get totalSolicitudesPendientes => solicitudesTransferencia.length;

  // ==================== INICIALIZACIÓN ====================
  @override
  void onInit() {
    super.onInit();

    searchText.listen((query) {
      if (_debounceTimer == null || !_debounceTimer!.isActive) {
        _debounceTimer?.cancel();
        _debounceTimer = Timer(const Duration(milliseconds: 100), () {
          _filterCargas(query);
        });
      }
    });

    searchController.addListener(() {
      searchText.value = searchController.text;
    });

    loadCargas();
    loadSolicitudesTransferencia();
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

      // Cargar SAPs de los asociados
      await _loadAsociadosSaps();

      _updateCargasLists();
    } catch (e) {
      _showErrorSnackbar("Error", "No se pudieron cargar las cargas familiares");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadAsociadosSaps() async {
    try {
      // Obtener IDs únicos de asociados
      final asociadoIds = _allCargasFamiliares
          .map((c) => c.asociadoId)
          .toSet()
          .toList();

      if (asociadoIds.isEmpty) return;

      // Buscar asociados en Firestore (máximo 10 por consulta debido a limitación de whereIn)
      for (int i = 0; i < asociadoIds.length; i += 10) {
        final batch = asociadoIds.skip(i).take(10).toList();
        
        final asociadosSnapshot = await FirebaseFirestore.instance
            .collection('asociados')
            .where(FieldPath.documentId, whereIn: batch)
            .get();

        // Guardar en cache
        for (var doc in asociadosSnapshot.docs) {
          final sap = doc.data()['sap'] as String?;
          if (sap != null && sap.isNotEmpty) {
            _asociadosSapCache[doc.id] = sap;
          }
        }
      }
    } catch (e) {
      // Error silencioso
    }
  }

  Future<void> refreshCargas() async {
    await loadCargas();
    await loadSolicitudesTransferencia();
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
      'email': carga.email,
      'telefono': carga.telefono,
      'direccion': carga.direccion,
      'asociadoSap': _asociadosSapCache[carga.asociadoId] ?? '',
    };
  }

  // ==================== BÚSQUEDA Y FILTRADO ====================
  void _filterCargas(String query) {
    if (query.isEmpty) {
      filteredCargas.value = List.from(allCargas);
      return;
    }

    final queryLower = query.toLowerCase();
    final querySinFormato = query.replaceAll(RegExp(r'[^0-9kK]'), '').toLowerCase();
    
    final filteredList = allCargas.where((carga) {
      final rutSinFormato = (carga['rut'] as String).replaceAll(RegExp(r'[^0-9kK]'), '').toLowerCase();
      final nombreCompleto = (carga['nombreCompleto'] as String).toLowerCase();
      final email = (carga['email'] as String? ?? '').toLowerCase();
      final asociadoSap = (carga['asociadoSap'] as String? ?? '').toLowerCase();
      
      return rutSinFormato.contains(querySinFormato) || 
             nombreCompleto.contains(queryLower) ||
             email.contains(queryLower) ||
             asociadoSap.contains(queryLower);
    }).toList();

    filteredCargas.value = filteredList;
  }

  void onSearchQueryChanged(String query) {
    _debounceTimer?.cancel();
    _filterCargasImmediate(query);
  }
  
  void _filterCargasImmediate(String query) {
    if (query.isEmpty) {
      filteredCargas.value = List.from(allCargas);
      filteredCargas.refresh();
      return;
    }

    final queryLower = query.toLowerCase();
    final querySinFormato = query.replaceAll(RegExp(r'[^0-9kK]'), '').toLowerCase();
    
    final filteredList = allCargas.where((carga) {
      final rutSinFormato = (carga['rut'] as String).replaceAll(RegExp(r'[^0-9kK]'), '').toLowerCase();
      final nombreCompleto = (carga['nombreCompleto'] as String).toLowerCase();
      final email = (carga['email'] as String? ?? '').toLowerCase();
      final asociadoSap = (carga['asociadoSap'] as String? ?? '').toLowerCase();
      
      return rutSinFormato.contains(querySinFormato) || 
             nombreCompleto.contains(queryLower) ||
             email.contains(queryLower) ||
             asociadoSap.contains(queryLower);
    }).toList();

    filteredCargas.value = filteredList;
    filteredCargas.refresh();
  }

  void clearSearchField() {
    try {
      if (!Get.isRegistered<CargasFamiliaresController>()) return;
      
      final dynamic searchField = searchFieldKey.currentState;
      if (searchField != null && searchField is State && searchField.mounted) {
        if (searchField.runtimeType.toString().contains('_CargaFamiliarSearchFieldState')) {
          (searchField as dynamic).clearField();
        }
      }
    } catch (e) {
      // Error silencioso
    }
  }

  void resetFilter() {
    searchText.value = '';
    _filterCargasImmediate('');
  }

  // ==================== BÚSQUEDA EXACTA ====================
  Future<void> searchCargas(String searchTerm) async {
    if (searchTerm.isEmpty) {
      selectedCarga.value = null;
      searchText.value = '';
      return;
    }
    
    isLoading.value = true;

    try {
      final cleanSearchTerm = searchTerm.trim();
      
      // Detectar si es SAP (5 dígitos)
      final bool isSAP = RegExp(r'^[0-9]{5}$').hasMatch(cleanSearchTerm);
      
      if (isSAP) {
        await _searchCargasBySAP(cleanSearchTerm);
      } else {
        // 1. Intentar buscar por RUT de la carga
        await _searchCargaByRut(cleanSearchTerm);
        
        // 2. Si no se encontró, buscar por código de barras
        if (selectedCarga.value == null) {
          await _searchCargaByBarcode(cleanSearchTerm);
        }
      }
      
      if (selectedCarga.value == null && filteredCargas.isEmpty) {
        _showErrorSnackbar("No encontrado", "No se encontraron cargas con: $cleanSearchTerm");
      }
      
    } catch (e) {
      _showErrorSnackbar("Error", "Error al buscar carga familiar");
      selectedCarga.value = null;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _searchCargaByRut(String rut) async {
    final rutSinGuion = rut.replaceAll('-', '');
    
    // Buscar en memoria local
    final carga = _allCargasFamiliares.firstWhereOrNull((c) {
      if (c.rut == rut) return true;
      if (c.rutFormateado == rut) return true;
      
      final cargaRutSinGuion = c.rut.replaceAll('-', '');
      if (cargaRutSinGuion == rutSinGuion) return true;
      
      return false;
    });

    if (carga != null) {
      selectedCarga.value = carga;
      searchText.value = '';
      _showSuccessSnackbar("Encontrado", "Carga familiar encontrada: ${carga.nombreCompleto}");
      return;
    }
    
    // Buscar en Firestore
    final snapshot = await FirebaseFirestore.instance
        .collection('cargas_familiares')
        .where('rut', isEqualTo: rut)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      final doc = snapshot.docs.first;
      final cargaEncontrada = CargaFamiliar.fromMap(
        doc.data(),
        doc.id,
      );
      
      selectedCarga.value = cargaEncontrada;
      searchText.value = '';
      
      if (!_allCargasFamiliares.any((c) => c.id == cargaEncontrada.id)) {
        _allCargasFamiliares.add(cargaEncontrada);
        cargasFamiliares.add(cargaEncontrada);
        _updateCargasLists();
      }
      
      _showSuccessSnackbar("Encontrado", "Carga familiar encontrada: ${cargaEncontrada.nombreCompleto}");
    }
  }

  Future<void> _searchCargaByBarcode(String barcode) async {
    // Buscar en memoria local
    final carga = _allCargasFamiliares.firstWhereOrNull(
      (c) => c.codigoBarras == barcode,
    );

    if (carga != null) {
      selectedCarga.value = carga;
      searchText.value = '';
      _showSuccessSnackbar("Encontrado", "Carga familiar encontrada: ${carga.nombreCompleto}");
      return;
    }
    
    // Buscar en Firestore
    final snapshot = await FirebaseFirestore.instance
        .collection('cargas_familiares')
        .where('codigoBarras', isEqualTo: barcode)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      final doc = snapshot.docs.first;
      final cargaEncontrada = CargaFamiliar.fromMap(
        doc.data(),
        doc.id,
      );
      
      selectedCarga.value = cargaEncontrada;
      searchText.value = '';
      
      if (!_allCargasFamiliares.any((c) => c.id == cargaEncontrada.id)) {
        _allCargasFamiliares.add(cargaEncontrada);
        cargasFamiliares.add(cargaEncontrada);
        _updateCargasLists();
      }
      
      _showSuccessSnackbar("Encontrado", "Carga familiar encontrada: ${cargaEncontrada.nombreCompleto}");
    }
  }

  Future<void> _searchCargasBySAP(String sap) async {
    // 1. Buscar el asociado con ese SAP
    final asociadoSnapshot = await FirebaseFirestore.instance
        .collection('asociados')
        .where('sap', isEqualTo: sap)
        .limit(1)
        .get();

    if (asociadoSnapshot.docs.isEmpty) {
      _showErrorSnackbar("No encontrado", "No existe un asociado con SAP: $sap");
      return;
    }

    final asociadoId = asociadoSnapshot.docs.first.id;
    final asociadoData = Asociado.fromMap(
      asociadoSnapshot.docs.first.data(),
      asociadoId,
    );
    
    // 2. Buscar todas las cargas de ese asociado
    await _filterCargasByAsociadoId(asociadoId, asociadoData.nombreCompleto);
  }

  Future<void> _filterCargasByAsociadoId(String asociadoId, String nombreAsociado) async {
    // Buscar en memoria local
    final cargasDelAsociado = _allCargasFamiliares
        .where((c) => c.asociadoId == asociadoId)
        .toList();

    if (cargasDelAsociado.isNotEmpty) {
      // Filtrar la lista visual
      final cargasMapeadas = cargasDelAsociado.map((c) => _cargaToMap(c)).toList();
      filteredCargas.value = cargasMapeadas;
      
      // Seleccionar la primera carga
      selectedCarga.value = cargasDelAsociado.first;
      searchText.value = '';
      
      _showSuccessSnackbar(
        "Encontradas ${cargasDelAsociado.length} cargas", 
        "Cargas familiares de: $nombreAsociado"
      );
      return;
    }
    
    // Buscar en Firestore
    final snapshot = await FirebaseFirestore.instance
        .collection('cargas_familiares')
        .where('asociadoId', isEqualTo: asociadoId)
        .get();

    if (snapshot.docs.isNotEmpty) {
      final cargasEncontradas = snapshot.docs.map((doc) {
        return CargaFamiliar.fromMap(doc.data(), doc.id);
      }).toList();
      
      // Agregar a la lista local si no existen
      for (var carga in cargasEncontradas) {
        if (!_allCargasFamiliares.any((c) => c.id == carga.id)) {
          _allCargasFamiliares.add(carga);
          cargasFamiliares.add(carga);
        }
      }
      
      _updateCargasLists();
      
      // Filtrar la lista visual
      final cargasMapeadas = cargasEncontradas.map((c) => _cargaToMap(c)).toList();
      filteredCargas.value = cargasMapeadas;
      
      // Seleccionar la primera carga
      selectedCarga.value = cargasEncontradas.first;
      searchText.value = '';
      
      _showSuccessSnackbar(
        "Encontradas ${cargasEncontradas.length} cargas", 
        "Cargas familiares de: $nombreAsociado"
      );
    }
  }

  void clearSearch() {
    selectedCarga.value = null;
    searchText.value = '';
  }

  // ==================== SOLICITUDES DE TRANSFERENCIA ====================
  Future<void> loadSolicitudesTransferencia() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('solicitudes_transferencia')
          .where('estado', isEqualTo: 'pendiente')
          .orderBy('fechaSolicitud', descending: true)
          .get();

      solicitudesTransferencia.clear();
      for (var doc in snapshot.docs) {
        final solicitud = TransferenciaSolicitud.fromMap(doc.data(), doc.id);
        solicitudesTransferencia.add(solicitud);
      }
    } catch (e) {
      // Error silencioso
    }
  }

  Future<bool> createTransferenciaSolicitud({
    required CargaFamiliar carga,
    required String nuevoAsociadoId,
    required String nuevoAsociadoNombre,
  }) async {
    try {
      isLoading.value = true;

      // Obtener nombre del asociado origen
      final asociadoOrigen = await FirebaseFirestore.instance
          .collection('asociados')
          .doc(carga.asociadoId)
          .get();

      final asociadoOrigenNombre = asociadoOrigen.exists
          ? '${asociadoOrigen.data()!['nombre']} ${asociadoOrigen.data()!['apellido']}'
          : 'Desconocido';

      final solicitud = TransferenciaSolicitud(
        cargaId: carga.id!,
        cargaNombre: carga.nombreCompleto,
        cargaRut: carga.rutFormateado,
        asociadoOrigenId: carga.asociadoId,
        asociadoOrigenNombre: asociadoOrigenNombre,
        asociadoDestinoId: nuevoAsociadoId,
        asociadoDestinoNombre: nuevoAsociadoNombre,
        fechaSolicitud: DateTime.now(),
      );

      await FirebaseFirestore.instance
          .collection('solicitudes_transferencia')
          .add(solicitud.toMap());

      await loadSolicitudesTransferencia();

      _showSuccessSnackbar(
        'Solicitud creada',
        'La transferencia está pendiente de aprobación',
      );

      return true;
    } catch (e) {
      _showErrorSnackbar('Error', 'No se pudo crear la solicitud de transferencia');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> aprobarTransferencia(TransferenciaSolicitud solicitud) async {
    try {
      isLoading.value = true;

      // 1. Actualizar la carga con el nuevo asociado
      final carga = _allCargasFamiliares.firstWhereOrNull((c) => c.id == solicitud.cargaId);
      if (carga == null) {
        _showErrorSnackbar('Error', 'No se encontró la carga familiar');
        return false;
      }

      final cargaActualizada = carga.copyWith(
        asociadoId: solicitud.asociadoDestinoId,
        ultimaActividad: DateTime.now(),
      );

      await FirebaseFirestore.instance
          .collection('cargas_familiares')
          .doc(solicitud.cargaId)
          .update(cargaActualizada.toMap());

      // 2. Actualizar el estado de la solicitud
      await FirebaseFirestore.instance
          .collection('solicitudes_transferencia')
          .doc(solicitud.id)
          .update({
        'estado': 'aprobada',
        'fechaRespuesta': DateTime.now(),
      });

      // 3. Actualizar listas locales
      final index = _allCargasFamiliares.indexWhere((c) => c.id == cargaActualizada.id);
      if (index != -1) {
        _allCargasFamiliares[index] = cargaActualizada;
        cargasFamiliares[index] = cargaActualizada;
      }

      await loadSolicitudesTransferencia();
      await loadCargas();

      _showSuccessSnackbar(
        'Transferencia aprobada',
        'La carga fue transferida exitosamente',
      );

      return true;
    } catch (e) {
      _showErrorSnackbar('Error', 'No se pudo aprobar la transferencia');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> rechazarTransferencia(TransferenciaSolicitud solicitud, String motivo) async {
    try {
      isLoading.value = true;

      await FirebaseFirestore.instance
          .collection('solicitudes_transferencia')
          .doc(solicitud.id!)
          .update({
        'estado': 'rechazada',
        'motivoRechazo': motivo,
        'fechaRespuesta': DateTime.now(),
      });

      await loadSolicitudesTransferencia();

      _showSuccessSnackbar(
        'Transferencia rechazada',
        'La solicitud fue rechazada',
      );

      return true;
    } catch (e) {
      _showErrorSnackbar('Error', 'No se pudo rechazar la transferencia');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // ==================== CÓDIGO DE BARRAS ====================
  Future<bool> updateCargaBarcode(String cargaId, String codigoBarras) async {
    try {
      final carga = _allCargasFamiliares.firstWhereOrNull((c) => c.id == cargaId);
      if (carga == null) return false;

      final cargaActualizada = carga.copyWith(
        codigoBarras: codigoBarras,
        ultimaActividad: DateTime.now(),
      );

      await FirebaseFirestore.instance
          .collection('cargas_familiares')
          .doc(cargaId)
          .update(cargaActualizada.toMap());
      
      if (selectedCarga.value?.id == cargaId) {
        selectedCarga.value = cargaActualizada;
        selectedCarga.refresh();
      }
      
      final index = cargasFamiliares.indexWhere((c) => c.id == cargaId);
      if (index != -1) {
        cargasFamiliares[index] = cargaActualizada;
        cargasFamiliares.refresh();
      }

      final allIndex = _allCargasFamiliares.indexWhere((c) => c.id == cargaId);
      if (allIndex != -1) {
        _allCargasFamiliares[allIndex] = cargaActualizada;
      }
      
      _updateCargasLists();
      
      Get.snackbar(
        'Éxito',
        'Código de barras generado correctamente',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF10B981).withValues(alpha: 0.8),
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
        margin: const EdgeInsets.all(16),
        borderRadius: 8,
      );
      
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

  // ==================== MÉTODOS DE INTERFAZ ====================
  Future<void> qrCodeSearch() async {
    final context = Get.context;
    if (context != null && context.mounted) {
      BarcodeSearchDialog.show(context);
    } else {
      _showErrorSnackbar("Error", "No se pudo abrir el escáner de código de barras");
    }
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
    searchText.value = '';
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

      // Guardar carga anterior para historial
      final cargaAnterior = _allCargasFamiliares.firstWhere((c) => c.id == cargaActualizada.id);

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

      // Registrar en historial
      _registrarEdicion(cargaAnterior, cargaConActividad);

      return true;
    } catch (e) {
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
      final cargaEliminada = selectedCarga.value!;

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
      
      // Registrar en historial
      _registrarEliminacion(cargaEliminada);

    } catch (e) {
      _showErrorSnackbar('Error', 'No se pudo eliminar la carga familiar');
    } finally {
      isLoading.value = false;
    }
  }

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

    final context = Get.context;
    if (context != null) {
      // Obtener el SAP del asociado desde el cache
      final asociadoSap = _asociadosSapCache[selectedCarga.value!.asociadoId] ?? 'Sin SAP';
      
      GenerarCodigoBarrasCargaDialog.show(
        context,
        cargaId: selectedCarga.value!.id!,
        nombreCompleto: selectedCarga.value!.nombreCompleto,
        rut: selectedCarga.value!.rutFormateado,
        asociadoSap: asociadoSap,
        codigoExistente: selectedCarga.value!.codigoBarras,
      );
    } else {
      _showErrorSnackbar('Error', 'No se pudo abrir el generador de código de barras');
    }
  }

  void viewHistory() {
    if (selectedCarga.value?.id == null) {
      _showErrorSnackbar('Error', 'No hay carga seleccionada');
      return;
    }

    final context = Get.context;
    if (context != null) {
      HistorialCargaDialog.show(
        context,
        cargaFamiliarId: selectedCarga.value!.id!,
        nombreCarga: selectedCarga.value!.nombreCompleto,
      );
    } else {
      _showErrorSnackbar('Error', 'No se pudo abrir el historial');
    }
  }

  void updateMedicalInfo() {
    if (selectedCarga.value == null) {
      _showErrorSnackbar('Error', 'No hay carga seleccionada');
      return;
    }

    _showInfoSnackbar('Información', 'Funcionalidad en desarrollo');
  }

  // ==================== HISTORIAL ====================
  
  void _registrarEdicion(CargaFamiliar cargaAnterior, CargaFamiliar cargaNueva) {
    try {
      final historialController = Get.put(HistorialCargasController());
      historialController.registrarEdicion(
        cargaFamiliarId: cargaNueva.id!,
        asociadoId: cargaNueva.asociadoId,
        cargaAnterior: cargaAnterior,
        cargaNueva: cargaNueva,
      );
    } catch (e) {
      // Error silencioso
    }
  }

  void _registrarEliminacion(CargaFamiliar carga) {
    try {
      final historialController = Get.put(HistorialCargasController());
      historialController.registrarEliminacion(
        cargaFamiliarId: carga.id!,
        asociadoId: carga.asociadoId,
        carga: carga,
      );
    } catch (e) {
      // Error silencioso
    }
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