import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import '../models/asociado.dart';
import '../models/carga_familiar.dart';
import '../widgets/dashboard/modules/gestion_asociados/shared/dialogs/new_asociado_dialog.dart';
import '../widgets/dashboard/modules/gestion_asociados/shared/dialogs/edit_asociado_dialog.dart';
import '../widgets/dashboard/modules/gestion_asociados/shared/dialogs/new_carga_familiar_dialog.dart';

class AsociadosController extends GetxController {
  // ========== VARIABLES OBSERVABLES ==========
  RxBool isLoading = false.obs;
  Rxn<Asociado> selectedAsociado = Rxn<Asociado>();
  RxString searchQuery = ''.obs;
  
  // Lista completa y lista filtrada para búsqueda en tiempo real
  // ignore: prefer_final_fields
  RxList<Asociado> _allAsociados = <Asociado>[].obs; // Lista completa (privada)
  RxList<Asociado> asociados = <Asociado>[].obs;     // Lista filtrada (pública)
  
  RxList<CargaFamiliar> cargasFamiliares = <CargaFamiliar>[].obs;

  // Key global para acceder al RutSearchField
  final GlobalKey<State<StatefulWidget>> searchFieldKey = GlobalKey();

  // Timer para debounce en búsqueda en tiempo real
  Timer? _debounceTimer;

  @override
  void onInit() {
    super.onInit();
    
    // Listener para manejar cambios en searchQuery (para compatibilidad)
    searchQuery.listen((query) {
      // Solo usar debounce si no es una búsqueda inmediata
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

  // ========== NUEVOS MÉTODOS PARA BÚSQUEDA EN TIEMPO REAL ==========

  /// Filtra los asociados basado en el query de búsqueda
  void _filterAsociados(String query) {
    if (query.isEmpty) {
      asociados.value = List.from(_allAsociados);
      return;
    }

    final queryLower = query.toLowerCase();
    final querySinFormato = query.replaceAll(RegExp(r'[^0-9kK]'), '').toLowerCase();
    
    final filteredList = _allAsociados.where((asociado) {
      // Filtrar por RUT (sin formato)
      final rutSinFormato = asociado.rut.replaceAll(RegExp(r'[^0-9kK]'), '').toLowerCase();
      
      // Filtrar por nombre completo
      final nombreCompleto = asociado.nombreCompleto.toLowerCase();
      
      // Filtrar por email
      final email = asociado.email.toLowerCase();
      
      return rutSinFormato.contains(querySinFormato) || 
             nombreCompleto.contains(queryLower) ||
             email.contains(queryLower);
    }).toList();

    asociados.value = filteredList;
  }

  /// Maneja el cambio de query de búsqueda en tiempo real
  void onSearchQueryChanged(String query) {
    // Cancelar cualquier timer anterior
    _debounceTimer?.cancel();
    
    // Para búsqueda verdaderamente instantánea, ejecutar inmediatamente
    _filterAsociadosImmediate(query);
  }
  
  /// Filtro inmediato sin debounce para búsqueda instantánea
  void _filterAsociadosImmediate(String query) {
    if (query.isEmpty) {
      asociados.value = List.from(_allAsociados);
      asociados.refresh(); // Forzar actualización
      return;
    }

    final queryLower = query.toLowerCase();
    final querySinFormato = query.replaceAll(RegExp(r'[^0-9kK]'), '').toLowerCase();
    
    final filteredList = _allAsociados.where((asociado) {
      final rutSinFormato = asociado.rut.replaceAll(RegExp(r'[^0-9kK]'), '').toLowerCase();
      final nombreCompleto = asociado.nombreCompleto.toLowerCase();
      final email = asociado.email.toLowerCase();
      
      return rutSinFormato.contains(querySinFormato) || 
             nombreCompleto.contains(queryLower) ||
             email.contains(queryLower);
    }).toList();

    // Actualizar la lista y forzar refresh
    asociados.value = filteredList;
    asociados.refresh();
  }

  /// Resetea el filtro para mostrar todos los asociados
  void resetFilter() {
    searchQuery.value = '';
    _filterAsociadosImmediate('');
  }
  
  void clearSearchField() {
    try {
      final dynamic searchField = searchFieldKey.currentState;
      if (searchField != null) {
        // Llamar directamente al método clearField del RutSearchField
        if (searchField.runtimeType.toString().contains('_RutSearchFieldState')) {
          (searchField as dynamic).clearField();
        }
      }
    } catch (e) {
      Get.log('Error limpiando campo de búsqueda: $e');
    }
  }

  // ========== GESTIÓN DE ASOCIADOS (MODIFICADOS) ==========

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
      
      // Aplicar filtro actual después de cargar
      _filterAsociados(searchQuery.value);
      
      Get.log('Asociados cargados: ${_allAsociados.length}');
    } catch (e) {
      Get.log('Error cargando asociados: $e');
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

      // Validaciones
      if (!Asociado.validarRUT(rut)) {
        _showErrorSnackbar("Error", "RUT inválido. Formato: 12345678-9");
        return false;
      }

      if (!Asociado.validarEmail(email)) {
        _showErrorSnackbar("Error", "Email inválido");
        return false;
      }

      // Verificar que el RUT no exista en _allAsociados
      final existingAsociado = _allAsociados.firstWhereOrNull(
        (asociado) => asociado.rut == rut
      );
      
      if (existingAsociado != null) {
        _showErrorSnackbar("Error", "Ya existe un asociado con este RUT");
        return false;
      }

      // Crear objeto Asociado
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
        fechaCreacion: DateTime.now(),
        fechaIngreso: DateTime.now(),
      );

      // Guardar en Firestore
      final docRef = await FirebaseFirestore.instance
          .collection('asociados')
          .add(nuevoAsociado.toMap());

      // Actualizar el objeto con el ID generado
      final asociadoConId = nuevoAsociado.copyWith(id: docRef.id);
      
      // Agregar a la lista completa
      _allAsociados.add(asociadoConId);
      
      // Seleccionar el nuevo asociado
      selectedAsociado.value = asociadoConId;
      searchQuery.value = '';

      _showSuccessSnackbar("Éxito!", "Asociado creado correctamente");
      
      return true;

    } catch (e) {
      Get.log('Error creando asociado: $e');
      _showErrorSnackbar("Error", "No se pudo crear el asociado: ${e.toString()}");
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> searchAsociado(String rut) async {
    if (rut.isEmpty) {
      selectedAsociado.value = null;
      searchQuery.value = '';
      return;
    }
    
    isLoading.value = true;

    try {
      // Buscar en la lista completa primero
      final asociado = _allAsociados.firstWhereOrNull(
        (asociado) => asociado.rut == rut || asociado.rutFormateado == rut
      );

      if (asociado != null) {
        selectedAsociado.value = asociado;
        searchQuery.value = '';
        
        // Cargar todas las cargas si no están cargadas
        if (cargasFamiliares.isEmpty) {
          await loadAllCargasFamiliares();
        }
        
        _showSuccessSnackbar("Encontrado", "Asociado encontrado: ${asociado.nombreCompleto}");
      } else {
        // Si no está en local, buscar en Firestore
        final QuerySnapshot snapshot = await FirebaseFirestore.instance
            .collection('asociados')
            .where('rut', isEqualTo: rut)
            .limit(1)
            .get();

        if (snapshot.docs.isNotEmpty) {
          final doc = snapshot.docs.first;
          final asociadoEncontrado = Asociado.fromMap(
            doc.data() as Map<String, dynamic>, 
            doc.id
          );
          
          selectedAsociado.value = asociadoEncontrado;
          searchQuery.value = '';
          
          // Agregar a la lista completa si no está
          if (!_allAsociados.any((a) => a.id == asociadoEncontrado.id)) {
            _allAsociados.add(asociadoEncontrado);
            // Aplicar filtro después de agregar
            _filterAsociados(searchQuery.value);
          }
          
          // Cargar todas las cargas si no están cargadas
          if (cargasFamiliares.isEmpty) {
            await loadAllCargasFamiliares();
          }
          
          _showSuccessSnackbar("Encontrado", "Asociado encontrado: ${asociadoEncontrado.nombreCompleto}");
        } else {
          selectedAsociado.value = null;
          _showErrorSnackbar("No encontrado", "No se encontró ningún asociado con RUT: $rut");
        }
      }
    } catch (e) {
      Get.log('Error buscando asociado: $e');
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

      // Actualizar en Firestore
      await FirebaseFirestore.instance
          .collection('asociados')
          .doc(asociado.id)
          .update(asociado.toMap());

      // Actualizar en la lista completa
      final index = _allAsociados.indexWhere((a) => a.id == asociado.id);
      if (index != -1) {
        _allAsociados[index] = asociado;
        // Aplicar filtro después de actualizar
        _filterAsociados(searchQuery.value);
      }

      // FORZAR actualización del UI
      selectedAsociado.value = null;
      await Future.delayed(const Duration(milliseconds: 50));
      selectedAsociado.value = asociado;

      _showSuccessSnackbar("Éxito!", "Asociado actualizado correctamente");
      return true;

    } catch (e) {
      Get.log('Error actualizando asociado: $e');
      _showErrorSnackbar("Error", "No se pudo actualizar el asociado");
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> deleteAsociadoById(String id) async {
    try {
      isLoading.value = true;

      // Eliminar de Firestore
      await FirebaseFirestore.instance
          .collection('asociados')
          .doc(id)
          .delete();

      // Eliminar de la lista completa
      _allAsociados.removeWhere((asociado) => asociado.id == id);
      // Aplicar filtro después de eliminar
      _filterAsociados(searchQuery.value);

      // Limpiar selección si era el asociado seleccionado
      if (selectedAsociado.value?.id == id) {
        selectedAsociado.value = null;
        searchQuery.value = '';
        cargasFamiliares.removeWhere((carga) => carga.asociadoId == id);
      }

      _showSuccessSnackbar("Eliminado", "Asociado eliminado correctamente");
      return true;

    } catch (e) {
      Get.log('Error eliminando asociado: $e');
      _showErrorSnackbar("Error", "No se pudo eliminar el asociado");
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // ========== RESTO DE MÉTODOS ORIGINALES ==========

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
      
      Get.log('Cargas familiares cargadas: ${cargasFamiliares.length}');
    } catch (e) {
      Get.log('Error cargando todas las cargas familiares: $e');
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

      // Validaciones
      if (!CargaFamiliar.validarRUT(rut)) {
        _showErrorSnackbar("Error", "RUT inválido. Formato: 12345678-9");
        return false;
      }

      // Verificar que el RUT no exista
      final existingCarga = cargasFamiliares.firstWhereOrNull(
        (carga) => carga.rut == rut
      );
      
      if (existingCarga != null) {
        _showErrorSnackbar("Error", "Ya existe una carga familiar con este RUT");
        return false;
      }

      // Crear objeto CargaFamiliar
      final nuevaCarga = CargaFamiliar(
        asociadoId: selectedAsociado.value!.id!,
        nombre: nombre.trim(),
        apellido: apellido.trim(),
        rut: rut.trim(),
        parentesco: parentesco,
        fechaNacimiento: fechaNacimiento,
        fechaCreacion: DateTime.now(),
      );

      // Guardar en Firestore
      final docRef = await FirebaseFirestore.instance
          .collection('cargas_familiares')
          .add(nuevaCarga.toMap());

      // Actualizar el objeto con el ID generado
      final cargaConId = nuevaCarga.copyWith(id: docRef.id);
      
      // Agregar a la lista local de cargas
      cargasFamiliares.add(cargaConId);

      _showSuccessSnackbar("Éxito!", "Carga familiar agregada correctamente");
      
      return true;

    } catch (e) {
      Get.log('Error creando carga familiar: $e');
      _showErrorSnackbar("Error", "No se pudo crear la carga familiar: ${e.toString()}");
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Métodos de interfaz
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
    isLoading.value = true;
    
    try {
      await Future.delayed(const Duration(seconds: 2));
      
      if (_allAsociados.isNotEmpty) {
        final asociadoAleatorio = _allAsociados[
          DateTime.now().millisecond % _allAsociados.length
        ];
        await searchAsociado(asociadoAleatorio.rut);
      } else {
        _showErrorSnackbar("Sin datos", "No hay asociados registrados para el escaneo QR");
      }
    } catch (e) {
      _showErrorSnackbar("Error", "Error en escaneo QR");
    } finally {
      isLoading.value = false;
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
    Get.snackbar(
      'Ver Historial', 
      'Función para ver historial (próximamente)',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void generateQR() {
    Get.snackbar(
      'Generar QR', 
      'Código QR generado exitosamente',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Get.theme.colorScheme.primary.withValues(alpha: 0.8),
      colorText: Get.theme.colorScheme.onPrimary,
    );
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
  int get totalAsociados => asociados.length; // Total filtrados
  int get totalAllAsociados => _allAsociados.length; // Total sin filtrar
  bool get hasAsociados => asociados.isNotEmpty;
  int get totalCargasFamiliares => cargasFamiliares.length;
}