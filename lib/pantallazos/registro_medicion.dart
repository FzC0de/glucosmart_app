import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '/estado_global.dart';
import '/services/auth_service.dart';

class RegistroMedicionScreen extends StatefulWidget {
  final RegistroSalud? registroAEditar;

  const RegistroMedicionScreen({
    super.key,
    this.registroAEditar,
  });

  @override
  State<RegistroMedicionScreen> createState() =>
      _RegistroMedicionScreenState();
}

class _RegistroMedicionScreenState
    extends State<RegistroMedicionScreen> {
  final _glucosaCtrl = TextEditingController();
  final _sisCtrl = TextEditingController();
  final _diaCtrl = TextEditingController();
  final _notasCtrl = TextEditingController();

  final AuthService _authService = AuthService();

  String _tipoSeleccionado = 'ambos';
  late DateTime _fechaSeleccionada;
  bool _guardando = false;

  bool get _estaEditando => widget.registroAEditar != null;

  @override
  void initState() {
    super.initState();

    _fechaSeleccionada = DateTime.now();

    if (_estaEditando) {
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

      _fechaSeleccionada = reg.fecha;
    }
  }

  @override
  void dispose() {
    _glucosaCtrl.dispose();
    _sisCtrl.dispose();
    _diaCtrl.dispose();
    _notasCtrl.dispose();

    super.dispose();
  }

  // SELECCIONAR FECHA
  Future<void> _seleccionarFecha(BuildContext context) async {
    final DateTime? fechaElegida = await showDatePicker(
      context: context,
      initialDate: _fechaSeleccionada,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF2F80ED),
              onPrimary: Colors.white,
              onSurface: Color(0xFF12305B),
            ),
          ),
          child: child!,
        );
      },
    );

    if (fechaElegida != null &&
        fechaElegida != _fechaSeleccionada) {
      setState(() {
        final horaActual = _fechaSeleccionada;

        _fechaSeleccionada = DateTime(
          fechaElegida.year,
          fechaElegida.month,
          fechaElegida.day,
          horaActual.hour,
          horaActual.minute,
          horaActual.second,
        );
      });
    }
  }

  // GUARDAR O ACTUALIZAR
  Future<void> _guardar() async {
    if (_guardando) return;

    final bool incluyeGlucosa =
        _tipoSeleccionado == 'ambos' ||
        _tipoSeleccionado == 'glucosa';

    final bool incluyePresion =
        _tipoSeleccionado == 'ambos' ||
        _tipoSeleccionado == 'presion';

    final double? glucosa = incluyeGlucosa
        ? double.tryParse(_glucosaCtrl.text.trim())
        : null;

    final int? sistolica = incluyePresion
        ? int.tryParse(_sisCtrl.text.trim())
        : null;

    final int? diastolica = incluyePresion
        ? int.tryParse(_diaCtrl.text.trim())
        : null;

    if (incluyeGlucosa &&
        (glucosa == null || glucosa <= 0)) {
      _mostrarMensaje(
        'Ingresa un valor válido de glucosa.',
      );
      return;
    }

    if (incluyePresion &&
        (sistolica == null ||
            diastolica == null ||
            sistolica <= 0 ||
            diastolica <= 0)) {
      _mostrarMensaje(
        'Ingresa valores válidos de presión sistólica y diastólica.',
      );
      return;
    }

    setState(() => _guardando = true);

    try {
      if (_estaEditando) {
        final id = int.tryParse(
          widget.registroAEditar!.id,
        );

        if (id == null) {
          throw Exception(
            'No se pudo identificar la medición que deseas editar.',
          );
        }

        await _authService.actualizarMedicion(
          readingId: id,
          glucosa: glucosa,
          presionSis: sistolica,
          presionDia: diastolica,
          notas: _notasCtrl.text.trim(),
          fecha: _fechaSeleccionada,
        );
      } else {
        await _authService.registrarMedicion(
          glucosa: glucosa,
          presionSis: sistolica,
          presionDia: diastolica,
          notas: _notasCtrl.text.trim(),
          fecha: _fechaSeleccionada,
        );
      }

      // Recargar los registros desde FastAPI.
      await appState.cargarRegistrosDesdeApi();

      if (!mounted) return;

      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _estaEditando
                ? 'Medición actualizada correctamente.'
                : 'Medición guardada correctamente.',
          ),
          backgroundColor: const Color(0xFF2E9D65),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      _mostrarMensaje(
        e.toString().replaceFirst('Exception: ', ''),
      );
    } finally {
      if (mounted) {
        setState(() => _guardando = false);
      }
    }
  }

  void _mostrarMensaje(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F8FF),

      appBar: AppBar(
        title: Text(
          _estaEditando
              ? 'Editar Medición'
              : 'Nueva Medición',
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            color: Color(0xFF12305B),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(
          color: Color(0xFF12305B),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(
                  value: 'glucosa',
                  label: Text('Glucosa'),
                ),
                ButtonSegment(
                  value: 'ambos',
                  label: Text('Ambos'),
                ),
                ButtonSegment(
                  value: 'presion',
                  label: Text('Presión'),
                ),
              ],
              selected: {_tipoSeleccionado},
              onSelectionChanged: _guardando
                  ? null
                  : (Set<String> newSelection) {
                      setState(() {
                        _tipoSeleccionado =
                            newSelection.first;
                      });
                    },
              style: ButtonStyle(
                backgroundColor:
                    WidgetStateProperty.resolveWith(
                  (states) {
                    if (states.contains(
                      WidgetState.selected,
                    )) {
                      return const Color(0xFF2F80ED);
                    }

                    return Colors.white;
                  },
                ),
                foregroundColor:
                    WidgetStateProperty.resolveWith(
                  (states) {
                    if (states.contains(
                      WidgetState.selected,
                    )) {
                      return Colors.white;
                    }

                    return const Color(0xFF12305B);
                  },
                ),
              ),
            ),

            const SizedBox(height: 24),

            Container(
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
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Fecha de la medición',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF12305B),
                    ),
                  ),

                  const SizedBox(height: 8),

                  GestureDetector(
                    onTap: _guardando
                        ? null
                        : () => _seleccionarFecha(context),

                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FBFF),
                        borderRadius: BorderRadius.circular(12),
                      ),

                      child: Row(
                        children: [
                          const Icon(
                            Icons.calendar_today,
                            color: Color(0xFF2F80ED),
                          ),

                          const SizedBox(width: 12),

                          Expanded(
                            child: Text(
                              DateFormat('dd MMM yyyy')
                                  .format(_fechaSeleccionada),
                              style: const TextStyle(
                                fontSize: 16,
                                color: Color(0xFF12305B),
                              ),
                            ),
                          ),

                          const Icon(
                            Icons.edit,
                            size: 16,
                            color: Color(0xFF6B7280),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  if (_tipoSeleccionado == 'ambos' ||
                      _tipoSeleccionado == 'glucosa')
                    _buildInput(
                      'Glucosa (mg/dL)',
                      _glucosaCtrl,
                      Icons.water_drop_outlined,
                      const Color(0xFF00C7BE),
                    ),

                  if (_tipoSeleccionado == 'ambos' ||
                      _tipoSeleccionado == 'presion')
                    Row(
                      children: [
                        Expanded(
                          child: _buildInput(
                            'Sistólica',
                            _sisCtrl,
                            Icons.favorite_border,
                            const Color(0xFFFF3B30),
                          ),
                        ),

                        const SizedBox(width: 16),

                        Expanded(
                          child: _buildInput(
                            'Diastólica',
                            _diaCtrl,
                            Icons.favorite_border,
                            const Color(0xFFFF3B30),
                          ),
                        ),
                      ],
                    ),

                  const SizedBox(height: 16),

                  const Text(
                    'Notas (Opcional)',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF12305B),
                    ),
                  ),

                  const SizedBox(height: 8),

                  TextField(
                    controller: _notasCtrl,
                    maxLines: 3,
                    enabled: !_guardando,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFFF8FBFF),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2F80ED),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),

                      onPressed: _guardando
                          ? null
                          : _guardar,

                      child: _guardando
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              _estaEditando
                                  ? 'Actualizar Registro'
                                  : 'Guardar Registro',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // CAMPOS DE ENTRADA
  Widget _buildInput(
    String label,
    TextEditingController ctrl,
    IconData icon,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Color(0xFF12305B),
            ),
          ),

          const SizedBox(height: 8),

          TextField(
            controller: ctrl,
            enabled: !_guardando,
            keyboardType:
                const TextInputType.numberWithOptions(
              decimal: true,
            ),
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: color),
              filled: true,
              fillColor: const Color(0xFFF8FBFF),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}