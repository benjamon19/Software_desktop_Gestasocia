import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:gestasocia/utils/app_theme.dart';
import '../../../../../../controllers/historial_clinico_controller.dart';
import '../../shared/dialog/select_asociado_dialog.dart';

class FormSection extends StatefulWidget {
  final HistorialClinicoController controller;

  const FormSection({super.key, required this.controller});

  @override
  State<FormSection> createState() => _FormSectionState();
}

class _FormSectionState extends State<FormSection> {
  final _formKey = GlobalKey<FormState>();
  
  // Paciente seleccionado
  Map<String, dynamic>? _selectedPaciente;
  
  // Controladores de texto
  final _motivoController = TextEditingController();
  final _diagnosticoController = TextEditingController();
  final _tratamientoRecomendadoController = TextEditingController();
  final _tratamientoRealizadoController = TextEditingController();
  final _dienteTratadoController = TextEditingController();
  final _observacionesController = TextEditingController();
  final _alergiasController = TextEditingController();
  final _medicamentosController = TextEditingController();
  final _costoController = TextEditingController();
  
  String _tipoConsulta = 'consulta';
  String _odontologo = 'ejemplo1'; // ← Cambiado a ejemplo1
  String _estado = 'pendiente';
  DateTime? _proximaCita;

  @override
  void dispose() {
    _motivoController.dispose();
    _diagnosticoController.dispose();
    _tratamientoRecomendadoController.dispose();
    _tratamientoRealizadoController.dispose();
    _dienteTratadoController.dispose();
    _observacionesController.dispose();
    _alergiasController.dispose();
    _medicamentosController.dispose();
    _costoController.dispose();
    super.dispose();
  }
  
  Future<void> _selectPaciente() async {
    final paciente = await SelectPacienteDialog.show(context);
    if (paciente != null) {
      if (!mounted) return;
      setState(() {
        _selectedPaciente = paciente;
      });
    }
  }

  Future<void> _selectProximaCita() async {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: _proximaCita ?? DateTime.now().add(const Duration(days: 7)),
        firstDate: DateTime.now(),
        lastDate: DateTime.now().add(const Duration(days: 365)),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: Theme.of(context).colorScheme.copyWith(
                primary: AppTheme.primaryColor,
                onPrimary: Colors.white,
                surface: AppTheme.getSurfaceColor(context),
                onSurface: AppTheme.getTextPrimary(context),
              ),
            ),
            child: child!,
          );
        },
      );
      
      if (picked != null) {
        if (!mounted) return;
        setState(() {
          _proximaCita = picked;
        });
      }
    }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isSmallScreen = screenWidth < 600;
    
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.getSurfaceColor(context),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).brightness == Brightness.dark 
                ? Colors.black.withValues(alpha: 0.3)
                : Colors.grey.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header compacto y profesional
          Padding(
            padding: EdgeInsets.all(isSmallScreen ? 14 : 16),
            child: Row(
              children: [
                Icon(
                  Icons.medical_information_outlined,
                  color: AppTheme.primaryColor,
                  size: isSmallScreen ? 18 : 20,
                ),
                SizedBox(width: isSmallScreen ? 10 : 12),
                Expanded(
                  child: Text(
                    'Nuevo Historial Clínico',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 15 : 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.getTextPrimary(context),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'Requerido *',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Línea divisoria sutil
          Container(
            height: 1,
            margin: EdgeInsets.symmetric(horizontal: isSmallScreen ? 12 : 16),
            color: AppTheme.getTextSecondary(context).withValues(alpha: 0.1),
          ),
          
          // Formulario
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(isSmallScreen ? 14 : 16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Sección: Datos del Paciente
                    Row(
                      children: [
                        Expanded(
                          child: _buildSectionHeader(
                            context,
                            'Datos del asociado o carga',
                            Icons.person_outline,
                            isSmallScreen,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    
                    // Botón para seleccionar paciente
                    InkWell(
                      onTap: _selectPaciente,
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: _selectedPaciente == null
                              ? AppTheme.getInputBackground(context)
                              : AppTheme.primaryColor.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: _selectedPaciente == null
                                ? AppTheme.getBorderLight(context)
                                : AppTheme.primaryColor,
                            width: _selectedPaciente == null ? 1 : 2,
                          ),
                        ),
                        child: _selectedPaciente == null
                            ? Row(
                                children: [
                                  Icon(
                                    Icons.person_search,
                                    color: AppTheme.primaryColor,
                                    size: 24,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Seleccionar asociado o carga *',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: AppTheme.getTextPrimary(context),
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'Haz clic para buscar un asociado o carga familiar',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: AppTheme.getTextSecondary(context),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(
                                    Icons.chevron_right,
                                    color: AppTheme.getTextSecondary(context),
                                  ),
                                ],
                              )
                            : Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: AppTheme.primaryColor.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      _selectedPaciente!['tipo'] == 'asociado'
                                          ? Icons.person
                                          : Icons.family_restroom,
                                      color: AppTheme.primaryColor,
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                _selectedPaciente!['nombre'],
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
                                                  color: AppTheme.getTextPrimary(context),
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: _selectedPaciente!['tipo'] == 'asociado'
                                                    ? const Color(0xFF3B82F6).withValues(alpha: 0.1)
                                                    : const Color(0xFF10B981).withValues(alpha: 0.1),
                                                borderRadius: BorderRadius.circular(4),
                                              ),
                                              child: Text(
                                                _selectedPaciente!['tipo'] == 'asociado' ? 'Asociado' : 'Carga',
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w600,
                                                  color: _selectedPaciente!['tipo'] == 'asociado'
                                                      ? const Color(0xFF3B82F6)
                                                      : const Color(0xFF10B981),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${_selectedPaciente!['rut']} • ${_selectedPaciente!['edad']} años',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: AppTheme.getTextSecondary(context),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      if (!mounted) return;
                                      setState(() {
                                        _selectedPaciente = null;
                                      });
                                    },
                                    icon: Icon(
                                      Icons.close,
                                      color: AppTheme.getTextSecondary(context),
                                      size: 20,
                                    ),
                                    tooltip: 'Quitar selección',
                                  ),
                                ],
                              ),
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Sección: Información de la Consulta
                    _buildSectionHeader(
                      context,
                      'Información de la Consulta',
                      Icons.medical_services_outlined,
                      isSmallScreen,
                    ),
                    const SizedBox(height: 12),
                    
                    Row(
                      children: [
                        Expanded(
                          child: _buildDropdown(
                            context: context,
                            label: 'Tipo de Consulta',
                            value: _tipoConsulta,
                            items: [
                              {'value': 'consulta', 'label': 'Consulta'},
                              {'value': 'control', 'label': 'Control'},
                              {'value': 'urgencia', 'label': 'Urgencia'},
                              {'value': 'tratamiento', 'label': 'Tratamiento'},
                            ],
                            icon: Icons.medical_services_outlined,
                            onChanged: (value) {
                              if (!mounted) return;
                              setState(() => _tipoConsulta = value!);
                            },
                            isSmallScreen: isSmallScreen,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildDropdown(
                            context: context,
                            label: 'Odontólogo',
                            value: _odontologo,
                            items: [
                              {'value': 'ejemplo1', 'label': 'Ejemplo 1'}, // ← Cambiado
                              {'value': 'ejemplo2', 'label': 'Ejemplo 2'}, // ← Cambiado
                            ],
                            icon: Icons.person_outline,
                            onChanged: (value) {
                              if (!mounted) return;
                              setState(() => _odontologo = value!);
                            },
                            isSmallScreen: isSmallScreen,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 10),
                    
                    _buildTextField(
                      context: context,
                      controller: _motivoController,
                      label: 'Motivo de Consulta',
                      icon: Icons.description_outlined,
                      hint: 'Ej: Dolor en muela del juicio',
                      maxLines: 2,
                      isSmallScreen: isSmallScreen,
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Sección: Diagnóstico y Tratamiento
                    _buildSectionHeader(
                      context,
                      'Diagnóstico y Tratamiento',
                      Icons.healing_outlined,
                      isSmallScreen,
                    ),
                    const SizedBox(height: 12),
                    
                    _buildTextField(
                      context: context,
                      controller: _diagnosticoController,
                      label: 'Diagnóstico',
                      icon: Icons.local_hospital_outlined,
                      hint: 'Ej: Caries profunda en molar inferior',
                      maxLines: 2,
                      isSmallScreen: isSmallScreen,
                    ),
                    
                    const SizedBox(height: 10),
                    
                    _buildTextField(
                      context: context,
                      controller: _tratamientoRecomendadoController,
                      label: 'Tratamiento Recomendado',
                      icon: Icons.assignment_outlined,
                      hint: 'Ej: Endodoncia + corona',
                      maxLines: 2,
                      isSmallScreen: isSmallScreen,
                    ),
                    
                    const SizedBox(height: 10),
                    
                    _buildTextField(
                      context: context,
                      controller: _tratamientoRealizadoController,
                      label: 'Tratamiento Realizado',
                      icon: Icons.medication_outlined,
                      hint: 'Ej: Limpieza dental profunda',
                      maxLines: 2,
                      isSmallScreen: isSmallScreen,
                    ),
                    
                    const SizedBox(height: 10),
                    
                    _buildTextField(
                      context: context,
                      controller: _dienteTratadoController,
                      label: 'Diente(s) Tratado(s)',
                      icon: Icons.medical_services,
                      hint: 'Ej: 16, 17 o Molar superior derecho',
                      maxLines: 1,
                      isSmallScreen: isSmallScreen,
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Sección: Información Médica
                    _buildSectionHeader(
                      context,
                      'Información Médica Importante',
                      Icons.health_and_safety_outlined,
                      isSmallScreen,
                    ),
                    const SizedBox(height: 12),
                    
                    _buildTextField(
                      context: context,
                      controller: _alergiasController,
                      label: 'Alergias',
                      icon: Icons.warning_outlined,
                      hint: 'Ej: Penicilina, látex, anestesia',
                      maxLines: 2,
                      isSmallScreen: isSmallScreen,
                    ),
                    
                    const SizedBox(height: 10),
                    
                    _buildTextField(
                      context: context,
                      controller: _medicamentosController,
                      label: 'Medicamentos Actuales',
                      icon: Icons.medication_liquid_outlined,
                      hint: 'Ej: Ibuprofeno 400mg cada 8 horas',
                      maxLines: 2,
                      isSmallScreen: isSmallScreen,
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Sección: Seguimiento y Costos
                    _buildSectionHeader(
                      context,
                      'Seguimiento y Costos',
                      Icons.event_outlined,
                      isSmallScreen,
                    ),
                    const SizedBox(height: 12),
                    
                    // Próxima cita
                    InkWell(
                      onTap: _selectProximaCita,
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.getInputBackground(context),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: _proximaCita != null
                                ? AppTheme.primaryColor
                                : AppTheme.getBorderLight(context),
                            width: _proximaCita != null ? 1.5 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.calendar_today_outlined,
                              color: AppTheme.primaryColor,
                              size: isSmallScreen ? 18 : 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Próxima Cita',
                                    style: TextStyle(
                                      fontSize: isSmallScreen ? 12 : 13,
                                      color: AppTheme.getTextSecondary(context),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    _proximaCita != null
                                        ? '${_proximaCita!.day.toString().padLeft(2, '0')}/${_proximaCita!.month.toString().padLeft(2, '0')}/${_proximaCita!.year}'
                                        : 'Seleccionar fecha (opcional)',
                                    style: TextStyle(
                                      fontSize: isSmallScreen ? 13 : 14,
                                      fontWeight: _proximaCita != null ? FontWeight.w600 : FontWeight.normal,
                                      color: _proximaCita != null
                                          ? AppTheme.getTextPrimary(context)
                                          : AppTheme.getTextSecondary(context).withValues(alpha: 0.5),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (_proximaCita != null)
                              IconButton(
                                onPressed: () {
                                  if (!mounted) return;
                                  setState(() {
                                    _proximaCita = null;
                                  });
                                },
                                icon: Icon(
                                  Icons.close,
                                  color: AppTheme.getTextSecondary(context),
                                  size: 18,
                                ),
                                tooltip: 'Quitar fecha',
                              )
                            else
                              Icon(
                                Icons.chevron_right,
                                color: AppTheme.getTextSecondary(context),
                              ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 10),
                    
                    _buildTextField(
                      context: context,
                      controller: _costoController,
                      label: 'Costo del Tratamiento',
                      icon: Icons.attach_money,
                      hint: 'Ej: 50000',
                      maxLines: 1,
                      keyboardType: TextInputType.number,
                      isSmallScreen: isSmallScreen,
                    ),
                    
                    const SizedBox(height: 10),
                    
                    _buildDropdown(
                      context: context,
                      label: 'Estado del Registro',
                      value: _estado,
                      items: [
                        {'value': 'completado', 'label': 'Completado'},
                        {'value': 'pendiente', 'label': 'Pendiente'},
                        {'value': 'requiere_seguimiento', 'label': 'Requiere Seguimiento'},
                      ],
                      icon: Icons.flag_outlined,
                      onChanged: (value) {
                        if (!mounted) return;
                        setState(() => _estado = value!);
                      },
                      isSmallScreen: isSmallScreen,
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Sección: Observaciones
                    _buildSectionHeader(
                      context,
                      'Observaciones Adicionales',
                      Icons.notes_outlined,
                      isSmallScreen,
                    ),
                    const SizedBox(height: 12),
                    
                    _buildTextField(
                      context: context,
                      controller: _observacionesController,
                      label: 'Notas del Odontólogo',
                      icon: Icons.notes_outlined,
                      hint: 'Notas importantes sobre el caso...',
                      maxLines: 3,
                      isSmallScreen: isSmallScreen,
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Botones de acción
                    Row(
                      children: [
                        Expanded(
                          child: TextButton.icon(
                            onPressed: _clearForm,
                            label: Text(isSmallScreen ? 'Limpiar' : 'Limpiar Formulario'),
                            style: TextButton.styleFrom(
                              foregroundColor: AppTheme.getTextSecondary(context),
                              padding: EdgeInsets.symmetric(
                                vertical: isSmallScreen ? 12 : 14,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton.icon(
                            onPressed: _saveHistorial,
                            label: Text(isSmallScreen ? 'Guardar' : 'Guardar Historial'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryColor,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(
                                vertical: isSmallScreen ? 12 : 14,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              elevation: 0,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    IconData icon,
    bool isSmallScreen,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(
            icon,
            size: isSmallScreen ? 14 : 16,
            color: AppTheme.primaryColor,
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: TextStyle(
            fontSize: isSmallScreen ? 13 : 14,
            fontWeight: FontWeight.w600,
            color: AppTheme.getTextPrimary(context),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required BuildContext context,
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String hint,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    bool isRequired = false,
    required bool isSmallScreen,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      inputFormatters: keyboardType == TextInputType.number
          ? [FilteringTextInputFormatter.digitsOnly]
          : null,
      style: TextStyle(
        color: AppTheme.getTextPrimary(context),
        fontSize: isSmallScreen ? 13 : 14,
      ),
      decoration: InputDecoration(
        labelText: isRequired ? '$label *' : label,
        hintText: hint,
        prefixIcon: Icon(
          icon,
          size: isSmallScreen ? 18 : 20,
          color: AppTheme.primaryColor,
        ),
        filled: true,
        fillColor: AppTheme.getInputBackground(context),
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
          borderSide: BorderSide(color: AppTheme.primaryColor, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
        labelStyle: TextStyle(
          color: AppTheme.getTextSecondary(context),
          fontSize: isSmallScreen ? 12 : 13,
        ),
        hintStyle: TextStyle(
          color: AppTheme.getTextSecondary(context).withValues(alpha: 0.5),
          fontSize: isSmallScreen ? 12 : 13,
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: 12,
          vertical: isSmallScreen ? 10 : 12,
        ),
      ),
      validator: isRequired
          ? (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Este campo es requerido';
              }
              return null;
            }
          : null,
    );
  }

  Widget _buildDropdown({
    required BuildContext context,
    required String label,
    required String value,
    required List<Map<String, String>> items,
    required IconData icon,
    required Function(String?) onChanged,
    required bool isSmallScreen,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.getInputBackground(context),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.getBorderLight(context)),
      ),
      child: DropdownButtonFormField<String>(
        initialValue: value,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(
            icon,
            size: isSmallScreen ? 18 : 20,
            color: AppTheme.primaryColor,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 12,
            vertical: isSmallScreen ? 10 : 12,
          ),
          labelStyle: TextStyle(
            color: AppTheme.getTextSecondary(context),
            fontSize: isSmallScreen ? 12 : 13,
          ),
        ),
        dropdownColor: AppTheme.getSurfaceColor(context),
        style: TextStyle(
          color: AppTheme.getTextPrimary(context),
          fontSize: isSmallScreen ? 13 : 14,
        ),
        icon: Icon(
          Icons.keyboard_arrow_down,
          color: AppTheme.getTextSecondary(context),
        ),
        items: items.map((item) {
          return DropdownMenuItem<String>(
            value: item['value'],
            child: Text(item['label']!),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  void _clearForm() {
    if (!mounted) return;
    
    _motivoController.clear();
    _diagnosticoController.clear();
    _tratamientoRecomendadoController.clear();
    _tratamientoRealizadoController.clear();
    _dienteTratadoController.clear();
    _observacionesController.clear();
    _alergiasController.clear();
    _medicamentosController.clear();
    _costoController.clear();
    
    setState(() {
      _selectedPaciente = null;
      _tipoConsulta = 'consulta';
      _odontologo = 'ejemplo1'; // ← Reiniciar a ejemplo1
      _estado = 'pendiente';
      _proximaCita = null;
    });
  }

  void _saveHistorial() async {
    if (!mounted) return;

    if (_formKey.currentState!.validate()) {
      if (_selectedPaciente == null) {
        Get.snackbar(
          'Error',
          'Debes seleccionar un paciente',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withValues(alpha: 0.1),
          colorText: Colors.red,
          duration: const Duration(seconds: 3),
          margin: const EdgeInsets.all(16),
          borderRadius: 8,
          icon: const Icon(Icons.error_outline, color: Colors.red),
        );
        return;
      }

      if (!mounted) return;

      // Parsear costo si existe
      double? costo;
      if (_costoController.text.trim().isNotEmpty) {
        costo = double.tryParse(_costoController.text.trim());
      }

      final historialData = {
        // Información del paciente
        'pacienteId': _selectedPaciente!['id'],
        'pacienteTipo': _selectedPaciente!['tipo'],
        'pacienteNombre': _selectedPaciente!['nombre'],
        'pacienteRut': _selectedPaciente!['rut'],
        'pacienteEdad': _selectedPaciente!['edad'],
        'pacienteTelefono': _selectedPaciente!['telefono'] ?? '',
        
        // Información de la consulta
        'tipoConsulta': _tipoConsulta,
        'odontologo': _odontologo, // ← Guarda "ejemplo1" o "ejemplo2" directamente
        'fecha': DateTime.now(),
        'hora': '${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}',
        'motivoPrincipal': _motivoController.text.trim(),
        
        // Diagnóstico y tratamiento
        'diagnostico': _diagnosticoController.text.trim().isEmpty ? null : _diagnosticoController.text.trim(),
        'tratamientoRecomendado': _tratamientoRecomendadoController.text.trim().isEmpty ? null : _tratamientoRecomendadoController.text.trim(),
        'tratamientoRealizado': _tratamientoRealizadoController.text.trim().isEmpty ? null : _tratamientoRealizadoController.text.trim(),
        'dienteTratado': _dienteTratadoController.text.trim().isEmpty ? null : _dienteTratadoController.text.trim(),
        'observacionesOdontologo': _observacionesController.text.trim().isEmpty ? null : _observacionesController.text.trim(),
        
        // Información médica
        'alergias': _alergiasController.text.trim().isEmpty ? null : _alergiasController.text.trim(),
        'medicamentosActuales': _medicamentosController.text.trim().isEmpty ? null : _medicamentosController.text.trim(),
        
        // Seguimiento
        'proximaCita': _proximaCita,
        'estado': _estado == 'completado' ? 'Completado' : (_estado == 'pendiente' ? 'Pendiente' : 'Requiere Seguimiento'),
        'costoTratamiento': costo,
        
        // Metadata
        'fechaCreacion': DateTime.now(),
        'fechaActualizacion': null,
        
        // Campos adicionales heredados (mantener compatibilidad)
        'condicionesMedicas': [],
        'embarazo': false,
        'ultimaVisita': '',
        'tratamientosPrevios': [],
        'problemasFrecuentes': [],
        'experienciasNegativas': 'Ninguna',
        'higieneDental': '',
        'habitos': [],
        'alimentacion': '',
        'sintomasReportados': [],
        'asociadoTitular': _selectedPaciente!['nombre'],
      };

      try {
        await widget.controller.addNewHistorial(historialData);
        if (!mounted) return;
        
        _clearForm();
        
        Get.snackbar(
          'Éxito',
          'Historial clínico guardado correctamente',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF10B981).withValues(alpha: 0.1),
          colorText: const Color(0xFF10B981),
          duration: const Duration(seconds: 3),
          margin: const EdgeInsets.all(16),
          borderRadius: 8,
          icon: const Icon(Icons.check_circle, color: Color(0xFF10B981)),
        );
      } catch (e) {
        if (!mounted) return;
        Get.snackbar(
          'Error',
          'No se pudo guardar el historial: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withValues(alpha: 0.1),
          colorText: Colors.red,
          duration: const Duration(seconds: 3),
          margin: const EdgeInsets.all(16),
          borderRadius: 8,
          icon: const Icon(Icons.error_outline, color: Colors.red),
        );
      }
    }
  }
}