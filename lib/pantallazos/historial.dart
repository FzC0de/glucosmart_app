
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '/estado_global.dart';
import 'package:glucosmart_app/pantallazos/registro_medicion.dart';
import 'package:glucosmart_app/services/auth_service.dart';

class HistorialScreen extends StatelessWidget {
  HistorialScreen({super.key});

  final AuthService _authService = AuthService();

  // MENÚ DE OPCIONES DEL REGISTRO
  void _mostrarOpciones(BuildContext context, RegistroSalud reg) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // INDICADOR SUPERIOR
                    Container(
                      width: 45,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 18),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),

                    // TÍTULO
                    const Text(
                      'Opciones del registro',
                      style: TextStyle(
                        color: Color(0xFF12305B),
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      DateFormat('dd MMM yyyy • hh:mm a')
                          .format(reg.fecha),
                      style: const TextStyle(
                        color: Color(0xFF6B7280),
                        fontSize: 12,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // MODIFICAR REGISTRO
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                      ),
                      leading: const Icon(
                        Icons.edit_outlined,
                        color: Color(0xFF12305B),
                      ),
                      title: const Text(
                        'Modificar registro',
                        style: TextStyle(
                          color: Color(0xFF12305B),
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      onTap: () {
                        Navigator.pop(sheetContext);

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => RegistroMedicionScreen(
                              registroAEditar: reg,
                            ),
                          ),
                        );
                      },
                    ),

                    const Divider(
                      height: 1,
                      color: Color(0xFFF4F8FF),
                    ),

                    // ELIMINAR REGISTRO
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                      ),
                      leading: const Icon(
                        Icons.delete_outline,
                        color: Color(0xFFFF3B30),
                      ),
                      title: const Text(
                        'Eliminar',
                        style: TextStyle(
                          color: Color(0xFFFF3B30),
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      onTap: () async {
                        final id = int.tryParse(reg.id);

                        if (id == null) {
                          Navigator.pop(sheetContext);

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'No se pudo identificar el registro.',
                              ),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }

                        try {
                          // ELIMINAR EN FASTAPI
                          await _authService.eliminarMedicion(id);

                          // ACTUALIZAR HISTORIAL DESDE EL SERVIDOR
                          await appState.cargarRegistrosDesdeApi();

                          if (!context.mounted ||
                              !sheetContext.mounted) {
                            return;
                          }

                          Navigator.pop(sheetContext);

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Registro eliminado correctamente.',
                              ),
                              backgroundColor: Color(0xFF12305B),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        } catch (e) {
                          if (!context.mounted ||
                              !sheetContext.mounted) {
                            return;
                          }

                          Navigator.pop(sheetContext);

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                e.toString().replaceFirst(
                                  'Exception: ',
                                  '',
                                ),
                              ),
                              backgroundColor: Colors.red,
                              duration: const Duration(seconds: 3),
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: appState,
      builder: (context, child) {
        return Scaffold(
          backgroundColor: const Color(0xFFF4F8FF),

          appBar: AppBar(
            title: const Text(
              'Historial',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: Color(0xFF12305B),
              ),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            automaticallyImplyLeading: false,
          ),

          body: appState.cargandoRegistros
              ? const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF2F80ED),
                  ),
                )
              : appState.registros.isEmpty
                  ? const Center(
                      child: Text(
                        'No hay registros aún',
                        style: TextStyle(
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(20),
                      itemCount: appState.registros.length,
                      itemBuilder: (context, index) {
                        final reg = appState.registros[index];

                        return GestureDetector(
                          onTap: () => _mostrarOpciones(
                            context,
                            reg,
                          ),
                          child: Container(
                            margin: const EdgeInsets.only(
                              bottom: 12,
                            ),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x05000000),
                                  blurRadius: 5,
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                // ICONO
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: reg.tieneGlucosa &&
                                            reg.tienePresion
                                        ? const Color(0xFFEAF3FF)
                                        : (reg.tieneGlucosa
                                            ? const Color(0xFF00C7BE)
                                                .withValues(alpha: 0.1)
                                            : const Color(0xFFFF3B30)
                                                .withValues(alpha: 0.1)),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    reg.tieneGlucosa &&
                                            reg.tienePresion
                                        ? Icons.health_and_safety
                                        : (reg.tieneGlucosa
                                            ? Icons.water_drop_outlined
                                            : Icons.favorite_border),
                                    color: reg.tieneGlucosa &&
                                            reg.tienePresion
                                        ? const Color(0xFF2F80ED)
                                        : (reg.tieneGlucosa
                                            ? const Color(0xFF00C7BE)
                                            : const Color(0xFFFF3B30)),
                                  ),
                                ),

                                const SizedBox(width: 16),

                                // INFORMACIÓN
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        reg.tieneGlucosa &&
                                                reg.tienePresion
                                            ? 'Glucosa y Presión'
                                            : (reg.tieneGlucosa
                                                ? 'Glucosa'
                                                : 'Presión'),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF12305B),
                                        ),
                                      ),
                                      Text(
                                        DateFormat(
                                          'dd MMM yyyy • hh:mm a',
                                        ).format(reg.fecha),
                                        style: const TextStyle(
                                          color: Color(0xFF6B7280),
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // VALORES
                                Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.end,
                                  children: [
                                    if (reg.tieneGlucosa)
                                      Text(
                                        '${reg.glucosa!.toInt()} mg/dL',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          color: Color(0xFF00C7BE),
                                        ),
                                      ),
                                    if (reg.tienePresion)
                                      Text(
                                        '${reg.presionSis}/${reg.presionDia}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          color: Color(0xFFFF3B30),
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
        );
      },
    );
  }
}
