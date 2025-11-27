import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../../../../../utils/app_theme.dart';
import '../../../../../../controllers/asociados_controller.dart';
import '../../../../../../controllers/cargas_familiares_controller.dart';

class SelectPacienteDialog {
  static Future<Map<String, dynamic>?> show(BuildContext context) async {
    final AsociadosController asociadosController = Get.find<AsociadosController>();
    final CargasFamiliaresController cargasController = Get.find<CargasFamiliaresController>();
    
    final searchController = TextEditingController();
    final RxString searchQuery = ''.obs;
    final RxString tipoSeleccionado = 'todos'.obs; // 'todos', 'asociado', 'carga'
    final RxList<Map<String, dynamic>> filteredPacientes = <Map<String, dynamic>>[].obs;
    final Rxn<Map<String, dynamic>> selectedPaciente = Rxn<Map<String, dynamic>>();

    void loadAllPacientes() {
      final List<Map<String, dynamic>> allPacientes = [];
      
      // Agregar asociados
      for (var asociado in asociadosController.asociados) {
        allPacientes.add({
          'tipo': 'asociado',
          'id': asociado.id,
          'nombre': asociado.nombreCompleto,
          'rut': asociado.rutFormateado,
          'sap': asociado.sap,
          'edad': asociado.edad,
          'telefono': asociado.telefono,
          'data': asociado,
          'asociadoId': asociado.id,
        });
      }
      
      // Agregar cargas familiares
      for (var carga in cargasController.cargasFamiliares) {
        final asociado = asociadosController.getAsociadoById(carga.asociadoId);
        final titularNombre = asociado?.nombreCompleto ?? 'Desconocido';
        
        allPacientes.add({
          'tipo': 'carga',
          'id': carga.id,
          'nombre': carga.nombreCompleto,
          'rut': carga.rutFormateado,
          'edad': carga.edad,
          'parentesco': carga.parentesco,
          'titularNombre': titularNombre,
          'data': carga,
          'asociadoId': carga.asociadoId,
        });
      }
      
      filteredPacientes.value = allPacientes;
    }

    void filterPacientes(String query, String tipo) {
      List<Map<String, dynamic>> allPacientes = [];
      
      // Cargar según tipo
      if (tipo == 'todos' || tipo == 'asociado') {
        for (var asociado in asociadosController.asociados) {
          allPacientes.add({
            'tipo': 'asociado',
            'id': asociado.id,
            'nombre': asociado.nombreCompleto,
            'rut': asociado.rutFormateado,
            'sap': asociado.sap,
            'edad': asociado.edad,
            'telefono': asociado.telefono,
            'data': asociado,
            'asociadoId': asociado.id,
          });
        }
      }
      
      if (tipo == 'todos' || tipo == 'carga') {
        for (var carga in cargasController.cargasFamiliares) {
          final asociado = asociadosController.getAsociadoById(carga.asociadoId);
          final titularNombre = asociado?.nombreCompleto ?? 'Desconocido';
          
          allPacientes.add({
            'tipo': 'carga',
            'id': carga.id,
            'nombre': carga.nombreCompleto,
            'rut': carga.rutFormateado,
            'edad': carga.edad,
            'parentesco': carga.parentesco,
            'titularNombre': titularNombre,
            'data': carga,
            'asociadoId': carga.asociadoId,
          });
        }
      }
      
      // Filtrar por búsqueda
      if (query.isEmpty) {
        filteredPacientes.value = allPacientes;
        return;
      }

      final queryLower = query.toLowerCase().trim();
      final querySinFormato = query.replaceAll(RegExp(r'[^0-9kK]'), '');
      
      // Lista temporal para agrupar resultados
      List<Map<String, dynamic>> resultados = [];
      Set<String> asociadosEncontrados = {};
      
      // Filtrar pacientes
      for (var paciente in allPacientes) {
        bool matches = false;
        
        // Buscar por nombre
        if (paciente['nombre'].toString().toLowerCase().contains(queryLower)) {
          matches = true;
        }
        
        // Buscar por RUT
        if (!matches) {
          final rutSinFormato = paciente['rut'].toString().replaceAll(RegExp(r'[^0-9kK]'), '').toLowerCase();
          if (rutSinFormato.contains(querySinFormato)) {
            matches = true;
          }
        }
        
        // Buscar por SAP (solo asociados)
        if (!matches && paciente['tipo'] == 'asociado' && paciente['sap'] != null) {
          if (paciente['sap'].toString().toLowerCase().contains(queryLower)) {
            matches = true;
            // Marcar que este asociado fue encontrado por SAP
            asociadosEncontrados.add(paciente['id']);
          }
        }
        
        if (matches) {
          resultados.add(paciente);
        }
      }
      
      if (asociadosEncontrados.isNotEmpty) {
        for (var paciente in allPacientes) {
          if (paciente['tipo'] == 'carga' && 
              asociadosEncontrados.contains(paciente['asociadoId']) &&
              !resultados.contains(paciente)) {
            resultados.add(paciente);
          }
        }
      }

      resultados.sort((a, b) {

        int asociadoCompare = a['asociadoId'].compareTo(b['asociadoId']);
        if (asociadoCompare != 0) return asociadoCompare;
        if (a['tipo'] == 'asociado' && b['tipo'] == 'carga') return -1;
        if (a['tipo'] == 'carga' && b['tipo'] == 'asociado') return 1;
        
        return a['nombre'].toString().compareTo(b['nombre'].toString());
      });
      
      filteredPacientes.value = resultados;
    }

    Future<Map<String, dynamic>?> selectPacienteAction() async {
      if (selectedPaciente.value == null) {
        Get.snackbar(
          'Error',
          'Debes seleccionar un paciente',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Get.theme.colorScheme.error.withValues(alpha: 0.8),
          colorText: Get.theme.colorScheme.onError,
          margin: const EdgeInsets.all(16),
          borderRadius: 8,
          duration: const Duration(seconds: 4),
        );
        return null;
      }

      return selectedPaciente.value;
    }

    loadAllPacientes();

    return showDialog<Map<String, dynamic>>(
      context: context,
      barrierDismissible: false,
      builder: (context) => Focus(
        autofocus: true,
        onKeyEvent: (node, event) {
          if (event is KeyDownEvent) {
            if (event.logicalKey == LogicalKeyboardKey.escape) {
              Navigator.of(context).pop(null);
              return KeyEventResult.handled;
            } else if (event.logicalKey == LogicalKeyboardKey.enter) {
              if (selectedPaciente.value != null) {
                Navigator.of(context).pop(selectedPaciente.value);
              }
              return KeyEventResult.handled;
            }
          }
          return KeyEventResult.ignored;
        },
        child: AlertDialog(
          backgroundColor: AppTheme.getSurfaceColor(context),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Row(
            children: [
              const Icon(
                Icons.person_search,
                color: AppTheme.primaryColor,
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Seleccionar Paciente',
                      style: TextStyle(
                        color: AppTheme.getTextPrimary(context),
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Buscar asociado o carga familiar',
                      style: TextStyle(
                        color: AppTheme.getTextSecondary(context),
                        fontSize: 14,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                'ESC para cancelar • Enter para seleccionar',
                style: TextStyle(
                  color: AppTheme.getTextSecondary(context),
                  fontSize: 12,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: 600,
            height: 550,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Filtros de tipo
                Row(
                  children: [
                    Expanded(
                      child: Obx(() => _buildFilterChip(
                        context,
                        'Todos',
                        Icons.all_inclusive,
                        tipoSeleccionado.value == 'todos',
                        () {
                          tipoSeleccionado.value = 'todos';
                          filterPacientes(searchQuery.value, 'todos');
                        },
                      )),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Obx(() => _buildFilterChip(
                        context,
                        'Asociados',
                        Icons.person,
                        tipoSeleccionado.value == 'asociado',
                        () {
                          tipoSeleccionado.value = 'asociado';
                          filterPacientes(searchQuery.value, 'asociado');
                        },
                      )),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Obx(() => _buildFilterChip(
                        context,
                        'Cargas',
                        Icons.family_restroom,
                        tipoSeleccionado.value == 'carga',
                        () {
                          tipoSeleccionado.value = 'carga';
                          filterPacientes(searchQuery.value, 'carga');
                        },
                      )),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Campo de búsqueda
                TextField(
                  controller: searchController,
                  onChanged: (value) {
                    searchQuery.value = value;
                    filterPacientes(value, tipoSeleccionado.value);
                  },
                  style: TextStyle(color: AppTheme.getTextPrimary(context)),
                  decoration: InputDecoration(
                    labelText: 'Buscar paciente',
                    hintText: 'Buscar por nombre, RUT o SAP...',
                    prefixIcon: const Icon(Icons.search, color: AppTheme.primaryColor),
                    suffixIcon: Obx(() => searchQuery.value.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              searchController.clear();
                              searchQuery.value = '';
                              filterPacientes('', tipoSeleccionado.value);
                            },
                          )
                        : const SizedBox()),
                    labelStyle: TextStyle(color: AppTheme.getTextSecondary(context)),
                    hintStyle: TextStyle(color: AppTheme.getTextSecondary(context).withValues(alpha: 0.5)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: AppTheme.getBorderLight(context)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: AppTheme.getBorderLight(context)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2),
                    ),
                  ),
                ),

                const SizedBox(height: 16),
                Expanded(
                  child: Obx(() {
                    if (filteredPacientes.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              searchQuery.value.isEmpty
                                  ? Icons.people_outline
                                  : Icons.person_search,
                              size: 48,
                              color: AppTheme.getTextSecondary(context).withValues(alpha: 0.3),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              searchQuery.value.isEmpty
                                  ? 'No hay pacientes disponibles'
                                  : 'No se encontraron pacientes',
                              style: TextStyle(
                                color: AppTheme.getTextSecondary(context),
                                fontSize: 14,
                              ),
                            ),
                            if (searchQuery.value.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  'Intenta buscar por nombre, RUT o SAP',
                                  style: TextStyle(
                                    color: AppTheme.getTextSecondary(context).withValues(alpha: 0.7),
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    }

                    return Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: AppTheme.getBorderLight(context)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ListView.separated(
                        itemCount: filteredPacientes.length,
                        separatorBuilder: (context, index) => Divider(
                          height: 1,
                          color: AppTheme.getBorderLight(context),
                        ),
                        itemBuilder: (context, index) {
                          final paciente = filteredPacientes[index];
                          final isAsociado = paciente['tipo'] == 'asociado';
                          
                          return Obx(() => ListTile(
                            selected: selectedPaciente.value?['id'] == paciente['id'],
                            selectedTileColor: AppTheme.primaryColor.withValues(alpha: 0.1),
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: selectedPaciente.value?['id'] == paciente['id']
                                    ? AppTheme.primaryColor.withValues(alpha: 0.2)
                                    : AppTheme.getInputBackground(context),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                isAsociado ? Icons.person : Icons.family_restroom,
                                color: selectedPaciente.value?['id'] == paciente['id']
                                    ? AppTheme.primaryColor
                                    : AppTheme.getTextSecondary(context),
                              ),
                            ),
                            title: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    paciente['nombre'],
                                    style: TextStyle(
                                      color: AppTheme.getTextPrimary(context),
                                      fontWeight: selectedPaciente.value?['id'] == paciente['id']
                                          ? FontWeight.bold
                                          : FontWeight.w600,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: isAsociado 
                                        ? const Color(0xFF3B82F6).withValues(alpha: 0.1)
                                        : const Color(0xFF10B981).withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    isAsociado ? 'Asociado' : 'Carga',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: isAsociado 
                                          ? const Color(0xFF3B82F6)
                                          : const Color(0xFF10B981),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    Text(
                                      paciente['rut'],
                                      style: TextStyle(
                                        color: AppTheme.getTextSecondary(context),
                                        fontSize: 13,
                                      ),
                                    ),
                                    if (isAsociado && paciente['sap'] != null) ...[
                                      const SizedBox(width: 8),
                                      Text(
                                        '• SAP: ${paciente['sap']}',
                                        style: TextStyle(
                                          color: AppTheme.getTextSecondary(context),
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                    const SizedBox(width: 8),
                                    Text(
                                      '• ${paciente['edad']} años',
                                      style: TextStyle(
                                        color: AppTheme.getTextSecondary(context),
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                                if (!isAsociado) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    '${paciente['parentesco']} de ${paciente['titularNombre']}',
                                    style: TextStyle(
                                      color: AppTheme.getTextSecondary(context),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            trailing: selectedPaciente.value?['id'] == paciente['id']
                                ? const Icon(
                                    Icons.check_circle,
                                    color: AppTheme.primaryColor,
                                  )
                                : null,
                            onTap: () {
                              selectedPaciente.value = paciente;
                            },
                          ));
                        },
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(null),
              child: Text(
                'Cancelar',
                style: TextStyle(
                  color: AppTheme.getTextSecondary(context),
                ),
              ),
            ),
            Obx(() => ElevatedButton(
              onPressed: selectedPaciente.value == null
                  ? null
                  : () async {
                      final result = await selectPacienteAction();
                      if (result != null && context.mounted) {
                        Navigator.of(context).pop(result);
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Seleccionar'),
            )),
          ],
        ),
      ),
    );
  }

  static Widget _buildFilterChip(
    BuildContext context,
    String label,
    IconData icon,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        hoverColor: AppTheme.primaryColor.withValues(alpha: 0.05),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? AppTheme.primaryColor.withValues(alpha: 0.1)
                : AppTheme.getInputBackground(context),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected
                  ? AppTheme.primaryColor
                  : AppTheme.getBorderLight(context),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected
                    ? AppTheme.primaryColor
                    : AppTheme.getTextSecondary(context),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected
                      ? AppTheme.primaryColor
                      : AppTheme.getTextPrimary(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}