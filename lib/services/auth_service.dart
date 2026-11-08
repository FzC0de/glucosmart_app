import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  static const String baseUrl = 'http://127.0.0.1:8000';
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('$baseUrl/api/auth/login');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': email.trim(),
          'password': password,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final token = data['access_token'];

        if (token == null || token.toString().isEmpty) {
          throw Exception('El servidor no devolvió un token.');
        }

        await _storage.write(
          key: 'access_token',
          value: token.toString(),
        );

        return Map<String, dynamic>.from(data);
      }

      final detail = data is Map ? data['detail']?.toString() : null;
      throw Exception(
        detail ?? 'Error al iniciar sesión (${response.statusCode}).',
      );
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception(
        'No se pudo conectar con el servidor. Verifica que FastAPI esté activo.',
      );
    }
  }

  Future<String?> getToken() async =>
      _storage.read(key: 'access_token');

  Future<void> logout() async =>
      _storage.delete(key: 'access_token');

  Future<bool> tieneSesion() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  Future<Map<String, String>> _authHeaders() async {
    final token = await getToken();

    if (token == null || token.isEmpty) {
      throw Exception(
        'No existe una sesión activa. Inicia sesión nuevamente.',
      );
    }

    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // CONSULTAR MEDICIONES
  Future<List<Map<String, dynamic>>> obtenerMediciones() async {
    final headers = await _authHeaders();
    final url = Uri.parse('$baseUrl/api/readings');

    try {
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        return data
            .map((item) => Map<String, dynamic>.from(item))
            .toList();
      }

      if (response.statusCode == 401) {
        throw Exception(
          'La sesión ha expirado. Inicia sesión nuevamente.',
        );
      }

      throw Exception(
        'Error al obtener mediciones (${response.statusCode}).',
      );
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception(
        'No se pudieron obtener las mediciones. Verifica la conexión con FastAPI.',
      );
    }
  }

  // REGISTRAR MEDICIÓN
  Future<Map<String, dynamic>> registrarMedicion({
    double? glucosa,
    int? presionSis,
    int? presionDia,
    String notas = '',
    DateTime? fecha,
  }) async {
    final headers = await _authHeaders();
    final url = Uri.parse('$baseUrl/api/readings');

    try {
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode({
          'glucosa': glucosa,
          'presion_sis': presionSis,
          'presion_dia': presionDia,
          'notas': notas,
          if (fecha != null) 'fecha': fecha.toIso8601String(),
        }),
      );

      final dynamic decoded =
          response.body.isEmpty ? null : jsonDecode(response.body);

      if (response.statusCode == 200 ||
          response.statusCode == 201) {
        return Map<String, dynamic>.from(decoded as Map);
      }

      if (response.statusCode == 401) {
        throw Exception(
          'La sesión ha expirado. Inicia sesión nuevamente.',
        );
      }

      final detail =
          decoded is Map ? decoded['detail']?.toString() : null;

      throw Exception(
        detail ??
            'No se pudo guardar la medición (${response.statusCode}).',
      );
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception(
        'No se pudo conectar con el servidor para guardar la medición.',
      );
    }
  }

  // ACTUALIZAR MEDICIÓN
  Future<Map<String, dynamic>> actualizarMedicion({
    required int readingId,
    double? glucosa,
    int? presionSis,
    int? presionDia,
    String notas = '',
    DateTime? fecha,
  }) async {
    final headers = await _authHeaders();
    final url = Uri.parse('$baseUrl/api/readings/$readingId');

    try {
      final response = await http.patch(
        url,
        headers: headers,
        body: jsonEncode({
          'glucosa': glucosa,
          'presion_sis': presionSis,
          'presion_dia': presionDia,
          'notas': notas,
          if (fecha != null) 'fecha': fecha.toIso8601String(),
        }),
      );

      final dynamic decoded =
          response.body.isEmpty ? null : jsonDecode(response.body);

      if (response.statusCode == 200) {
        return Map<String, dynamic>.from(decoded as Map);
      }

      if (response.statusCode == 401) {
        throw Exception(
          'La sesión ha expirado. Inicia sesión nuevamente.',
        );
      }

      if (response.statusCode == 404) {
        throw Exception(
          'La medición ya no existe o no está disponible.',
        );
      }

      final detail =
          decoded is Map ? decoded['detail']?.toString() : null;

      throw Exception(
        detail ??
            'No se pudo actualizar la medición (${response.statusCode}).',
      );
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception(
        'No se pudo conectar con el servidor para actualizar la medición.',
      );
    }
  }

  // ELIMINAR MEDICIÓN
  Future<void> eliminarMedicion(int readingId) async {
    final headers = await _authHeaders();
    final url = Uri.parse('$baseUrl/api/readings/$readingId');

    try {
      final response = await http.delete(url, headers: headers);

      if (response.statusCode == 200 ||
          response.statusCode == 204) {
        return;
      }

      if (response.statusCode == 401) {
        throw Exception(
          'La sesión ha expirado. Inicia sesión nuevamente.',
        );
      }

      if (response.statusCode == 404) {
        throw Exception(
          'La medición ya no existe o no está disponible.',
        );
      }

      dynamic decoded;

      if (response.body.isNotEmpty) {
        decoded = jsonDecode(response.body);
      }

      final detail =
          decoded is Map ? decoded['detail']?.toString() : null;

      throw Exception(
        detail ??
            'No se pudo eliminar la medición (${response.statusCode}).',
      );
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception(
        'No se pudo conectar con el servidor para eliminar la medición.',
      );
    }
  }
}