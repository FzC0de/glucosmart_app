import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '/estado_global.dart';
import 'package:glucosmart_app/pantallazos/registro_medicion.dart';

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
          // Los registros provienen de appState, que se sincroniza con FastAPI.
          // Se ordenan aquí para garantizar que las tarjetas muestren el dato más reciente.
          final registrosOrdenados = [...appState.registros]
            ..sort((a, b) => b.fecha.compareTo(a.fecha));

          // La bienvenida aparece únicamente cuando el usuario aún no tiene mediciones.
          final mostrarBienvenida = registrosOrdenados.isEmpty;

          // 1. Obtener datos reales para las tarjetas y la lista.
          final recientes = registrosOrdenados.take(3).toList();
          final actualGlucosa = registrosOrdenados.firstWhere(
            (r) => r.tieneGlucosa,
            orElse: () => RegistroSalud(id: '', fecha: DateTime.now()),
          );
          final actualPresion = registrosOrdenados.firstWhere(
            (r) => r.tienePresion,
            orElse: () => RegistroSalud(id: '', fecha: DateTime.now()),
          );

          // 2. Promedios semanales usando exclusivamente mediciones reales
          final now = DateTime.now();
          final List<double?> promGlucosa = List.filled(5, null);
          final List<double?> promPresion = List.filled(5, null);

          for (int i = 0; i < 5; i++) {
            final diasAtrasInicio = (4 - i) * 7;
            final diasAtrasFin = diasAtrasInicio + 7;
            final inicioSemana = now.subtract(Duration(days: diasAtrasFin));
            final finSemana = now.subtract(Duration(days: diasAtrasInicio));

            final registrosSemana = registrosOrdenados.where((r) =>
                r.fecha.isAfter(inicioSemana) &&
                (r.fecha.isBefore(finSemana) ||
                    r.fecha.isAtSameMomentAs(finSemana)));

            final regGlucosa =
                registrosSemana.where((r) => r.tieneGlucosa).toList();
            if (regGlucosa.isNotEmpty) {
              promGlucosa[i] = regGlucosa
                      .map((r) => r.glucosa!)
                      .reduce((a, b) => a + b) /
                  regGlucosa.length;
            }

            final regPresion =
                registrosSemana.where((r) => r.tienePresion).toList();
            if (regPresion.isNotEmpty) {
              promPresion[i] = regPresion
                      .map((r) => r.presionSis!.toDouble())
                      .reduce((a, b) => a + b) /
                  regPresion.length;
            }
          }

          // Las semanas sin registros permanecen vacías; no se inventan valores.
          final spotsGlucosa = promGlucosa.asMap().entries
              .where((e) => e.value != null)
              .map((e) => FlSpot(e.key.toDouble(), e.value!))
              .toList();
          final spotsPresion = promPresion.asMap().entries
              .where((e) => e.value != null)
              .map((e) => FlSpot(e.key.toDouble(), e.value!))
              .toList();

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

                    // --- ESTADO DE CARGA Y ERRORES DE LA API ---
                    if (appState.cargandoRegistros)
                      const Padding(
                        padding: EdgeInsets.only(bottom: 16),
                        child: LinearProgressIndicator(
                          color: Color(0xFF2F80ED),
                        ),
                      ),

                    if (appState.errorRegistros != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Text(
                          'No se pudieron actualizar las mediciones: ${appState.errorRegistros}',
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),

                    if (mostrarBienvenida) ...[
                      _buildEmptyState(context),
                      const SizedBox(height: 20),
                      _buildGraphCard(
                        "Tendencias de Glucosa",
                        spotsGlucosa,
                        colorGlucosa,
                        "Promedio semanal (mg/dL)",
                      ),
                      const SizedBox(height: 20),
                      _buildGraphCard(
                        "Tendencias de Presión Sistólica",
                        spotsPresion,
                        colorPresion,
                        "Promedio semanal (mmHg)",
                      ),
                      const SizedBox(height: 80),
                    ] else ...[
                    // --- TARJETAS SUPERIORES ---
                    Row(
                      children: [
                        Expanded(child: _metricCard("Glucosa", actualGlucosa.glucosa != null ? "${actualGlucosa.glucosa!.toInt()}" : '--', "mg/dL", Icons.water_drop_outlined, colorGlucosa)),
                        const SizedBox(width: 16),
                        Expanded(child: _metricCard("Presión", actualPresion.presionSis != null ? "${actualPresion.presionSis}/${actualPresion.presionDia}" : '--', "mmHg", Icons.favorite_border, colorPresion)),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // --- RESUMEN DE ACTIVIDAD ---
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x0A000000),
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(11),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEAF3FF),
                              borderRadius: BorderRadius.circular(13),
                            ),
                            child: const Icon(
                              Icons.monitor_heart_outlined,
                              color: Color(0xFF2F80ED),
                              size: 25,
                            ),
                          ),
                          const SizedBox(width: 13),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Resumen de seguimiento',
                                  style: TextStyle(
                                    color: colorOscuroText,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${registrosOrdenados.length} '
                                  '${registrosOrdenados.length == 1 ? 'medición registrada' : 'mediciones registradas'}',
                                  style: const TextStyle(
                                    color: Color(0xFF6B7280),
                                    fontSize: 12,
                                  ),
                                ),
                                if (registrosOrdenados.isNotEmpty)
                                  Text(
                                    'Último registro: ${DateFormat('dd/MM/yyyy – hh:mm a').format(registrosOrdenados.first.fecha)}',
                                    style: const TextStyle(
                                      color: Color(0xFF6B7280),
                                      fontSize: 12,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
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
                    ]
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

  // Bienvenida para usuarios que todavía no registran mediciones.
  Widget _buildEmptyState(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFEAF3FF), Color(0xFFF2F8FF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.health_and_safety_outlined,
                  color: Color(0xFF2F80ED),
                  size: 30,
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                '¡Comienza tu seguimiento!',
                style: TextStyle(
                  color: colorOscuroText,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Registra tus primeras mediciones de glucosa o presión arterial '
                'y empieza a conocer la evolución de tus indicadores.',
                style: TextStyle(
                  color: Color(0xFF53657D),
                  fontSize: 14,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => RegistroMedicionScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: const Text(
                    'Registrar mi primera medición',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2F80ED),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        const Text(
          'Descubre lo que puedes hacer',
          style: TextStyle(
            color: colorOscuroText,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 12),
        _emptyFeatureCard(
          icon: Icons.edit_note_rounded,
          color: const Color(0xFF2F80ED),
          title: 'Registra tus mediciones',
          description:
              'Guarda tus valores de glucosa y presión en un solo lugar.',
        ),
        const SizedBox(height: 10),
        _emptyFeatureCard(
          icon: Icons.show_chart_rounded,
          color: colorGlucosa,
          title: 'Observa tus tendencias',
          description:
              'Los gráficos se irán completando conforme agregues registros.',
        ),
        const SizedBox(height: 10),
        _emptyFeatureCard(
          icon: Icons.history_rounded,
          color: const Color(0xFF8B70D6),
          title: 'Consulta tu historial',
          description:
              'Encuentra tus mediciones anteriores y revisa sus detalles.',
        ),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF7E8),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.info_outline,
                color: Color(0xFFB7791F),
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Los gráficos mostrarán tendencias cuando acumules mediciones. '
                  'GlucoSmart organiza tus datos; no reemplaza '
                  'la evaluación de un profesional de salud.',
                  style: TextStyle(
                    color: Color(0xFF79551B),
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _emptyFeatureCard({
    required IconData icon,
    required Color color,
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x05000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: colorOscuroText,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  description,
                  style: const TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 12,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Tarjeta del gráfico. Se mantiene visible aunque todavía no haya
  // suficientes mediciones para dibujar una tendencia.
  Widget _buildGraphCard(
    String title,
    List<FlSpot> spots,
    Color color,
    String legendText,
  ) {
    final hayDatosSuficientes = spots.length >= 2;

    // Con cero o una semana con datos, mostramos una explicación en lugar
    // de dibujar un gráfico que podría inducir a interpretar una tendencia.
    if (!hayDatosSuficientes) {
      final mensaje = spots.isEmpty
          ? 'Aún no hay mediciones para mostrar. Registra tus valores para comenzar.'
          : 'Ya tienes una medición. Registra otra en una fecha diferente para comenzar a visualizar tu evolución.';

      return Container(
        height: 260,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0A000000),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: colorOscuroText,
              ),
            ),
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.show_chart_rounded,
                        color: color.withValues(alpha: 0.75),
                        size: 38,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        mensaje,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color(0xFF6B7280),
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [_legendItem(legendText, color)],
            ),
          ],
        ),
      );
    }

    // Encontrar mínimo y máximo para escalar el gráfico.
    double minVal = spots.first.y;
    double maxVal = spots.first.y;
    for (final spot in spots) {
      if (spot.y < minVal) minVal = spot.y;
      if (spot.y > maxVal) maxVal = spot.y;
    }

    // Añadir margen para que la curva no toque los bordes.
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
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: colorOscuroText,
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                minY: finalMinY,
                maxY: finalMaxY,
                minX: 0,
                maxX: 4,
                titlesData: FlTitlesData(
                  show: true,
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        if (value != value.toInt().toDouble()) {
                          return const SizedBox.shrink();
                        }

                        const semanas = [
                          'Hace 4 Sem',
                          'Hace 3 Sem',
                          'Hace 2 Sem',
                          'Hace 1 Sem',
                          'Actual',
                        ];
                        final index = value.toInt();

                        if (index >= 0 && index < semanas.length) {
                          EdgeInsetsGeometry paddingLateral;
                          if (index == 0) {
                            paddingLateral = const EdgeInsets.only(
                              top: 8,
                              left: 24,
                            );
                          } else if (index == semanas.length - 1) {
                            paddingLateral = const EdgeInsets.only(
                              top: 8,
                              right: 24,
                            );
                          } else {
                            paddingLateral = const EdgeInsets.only(top: 8);
                          }

                          return Padding(
                            padding: paddingLateral,
                            child: Text(
                              semanas[index],
                              style: const TextStyle(
                                fontSize: 10,
                                color: Color(0xFF6B7280),
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
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
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, bar, index) =>
                          FlDotCirclePainter(
                        radius: 4,
                        color: color,
                        strokeWidth: 2,
                        strokeColor: Colors.white,
                      ),
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: color.withValues(alpha: 0.1),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [_legendItem(legendText, color)],
          ),
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
                color: reg.tieneGlucosa && reg.tienePresion ? const Color(0xFFEAF3FF) : (reg.tieneGlucosa ? colorGlucosa.withValues(alpha: 0.1) : colorPresion.withValues(alpha: 0.1)),
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