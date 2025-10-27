import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../../utils/app_theme.dart';
import '../../../../../../controllers/historial_clinico_controller.dart';

class FormSection extends StatefulWidget {
  final HistorialClinicoController controller;

  const FormSection({super.key, required this.controller});

  @override
  State<FormSection> createState() => _FormSectionState();
}

class _FormSectionState extends State<FormSection> {
  final _formKey = GlobalKey<FormState>();
  
  // Controladores de texto
  final _nombreController = TextEditingController();
  final _rutController = TextEditingController();
  final _edadController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _motivoController = TextEditingController();
  final _diagnosticoController = TextEditingController();
  final _tratamientoController = TextEditingController();
  final _observacionesController = TextEditingController();
  
  String _tipoConsulta = 'consulta';
  String _odontologo = 'dr.lopez';
  String _estado = 'pendiente';

  @override
  void dispose() {
    _nombreController.dispose();
    _rutController.dispose();
    _edadController.dispose();
    _telefonoController.dispose();
    _motivoController.dispose();
    _diagnosticoController.dispose();
    _tratamientoController.dispose();
    _observacionesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.getSurfaceColor(context),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).brightness == Brightness.dark 
                ? Colors.black.withValues(alpha: 0.3)
                : Colors.grey.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.medical_information,
                  color: AppTheme.primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Nuevo Historial Clínico',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
          ),
          
          // Formulario
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('Datos del Paciente'),
                    const SizedBox(height: 16),
                    
                    _buildTextField(
                      controller: _nombreController,
                      label: 'Nombre Completo',
                      icon: Icons.person_outline,
                      hint: 'Juan Pérez González',
                    ),
                    
                    const SizedBox(height: 12),
                    
                    _buildTextField(
                      controller: _rutController,
                      label: 'RUT',
                      icon: Icons.badge_outlined,
                      hint: '12345678-9',
                    ),
                    
                    const SizedBox(height: 12),
                    
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: _edadController,
                            label: 'Edad',
                            icon: Icons.cake_outlined,
                            hint: '32',
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildTextField(
                            controller: _telefonoController,
                            label: 'Teléfono',
                            icon: Icons.phone_outlined,
                            hint: '912345678',
                            keyboardType: TextInputType.phone,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 24),
                    _buildSectionTitle('Información de la Consulta'),
                    const SizedBox(height: 16),
                    
                    _buildDropdown(
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
                        setState(() => _tipoConsulta = value!);
                      },
                    ),
                    
                    const SizedBox(height: 12),
                    
                    _buildDropdown(
                      label: 'Odontólogo',
                      value: _odontologo,
                      items: [
                        {'value': 'dr.lopez', 'label': 'Dr. López'},
                        {'value': 'dr.martinez', 'label': 'Dr. Martínez'},
                      ],
                      icon: Icons.person_outline,
                      onChanged: (value) {
                        setState(() => _odontologo = value!);
                      },
                    ),
                    
                    const SizedBox(height: 12),
                    
                    _buildTextField(
                      controller: _motivoController,
                      label: 'Motivo Principal',
                      icon: Icons.help_outline,
                      hint: 'Ej: Dolor en muela',
                      maxLines: 2,
                    ),
                    
                    const SizedBox(height: 12),
                    
                    _buildTextField(
                      controller: _diagnosticoController,
                      label: 'Diagnóstico',
                      icon: Icons.medical_information_outlined,
                      hint: 'Ej: Caries profunda',
                      maxLines: 2,
                    ),
                    
                    const SizedBox(height: 12),
                    
                    _buildTextField(
                      controller: _tratamientoController,
                      label: 'Tratamiento Recomendado',
                      icon: Icons.healing_outlined,
                      hint: 'Ej: Endodoncia',
                      maxLines: 2,
                    ),
                    
                    const SizedBox(height: 12),
                    
                    _buildTextField(
                      controller: _observacionesController,
                      label: 'Observaciones',
                      icon: Icons.notes_outlined,
                      hint: 'Observaciones adicionales...',
                      maxLines: 3,
                    ),
                    
                    const SizedBox(height: 12),
                    
                    _buildDropdown(
                      label: 'Estado',
                      value: _estado,
                      items: [
                        {'value': 'completado', 'label': 'Completado'},
                        {'value': 'pendiente', 'label': 'Pendiente'},
                      ],
                      icon: Icons.flag_outlined,
                      onChanged: (value) {
                        setState(() => _estado = value!);
                      },
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Botones
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _clearForm,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppTheme.getTextSecondary(context),
                              side: BorderSide(color: AppTheme.getBorderLight(context)),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text('Limpiar'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            onPressed: _saveHistorial,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text('Guardar Historial'),
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

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 16,
          decoration: BoxDecoration(
            color: AppTheme.primaryColor,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppTheme.getTextPrimary(context),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String hint,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, size: 20, color: AppTheme.getTextSecondary(context)),
        filled: true,
        fillColor: AppTheme.getInputBackground(context),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppTheme.getBorderLight(context)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppTheme.getBorderLight(context)),
        ),
        labelStyle: TextStyle(
          color: AppTheme.getTextSecondary(context),
          fontSize: 13,
        ),
        hintStyle: TextStyle(
          color: AppTheme.getTextSecondary(context).withValues(alpha: 0.6),
          fontSize: 13,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
      style: TextStyle(
        color: AppTheme.getTextPrimary(context),
        fontSize: 14,
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<Map<String, String>> items,
    required IconData icon,
    required Function(String?) onChanged,
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
          prefixIcon: Icon(icon, size: 20, color: AppTheme.getTextSecondary(context)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          labelStyle: TextStyle(
            color: AppTheme.getTextSecondary(context),
            fontSize: 13,
          ),
        ),
        dropdownColor: AppTheme.getSurfaceColor(context),
        style: TextStyle(
          color: AppTheme.getTextPrimary(context),
          fontSize: 14,
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
    _nombreController.clear();
    _rutController.clear();
    _edadController.clear();
    _telefonoController.clear();
    _motivoController.clear();
    _diagnosticoController.clear();
    _tratamientoController.clear();
    _observacionesController.clear();
    setState(() {
      _tipoConsulta = 'consulta';
      _odontologo = 'dr.lopez';
      _estado = 'pendiente';
    });
  }

  void _saveHistorial() async {
    if (_formKey.currentState!.validate()) {
      // Validar que los campos requeridos no estén vacíos
      if (_nombreController.text.isEmpty || 
          _rutController.text.isEmpty || 
          _edadController.text.isEmpty) {
        Get.snackbar(
          'Error',
          'Por favor completa los campos obligatorios',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      // Crear el mapa de datos del historial
      final historialData = {
        'pacienteNombre': _nombreController.text.trim(),
        'pacienteRut': _rutController.text.trim(),
        'pacienteEdad': int.tryParse(_edadController.text) ?? 0,
        'pacienteTelefono': _telefonoController.text.trim(),
        'tipoConsulta': _tipoConsulta,
        'odontologo': _odontologo == 'dr.lopez' ? 'Dr. López' : 'Dr. Martínez',
        'motivoPrincipal': _motivoController.text.trim(),
        'diagnostico': _diagnosticoController.text.trim(),
        'tratamientoRecomendado': _tratamientoController.text.trim(),
        'observacionesOdontologo': _observacionesController.text.trim(),
        'estado': _estado == 'completado' ? 'Completado' : 'Pendiente',
        'fecha': DateTime.now(), // Timestamp de Firebase
        'hora': '${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}',
        
        // Campos adicionales opcionales
        'condicionesMedicas': [],
        'medicamentosActuales': [],
        'alergias': [],
        'embarazo': false,
        'ultimaVisita': '',
        'tratamientosPrevios': [],
        'problemasFrecuentes': [],
        'experienciasNegativas': 'Ninguna',
        'higieneDental': '',
        'habitos': [],
        'alimentacion': '',
        'sintomasReportados': [],
        'proximaCita': null,
        'asociadoTitular': _nombreController.text.trim(),
      };

      // Guardar a través del controlador
      await widget.controller.addNewHistorial(historialData);
      
      // Limpiar el formulario después de guardar exitosamente
      _clearForm();
    }
  }
}