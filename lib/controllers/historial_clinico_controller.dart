import 'package:get/get.dart';

class HistorialClinicoController extends GetxController {
  // Estados de vista (como los otros módulos)
  static const int listaView = 0;
  static const int detalleView = 1;

  // Variables observables
  RxBool isLoading = false.obs;
  RxInt currentView = listaView.obs;
  RxString searchQuery = ''.obs;
  RxString selectedFilter = 'todos'.obs; // todos, consulta, control, urgencia, tratamiento
  RxString selectedStatus = 'todos'.obs; // todos, completado, pendiente
  RxString selectedOdontologo = 'todos'.obs; // todos, dr.lopez, dr.martinez, etc.
  
  // Datos
  Rxn<Map<String, dynamic>> selectedHistorial = Rxn<Map<String, dynamic>>();
  RxList<Map<String, dynamic>> historialList = <Map<String, dynamic>>[].obs;
  RxList<Map<String, dynamic>> filteredHistorial = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadSampleData();
  }

  // ========== NAVEGACIÓN ==========

  void selectHistorial(Map<String, dynamic> historial) {
    selectedHistorial.value = historial;
    currentView.value = detalleView;
  }

  void backToList() {
    currentView.value = listaView;
    selectedHistorial.value = null;
  }

  void clearSearch() {
    searchQuery.value = '';
    _applyFilters();
  }

  // ========== BÚSQUEDA ==========

  void searchHistorial(String query) {
    searchQuery.value = query;
    _applyFilters();
  }

  void setFilter(String filter) {
    selectedFilter.value = filter;
    _applyFilters();
  }

  void setStatus(String status) {
    selectedStatus.value = status;
    _applyFilters();
  }

  void setOdontologo(String odontologo) {
    selectedOdontologo.value = odontologo;
    _applyFilters();
  }

  void _applyFilters() {
    List<Map<String, dynamic>> filtered = List.from(historialList);

    // Filtro por búsqueda (nombre o RUT)
    if (searchQuery.value.isNotEmpty) {
      filtered = filtered.where((historial) {
        final nombre = historial['pacienteNombre'].toString().toLowerCase();
        final rut = historial['pacienteRut'].toString().toLowerCase();
        final query = searchQuery.value.toLowerCase();
        
        return nombre.contains(query) || rut.contains(query);
      }).toList();
    }

    // Filtro por tipo de consulta
    if (selectedFilter.value != 'todos') {
      filtered = filtered.where((historial) => 
        historial['tipoConsulta'].toLowerCase() == selectedFilter.value.toLowerCase()
      ).toList();
    }

    // Filtro por estado
    if (selectedStatus.value != 'todos') {
      filtered = filtered.where((historial) => 
        historial['estado'].toLowerCase() == selectedStatus.value.toLowerCase()
      ).toList();
    }

    // Filtro por odontólogo
    if (selectedOdontologo.value != 'todos') {
      filtered = filtered.where((historial) => 
        historial['odontologo'].toLowerCase().contains(selectedOdontologo.value.toLowerCase())
      ).toList();
    }

    filteredHistorial.value = filtered;
  }

  // ========== ACCIONES CRUD ==========

  void addNewHistorial() {
    Get.snackbar('Nuevo Historial', 'Función para agregar nuevo historial clínico');
  }

  void editHistorial() {
    if (selectedHistorial.value != null) {
      Get.snackbar('Editar', 'Función para editar: ${selectedHistorial.value!['pacienteNombre']}');
    }
  }

  void deleteHistorial() {
    if (selectedHistorial.value != null) {
      Get.snackbar('Eliminar', 'Función para eliminar registro médico');
    }
  }

  void duplicateHistorial() {
    if (selectedHistorial.value != null) {
      Get.snackbar('Duplicar', 'Función para duplicar registro como plantilla');
    }
  }

  void exportHistorial() {
    if (selectedHistorial.value != null) {
      Get.snackbar('Exportar', 'Generar PDF del historial: ${selectedHistorial.value!['pacienteNombre']}');
    }
  }

  void printHistorial() {
    if (selectedHistorial.value != null) {
      Get.snackbar('Imprimir', 'Imprimir historial clínico');
    }
  }

  void viewPatientHistory() {
    if (selectedHistorial.value != null) {
      Get.snackbar('Historial Completo', 'Ver todos los registros del paciente');
    }
  }

  // ========== DATOS SIMULADOS ==========

  void _loadSampleData() {
    historialList.value = [
      {
        'id': '1',
        'fecha': '28/06/2025',
        'hora': '09:00',
        'pacienteNombre': 'María Elena González',
        'pacienteRut': '12345678-9',
        'pacienteEdad': 32,
        'pacienteTelefono': '+56 9 1234 5678',
        'asociadoTitular': 'Juan Carlos González',
        'tipoConsulta': 'Consulta',
        'odontologo': 'Dr. López',
        'motivoPrincipal': 'Dolor en muela del juicio',
        'diagnostico': 'Caries profunda en pieza 38',
        'estado': 'Completado',
        // Información médica general
        'condicionesMedicas': ['Hipertensión leve'],
        'medicamentosActuales': ['Losartán 50mg'],
        'alergias': ['Penicilina'],
        'embarazo': false,
        // Antecedentes odontológicos
        'ultimaVisita': '15/03/2025',
        'tratamientosPrevios': ['Limpieza dental', 'Obturación en pieza 26'],
        'problemasFrecuentes': ['Sensibilidad dental'],
        'experienciasNegativas': 'Ninguna',
        // Hábitos
        'higieneDental': 'Cepillado 2 veces al día',
        'habitos': ['Masticar hielo ocasionalmente'],
        'alimentacion': 'Consumo moderado de azúcar',
        // Información de la consulta
        'sintomasReportados': ['Dolor punzante', 'Sensibilidad al frío'],
        'observacionesOdontologo': 'Caries extensa que requiere tratamiento de conducto',
        'tratamientoRecomendado': 'Endodoncia en pieza 38',
        'proximaCita': '05/07/2025',
        'contactoEmergencia': {
          'nombre': 'Carlos González',
          'telefono': '+56 9 8765 4321',
          'relacion': 'Esposo'
        }
      },
      {
        'id': '2',
        'fecha': '27/06/2025',
        'hora': '14:30',
        'pacienteNombre': 'Roberto Silva Martínez',
        'pacienteRut': '87654321-0',
        'pacienteEdad': 45,
        'pacienteTelefono': '+56 9 9876 5432',
        'asociadoTitular': 'Roberto Silva Martínez',
        'tipoConsulta': 'Control',
        'odontologo': 'Dr. Martínez',
        'motivoPrincipal': 'Control post-operatorio',
        'diagnostico': 'Evolución favorable post-extracción',
        'estado': 'Completado',
        'condicionesMedicas': ['Diabetes tipo 2 controlada'],
        'medicamentosActuales': ['Metformina 850mg'],
        'alergias': [],
        'embarazo': false,
        'ultimaVisita': '13/06/2025',
        'tratamientosPrevios': ['Extracción pieza 47'],
        'problemasFrecuentes': ['Gingivitis leve'],
        'experienciasNegativas': 'Ansiedad durante procedimientos',
        'higieneDental': 'Cepillado 3 veces al día, uso de hilo dental',
        'habitos': ['Ex fumador (dejó hace 2 años)'],
        'alimentacion': 'Dieta controlada por diabetes',
        'sintomasReportados': ['Leve molestia en zona de extracción'],
        'observacionesOdontologo': 'Cicatrización adecuada, no hay complicaciones',
        'tratamientoRecomendado': 'Continuar higiene, control en 1 mes',
        'proximaCita': '27/07/2025',
        'contactoEmergencia': {
          'nombre': 'Ana Silva',
          'telefono': '+56 9 5555 4444',
          'relacion': 'Esposa'
        }
      },
      {
        'id': '3',
        'fecha': '26/06/2025',
        'hora': '11:15',
        'pacienteNombre': 'Isabella Rodríguez',
        'pacienteRut': '23456789-1',
        'pacienteEdad': 8,
        'pacienteTelefono': '+56 9 1111 2222',
        'asociadoTitular': 'Carmen Rodríguez',
        'tipoConsulta': 'Urgencia',
        'odontologo': 'Dr. López',
        'motivoPrincipal': 'Trauma dental por caída',
        'diagnostico': 'Fractura coronaria en incisivo central superior',
        'estado': 'Pendiente',
        'condicionesMedicas': [],
        'medicamentosActuales': [],
        'alergias': ['Látex'],
        'embarazo': false,
        'ultimaVisita': '15/01/2025',
        'tratamientosPrevios': ['Aplicación de flúor'],
        'problemasFrecuentes': [],
        'experienciasNegativas': 'Primera experiencia traumática',
        'higieneDental': 'Cepillado con supervisión parental',
        'habitos': ['Chuparse el dedo'],
        'alimentacion': 'Dieta infantil normal, pocos dulces',
        'sintomasReportados': ['Dolor leve', 'Sangrado al momento del trauma'],
        'observacionesOdontologo': 'Fractura requiere restauración estética urgente',
        'tratamientoRecomendado': 'Resina compuesta, posible pulpotomía',
        'proximaCita': '28/06/2025',
        'contactoEmergencia': {
          'nombre': 'Carmen Rodríguez',
          'telefono': '+56 9 1111 2222',
          'relacion': 'Madre'
        }
      },
      {
        'id': '4',
        'fecha': '25/06/2025',
        'hora': '16:00',
        'pacienteNombre': 'Luis Fernando Torres',
        'pacienteRut': '34567890-2',
        'pacienteEdad': 67,
        'pacienteTelefono': '+56 9 3333 4444',
        'asociadoTitular': 'Luis Fernando Torres',
        'tipoConsulta': 'Tratamiento',
        'odontologo': 'Dr. Martínez',
        'motivoPrincipal': 'Adaptación de prótesis dental',
        'diagnostico': 'Prótesis parcial superior necesita ajuste',
        'estado': 'Completado',
        'condicionesMedicas': ['Hipertensión', 'Artritis'],
        'medicamentosActuales': ['Enalapril 10mg', 'Ibuprofeno según necesidad'],
        'alergias': ['Aspirina'],
        'embarazo': false,
        'ultimaVisita': '18/06/2025',
        'tratamientosPrevios': ['Múltiples extracciones', 'Prótesis parcial'],
        'problemasFrecuentes': ['Sequedad bucal'],
        'experienciasNegativas': 'Dificultad inicial con prótesis',
        'higieneDental': 'Limpieza de prótesis diaria',
        'habitos': ['Consumo ocasional de café'],
        'alimentacion': 'Dieta blanda por prótesis',
        'sintomasReportados': ['Molestia al masticar', 'Prótesis se mueve'],
        'observacionesOdontologo': 'Ajuste realizado, mejor retención lograda',
        'tratamientoRecomendado': 'Control periódico, uso de adhesivo',
        'proximaCita': '25/08/2025',
        'contactoEmergencia': {
          'nombre': 'Elena Torres',
          'telefono': '+56 9 7777 8888',
          'relacion': 'Hija'
        }
      },
      {
        'id': '5',
        'fecha': '24/06/2025',
        'hora': '10:30',
        'pacienteNombre': 'Sofía Mendoza Paz',
        'pacienteRut': '45678901-3',
        'pacienteEdad': 28,
        'pacienteTelefono': '+56 9 6666 7777',
        'asociadoTitular': 'Pedro Mendoza',
        'tipoConsulta': 'Consulta',
        'odontologo': 'Dr. López',
        'motivoPrincipal': 'Limpieza dental y evaluación',
        'diagnostico': 'Gingivitis leve, cálculos dentales',
        'estado': 'Completado',
        'condicionesMedicas': [],
        'medicamentosActuales': ['Anticonceptivos orales'],
        'alergias': [],
        'embarazo': false,
        'ultimaVisita': '24/12/2024',
        'tratamientosPrevios': ['Limpiezas anuales'],
        'problemasFrecuentes': ['Sangrado de encías ocasional'],
        'experienciasNegativas': 'Ninguna',
        'higieneDental': 'Cepillado 2 veces al día, uso esporádico de hilo',
        'habitos': ['Consumo regular de té'],
        'alimentacion': 'Dieta equilibrada',
        'sintomasReportados': ['Sangrado leve al cepillarse'],
        'observacionesOdontologo': 'Mejorar técnica de cepillado y uso de hilo dental',
        'tratamientoRecomendado': 'Limpieza profunda, educación en higiene',
        'proximaCita': '24/12/2025',
        'contactoEmergencia': {
          'nombre': 'Pedro Mendoza',
          'telefono': '+56 9 9999 0000',
          'relacion': 'Padre'
        }
      },
    ];

    _applyFilters();
  }

  // ========== GETTERS ==========

  bool get hasSelectedHistorial => selectedHistorial.value != null;
  bool get isListView => currentView.value == listaView;
  bool get isDetailView => currentView.value == detalleView;
  bool get hasSearchQuery => searchQuery.value.isNotEmpty;
  
  String get currentTitle {
    if (isDetailView && hasSelectedHistorial) {
      return 'Historial de ${selectedHistorial.value!['pacienteNombre']}';
    }
    return 'Historial Clínico Odontológico';
  }

  int get totalRegistros => historialList.length;
  int get registrosCompletados => historialList.where((h) => h['estado'] == 'Completado').length;
  int get filteredCount => filteredHistorial.length;
}