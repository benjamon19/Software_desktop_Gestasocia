import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:gestasocia/utils/app_theme.dart';
import '../../../../../../controllers/cargas_familiares_controller.dart';
import '../../../../../../controllers/asociados_controller.dart';
import '../../../../../../models/carga_familiar.dart';
import '../../../../../../models/asociado.dart';

class TransferCargaDialog {
  static void show(BuildContext context, CargaFamiliar carga) {
    final CargasFamiliaresController cargasController = Get.find<CargasFamiliaresController>();
    final AsociadosController asociadosController = Get.find<AsociadosController>();
    
    final searchController = TextEditingController();
    final RxString searchQuery = ''.obs;
    final RxList<Asociado> filteredAsociados = <Asociado>[].obs;
    final Rxn<Asociado> selectedAsociado = Rxn<Asociado>();
    final RxBool isLoading = false.obs;

    void loadAsociados() {
      final allAsociados = asociadosController.asociados
          .where((a) => a.id != carga.asociadoId)
          .toList();
      filteredAsociados.value = allAsociados;
    }

    void filterAsociados(String query) {
      if (query.isEmpty) {
        loadAsociados();
        return;
      }

      final queryClean = query.trim();
      final queryLower = queryClean.toLowerCase();
      final querySinFormato = queryClean.replaceAll(RegExp(r'[^0-9kK]'), '');
      
      filteredAsociados.value = asociadosController.asociados
          .where((a) {
            if (a.id == carga.asociadoId) return false;
            
            if (a.sap != null && a.sap!.toLowerCase() == queryLower) return true;
            
            final rutSinFormato = a.rut.replaceAll(RegExp(r'[^0-9kK]'), '').toLowerCase();
            if (rutSinFormato.contains(querySinFormato)) return true;
            if (a.rutFormateado.toLowerCase().contains(queryLower)) return true;
            
            return false;
          })
          .toList();
    }

    Future<void> transferCargaAction() async {
      if (selectedAsociado.value == null) {
        Get.snackbar(
          'Error',
          'Debes seleccionar un asociado',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Get.theme.colorScheme.error.withValues(alpha: 0.8),
          colorText: Get.theme.colorScheme.onError,
        );
        return;
      }

      isLoading.value = true;

      final success = await cargasController.createTransferenciaSolicitud(
        carga: carga,
        nuevoAsociadoId: selectedAsociado.value!.id!,
        nuevoAsociadoNombre: selectedAsociado.value!.nombreCompleto,
      );

      isLoading.value = false;

      if (success && context.mounted) {
        Navigator.of(context).pop();
      }
    }

    loadAsociados();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Focus(
        autofocus: true,
        onKeyEvent: (node, event) {
          if (event is KeyDownEvent) {
            if (event.logicalKey == LogicalKeyboardKey.escape) {
              if (!isLoading.value) {
                Navigator.of(context).pop();
              }
              return KeyEventResult.handled;
            } else if (event.logicalKey == LogicalKeyboardKey.enter) {
              if (!isLoading.value && selectedAsociado.value != null) {
                transferCargaAction();
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
                Icons.swap_horiz,
                color: Color(0xFF10B981),
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Transferir Carga Familiar',
                      style: TextStyle(
                        color: AppTheme.getTextPrimary(context),
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Carga: ${carga.nombreCompleto}',
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
                'ESC para cancelar • Enter para transferir',
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
                // Información del asociado actual
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.getInputBackground(context),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppTheme.getBorderLight(context)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.person, color: AppTheme.primaryColor),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Asociado Actual',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppTheme.getTextSecondary(context),
                              ),
                            ),
                            Text(
                              _getAsociadoActualNombre(carga.asociadoId, asociadosController),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.getTextPrimary(context),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.amber.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.amber.shade700,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Los cambios se reflejarán después de un tiempo',
                          style: TextStyle(
                            color: AppTheme.getTextPrimary(context),
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Campo de búsqueda
                TextField(
                  controller: searchController,
                  onChanged: (value) {
                    searchQuery.value = value;
                    filterAsociados(value);
                  },
                  style: TextStyle(color: AppTheme.getTextPrimary(context)),
                  decoration: InputDecoration(
                    labelText: 'Buscar nuevo asociado',
                    hintText: 'Buscar por RUT o SAP...',
                    prefixIcon: Icon(Icons.search, color: const Color(0xFF10B981)),
                    suffixIcon: Obx(() => searchQuery.value.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              searchController.clear();
                              searchQuery.value = '';
                              loadAsociados();
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
                      borderSide: const BorderSide(color: Color(0xFF10B981), width: 2),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Lista de asociados
                Expanded(
                  child: Obx(() {
                    if (filteredAsociados.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.person_off,
                              size: 64,
                              color: AppTheme.getTextSecondary(context).withValues(alpha: 0.3),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              searchQuery.value.isEmpty
                                  ? 'No hay otros asociados disponibles'
                                  : 'No se encontraron asociados',
                              style: TextStyle(
                                color: AppTheme.getTextSecondary(context),
                                fontSize: 16,
                              ),
                            ),
                            if (searchQuery.value.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  'Intenta buscar por RUT o SAP',
                                  style: TextStyle(
                                    color: AppTheme.getTextSecondary(context),
                                    fontSize: 13,
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
                        itemCount: filteredAsociados.length,
                        separatorBuilder: (context, index) => Divider(
                          height: 1,
                          color: AppTheme.getBorderLight(context),
                        ),
                        itemBuilder: (context, index) {
                          final asociado = filteredAsociados[index];
                          return Obx(() => ListTile(
                            selected: selectedAsociado.value?.id == asociado.id,
                            selectedTileColor: const Color(0xFF10B981).withValues(alpha: 0.1),
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: selectedAsociado.value?.id == asociado.id
                                    ? const Color(0xFF10B981).withValues(alpha: 0.2)
                                    : AppTheme.getInputBackground(context),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.person,
                                color: selectedAsociado.value?.id == asociado.id
                                    ? const Color(0xFF10B981)
                                    : AppTheme.getTextSecondary(context),
                              ),
                            ),
                            title: Text(
                              asociado.nombreCompleto,
                              style: TextStyle(
                                color: AppTheme.getTextPrimary(context),
                                fontWeight: selectedAsociado.value?.id == asociado.id
                                    ? FontWeight.bold
                                    : FontWeight.w600,
                              ),
                            ),
                            subtitle: Row(
                              children: [
                                Text(
                                  asociado.rutFormateado,
                                  style: TextStyle(
                                    color: AppTheme.getTextSecondary(context),
                                    fontSize: 13,
                                  ),
                                ),
                                if (asociado.sap != null && asociado.sap!.isNotEmpty) ...[
                                  const SizedBox(width: 8),
                                  Text(
                                    '• SAP: ${asociado.sap}',
                                    style: TextStyle(
                                      color: AppTheme.getTextSecondary(context),
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            trailing: selectedAsociado.value?.id == asociado.id
                                ? const Icon(
                                    Icons.check_circle,
                                    color: Color(0xFF10B981),
                                  )
                                : null,
                            onTap: () {
                              selectedAsociado.value = asociado;
                            },
                          ));
                        },
                      ),
                    );
                  }),
                ),

                const SizedBox(height: 12),

                Obx(() {
                  if (selectedAsociado.value == null) {
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.getInputBackground(context),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppTheme.getBorderLight(context),
                          style: BorderStyle.solid,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: AppTheme.getTextSecondary(context),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Selecciona un asociado para transferir la carga',
                              style: TextStyle(
                                color: AppTheme.getTextSecondary(context),
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: const Color(0xFF10B981),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.arrow_forward,
                          color: Color(0xFF10B981),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Nuevo Asociado Titular',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.getTextSecondary(context),
                                ),
                              ),
                              Text(
                                selectedAsociado.value!.nombreCompleto,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.getTextPrimary(context),
                                ),
                              ),
                              Text(
                                '${selectedAsociado.value!.rutFormateado}${selectedAsociado.value!.sap != null ? ' • SAP: ${selectedAsociado.value!.sap}' : ''}',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppTheme.getTextSecondary(context),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: isLoading.value ? null : () => Navigator.of(context).pop(),
              child: Text(
                'Cancelar',
                style: TextStyle(
                  color: AppTheme.getTextSecondary(context),
                ),
              ),
            ),
            Obx(() => ElevatedButton(
              onPressed: isLoading.value || selectedAsociado.value == null
                  ? null
                  : transferCargaAction,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: isLoading.value
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text('Transferir Carga'),
            )),
          ],
        ),
      ),
    );
  }

  static String _getAsociadoActualNombre(String asociadoId, AsociadosController controller) {
    final asociado = controller.getAsociadoById(asociadoId);
    if (asociado != null) {
      return '${asociado.nombreCompleto} (${asociado.rutFormateado})';
    }
    return 'Titular desconocido';
  }
}
