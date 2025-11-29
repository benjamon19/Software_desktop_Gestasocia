import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../../../../utils/app_theme.dart';
import '../../../../../../controllers/asociados_controller.dart';
import '../../../../../../controllers/cargas_familiares_controller.dart';
import '../../../../../../models/usuario.dart';

class TransferPatientGeneralDialog {
  static void show(
    BuildContext context, {
    required String pacienteId,
    required String pacienteTipo,
    required String nombrePaciente,
    String? currentOdontologoId,
    String? currentOdontologoNombre,
  }) {
    // Controladores
    final AsociadosController asociadosController = Get.find<AsociadosController>();
    
    // Variables Reactivas
    final Rxn<Usuario> selectedOdontologo = Rxn<Usuario>();
    final RxList<Usuario> odontologos = <Usuario>[].obs;
    final isLoadingData = true.obs;
    final isSaving = false.obs;

    // Cargar Odontólogos
    Future<void> loadOdontologos() async {
      try {
        final list = await asociadosController.getAvailableOdontologos();
        odontologos.value = list.where((u) => u.id != currentOdontologoId).toList();
      } catch (e) {
        debugPrint('Error cargando odontólogos: $e');
      } finally {
        isLoadingData.value = false;
      }
    }

    loadOdontologos();

    // Acción Confirmar
    Future<void> confirmTransferAction() async {
      if (selectedOdontologo.value == null) {
        _showError('Debes seleccionar un odontólogo');
        return;
      }

      isSaving.value = true;
      bool success = false;

      try {
        if (pacienteTipo.toLowerCase() == 'asociado') {
          success = await asociadosController.transferirPaciente(
            asociadoId: pacienteId,
            nuevoOdontologoId: selectedOdontologo.value!.id!,
            nuevoOdontologoNombre: selectedOdontologo.value!.nombreCompleto,
          );
        } else if (pacienteTipo.toLowerCase() == 'carga') {
          final cargasController = Get.find<CargasFamiliaresController>();
          success = await cargasController.cambiarOdontologo(
            cargaId: pacienteId,
            nuevoOdontologoId: selectedOdontologo.value!.id!,
            nuevoOdontologoNombre: selectedOdontologo.value!.nombreCompleto,
          );
        }
      } catch (e) {
        _showError('Error al realizar la transferencia');
      } finally {
        isSaving.value = false;
      }
      
      if (success && context.mounted) {
        Navigator.of(context).pop();
      }
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Focus(
        autofocus: true,
        onKeyEvent: (node, event) {
          if (event is KeyDownEvent) {
            if (event.logicalKey == LogicalKeyboardKey.escape) {
              if (!isSaving.value) Navigator.of(context).pop();
              return KeyEventResult.handled;
            } else if (event.logicalKey == LogicalKeyboardKey.enter) {
              if (!isSaving.value && selectedOdontologo.value != null) {
                confirmTransferAction();
              }
              return KeyEventResult.handled;
            }
          }
          return KeyEventResult.ignored;
        },
        child: AlertDialog(
          backgroundColor: AppTheme.getSurfaceColor(context),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Row(
            children: [
              const Icon(Icons.swap_horiz, color: Color(0xFF3B82F6), size: 28),
              const SizedBox(width: 12),
              Text(
                'Transferir Paciente',
                style: TextStyle(color: AppTheme.getTextPrimary(context), fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              Text(
                'ESC cancelar • Enter confirmar',
                style: TextStyle(color: AppTheme.getTextSecondary(context), fontSize: 12),
              ),
            ],
          ),
          content: SizedBox(
            width: 450,
            child: Obx(() => Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- INFO ACTUAL ---
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.getInputBackground(context),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppTheme.getBorderLight(context)),
                  ),
                  child: Column(
                    children: [
                      _buildInfoRow(context, Icons.person, 'Paciente', nombrePaciente),
                      const SizedBox(height: 12),
                      Divider(height: 1, thickness: 0.5, color: AppTheme.getBorderLight(context)),
                      const SizedBox(height: 12),
                      _buildInfoRow(
                        context, 
                        Icons.medical_services, 
                        'Odontólogo Actual', 
                        currentOdontologoNombre ?? 'No asignado',
                        isHighlight: currentOdontologoNombre == null,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
                _sectionTitle(context, 'Nuevo Profesional'),

                // --- DROPDOWN ---
                if (isLoadingData.value)
                  Container(
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppTheme.getInputBackground(context),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppTheme.getBorderLight(context)),
                    ),
                    child: const Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                          SizedBox(width: 8),
                          Text('Cargando profesionales...', style: TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                  )
                else
                  _buildDropdown(
                    context,
                    value: selectedOdontologo.value,
                    hint: 'Seleccione un profesional',
                    items: odontologos,
                    onChanged: (val) => selectedOdontologo.value = val,
                  ),
                  
                if (odontologos.isEmpty && !isLoadingData.value)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0, left: 4),
                    child: Text(
                      'No hay otros odontólogos disponibles.',
                      style: TextStyle(color: Colors.orange.shade700, fontSize: 12),
                    ),
                  ),
              ],
            )),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancelar', style: TextStyle(color: AppTheme.getTextSecondary(context))),
            ),
            Obx(() => ElevatedButton(
              onPressed: selectedOdontologo.value == null || isSaving.value
                  ? null
                  : confirmTransferAction,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                disabledBackgroundColor: AppTheme.primaryColor.withValues(alpha: 0.3),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                elevation: 0,
              ),
              child: isSaving.value
                  ? const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)),
                        SizedBox(width: 10),
                        Text('Guardando...'),
                      ],
                    )
                  : const Text('Confirmar Transferencia'),
            ))
          ],
        ),
      ),
    );
  }

  // --- WIDGETS AUXILIARES ---

  static Widget _buildDropdown(
    BuildContext context, {
    required Usuario? value,
    required String hint,
    required List<Usuario> items,
    required Function(Usuario?) onChanged,
  }) {
    return DropdownButtonFormField<Usuario>(
      initialValue: value, 
      hint: Text(hint, style: TextStyle(color: AppTheme.getTextSecondary(context).withValues(alpha: 0.5), fontSize: 14)),
      items: items.map((u) {
        return DropdownMenuItem(
          value: u,
          child: Text(u.nombreCompleto, style: TextStyle(color: AppTheme.getTextPrimary(context), fontSize: 15)),
        );
      }).toList(),
      onChanged: onChanged,
      icon: Icon(Icons.arrow_drop_down, color: AppTheme.getTextSecondary(context)),
      dropdownColor: AppTheme.getSurfaceColor(context),
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.person_search_outlined, color: AppTheme.primaryColor, size: 20),
        filled: true,
        fillColor: AppTheme.getInputBackground(context),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: AppTheme.getBorderLight(context))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppTheme.primaryColor, width: 1.5)),
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      ),
    );
  }

  static Widget _buildInfoRow(BuildContext context, IconData icon, String label, String value, {bool isHighlight = false}) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppTheme.getTextSecondary(context).withValues(alpha: 0.7)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 12, color: AppTheme.getTextSecondary(context)),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isHighlight ? Colors.orange : AppTheme.getTextPrimary(context),
                  fontStyle: isHighlight ? FontStyle.italic : FontStyle.normal,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  static Widget _sectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(title, style: TextStyle(color: AppTheme.getTextPrimary(context), fontSize: 15, fontWeight: FontWeight.w600)),
    );
  }

  static void _showError(String message) {
    Get.snackbar('Atención', message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.orange.withValues(alpha: 0.8),
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
      duration: const Duration(seconds: 3),
    );
  }
}