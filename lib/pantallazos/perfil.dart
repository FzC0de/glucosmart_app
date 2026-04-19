import 'package:flutter/material.dart';
import '/estado_global.dart';

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  final _nombreCtrl = TextEditingController();
  final _edadCtrl = TextEditingController();
  final _pesoCtrl = TextEditingController();
  final _alturaCtrl = TextEditingController();
  bool _notificaciones = true;

  @override
  void initState() {
    super.initState();
    // Cargar los datos actuales del cerebro
    _nombreCtrl.text = appState.perfil.nombre;
    _edadCtrl.text = appState.perfil.edad?.toString() ?? '';
    _pesoCtrl.text = appState.perfil.peso?.toString() ?? '';
    _alturaCtrl.text = appState.perfil.altura?.toString() ?? '';
    _notificaciones = appState.perfil.notificacionesActivas;
  }

  void _guardarCambios() {
    final nuevoPerfil = PerfilUsuario(
      nombre: _nombreCtrl.text.isNotEmpty ? _nombreCtrl.text : "Usuario",
      edad: int.tryParse(_edadCtrl.text),
      peso: double.tryParse(_pesoCtrl.text),
      altura: double.tryParse(_alturaCtrl.text),
      notificacionesActivas: _notificaciones,
    );

    appState.actualizarPerfil(nuevoPerfil);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Perfil actualizado"), backgroundColor: Color(0xFF2F80ED)),
    );
  }

  void _cerrarSesion() {
    // Te devuelve a la pantalla de bienvenida destruyendo el historial de navegación
    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F8FF),
      appBar: AppBar(
        title: const Text("Mi Perfil", style: TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF12305B))),
        backgroundColor: Colors.transparent, elevation: 0,
        automaticallyImplyLeading: false, // Quita flecha atrás porque es pestaña principal
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Foto de perfil
            const Center(
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Color(0xFFEAF3FF),
                child: Icon(Icons.person, size: 50, color: Color(0xFF2F80ED)),
              ),
            ),
            const SizedBox(height: 32),

            // Formulario
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: const [BoxShadow(color: Color(0x0A000000), blurRadius: 10, offset: Offset(0, 4))]),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInput("Nombre", _nombreCtrl, Icons.person_outline),
                  Row(
                    children: [
                      Expanded(child: _buildInput("Edad", _edadCtrl, Icons.cake_outlined, isNumber: true)),
                      const SizedBox(width: 16),
                      Expanded(child: _buildInput("Peso (kg)", _pesoCtrl, Icons.monitor_weight_outlined, isNumber: true)),
                    ],
                  ),
                  _buildInput("Altura (m)", _alturaCtrl, Icons.height, isNumber: true),

                  const Divider(height: 32),

                  // Switch de Notificaciones
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.notifications_active_outlined, color: Color(0xFF12305B)),
                          SizedBox(width: 8),
                          Text("Notificaciones", style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF12305B))),
                        ],
                      ),
                      Switch(
                        value: _notificaciones,
                        activeColor: const Color(0xFF2F80ED),
                        onChanged: (val) {
                          setState(() { _notificaciones = val; });
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Botón Guardar
                  SizedBox(
                    width: double.infinity, height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2F80ED), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                      onPressed: _guardarCambios,
                      child: const Text("Guardar Cambios", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  )
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Botón Cerrar Sesión
            SizedBox(
              width: double.infinity, height: 50,
              child: TextButton.icon(
                style: TextButton.styleFrom(foregroundColor: const Color(0xFFFF3B30)), // Rojo vibrante
                onPressed: _cerrarSesion,
                icon: const Icon(Icons.logout),
                label: const Text("Cerrar Sesión", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
            const SizedBox(height: 80), // Espacio para el menú inferior
          ],
        ),
      ),
    );
  }

  Widget _buildInput(String label, TextEditingController ctrl, IconData icon, {bool isNumber = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF12305B))),
          const SizedBox(height: 8),
          TextField(
            controller: ctrl,
            keyboardType: isNumber ? TextInputType.number : TextInputType.text,
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: const Color(0xFF6B7280)),
              filled: true, fillColor: const Color(0xFFF8FBFF),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
          ),
        ],
      ),
    );
  }
}