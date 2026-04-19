import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Importante para formatear la fecha
import '/estado_global.dart';

class RegistroMedicionScreen extends StatefulWidget {
  final RegistroSalud? registroAEditar;
  const RegistroMedicionScreen({super.key, this.registroAEditar});

  @override
  State<RegistroMedicionScreen> createState() => _RegistroMedicionScreenState();
}

class _RegistroMedicionScreenState extends State<RegistroMedicionScreen> {
  final _glucosaCtrl = TextEditingController();
  final _sisCtrl = TextEditingController();
  final _diaCtrl = TextEditingController();
  final _notasCtrl = TextEditingController();

  // 'ambos', 'glucosa', o 'presion'
  String _tipoSeleccionado = 'ambos';

  // Variable para manejar la fecha
  late DateTime _fechaSeleccionada;

  @override
  void initState() {
    super.initState();
    // Iniciamos con la fecha actual por defecto
    _fechaSeleccionada = DateTime.now();

    if (widget.registroAEditar != null) {
      final reg = widget.registroAEditar!;
      if (reg.tieneGlucosa && reg.tienePresion) {
        _tipoSeleccionado = 'ambos';
      } else if (reg.tieneGlucosa) {
        _tipoSeleccionado = 'glucosa';
      } else if (reg.tienePresion) {
        _tipoSeleccionado = 'presion';
      }

      _glucosaCtrl.text = reg.glucosa?.toString() ?? '';
      _sisCtrl.text = reg.presionSis?.toString() ?? '';
      _diaCtrl.text = reg.presionDia?.toString() ?? '';
      _notasCtrl.text = reg.notas;

      // Si estamos editando, cargamos la fecha de ese registro
      _fechaSeleccionada = reg.fecha;
    }
  }

  // Función para abrir el calendario nativo de Android/iOS
  Future<void> _seleccionarFecha(BuildContext context) async {
    final DateTime? fechaElegida = await showDatePicker(
      context: context,
      initialDate: _fechaSeleccionada,
      firstDate: DateTime(2020), // Hasta qué año en el pasado puede elegir
      lastDate: DateTime.now(),  // No dejamos registrar fechas en el futuro
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF2F80ED), // Color principal del calendario
              onPrimary: Colors.white,
              onSurface: Color(0xFF12305B),
            ),
          ),
          child: child!,
        );
      },
    );

    if (fechaElegida != null && fechaElegida != _fechaSeleccionada) {
      setState(() {
        // Mantenemos la hora actual, pero cambiamos el día, mes y año
        _fechaSeleccionada = DateTime(
          fechaElegida.year,
          fechaElegida.month,
          fechaElegida.day,
          DateTime.now().hour,
          DateTime.now().minute,
        );
      });
    }
  }

  void _guardar() {
    final nuevoReg = RegistroSalud(
      id: widget.registroAEditar?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      // Solo guardamos el dato si su categoría está seleccionada
      glucosa: (_tipoSeleccionado == 'ambos' || _tipoSeleccionado == 'glucosa') ? double.tryParse(_glucosaCtrl.text) : null,
      presionSis: (_tipoSeleccionado == 'ambos' || _tipoSeleccionado == 'presion') ? int.tryParse(_sisCtrl.text) : null,
      presionDia: (_tipoSeleccionado == 'ambos' || _tipoSeleccionado == 'presion') ? int.tryParse(_diaCtrl.text) : null,
      // Usamos la fecha seleccionada en el calendario
      fecha: _fechaSeleccionada,
      notas: _notasCtrl.text,
    );

    if (widget.registroAEditar != null) {
      appState.actualizarRegistro(nuevoReg);
    } else {
      appState.agregarRegistro(nuevoReg);
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F8FF),
      appBar: AppBar(
        title: Text(widget.registroAEditar != null ? "Editar Medición" : "Nueva Medición", style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF12305B))),
        backgroundColor: Colors.transparent, elevation: 0, iconTheme: const IconThemeData(color: Color(0xFF12305B)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // SLIDER DE SELECCIÓN
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'glucosa', label: Text('Glucosa')),
                ButtonSegment(value: 'ambos', label: Text('Ambos')),
                ButtonSegment(value: 'presion', label: Text('Presión')),
              ],
              selected: {_tipoSeleccionado},
              onSelectionChanged: (Set<String> newSelection) {
                setState(() { _tipoSeleccionado = newSelection.first; });
              },
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) return const Color(0xFF2F80ED);
                  return Colors.white;
                }),
                foregroundColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) return Colors.white;
                  return const Color(0xFF12305B);
                }),
              ),
            ),
            const SizedBox(height: 24),

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: const [BoxShadow(color: Color(0x0A000000), blurRadius: 10, offset: Offset(0, 4))]),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // SECCIÓN DE FECHA NUEVA
                  const Text("Fecha de la medición", style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF12305B))),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () => _seleccionarFecha(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FBFF),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today, color: Color(0xFF2F80ED)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              DateFormat('dd MMM yyyy').format(_fechaSeleccionada),
                              style: const TextStyle(fontSize: 16, color: Color(0xFF12305B)),
                            ),
                          ),
                          const Icon(Icons.edit, size: 16, color: Color(0xFF6B7280)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // INPUTS DINÁMICOS
                  if (_tipoSeleccionado == 'ambos' || _tipoSeleccionado == 'glucosa')
                    _buildInput("Glucosa (mg/dL)", _glucosaCtrl, Icons.water_drop_outlined, const Color(0xFF00C7BE)),

                  if (_tipoSeleccionado == 'ambos' || _tipoSeleccionado == 'presion')
                    Row(
                      children: [
                        Expanded(child: _buildInput("Sistólica", _sisCtrl, Icons.favorite_border, const Color(0xFFFF3B30))),
                        const SizedBox(width: 16),
                        Expanded(child: _buildInput("Diastólica", _diaCtrl, Icons.favorite_border, const Color(0xFFFF3B30))),
                      ],
                    ),

                  const SizedBox(height: 16),
                  const Text("Notas (Opcional)", style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF12305B))),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _notasCtrl, maxLines: 3,
                    decoration: InputDecoration(
                      filled: true, fillColor: const Color(0xFFF8FBFF),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity, height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2F80ED), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                      onPressed: _guardar,
                      child: const Text("Guardar Registro", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInput(String label, TextEditingController ctrl, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF12305B))),
          const SizedBox(height: 8),
          TextField(
            controller: ctrl, keyboardType: TextInputType.number,
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: color),
              filled: true, fillColor: const Color(0xFFF8FBFF),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
          ),
        ],
      ),
    );
  }
}