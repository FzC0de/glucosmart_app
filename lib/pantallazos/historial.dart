import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '/estado_global.dart';
import '/pantallas/registro_medicion.dart';

class HistorialScreen extends StatelessWidget {
  const HistorialScreen({super.key});

  // Función para mostrar el menú inferior al tocar un registro
  void _mostrarOpciones(BuildContext context, RegistroSalud reg) {
    showModalBottomSheet(
        context: context,
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        builder: (context) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Pequeña barra gris superior (indicador de arrastre)
                  Container(
                    width: 40, height: 4,
                    margin: const EdgeInsets.only(bottom: 24),
                    decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
                  ),

                  // Botón Modificar (Color normal)
                  ListTile(
                    leading: const Icon(Icons.edit_outlined, color: Color(0xFF12305B)),
                    title: const Text("Modificar registro", style: TextStyle(color: Color(0xFF12305B), fontWeight: FontWeight.w600, fontSize: 16)),
                    onTap: () {
                      Navigator.pop(context); // Cierra el menú
                      Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => RegistroMedicionScreen(registroAEditar: reg))
                      );
                    },
                  ),

                  // Divisor sutil
                  const Divider(height: 1, color: Color(0xFFF4F8FF)),

                  // Botón Eliminar (Color Rojo)
                  ListTile(
                    leading: const Icon(Icons.delete_outline, color: Color(0xFFFF3B30)),
                    title: const Text("Eliminar", style: TextStyle(color: Color(0xFFFF3B30), fontWeight: FontWeight.w600, fontSize: 16)),
                    onTap: () {
                      appState.eliminarRegistro(reg.id);
                      Navigator.pop(context); // Cierra el menú tras eliminar

                      // Opcional: Mostrar un mensajito temporal (SnackBar)
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Registro eliminado"),
                            backgroundColor: Color(0xFF12305B),
                            duration: Duration(seconds: 2),
                          )
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        }
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
              title: const Text("Historial", style: TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF12305B))),
              backgroundColor: Colors.transparent, elevation: 0,
              automaticallyImplyLeading: false,
            ),
            body: appState.registros.isEmpty
                ? const Center(
              child: Text("No hay registros aún", style: TextStyle(color: Color(0xFF6B7280))),
            )
                : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: appState.registros.length,
              itemBuilder: (context, index) {
                final reg = appState.registros[index];
                return GestureDetector(
                  // AQUÍ LLAMAMOS AL NUEVO MENÚ EN LUGAR DE ABRIR DIRECTO
                  onTap: () => _mostrarOpciones(context, reg),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: const [BoxShadow(color: Color(0x05000000), blurRadius: 5)]),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                              color: reg.tieneGlucosa && reg.tienePresion ? const Color(0xFFEAF3FF) : (reg.tieneGlucosa ? const Color(0xFF00C7BE).withOpacity(0.1) : const Color(0xFFFF3B30).withOpacity(0.1)),
                              shape: BoxShape.circle
                          ),
                          child: Icon(
                              reg.tieneGlucosa && reg.tienePresion ? Icons.health_and_safety : (reg.tieneGlucosa ? Icons.water_drop_outlined : Icons.favorite_border),
                              color: reg.tieneGlucosa && reg.tienePresion ? const Color(0xFF2F80ED) : (reg.tieneGlucosa ? const Color(0xFF00C7BE) : const Color(0xFFFF3B30))
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(reg.tieneGlucosa && reg.tienePresion ? "Glucosa y Presión" : (reg.tieneGlucosa ? "Glucosa" : "Presión"), style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF12305B))),
                              Text(DateFormat('dd MMM yyyy • hh:mm a').format(reg.fecha), style: const TextStyle(color: Color(0xFF6B7280), fontSize: 12)),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            if (reg.tieneGlucosa) Text("${reg.glucosa!.toInt()} mg/dL", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF00C7BE))),
                            if (reg.tienePresion) Text("${reg.presionSis}/${reg.presionDia}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFFFF3B30))),
                          ],
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        }
    );
  }
}