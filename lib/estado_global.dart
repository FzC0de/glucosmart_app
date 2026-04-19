import 'package:flutter/material.dart';

// --- NUEVO: MODELO DE PERFIL ---
class PerfilUsuario {
  String nombre;
  int? edad;
  double? peso;
  double? altura;
  bool notificacionesActivas;

  PerfilUsuario({
    required this.nombre,
    this.edad,
    this.peso,
    this.altura,
    this.notificacionesActivas = true,
  });
}

// --- MODELO DE REGISTRO ---
class RegistroSalud {
  String id;
  double? glucosa;
  int? presionSis;
  int? presionDia;
  DateTime fecha;
  String notas;

  RegistroSalud({
    required this.id,
    this.glucosa,
    this.presionSis,
    this.presionDia,
    required this.fecha,
    this.notas = ''
  });

  bool get tieneGlucosa => glucosa != null;
  bool get tienePresion => presionSis != null && presionDia != null;
}

// --- EL CEREBRO ---
class AppState extends ChangeNotifier {
  static final AppState _instancia = AppState._interno();
  factory AppState() => _instancia;
  AppState._interno();

  // 1. Datos del usuario por defecto
  PerfilUsuario perfil = PerfilUsuario(nombre: "Luis", edad: 25, peso: 75.5, altura: 1.75);

  // 2. Historial de prueba
  List<RegistroSalud> registros = [
    RegistroSalud(id: '1', glucosa: 98, presionSis: 120, presionDia: 80, fecha: DateTime.now()),
    RegistroSalud(id: '2', presionSis: 125, presionDia: 82, fecha: DateTime.now().subtract(const Duration(days: 9)), notas: 'Semana pasada'),
    RegistroSalud(id: '3', glucosa: 110, fecha: DateTime.now().subtract(const Duration(days: 16)), notas: 'Hace 2 semanas'),
    RegistroSalud(id: '4', glucosa: 105, presionSis: 118, presionDia: 78, fecha: DateTime.now().subtract(const Duration(days: 23)), notas: 'Hace 3 semanas'),
    RegistroSalud(id: '5', glucosa: 95, presionSis: 115, presionDia: 75, fecha: DateTime.now().subtract(const Duration(days: 30)), notas: 'Hace 4 semanas'),
  ];

  // --- MÉTODOS DE PERFIL ---
  void actualizarPerfil(PerfilUsuario nuevoPerfil) {
    perfil = nuevoPerfil;
    notifyListeners(); // Avisa al Dashboard que el nombre o datos cambiaron
  }

  // --- MÉTODOS DE REGISTROS ---
  void agregarRegistro(RegistroSalud nuevo) {
    registros.insert(0, nuevo);
    registros.sort((a, b) => b.fecha.compareTo(a.fecha));
    notifyListeners();
  }

  void actualizarRegistro(RegistroSalud actualizado) {
    int index = registros.indexWhere((r) => r.id == actualizado.id);
    if (index != -1) {
      registros[index] = actualizado;
      registros.sort((a, b) => b.fecha.compareTo(a.fecha));
      notifyListeners();
    }
  }

  void eliminarRegistro(String id) {
    registros.removeWhere((r) => r.id == id);
    notifyListeners();
  }
}

final appState = AppState();