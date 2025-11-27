import 'package:flutter/material.dart';
import '../../../utils/app_theme.dart';
import 'charts/patient_growth_chart.dart';
import 'charts/age_distribution_chart.dart';
import 'charts/treatment_types_chart.dart';
import 'charts/weekly_attendance_chart.dart';
import 'cards/next_appointments_card.dart';
import 'cards/treatment_alert_card.dart';

class ChartsGridSection extends StatelessWidget {
  const ChartsGridSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.getSurfaceColor(context),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).brightness == Brightness.dark 
                ? Colors.black.withValues(alpha: 0.2) 
                : Colors.grey.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Análisis y Métricas', 
            style: TextStyle(
              fontSize: 18, 
              fontWeight: FontWeight.w600, 
              color: AppTheme.getTextPrimary(context)
            )
          ),
          const SizedBox(height: 16),
          
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final double width = constraints.maxWidth;
                final double height = constraints.maxHeight;
                
                final bool isMobile = width < 768;
                final bool isTablet = width >= 768 && width < 1350;
                final bool isDesktop = width >= 1350;

                final bool isVerticalSpacious = height > 880 && isDesktop;

                if (isVerticalSpacious) {
                  return Column(
                    children: [
                      Expanded(
                        flex: 4, 
                        child: ChartCard(
                          title: "Asistencia Mensual", 
                          chart: const WeeklyAttendanceChart(), 
                          width: width,
                          isHero: true,
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      Expanded(
                        flex: 3,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              flex: 2,
                              child: ChartCard(
                                title: "Crecimiento de Pacientes", 
                                chart: const PatientGrowthChart(), 
                                width: width * 0.65,
                                isHero: true,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              flex: 1,
                              child: ChartCard(
                                title: "Tipos de Tratamiento", 
                                chart: const TreatmentTypesChart(), 
                                width: width * 0.35
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      Expanded(
                        flex: 3,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: ChartCard(
                                title: "Distribución por Edad", 
                                chart: const AgeDistributionChart(), 
                                width: width * 0.5
                              ),
                            ),
                            const SizedBox(width: 16),
                            const Expanded(child: NextAppointmentsCard()),
                            const SizedBox(width: 16),
                            const Expanded(child: TreatmentAlertCard()),
                          ],
                        ),
                      ),
                    ],
                  );
                } else {
                  final double row1Height = isMobile ? 280 : 320;
                  final double row2Height = isMobile ? 260 : 300;
                  final double row3Height = isMobile ? 360 : 340;

                  return SingleChildScrollView(
                    padding: const EdgeInsets.only(right: 10),
                    child: Column(
                      children: [
                        // Fila 1
                        SizedBox(
                          height: row1Height,
                          child: ChartCard(
                            title: "Asistencia Mensual", 
                            chart: const WeeklyAttendanceChart(), 
                            width: width,
                            isHero: true,
                          ),
                        ),
                        
                        const SizedBox(height: 16),

                        // Fila 2: Crecimiento + Tipos
                        if (isDesktop || isTablet)
                          SizedBox(
                            height: row2Height,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: ChartCard(
                                    title: "Crecimiento de Pacientes", 
                                    chart: const PatientGrowthChart(), 
                                    width: width * 0.65,
                                    isHero: true,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  flex: 1,
                                  child: ChartCard(
                                    title: "Tipos de Tratamiento", 
                                    chart: const TreatmentTypesChart(), 
                                    width: width * 0.35
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          // Móvil: apilado
                          Column(
                            children: [
                              SizedBox(
                                height: row2Height,
                                child: ChartCard(
                                  title: "Crecimiento de Pacientes", 
                                  chart: const PatientGrowthChart(), 
                                  width: width,
                                  isHero: true,
                                ),
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                height: row2Height,
                                child: ChartCard(
                                  title: "Tipos de Tratamiento", 
                                  chart: const TreatmentTypesChart(), 
                                  width: width
                                ),
                              ),
                            ],
                          ),

                        const SizedBox(height: 16),

                        if (isDesktop || isTablet)
                          SizedBox(
                            height: row3Height,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Expanded(
                                  child: ChartCard(
                                    title: "Distribución por Edad", 
                                    chart: const AgeDistributionChart(), 
                                    width: width * 0.5
                                  ),
                                ),
                                const SizedBox(width: 16),
                                const Expanded(child: NextAppointmentsCard()),
                                const SizedBox(width: 16),
                                const Expanded(child: TreatmentAlertCard()),
                              ],
                            ),
                          )
                        else
                          Column(
                            children: [
                              SizedBox(
                                height: 300,
                                child: ChartCard(
                                  title: "Distribución por Edad", 
                                  chart: const AgeDistributionChart(), 
                                  width: width
                                ),
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                height: 380,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: const [
                                    Expanded(child: NextAppointmentsCard()),
                                    SizedBox(width: 16),
                                    Expanded(child: TreatmentAlertCard()),
                                  ],
                                ),
                              ),
                            ],
                          ),

                        const SizedBox(height: 20),
                      ],
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ChartCard sin cambios (funciona bien)
class ChartCard extends StatelessWidget {
  final String title;
  final Widget chart;
  final double width;
  final bool isHero;

  const ChartCard({
    super.key,
    required this.title,
    required this.chart,
    required this.width,
    this.isHero = false,
  });

  @override
  Widget build(BuildContext context) {
    double padding = width < 600 ? 12 : 20;
    double titleSize = width < 600 ? 14 : 16;

    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: AppTheme.getSurfaceColor(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.getTextSecondary(context).withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title.isNotEmpty && title != "Asistencia Mensual") ...[
             Text(
              title,
              style: TextStyle(
                fontSize: titleSize,
                fontWeight: FontWeight.w600,
                color: AppTheme.getTextPrimary(context),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: padding),
          ],
          Expanded(child: chart),
        ],
      ),
    );
  }
}