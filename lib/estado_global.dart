
import 'package:flutter/material.dart';
import 'services/auth_service.dart';

// --- MODELO DE PERFIL ---
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
    this.notas = '',
  });

  bool get tieneGlucosa => glucosa != null;
  bool get tienePresion => presionSis != null && presionDia != null;
}

// --- ESTADO GLOBAL DE LA APLICACIÓN ---
class AppState extends ChangeNotifier {
  static final AppState _instancia = AppState._interno();

  factory AppState() => _instancia;

  AppState._interno();

  final AuthService _authService = AuthService();

  // PERFIL
  PerfilUsuario perfil = PerfilUsuario(
    nombre: 'Luis',
    edad: 25,
    peso: 75.5,
    altura: 1.75,
  );

  // REGISTROS: ahora comienzan vacíos
  List<RegistroSalud> registros = [];

  // ESTADO DE CARGA
  bool cargandoRegistros = false;
  String? errorRegistros;

  // --- CARGAR MEDICIONES DESDE FASTAPI ---
  Future<void> cargarRegistrosDesdeApi() async {
    cargandoRegistros = true;
    errorRegistros = null;
    notifyListeners();

    try {
      final datos = await _authService.obtenerMediciones();

      registros = datos.map((item) {
        return RegistroSalud(
          id: item['id'].toString(),
          glucosa: item['glucosa'] == null
              ? null
              : (item['glucosa'] as num).toDouble(),
          presionSis: item['presion_sis'] == null
              ? null
              : (item['presion_sis'] as num).toInt(),
          presionDia: item['presion_dia'] == null
              ? null
              : (item['presion_dia'] as num).toInt(),
          fecha: DateTime.parse(item['fecha'].toString()),
          notas: item['notas']?.toString() ?? '',
        );
      }).toList();

      registros.sort((a, b) => b.fecha.compareTo(a.fecha));
    } catch (e) {
      errorRegistros = e.toString();
    } finally {
      cargandoRegistros = false;
      notifyListeners();
    }
  }

  // --- MÉTODOS DE PERFIL ---
  void actualizarPerfil(PerfilUsuario nuevoPerfil) {
    perfil = nuevoPerfil;
    notifyListeners();
  }

  // --- MÉTODOS DE REGISTROS ---
  void agregarRegistro(RegistroSalud nuevo) {
    registros.insert(0, nuevo);
    registros.sort((a, b) => b.fecha.compareTo(a.fecha));
    notifyListeners();
  }

  void actualizarRegistro(RegistroSalud actualizado) {
    final index = registros.indexWhere((r) => r.id == actualizado.id);

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

  // --- LIMPIAR DATOS AL CERRAR SESIÓN ---
  void limpiarRegistros() {
    registros = [];
    notifyListeners();
  }
}

final appState = AppState();
