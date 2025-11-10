import 'package:cloud_firestore/cloud_firestore.dart';

class HistorialClinico {
  String? id;

  // Referencia al paciente (asociado o carga familiar)
  String pacienteId; // ID del documento en 'asociados' o 'cargas_familiares'
  String pacienteTipo; // 'asociado' o 'carga'

  // Información de la consulta
  String tipoConsulta; // 'consulta', 'control', 'urgencia', 'tratamiento'
  String odontologo;
  DateTime fecha;
  String hora; // Formato HH:mm
  String motivoPrincipal;
  String? diagnostico;
  String? tratamientoRecomendado;
  String? observacionesOdontologo;
  String estado; // 'completado', 'pendiente'

  // Metadata
  DateTime fechaCreacion;
  DateTime? fechaActualizacion;

  HistorialClinico({
    this.id,
    required this.pacienteId,
    required this.pacienteTipo,
    required this.tipoConsulta,
    required this.odontologo,
    required this.fecha,
    required this.hora,
    required this.motivoPrincipal,
    this.diagnostico,
    this.tratamientoRecomendado,
    this.observacionesOdontologo,
    required this.estado,
    required this.fechaCreacion,
    this.fechaActualizacion,
  });

  // Getters útiles
  String get fechaFormateada {
    return '${fecha.day.toString().padLeft(2, '0')}/'
           '${fecha.month.toString().padLeft(2, '0')}/'
           '${fecha.year}';
  }

  String get tipoConsultaFormateado {
    switch (tipoConsulta.toLowerCase()) {
      case 'consulta':
        return 'Consulta';
      case 'control':
        return 'Control';
      case 'urgencia':
        return 'Urgencia';
      case 'tratamiento':
        return 'Tratamiento';
      default:
        return tipoConsulta;
    }
  }

  String get estadoFormateado {
    switch (estado.toLowerCase()) {
      case 'completado':
        return 'Completado';
      case 'pendiente':
        return 'Pendiente';
      default:
        return estado;
    }
  }

  // Validaciones
  static bool validarTipoConsulta(String tipo) {
    return ['consulta', 'control', 'urgencia', 'tratamiento'].contains(tipo.toLowerCase());
  }

  static bool validarEstado(String estado) {
    return ['completado', 'pendiente'].contains(estado.toLowerCase());
  }

  static bool validarPacienteTipo(String tipo) {
    return ['asociado', 'carga'].contains(tipo.toLowerCase());
  }

  // Conversión a Map para Firestore
  Map<String, dynamic> toMap() {
    return {
      'pacienteId': pacienteId,
      'pacienteTipo': pacienteTipo,
      'tipoConsulta': tipoConsulta,
      'odontologo': odontologo,
      'fecha': fecha,
      'hora': hora,
      'motivoPrincipal': motivoPrincipal,
      'diagnostico': diagnostico,
      'tratamientoRecomendado': tratamientoRecomendado,
      'observacionesOdontologo': observacionesOdontologo,
      'estado': estado,
      'fechaCreacion': fechaCreacion,
      'fechaActualizacion': fechaActualizacion,
    };
  }

  // Crear desde Map de Firestore
  factory HistorialClinico.fromMap(Map<String, dynamic> map, String id) {
    return HistorialClinico(
      id: id,
      pacienteId: map['pacienteId'] ?? '',
      pacienteTipo: map['pacienteTipo'] ?? 'asociado',
      tipoConsulta: map['tipoConsulta'] ?? 'consulta',
      odontologo: map['odontologo'] ?? '',
      fecha: _parseDateTime(map['fecha']),
      hora: map['hora'] ?? '00:00',
      motivoPrincipal: map['motivoPrincipal'] ?? '',
      diagnostico: map['diagnostico'],
      tratamientoRecomendado: map['tratamientoRecomendado'],
      observacionesOdontologo: map['observacionesOdontologo'],
      estado: map['estado'] ?? 'pendiente',
      fechaCreacion: _parseDateTime(map['fechaCreacion']),
      fechaActualizacion: map['fechaActualizacion'] != null ? _parseDateTime(map['fechaActualizacion']) : null,
    );
  }

  static DateTime _parseDateTime(dynamic fecha) {
    if (fecha == null) return DateTime.now();
    
    if (fecha is DateTime) {
      return fecha;
    } else if (fecha is String) {
      try {
        return DateTime.parse(fecha);
      } catch (e) {
        return DateTime.now();
      }
    } else if (fecha is Timestamp) {
      return fecha.toDate();
    } else {
      return DateTime.now();
    }
  }

  HistorialClinico copyWith({
    String? id,
    String? pacienteId,
    String? pacienteTipo,
    String? tipoConsulta,
    String? odontologo,
    DateTime? fecha,
    String? hora,
    String? motivoPrincipal,
    String? diagnostico,
    String? tratamientoRecomendado,
    String? observacionesOdontologo,
    String? estado,
    DateTime? fechaCreacion,
    DateTime? fechaActualizacion,
  }) {
    return HistorialClinico(
      id: id ?? this.id,
      pacienteId: pacienteId ?? this.pacienteId,
      pacienteTipo: pacienteTipo ?? this.pacienteTipo,
      tipoConsulta: tipoConsulta ?? this.tipoConsulta,
      odontologo: odontologo ?? this.odontologo,
      fecha: fecha ?? this.fecha,
      hora: hora ?? this.hora,
      motivoPrincipal: motivoPrincipal ?? this.motivoPrincipal,
      diagnostico: diagnostico ?? this.diagnostico,
      tratamientoRecomendado: tratamientoRecomendado ?? this.tratamientoRecomendado,
      observacionesOdontologo: observacionesOdontologo ?? this.observacionesOdontologo,
      estado: estado ?? this.estado,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      fechaActualizacion: fechaActualizacion ?? this.fechaActualizacion,
    );
  }

  @override
  String toString() {
    return 'HistorialClinico{id: $id, pacienteId: $pacienteId, pacienteTipo: $pacienteTipo, tipoConsulta: $tipoConsulta, fecha: $fechaFormateada, estado: $estado}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is HistorialClinico && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}