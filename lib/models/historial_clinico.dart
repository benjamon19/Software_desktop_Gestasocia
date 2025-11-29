import 'package:cloud_firestore/cloud_firestore.dart';

class HistorialClinico {
  String? id;
  String pacienteId;
  String pacienteTipo;
  String tipoConsulta;
  String odontologo;
  String? odontologoId;
  DateTime fecha;
  String hora;
  String motivoPrincipal;
  String? diagnostico;
  String? tratamientoRealizado;
  String? dienteTratado;
  String? observacionesOdontologo;
  String? alergias;
  String? medicamentosActuales;
  DateTime? proximaCita;
  String estado;
  double? costoTratamiento;
  String? imagenUrl;
  String? imagenLocalPath;
  DateTime fechaCreacion;
  DateTime? fechaActualizacion;

  HistorialClinico({
    this.id,
    required this.pacienteId,
    required this.pacienteTipo,
    required this.tipoConsulta,
    required this.odontologo,
    this.odontologoId,
    required this.fecha,
    required this.hora,
    required this.motivoPrincipal,
    this.diagnostico,
    this.tratamientoRealizado,
    this.dienteTratado,
    this.observacionesOdontologo,
    this.alergias,
    this.medicamentosActuales,
    this.proximaCita,
    required this.estado,
    this.costoTratamiento,
    this.imagenUrl,
    this.imagenLocalPath,
    required this.fechaCreacion,
    this.fechaActualizacion,
  });

  String get fechaFormateada {
    return '${fecha.day.toString().padLeft(2, '0')}/${fecha.month.toString().padLeft(2, '0')}/${fecha.year}';
  }

  String get proximaCitaFormateada {
    if (proximaCita == null) return 'No programada';
    return '${proximaCita!.day.toString().padLeft(2, '0')}/${proximaCita!.month.toString().padLeft(2, '0')}/${proximaCita!.year}';
  }

  String get tipoConsultaFormateado {
    switch (tipoConsulta.toLowerCase()) {
      case 'consulta': return 'Consulta';
      case 'control': return 'Control';
      case 'urgencia': return 'Urgencia';
      case 'tratamiento': return 'Tratamiento';
      default: return tipoConsulta;
    }
  }

  String get estadoFormateado {
    switch (estado.toLowerCase()) {
      case 'completado': return 'Completado';
      case 'pendiente': return 'Pendiente';
      case 'requiere_seguimiento': return 'Requiere Seguimiento';
      default: return estado;
    }
  }

  bool get tieneAlergias => alergias != null && alergias!.isNotEmpty;
  bool get tomaMedicamentos => medicamentosActuales != null && medicamentosActuales!.isNotEmpty;
  bool get tieneImagen => (imagenUrl != null && imagenUrl!.isNotEmpty) || (imagenLocalPath != null && imagenLocalPath!.isNotEmpty);

  static bool validarTipoConsulta(String tipo) {
    return ['consulta', 'control', 'urgencia', 'tratamiento'].contains(tipo.toLowerCase());
  }

  static bool validarEstado(String estado) {
    return ['completado', 'pendiente', 'requiere_seguimiento'].contains(estado.toLowerCase());
  }

  static bool validarPacienteTipo(String tipo) {
    return ['asociado', 'carga'].contains(tipo.toLowerCase());
  }

  Map<String, dynamic> toMap() {
    return {
      'pacienteId': pacienteId,
      'pacienteTipo': pacienteTipo,
      'tipoConsulta': tipoConsulta,
      'odontologo': odontologo,
      'odontologoId': odontologoId,
      'fecha': fecha,
      'hora': hora,
      'motivoPrincipal': motivoPrincipal,
      'diagnostico': diagnostico,
      'tratamientoRealizado': tratamientoRealizado,
      'dienteTratado': dienteTratado,
      'observacionesOdontologo': observacionesOdontologo,
      'alergias': alergias,
      'medicamentosActuales': medicamentosActuales,
      'proximaCita': proximaCita,
      'estado': estado,
      'costoTratamiento': costoTratamiento,
      'imagenUrl': imagenUrl,
      'fechaCreacion': fechaCreacion,
      'fechaActualizacion': fechaActualizacion,
    };
  }

  factory HistorialClinico.fromMap(Map<String, dynamic> map, String id) {
    return HistorialClinico(
      id: id,
      pacienteId: map['pacienteId'] ?? '',
      pacienteTipo: map['pacienteTipo'] ?? 'asociado',
      tipoConsulta: map['tipoConsulta'] ?? 'consulta',
      odontologo: map['odontologo'] ?? '',
      odontologoId: map['odontologoId'],
      fecha: _parseDateTime(map['fecha']),
      hora: map['hora'] ?? '00:00',
      motivoPrincipal: map['motivoPrincipal'] ?? '',
      diagnostico: map['diagnostico'],
      tratamientoRealizado: map['tratamientoRealizado'],
      dienteTratado: map['dienteTratado'],
      observacionesOdontologo: map['observacionesOdontologo'],
      alergias: map['alergias'],
      medicamentosActuales: map['medicamentosActuales'],
      proximaCita: map['proximaCita'] != null ? _parseDateTime(map['proximaCita']) : null,
      estado: map['estado'] ?? 'pendiente',
      costoTratamiento: map['costoTratamiento']?.toDouble(),
      imagenUrl: map['imagenUrl'],
      imagenLocalPath: null,
      fechaCreacion: _parseDateTime(map['fechaCreacion']),
      fechaActualizacion: map['fechaActualizacion'] != null ? _parseDateTime(map['fechaActualizacion']) : null,
    );
  }

  static DateTime _parseDateTime(dynamic fecha) {
    if (fecha == null) return DateTime.now();
    if (fecha is DateTime) return fecha;
    if (fecha is String) {
      try { return DateTime.parse(fecha); } catch (e) { return DateTime.now(); }
    }
    if (fecha is Timestamp) return fecha.toDate();
    return DateTime.now();
  }

  HistorialClinico copyWith({
    String? id,
    String? pacienteId,
    String? pacienteTipo,
    String? tipoConsulta,
    String? odontologo,
    String? odontologoId,
    DateTime? fecha,
    String? hora,
    String? motivoPrincipal,
    String? diagnostico,
    String? tratamientoRealizado,
    String? dienteTratado,
    String? observacionesOdontologo,
    String? alergias,
    String? medicamentosActuales,
    DateTime? proximaCita,
    String? estado,
    double? costoTratamiento,
    String? imagenUrl,
    String? imagenLocalPath,
    DateTime? fechaCreacion,
    DateTime? fechaActualizacion,
  }) {
    return HistorialClinico(
      id: id ?? this.id,
      pacienteId: pacienteId ?? this.pacienteId,
      pacienteTipo: pacienteTipo ?? this.pacienteTipo,
      tipoConsulta: tipoConsulta ?? this.tipoConsulta,
      odontologo: odontologo ?? this.odontologo,
      odontologoId: odontologoId ?? this.odontologoId,
      fecha: fecha ?? this.fecha,
      hora: hora ?? this.hora,
      motivoPrincipal: motivoPrincipal ?? this.motivoPrincipal,
      diagnostico: diagnostico ?? this.diagnostico,
      tratamientoRealizado: tratamientoRealizado ?? this.tratamientoRealizado,
      dienteTratado: dienteTratado ?? this.dienteTratado,
      observacionesOdontologo: observacionesOdontologo ?? this.observacionesOdontologo,
      alergias: alergias ?? this.alergias,
      medicamentosActuales: medicamentosActuales ?? this.medicamentosActuales,
      proximaCita: proximaCita ?? this.proximaCita,
      estado: estado ?? this.estado,
      costoTratamiento: costoTratamiento ?? this.costoTratamiento,
      imagenUrl: imagenUrl ?? this.imagenUrl,
      imagenLocalPath: imagenLocalPath ?? this.imagenLocalPath,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      fechaActualizacion: fechaActualizacion ?? this.fechaActualizacion,
    );
  }

  @override
  String toString() {
    return 'HistorialClinico{id: $id, pacienteId: $pacienteId, pacienteTipo: $pacienteTipo, tipoConsulta: $tipoConsulta, fecha: $fechaFormateada, estado: $estado, odontologoId: $odontologoId}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is HistorialClinico && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}