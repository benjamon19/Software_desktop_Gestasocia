import 'package:cloud_firestore/cloud_firestore.dart';

class CargaFamiliar {
  String? id;
  String asociadoId;
  String nombre;
  String apellido;
  String rut;
  String parentesco;
  DateTime fechaNacimiento;
  DateTime fechaCreacion;
  bool isActive;
  DateTime? ultimaActividad;
  String? codigoBarras;
  String? sap;
  String? ultimaVisita;
  String? proximaCita;
  List<String>? alertas;
  
  // Información de contacto de la carga
  String? email;
  String? telefono;
  String? direccion;

  CargaFamiliar({
    this.id,
    required this.asociadoId,
    required this.nombre,
    required this.apellido,
    required this.rut,
    required this.parentesco,
    required this.fechaNacimiento,
    required this.fechaCreacion,
    this.isActive = true,
    this.ultimaActividad,
    this.codigoBarras,
    this.sap,
    this.ultimaVisita,
    this.proximaCita,
    this.alertas,
    this.email,
    this.telefono,
    this.direccion,
  });

  String get nombreCompleto => '$nombre $apellido';
  
  String get rutFormateado {
    final rutLimpio = rut.replaceAll(RegExp(r'[^0-9kK]'), '');
    
    if (rutLimpio.length < 2) return rutLimpio;
    
    String cuerpo = rutLimpio.substring(0, rutLimpio.length - 1);
    String dv = rutLimpio.substring(rutLimpio.length - 1);
    
    String cuerpoFormateado = '';
    for (int i = cuerpo.length - 1; i >= 0; i--) {
      if ((cuerpo.length - i) % 3 == 1 && i != cuerpo.length - 1) {
        cuerpoFormateado = '.$cuerpoFormateado';
      }
      cuerpoFormateado = '${cuerpo[i]}$cuerpoFormateado';
    }
    
    return '$cuerpoFormateado-$dv';
  }

  String get fechaNacimientoFormateada {
    return '${fechaNacimiento.day.toString().padLeft(2, '0')}/'
           '${fechaNacimiento.month.toString().padLeft(2, '0')}/'
           '${fechaNacimiento.year}';
  }

  String get fechaCreacionFormateada {
    return '${fechaCreacion.day.toString().padLeft(2, '0')}/'
           '${fechaCreacion.month.toString().padLeft(2, '0')}/'
           '${fechaCreacion.year}';
  }

  bool get isActivoPorActividad {
    if (ultimaActividad == null) {
      final mesesSinActividad = DateTime.now().difference(fechaCreacion).inDays ~/ 30;
      return mesesSinActividad < 2;
    }
    
    final mesesSinActividad = DateTime.now().difference(ultimaActividad!).inDays ~/ 30;
    return mesesSinActividad < 2;
  }

  bool get estaActivo {
    if (!isActive) return false;
    return isActivoPorActividad;
  }

  CargaFamiliar actualizarActividad() {
    return copyWith(ultimaActividad: DateTime.now());
  }

  String get estado => estaActivo ? 'Activa' : 'Inactiva';

  int get edad {
    final now = DateTime.now();
    int age = now.year - fechaNacimiento.year;
    if (now.month < fechaNacimiento.month || 
        (now.month == fechaNacimiento.month && now.day < fechaNacimiento.day)) {
      age--;
    }
    return age;
  }

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

  static bool validarParentesco(String parentesco) {
    final parentescosValidos = ['Hijo', 'Hija', 'Cónyuge'];
    return parentescosValidos.contains(parentesco);
  }

  static bool validarSAP(String sap) {
    return RegExp(r'^[0-9]{5}$').hasMatch(sap);
  }

  Map<String, dynamic> toMap() {
    return {
      'asociadoId': asociadoId,
      'nombre': nombre,
      'apellido': apellido,
      'rut': rut,
      'parentesco': parentesco,
      'fechaNacimiento': fechaNacimiento,
      'fechaCreacion': fechaCreacion,
      'isActive': isActive,
      'ultimaActividad': ultimaActividad,
      'codigoBarras': codigoBarras,
      'sap': sap,
      'ultimaVisita': ultimaVisita,
      'proximaCita': proximaCita,
      'alertas': alertas,
      'email': email,
      'telefono': telefono,
      'direccion': direccion,
    };
  }

  factory CargaFamiliar.fromMap(Map<String, dynamic> map, String id) {
    List<String>? parseAlertas(dynamic alertas) {
      if (alertas == null) return null;
      if (alertas is List) {
        return alertas.map((e) => e.toString()).toList();
      }
      return null;
    }

    return CargaFamiliar(
      id: id,
      asociadoId: map['asociadoId'] ?? '',
      nombre: map['nombre'] ?? '',
      apellido: map['apellido'] ?? '',
      rut: map['rut'] ?? '',
      parentesco: map['parentesco'] ?? '',
      fechaNacimiento: _parseDateTime(map['fechaNacimiento']),
      fechaCreacion: _parseDateTime(map['fechaCreacion']),
      isActive: map['isActive'] ?? true,
      ultimaActividad: map['ultimaActividad'] != null ? _parseDateTime(map['ultimaActividad']) : null,
      codigoBarras: map['codigoBarras'],
      sap: map['sap'],
      ultimaVisita: map['ultimaVisita']?.toString(),
      proximaCita: map['proximaCita']?.toString(),
      alertas: parseAlertas(map['alertas']),
      email: map['email'],
      telefono: map['telefono'],
      direccion: map['direccion'],
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

  CargaFamiliar copyWith({
    String? id,
    String? asociadoId,
    String? nombre,
    String? apellido,
    String? rut,
    String? parentesco,
    DateTime? fechaNacimiento,
    DateTime? fechaCreacion,
    bool? isActive,
    DateTime? ultimaActividad,
    String? codigoBarras,
    String? sap,
    String? ultimaVisita,
    String? proximaCita,
    List<String>? alertas,
    String? email,
    String? telefono,
    String? direccion,
  }) {
    return CargaFamiliar(
      id: id ?? this.id,
      asociadoId: asociadoId ?? this.asociadoId,
      nombre: nombre ?? this.nombre,
      apellido: apellido ?? this.apellido,
      rut: rut ?? this.rut,
      parentesco: parentesco ?? this.parentesco,
      fechaNacimiento: fechaNacimiento ?? this.fechaNacimiento,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      isActive: isActive ?? this.isActive,
      ultimaActividad: ultimaActividad ?? this.ultimaActividad,
      codigoBarras: codigoBarras ?? this.codigoBarras,
      sap: sap ?? this.sap,
      ultimaVisita: ultimaVisita ?? this.ultimaVisita,
      proximaCita: proximaCita ?? this.proximaCita,
      alertas: alertas ?? this.alertas,
      email: email ?? this.email,
      telefono: telefono ?? this.telefono,
      direccion: direccion ?? this.direccion,
    );
  }

  @override
  String toString() {
    return 'CargaFamiliar{id: $id, nombreCompleto: $nombreCompleto, rut: $rutFormateado, parentesco: $parentesco, sap: $sap}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CargaFamiliar && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}