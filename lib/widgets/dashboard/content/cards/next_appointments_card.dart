import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../utils/app_theme.dart';
import '../../../../controllers/reserva_horas_controller.dart';
import '../../../../models/reserva_hora.dart';
import '../../modules/gestion_reserva_de_horas/shared/dialogs/reserva_detail_dialog.dart';

class NextAppointmentsCard extends StatelessWidget {
  final bool isCompact; // 👈 Nuevo: permite forzar modo compacto desde ChartsGridSection

  const NextAppointmentsCard({super.key, this.isCompact = false});

  @override
  Widget build(BuildContext context) {
    final ReservaHorasController controller = Get.find<ReservaHorasController>();
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final bool isSmallScreen = screenWidth < 600;
    final bool isMediumScreen = screenWidth >= 600 && screenWidth < 1000;
    final bool isVeryShortScreen = screenHeight < 600;
    final bool useCompactMode = isCompact || isVeryShortScreen;

    // Padding adaptativo (más pequeño si es compacto o pantalla corta)
    double cardPadding = useCompactMode ? 8 : (isSmallScreen ? 10 : 16);

    return Container(
      padding: EdgeInsets.all(cardPadding),
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
      child: Obx(() {
        final now = DateTime.now();
        final dateLimit = now.add(const Duration(days: 30));
        
        final upcomingAppointments = controller.reservas.where((r) {
          final isFuture = r.fecha.isAfter(now.subtract(const Duration(minutes: 30)));
          final isWithinMonth = r.fecha.isBefore(dateLimit);
          final isNotCancelled = r.estado.toLowerCase() != 'cancelada';
          return isFuture && isWithinMonth && isNotCancelled;
        }).toList()..sort((a, b) => a.fecha.compareTo(b.fecha));

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context, upcomingAppointments.length, isSmallScreen),
            
            SizedBox(height: useCompactMode ? 8 : 12), // ✅ sin const
            
            // Lista (mantiene scroll en notebook/móvil, pero en compacto se ve más apretada)
            Expanded(
              child: upcomingAppointments.isEmpty 
                ? _buildEmptyState(context, useCompactMode)
                : ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: upcomingAppointments.length,
                    itemBuilder: (context, index) {
                      return _buildAppointmentItem(
                        context, 
                        upcomingAppointments[index],
                        isSmallScreen,
                        isMediumScreen,
                        useCompactMode,
                      );
                    },
                  ),
            ),
            
            if (!isVeryShortScreen && upcomingAppointments.isNotEmpty) ...[
              SizedBox(height: useCompactMode ? 6 : 8), // ✅ sin const
              _buildFooter(context, controller, isSmallScreen),
            ]
          ],
        );
      }),
    );
  }

  Widget _buildHeader(BuildContext context, int count, bool isSmallScreen) {
    return Row(
      children: [
        Text(
          'Próximas Citas (30 días)',
          style: TextStyle(
            fontSize: isSmallScreen ? 14 : 16,
            fontWeight: FontWeight.w600,
            color: AppTheme.getTextPrimary(context),
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: Color(0xFF3B82F6).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            '$count',
            style: TextStyle(
              fontSize: isSmallScreen ? 10 : 12,
              color: const Color(0xFF3B82F6),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context, bool compact) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_available,
            size: compact ? 28 : 32,
            color: AppTheme.getTextSecondary(context).withValues(alpha: 0.3),
          ),
          SizedBox(height: compact ? 6 : 8),
          Text(
            compact ? 'Sin citas' : 'Sin citas próximas',
            style: TextStyle(
              fontSize: compact ? 11 : 12,
              color: AppTheme.getTextSecondary(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context, ReservaHorasController controller, bool isSmallScreen) {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () => _showAllAppointmentsDialog(context, controller),
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: Text(
          isSmallScreen ? 'Ver más →' : 'Ver todas →',
          style: TextStyle(
            fontSize: isSmallScreen ? 11 : 12,
            color: const Color(0xFF3B82F6),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildAppointmentItem(
    BuildContext context, 
    ReservaHora reserva,
    bool isSmallScreen,
    bool isMediumScreen,
    bool compact,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: compact ? 3 : 4), // ✅ más compacto si es necesario
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => ReservaDetailDialog.show(context, reserva),
          borderRadius: BorderRadius.circular(6),
          child: Container(
            padding: EdgeInsets.symmetric(vertical: compact ? 5 : 6, horizontal: 4),
            child: Row(
              children: [
                Container(
                  width: compact ? 40 : 45,
                  alignment: Alignment.centerLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        reserva.hora,
                        style: TextStyle(
                          fontSize: compact ? 11 : 12,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF3B82F6),
                        ),
                      ),
                      Text(
                        '${reserva.fecha.day}/${reserva.fecha.month}',
                        style: TextStyle(
                          fontSize: compact ? 9 : 10,
                          color: AppTheme.getTextSecondary(context),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        reserva.pacienteNombre,
                        style: TextStyle(
                          fontSize: compact ? 12 : 13,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.getTextPrimary(context),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (!compact)
                        Text(
                          reserva.motivo,
                          style: TextStyle(
                            fontSize: 11,
                            color: AppTheme.getTextSecondary(context),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
                Container(
                  width: compact ? 6 : 8,
                  height: compact ? 6 : 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _getStatusColor(reserva.estado),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showAllAppointmentsDialog(BuildContext context, ReservaHorasController controller) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppTheme.getSurfaceColor(dialogContext),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Row(
          children: [
            const Icon(Icons.calendar_month, color: Color(0xFF3B82F6)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Próximas Citas (Todas)',
                style: TextStyle(
                  color: AppTheme.getTextPrimary(dialogContext),
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            IconButton(
              onPressed: () => Navigator.pop(dialogContext),
              icon: Icon(Icons.close, color: AppTheme.getTextSecondary(dialogContext)),
            ),
          ],
        ),
        content: SizedBox(
          width: 500,
          height: 400,
          child: Obx(() {
            final now = DateTime.now();
            final allFutureAppointments = controller.reservas.where((r) {
              return r.fecha.isAfter(now.subtract(const Duration(minutes: 30))) && 
                     r.estado.toLowerCase() != 'cancelada';
            }).toList()..sort((a, b) {
              int dateComp = a.fecha.compareTo(b.fecha);
              if (dateComp != 0) return dateComp;
              return a.hora.compareTo(b.hora);
            });

            if (allFutureAppointments.isEmpty) {
              return Center(
                child: Text(
                  'No hay citas futuras programadas.',
                  style: TextStyle(color: AppTheme.getTextSecondary(dialogContext)),
                ),
              );
            }

            return ListView.separated(
              itemCount: allFutureAppointments.length,
              separatorBuilder: (ctx, i) => Divider(
                height: 1,
                color: AppTheme.getBorderLight(dialogContext).withValues(alpha: 0.5),
              ),
              itemBuilder: (ctx, index) {
                final reserva = allFutureAppointments[index];
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  onTap: () {
                    Navigator.pop(dialogContext);
                    ReservaDetailDialog.show(context, reserva);
                  },
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Color(0xFF3B82F6).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          reserva.fecha.day.toString(),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF3B82F6),
                            fontSize: 14,
                            height: 1,
                          ),
                        ),
                        Text(
                          DateFormat('MMM', 'es').format(reserva.fecha).toUpperCase(),
                          style: const TextStyle(
                            fontSize: 9,
                            color: Color(0xFF3B82F6),
                            height: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  title: Text(
                    reserva.pacienteNombre,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.getTextPrimary(dialogContext),
                      fontSize: 14,
                    ),
                  ),
                  subtitle: Text(
                    '${reserva.hora} • ${reserva.motivo}',
                    style: TextStyle(
                      color: AppTheme.getTextSecondary(dialogContext),
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(reserva.estado).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _getStatusColor(reserva.estado).withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      reserva.estado,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: _getStatusColor(reserva.estado),
                      ),
                    ),
                  ),
                );
              },
            );
          }),
        ),
      ),
    );
  }

  Color _getStatusColor(String estado) {
    switch (estado.toLowerCase()) {
      case 'confirmada': return const Color(0xFF10B981);
      case 'cancelada': return const Color(0xFFEF4444);
      case 'realizada': return const Color(0xFF8B5CF6);
      default: return const Color(0xFFF59E0B);
    }
  }
}