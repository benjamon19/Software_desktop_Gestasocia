import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/reserva_hora.dart';

// Modelo simple para los datos del gráfico
class AttendanceData {
  final String label; // Ej: "Sem 1"
  final int attended;
  final int missed;

  AttendanceData({required this.label, required this.attended, required this.missed});
}

class ReservaHorasController extends GetxController {
  // === ESTADO REACTIVO ===
  RxList<ReservaHora> reservas = <ReservaHora>[].obs;
  RxBool isLoading = false.obs;
  Rx<DateTime> selectedDate = DateTime.now().obs;

  // === CONFIGURACIÓN DE HORARIO ===
  static const int horaApertura = 8;
  static const int horaCierre = 20;

  @override
  void onInit() {
    super.onInit();
    loadReservas();
  }

  // =========================================================
  // === GETTERS PARA DASHBOARD Y GRÁFICOS ===
  // =========================================================

  // KPI: Total de citas activas hoy
  int get totalCitasHoy {
    final today = DateTime.now();
    return reservas.where((r) {
      final bool isToday = r.fecha.year == today.year &&
                           r.fecha.month == today.month &&
                           r.fecha.day == today.day;
      final bool isNotCancelled = r.estado.toLowerCase() != 'cancelada';
      return isToday && isNotCancelled;
    }).length;
  }

  // GRÁFICO: Asistencia Mensual (Últimas 4 semanas)
  List<AttendanceData> get attendanceStatsLast4Weeks {
    final now = DateTime.now();
    // Inicializamos contadores: [Semana-3, Semana-2, Semana-1, Actual]
    List<int> attendedCounts = [0, 0, 0, 0];
    List<int> missedCounts = [0, 0, 0, 0];

    for (var r in reservas) {
      final differenceInDays = now.difference(r.fecha).inDays;
      
      // Filtramos solo lo que está dentro de los últimos 28 días
      if (differenceInDays >= 0 && differenceInDays < 28) {
        int weekIndex;
        
        // FIX LINTER: Agregadas llaves {} a los bloques if/else
        if (differenceInDays < 7) {
          weekIndex = 3;       // Semana Actual
        } else if (differenceInDays < 14) {
          weekIndex = 2;       // Semana Anterior
        } else if (differenceInDays < 21) {
          weekIndex = 1;       // Hace 2 semanas
        } else {
          weekIndex = 0;       // Hace 3 semanas
        }

        if (r.estado.toLowerCase() == 'realizada') {
          attendedCounts[weekIndex]++;
        } else if (r.estado.toLowerCase() == 'cancelada' || r.estado.toLowerCase() == 'no_asistio') {
          missedCounts[weekIndex]++;
        }
      }
    }

    return [
      AttendanceData(label: "Sem 1", attended: attendedCounts[0], missed: missedCounts[0]),
      AttendanceData(label: "Sem 2", attended: attendedCounts[1], missed: missedCounts[1]),
      AttendanceData(label: "Sem 3", attended: attendedCounts[2], missed: missedCounts[2]),
      AttendanceData(label: "Actual", attended: attendedCounts[3], missed: missedCounts[3]),
    ];
  }
  // =========================================================

  // === VALIDACIÓN DE DISPONIBILIDAD ===
  String? validarReserva(String odontologoNombre, DateTime fecha, String horaStr) {
    final parts = horaStr.split(':');
    final horaInt = int.parse(parts[0]);
    
    if (horaInt < horaApertura || horaInt >= horaCierre) {
      return 'La clínica está cerrada a esa hora. Horario: $horaApertura:00 - $horaCierre:00';
    }

    // 2. Validar Colisión
    final conflicto = reservas.firstWhereOrNull((reserva) {
      if (reserva.estado.toLowerCase() == 'cancelada') return false;
      if (reserva.odontologo != odontologoNombre) return false;

      if (reserva.fecha.year != fecha.year || 
          reserva.fecha.month != fecha.month || 
          reserva.fecha.day != fecha.day) {
        return false;
      }
      return reserva.hora == horaStr;
    });

    if (conflicto != null) {
      return 'El odontólogo $odontologoNombre ya tiene una cita a las $horaStr.';
    }

    return null;
  }

  // === CARGAR RESERVAS ===
  Future<void> loadReservas() async {
    try {
      isLoading.value = true;
      final snapshot = await FirebaseFirestore.instance
          .collection('reservas_horas')
          .orderBy('fecha')
          .get();

      reservas.assignAll(
        snapshot.docs.map((d) => ReservaHora.fromMap(d.data(), d.id)).toList(),
      );
    } catch (e) {
      debugPrint('Error cargando reservas: $e');
      _showSnackbar('Error', 'No se pudieron cargar las reservas', isError: true);
    } finally {
      isLoading.value = false;
    }
  }

  // === CREAR RESERVA ===
  Future<bool> createReserva(ReservaHora reserva) async {
    try {
      isLoading.value = true;
      final docRef = await FirebaseFirestore.instance
          .collection('reservas_horas')
          .add(reserva.toMap());

      reservas.add(reserva.copyWith(id: docRef.id));
      _showSnackbar('Éxito', 'Reserva agendada correctamente');
      return true;
    } catch (e) {
      debugPrint('Error creando reserva: $e');
      _showSnackbar('Error', 'No se pudo crear la reserva', isError: true);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // === ACTUALIZAR RESERVA ===
  Future<bool> updateReserva(ReservaHora reservaActualizada) async {
    try {
      isLoading.value = true;
      if (reservaActualizada.id == null) throw Exception('ID de reserva no válido');

      await FirebaseFirestore.instance
          .collection('reservas_horas')
          .doc(reservaActualizada.id)
          .update(reservaActualizada.toMap());

      final index = reservas.indexWhere((r) => r.id == reservaActualizada.id);
      if (index != -1) {
        reservas[index] = reservaActualizada;
        reservas.refresh();
      }

      _showSnackbar('Éxito', 'Reserva actualizada');
      return true;
    } catch (e) {
      debugPrint('Error actualizando reserva: $e');
      _showSnackbar('Error', 'No se pudo actualizar la reserva', isError: true);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // === ELIMINAR RESERVA ===
  Future<bool> deleteReserva(String reservaId) async {
    try {
      isLoading.value = true;
      await FirebaseFirestore.instance
          .collection('reservas_horas')
          .doc(reservaId)
          .delete();

      reservas.removeWhere((r) => r.id == reservaId);
      reservas.refresh();

      _showSnackbar('Éxito', 'Reserva eliminada');
      return true;
    } catch (e) {
      debugPrint('Error eliminando reserva: $e');
      _showSnackbar('Error', 'No se pudo eliminar la reserva', isError: true);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // === UI HELPERS ===
  void _showSnackbar(String title, String message, {bool isError = false}) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: isError ? Colors.red.withValues(alpha: 0.9) : const Color(0xFF10B981).withValues(alpha: 0.9),
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(12),
      borderRadius: 8,
    );
  }
}