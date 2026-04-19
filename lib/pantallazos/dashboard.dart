import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '/estado_global.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  // Paleta de colores principal
  static const Color colorGlucosa = Color(0xFF00C7BE);
  static const Color colorPresion = Color(0xFFFF3B30);
  static const Color colorOscuroText = Color(0xFF12305B);

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
        listenable: appState,
        builder: (context, child) {
          // 1. Obtener datos para las tarjetas y la lista
          final recientes = appState.registros.take(3).toList();
          final actualGlucosa = appState.registros.firstWhere(
                  (r) => r.tieneGlucosa,
              orElse: () => RegistroSalud(id: '', fecha: DateTime.now())
          );
          final actualPresion = appState.registros.firstWhere(
                  (r) => r.tienePresion,
              orElse: () => RegistroSalud(id: '', fecha: DateTime.now())
          );

          // 2. Lógica para los promedios semanales (Gráficos)
          final now = DateTime.now();
          List<double?> promGlucosa = List.filled(5, null);
          List<double?> promPresion = List.filled(5, null);

          // Agrupar y promediar por semanas
          for (int i = 0; i < 5; i++) {
            int diasAtrasInicio = (4 - i) * 7;
            int diasAtrasFin = diasAtrasInicio + 7;

            DateTime inicioSemana = now.subtract(Duration(days: diasAtrasFin));
            DateTime finSemana = now.subtract(Duration(days: diasAtrasInicio));

            var registrosSemana = appState.registros.where((r) =>
            r.fecha.isAfter(inicioSemana) &&
                (r.fecha.isBefore(finSemana) || r.fecha.isAtSameMomentAs(finSemana))
            );

            var regGlucosa = registrosSemana.where((r) => r.tieneGlucosa);
            if (regGlucosa.isNotEmpty) {
              promGlucosa[i] = regGlucosa.map((r) => r.glucosa!).reduce((a, b) => a + b) / regGlucosa.length;
            }

            var regPresion = registrosSemana.where((r) => r.tienePresion);
            if (regPresion.isNotEmpty) {
              promPresion[i] = regPresion.map((r) => r.presionSis!.toDouble()).reduce((a, b) => a + b) / regPresion.length;
            }
          }

          // Heredar valores si una semana está vacía (para que la línea no se corte)
          double baseGlucosa = appState.registros.lastWhere((r) => r.tieneGlucosa, orElse: () => RegistroSalud(id: '', fecha: now, glucosa: 100)).glucosa ?? 100.0;
          double basePresion = appState.registros.lastWhere((r) => r.tienePresion, orElse: () => RegistroSalud(id: '', fecha: now, presionSis: 120)).presionSis?.toDouble() ?? 120.0;

          for (int i = 0; i < 5; i++) {
            if (promGlucosa[i] == null) {
              promGlucosa[i] = i == 0 ? baseGlucosa : promGlucosa[i - 1];
            }
            if (promPresion[i] == null) {
              promPresion[i] = i == 0 ? basePresion : promPresion[i - 1];
            }
          }

          // Convertir los promedios a puntos (Spots) para FL Chart
          final spotsGlucosa = promGlucosa.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value!)).toList();
          final spotsPresion = promPresion.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value!)).toList();

          // 3. Construcción visual de la pantalla
          return Scaffold(
            backgroundColor: const Color(0xFFF4F8FF),
            body: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- CABECERA ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Hola, ${appState.perfil.nombre}", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: colorOscuroText)),
                            const Text("¿Cómo te sientes hoy?", style: TextStyle(color: Color(0xFF6B7280))),
                          ],
                        ),
                        const CircleAvatar(
                            backgroundColor: Color(0xFFEAF3FF),
                            radius: 24,
                            child: Icon(Icons.person, color: Color(0xFF2F80ED), size: 30)
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // --- TARJETAS SUPERIORES ---
                    Row(
                      children: [
                        Expanded(child: _metricCard("Glucosa", actualGlucosa.glucosa != null ? "${actualGlucosa.glucosa!.toInt()}" : '--', "mg/dL", Icons.water_drop_outlined, colorGlucosa)),
                        const SizedBox(width: 16),
                        Expanded(child: _metricCard("Presión", actualPresion.presionSis != null ? "${actualPresion.presionSis}/${actualPresion.presionDia}" : '--', "mmHg", Icons.favorite_border, colorPresion)),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // --- GRÁFICO 1: GLUCOSA ---
                    _buildGraphCard("Tendencias de Glucosa", spotsGlucosa, colorGlucosa, "Promedio semanal (mg/dL)"),

                    const SizedBox(height: 20),

                    // --- GRÁFICO 2: PRESIÓN ---
                    _buildGraphCard("Tendencias de Presión Sistólica", spotsPresion, colorPresion, "Promedio semanal (mmHg)"),

                    const SizedBox(height: 24),

                    // --- BOTÓN DE IA ---
                    InkWell(
                      onTap: () {}, // Acción futura para la pantalla de IA
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                            color: const Color(0xFFEAFBF4),
                            borderRadius: BorderRadius.circular(16)
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.psychology, color: Color(0xFF1DB954), size: 28),
                            SizedBox(width: 16),
                            Expanded(
                                child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text("Ver recomendaciones de la IA", style: TextStyle(color: Color(0xFF1DB954), fontWeight: FontWeight.bold, fontSize: 16)),
                                      Text("Basado en tus tendencias", style: TextStyle(color: Color(0xFF1DB954), fontSize: 12)),
                                    ]
                                )
                            ),
                            Icon(Icons.arrow_forward_ios, color: Color(0xFF1DB954), size: 16),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // --- LISTA DE REGISTROS RECIENTES ---
                    const Text("Registros Recientes", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: colorOscuroText)),
                    const SizedBox(height: 12),
                    ...recientes.map((reg) => _historyTile(reg)),
                    const SizedBox(height: 80), // Espacio para el menú inferior
                  ],
                ),
              ),
            ),
          );
        }
    );
  }

  // ===========================================================================
  // WIDGETS REUTILIZABLES
  // ===========================================================================

  // Constructor del gráfico con márgenes dinámicos
  Widget _buildGraphCard(String title, List<FlSpot> spots, Color color, String legendText) {
    // 1. Encontrar mínimo y máximo para escalar
    double minVal = spots.first.y;
    double maxVal = spots.first.y;
    for (var spot in spots) {
      if (spot.y < minVal) minVal = spot.y;
      if (spot.y > maxVal) maxVal = spot.y;
    }

    // 2. Colchón dinámico para que las curvas se vean completas y no toquen los bordes
    double finalMinY = minVal - 15;
    double finalMaxY = maxVal + 15;

    if (minVal == maxVal) {
      finalMinY = minVal - 10;
      finalMaxY = maxVal + 10;
    }

    return Container(
      height: 260,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [BoxShadow(color: Color(0x0A000000), blurRadius: 10, offset: Offset(0, 4))]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: colorOscuroText)),
          const SizedBox(height: 24),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                minY: finalMinY,
                maxY: finalMaxY,
                titlesData: FlTitlesData(
                  show: true,
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        // Evita duplicados en valores flotantes
                        if (value != value.toInt().toDouble()) return const SizedBox.shrink();

                        const semanas = ['Hace 4 Sem', 'Hace 3 Sem', 'Hace 2 Sem', 'Hace 1 Sem', 'Actual'];
                        int index = value.toInt();
                        if (index >= 0 && index < 5) {
                          // Truco de padding para que los bordes no corten el texto
                          EdgeInsetsGeometry paddingLateral;
                          if (index == 0) {
                            paddingLateral = const EdgeInsets.only(top: 8.0, left: 24.0);
                          } else if (index == semanas.length - 1) {
                            paddingLateral = const EdgeInsets.only(top: 8.0, right: 24.0);
                          } else {
                            paddingLateral = const EdgeInsets.only(top: 8.0);
                          }

                          return Padding(
                            padding: paddingLateral,
                            child: Text(semanas[index], style: const TextStyle(fontSize: 10, color: Color(0xFF6B7280))),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: color,
                    barWidth: 3,
                    dotData: FlDotData(show: true, getDotPainter: (s, p, b, i) => FlDotCirclePainter(radius: 4, color: color, strokeWidth: 2, strokeColor: Colors.white)),
                    belowBarData: BarAreaData(show: true, color: color.withOpacity(0.1)),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _legendItem(legendText, color),
            ],
          )
        ],
      ),
    );
  }

  // Tarjetas pequeñas superiores
  Widget _metricCard(String title, String val, String unit, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [BoxShadow(color: Color(0x0A000000), blurRadius: 10, offset: Offset(0, 4))]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(color: Color(0xFF6B7280), fontSize: 14)),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(val, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: colorOscuroText)),
              const SizedBox(width: 4),
              Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(unit, style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.bold))
              ),
            ],
          )
        ],
      ),
    );
  }

  // Ítem de la leyenda bajo los gráficos
  Widget _legendItem(String text, Color color) {
    return Row(
        children: [
          Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
        ]
    );
  }

  // Tarjeta de la lista de historial reciente
  Widget _historyTile(RegistroSalud reg) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [BoxShadow(color: Color(0x05000000), blurRadius: 5)]
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: reg.tieneGlucosa && reg.tienePresion ? const Color(0xFFEAF3FF) : (reg.tieneGlucosa ? colorGlucosa.withOpacity(0.1) : colorPresion.withOpacity(0.1)),
                shape: BoxShape.circle
            ),
            child: Icon(
                reg.tieneGlucosa && reg.tienePresion ? Icons.health_and_safety : (reg.tieneGlucosa ? Icons.water_drop_outlined : Icons.favorite_border),
                color: reg.tieneGlucosa && reg.tienePresion ? const Color(0xFF2F80ED) : (reg.tieneGlucosa ? colorGlucosa : colorPresion)
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(reg.tieneGlucosa && reg.tienePresion ? "Glucosa y Presión" : (reg.tieneGlucosa ? "Glucosa" : "Presión"), style: const TextStyle(fontWeight: FontWeight.bold, color: colorOscuroText)),
                    Text(DateFormat('dd MMM yyyy').format(reg.fecha), style: const TextStyle(color: Color(0xFF6B7280), fontSize: 12)),
                  ]
              )
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (reg.tieneGlucosa) Text("${reg.glucosa!.toInt()} mg/dL", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: colorGlucosa)),
              if (reg.tienePresion) Text("${reg.presionSis}/${reg.presionDia}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: colorPresion)),
            ],
          )
        ],
      ),
    );
  }
}