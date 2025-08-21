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
  });

  // Getters útiles
  String get nombreCompleto => '$nombre $apellido';
  
  String get rutFormateado {
    if (rut.length < 2) return rut;
    String cuerpo = rut.substring(0, rut.length - 1);
    String dv = rut.substring(rut.length - 1);
    
    // Formatear cuerpo con puntos
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

  String get fechaIngresoFormateada {
    return '${fechaIngreso.day.toString().padLeft(2, '0')}/'
           '${fechaIngreso.month.toString().padLeft(2, '0')}/'
           '${fechaIngreso.year}';
  }

  String get estado => isActive ? 'Activo' : 'Inactivo';

  // Validación de RUT chileno (reutilizada del modelo Usuario)
  static bool validarRUT(String rut) {
    try {
      // Limpiar RUT (quitar puntos y guión)
      String rutLimpio = rut.replaceAll(RegExp(r'[^0-9kK]'), '');
      
      if (rutLimpio.length < 2) return false;
      
      String cuerpo = rutLimpio.substring(0, rutLimpio.length - 1);
      String dv = rutLimpio.substring(rutLimpio.length - 1).toUpperCase();
      
      // Validar que el cuerpo sean solo números
      if (!RegExp(r'^[0-9]+$').hasMatch(cuerpo)) return false;
      
      // Calcular dígito verificador
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

  // Validación de email
  static bool validarEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  // Convertir a Map para Firestore
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
    };
  }

  // Crear desde Map de Firestore
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
    );
  }

  // Helper para manejar diferentes tipos de fecha
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
      // Para Timestamp de Firestore
      return fecha.toDate();
    } else {
      return DateTime.now();
    }
  }

  // Crear copia con cambios
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
    );
  }

  @override
  String toString() {
    return 'Asociado{id: $id, nombreCompleto: $nombreCompleto, email: $email, rut: $rutFormateado}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Asociado && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}