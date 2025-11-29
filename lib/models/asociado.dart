import 'package:cloud_firestore/cloud_firestore.dart';

class Asociado {
  String? id;
  String nombre;
  String apellido;
  String rut;
  DateTime fechaNacimiento;
  String estadoCivil;
  String email;
  String telefono;
  String direccion;
  String plan;
  DateTime fechaCreacion;
  DateTime fechaIngreso;
  bool isActive;
  String? codigoBarras;
  String? sap;
  DateTime? ultimaActividad;
  String? odontologoAsignadoId;
  String? odontologoAsignadoNombre;

  Asociado({
    this.id,
    required this.nombre,
    required this.apellido,
    required this.rut,
    required this.fechaNacimiento,
    required this.estadoCivil,
    required this.email,
    required this.telefono,
    required this.direccion,
    required this.plan,
    required this.fechaCreacion,
    required this.fechaIngreso,
    this.isActive = true,
    this.codigoBarras,
    this.sap,
    this.ultimaActividad,
    this.odontologoAsignadoId,
    this.odontologoAsignadoNombre,
  });

  String get nombreCompleto => '$nombre $apellido';

  int get edad {
    final hoy = DateTime.now();
    int edadCalculada = hoy.year - fechaNacimiento.year;
    
    if (hoy.month < fechaNacimiento.month ||
        (hoy.month == fechaNacimiento.month && hoy.day < fechaNacimiento.day)) {
      edadCalculada--;
    }
    return edadCalculada;
  }

  bool get isActivoPorActividad {
    if (ultimaActividad == null) {
      final mesesSinActividad = DateTime.now().difference(fechaIngreso).inDays ~/ 30;
      return mesesSinActividad < 2;
    }
    
    final mesesSinActividad = DateTime.now().difference(ultimaActividad!).inDays ~/ 30;
    return mesesSinActividad < 2;
  }

  bool get estaActivo {
    if (!isActive) return false;
    return isActivoPorActividad;
  }

  Asociado actualizarActividad() {
    return copyWith(ultimaActividad: DateTime.now());
  }
  
  // === FORMATO RUT ===
  String get rutFormateado {
    final rutLimpio = rut.replaceAll(RegExp(r'[^0-9kK]'), '').toUpperCase();
    
    if (rutLimpio.length < 2) return rutLimpio;
    
    final cuerpo = rutLimpio.substring(0, rutLimpio.length - 1);
    final dv = rutLimpio.substring(rutLimpio.length - 1);
    
    String cuerpoFormateado = "";
    int contador = 0;

    for (int i = cuerpo.length - 1; i >= 0; i--) {
      cuerpoFormateado = cuerpo[i] + cuerpoFormateado;
      contador++;
      
      if (contador == 3 && i > 0) {
        cuerpoFormateado = ".$cuerpoFormateado";
        contador = 0;
      }
    }
    
    return "$cuerpoFormateado-$dv";
  }

  String get fechaNacimientoFormateada {
    return '${fechaNacimiento.day.toString().padLeft(2, '0')}/'
          '${fechaNacimiento.month.toString().padLeft(2, '0')}/'
          '${fechaNacimiento.year}';
  }

  String get fechaIngresoFormateada {
    return '${fechaIngreso.day.toString().padLeft(2, '0')}/'
          '${fechaIngreso.month.toString().padLeft(2, '0')}/'
          '${fechaIngreso.year}';
  }

  String get estado => estaActivo ? 'Activo' : 'Inactivo';

  static bool validarRUT(String rut) {
    try {
      String rutLimpio = rut.replaceAll(RegExp(r'[^0-9kK]'), '');
      
      if (rutLimpio.length < 2) return false;
      
      String cuerpo = rutLimpio.substring(0, rutLimpio.length - 1);
      String dv = rutLimpio.substring(rutLimpio.length - 1).toUpperCase();
      
      if (!RegExp(r'^[0-9]+$').hasMatch(cuerpo)) return false;
      
      int suma = 0;
      int multiplicador = 2;
      
      for (int i = cuerpo.length - 1; i >= 0; i--) {
        suma += int.parse(cuerpo[i]) * multiplicador;
        multiplicador = multiplicador == 7 ? 2 : multiplicador + 1;
      }
      
      int resto = suma % 11;
      String dvCalculado = resto == 0 ? '0' : resto == 1 ? 'K' : (11 - resto).toString();
      
      return dv == dvCalculado;
    } catch (e) {
      return false;
    }
  }

  static bool validarEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  static bool validarSAP(String sap) {
    return RegExp(r'^[0-9]{5}$').hasMatch(sap);
  }

  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'apellido': apellido,
      'rut': rut,
      'fechaNacimiento': fechaNacimiento,
      'estadoCivil': estadoCivil,
      'email': email,
      'telefono': telefono,
      'direccion': direccion,
      'plan': plan,
      'fechaCreacion': fechaCreacion,
      'fechaIngreso': fechaIngreso,
      'isActive': isActive,
      'codigoBarras': codigoBarras,
      'sap': sap,
      'ultimaActividad': ultimaActividad,
      'odontologoAsignadoId': odontologoAsignadoId,
      'odontologoAsignadoNombre': odontologoAsignadoNombre,
    };
  }

  factory Asociado.fromMap(Map<String, dynamic> map, String id) {
    return Asociado(
      id: id,
      nombre: map['nombre'] ?? '',
      apellido: map['apellido'] ?? '',
      rut: map['rut'] ?? '',
      fechaNacimiento: _parseDateTime(map['fechaNacimiento']),
      estadoCivil: map['estadoCivil'] ?? '',
      email: map['email'] ?? '',
      telefono: map['telefono'] ?? '',
      direccion: map['direccion'] ?? '',
      plan: map['plan'] ?? '',
      fechaCreacion: _parseDateTime(map['fechaCreacion']),
      fechaIngreso: _parseDateTime(map['fechaIngreso']),
      isActive: map['isActive'] ?? true,
      codigoBarras: map['codigoBarras'],
      sap: map['sap'],
      ultimaActividad: map['ultimaActividad'] != null ? _parseDateTime(map['ultimaActividad']) : null,
      odontologoAsignadoId: map['odontologoAsignadoId'],
      odontologoAsignadoNombre: map['odontologoAsignadoNombre'],
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

  Asociado copyWith({
    String? id,
    String? nombre,
    String? apellido,
    String? rut,
    DateTime? fechaNacimiento,
    String? estadoCivil,
    String? email,
    String? telefono,
    String? direccion,
    String? plan,
    DateTime? fechaCreacion,
    DateTime? fechaIngreso,
    bool? isActive,
    String? codigoBarras,
    String? sap,
    DateTime? ultimaActividad,
    String? odontologoAsignadoId,
    String? odontologoAsignadoNombre,
  }) {
    return Asociado(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      apellido: apellido ?? this.apellido,
      rut: rut ?? this.rut,
      fechaNacimiento: fechaNacimiento ?? this.fechaNacimiento,
      estadoCivil: estadoCivil ?? this.estadoCivil,
      email: email ?? this.email,
      telefono: telefono ?? this.telefono,
      direccion: direccion ?? this.direccion,
      plan: plan ?? this.plan,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      fechaIngreso: fechaIngreso ?? this.fechaIngreso,
      isActive: isActive ?? this.isActive,
      codigoBarras: codigoBarras ?? this.codigoBarras,
      sap: sap ?? this.sap,
      ultimaActividad: ultimaActividad ?? this.ultimaActividad,
      odontologoAsignadoId: odontologoAsignadoId ?? this.odontologoAsignadoId,
      odontologoAsignadoNombre: odontologoAsignadoNombre ?? this.odontologoAsignadoNombre,
    );
  }

  @override
  String toString() {
    return 'Asociado{id: $id, nombreCompleto: $nombreCompleto, email: $email, rut: $rutFormateado, sap: $sap}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Asociado && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}