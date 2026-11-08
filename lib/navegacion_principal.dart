import 'package:flutter/material.dart';
import 'package:glucosmart_app/pantallazos/dashboard.dart';
import 'package:glucosmart_app/pantallazos/historial.dart';
import 'package:glucosmart_app/pantallazos/registro_medicion.dart';
import 'package:glucosmart_app/pantallazos/perfil.dart';
import 'package:glucosmart_app/estado_global.dart';

class NavegacionPrincipal extends StatefulWidget {
  const NavegacionPrincipal({super.key});

  @override
  State<NavegacionPrincipal> createState() => _NavegacionPrincipalState();
}

class _NavegacionPrincipalState extends State<NavegacionPrincipal> {
  // Índices de las pantallas reales: Inicio, Historial y Perfil.
  // Registrar es una acción y abre una pantalla independiente.
  int _indiceSeleccionado = 0;

  final List<Widget> _pantallas = [
    DashboardScreen(),
    HistorialScreen(),
    PerfilScreen(),
  ];

  @override
  void initState() {
    super.initState();

    // Cargar las mediciones reales desde FastAPI.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      appState.cargarRegistrosDesdeApi();
    });
  }

  // Convierte el índice de pantalla al índice visual de la barra:
  // Inicio = 0, Registrar = 1, Historial = 2, Perfil = 3.
  int get _indiceBarra {
    switch (_indiceSeleccionado) {
      case 0:
        return 0;
      case 1:
        return 2;
      case 2:
        return 3;
      default:
        return 0;
    }
  }

  void _seleccionarOpcion(int index) {
    if (index == 1) {
      // Registrar tiene su propio espacio y abre el formulario.
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const RegistroMedicionScreen(),
        ),
      );
      return;
    }

    setState(() {
      // Ajustamos los índices porque Registrar no es una pestaña.
      _indiceSeleccionado = index == 0 ? 0 : index - 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pantallas[_indiceSeleccionado],

      // Las cuatro opciones tienen ahora su propio espacio.
      // Ya no usamos un FloatingActionButton superpuesto a Historial.
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF2F80ED),
        unselectedItemColor: const Color(0xFF6B7280),
        currentIndex: _indiceBarra,
        onTap: _seleccionarOpcion,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        showUnselectedLabels: true,
        elevation: 8,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: "Inicio",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline),
            activeIcon: Icon(Icons.add_circle),
            label: "Registrar",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_outlined),
            activeIcon: Icon(Icons.history),
            label: "Historial",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: "Perfil",
          ),
        ],
      ),
    );
  }
}
