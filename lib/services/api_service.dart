// ════════════════════════════════════════════════════════════
//  CAPA DE SERVICIO API — api_service.dart
//  Función compartida: apiCall(route, method, body)
//  Todos los devs usan este archivo para llamar a la API
// ════════════════════════════════════════════════════════════
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// ─── CONSTANTES ───────────────────────────────────────────
const String _baseUrl = 'http://192.168.43.224:3000';

// ─── ALMACENAMIENTO SEGURO ────────────────────────────────
const _storage = FlutterSecureStorage();

class ApiService {
  static Future<String?> _getToken() async {
    return await _storage.read(key: 'jwt_token');
  }

  static Future<void> saveToken(String token) async {
    await _storage.write(key: 'jwt_token', value: token);
  }

  static Future<void> saveUserId(String userId) async {
    await _storage.write(key: 'user_id', value: userId);
  }

  static Future<String?> getUserId() async {
    return await _storage.read(key: 'user_id');
  }

  static Future<void> clearToken() async {
    await _storage.delete(key: 'jwt_token');
    await _storage.delete(key: 'user_id');
  }

  static Future<dynamic> _makeRequest(
    String route,
    String method, {
    Map<String, dynamic>? body,
    Map<String, String>? queryParams,
    Map<String, String>? extraHeaders,
  }) async {
    final token = await _getToken();
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
      ...?extraHeaders,
    };

    Uri uri = Uri.parse('$_baseUrl$route');
    if (queryParams != null) {
      uri = uri.replace(queryParameters: queryParams);
    }

    http.Response response;

    try {
      print('--- API REQUEST ---');
      print('URL: $uri');
      print('Method: $method');
      if (body != null) print('Body: ${jsonEncode(body)}');

      switch (method.toUpperCase()) {
        case 'GET': response = await http.get(uri, headers: headers); break;
        case 'POST': response = await http.post(uri, headers: headers, body: jsonEncode(body ?? {})); break;
        case 'PUT': response = await http.put(uri, headers: headers, body: jsonEncode(body ?? {})); break;
        case 'PATCH': response = await http.patch(uri, headers: headers, body: jsonEncode(body ?? {})); break;
        case 'DELETE': response = await http.delete(uri, headers: headers); break;
        default: throw Exception('Método HTTP no soportado: $method');
      }

      print('Status: ${response.statusCode}');
      print('Response: ${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (response.body.isEmpty) return <String, dynamic>{};
        return jsonDecode(response.body);
      } else {
        throw ApiException(
          statusCode: response.statusCode,
          message: _parseErrorMessage(response.body, route),
        );
      }
    } on ApiException {
      rethrow;
    } catch (e) {
      print('Connection Error: $e');
      throw ApiException(message: 'Error de conexión: $e');
    }
  }

  static Future<Map<String, dynamic>> apiCall(
    String route,
    String method, {
    Map<String, dynamic>? body,
    Map<String, String>? queryParams,
    Map<String, String>? extraHeaders,
  }) async {
    final result = await _makeRequest(route, method,
        body: body, queryParams: queryParams, extraHeaders: extraHeaders);
    if (result is Map<String, dynamic>) return result;
    return {'data': result};
  }

  static Future<List<dynamic>> apiCallList(
    String route,
    String method, {
    Map<String, dynamic>? body,
    Map<String, String>? queryParams,
    Map<String, String>? extraHeaders,
  }) async {
    final result = await _makeRequest(route, method,
        body: body, queryParams: queryParams, extraHeaders: extraHeaders);
    if (result is List) return result;
    if (result is Map && result.containsKey('data')) {
      final data = result['data'];
      if (data is List) return data;
    }
    return [];
  }

  static String _parseErrorMessage(String body, String route) {
    try {
      if (body.contains('Cannot POST') || body.contains('Cannot GET')) {
        return 'La ruta "$route" no existe en el servidor. Verifica el backend.';
      }
      final decoded = jsonDecode(body);
      return decoded['message'] ?? decoded['error'] ?? 'Error desconocido';
    } catch (_) {
      return body.isNotEmpty ? body : 'Error desconocido';
    }
  }
}

class ApiException implements Exception {
  final int? statusCode;
  final String message;
  ApiException({this.statusCode, required this.message});
  @override
  String toString() => 'ApiException(${statusCode ?? '?'}): $message';
}

// ─── SERVICIOS POR MÓDULO ──────────────────────────────────

class AuthService {
  static Future<Map<String, dynamic>> login(String email, String password) =>
      ApiService.apiCall('/auth/login', 'POST', body: {'email': email, 'password': password});
}

class JournalService {
  static Future<Map<String, dynamic>> createEntry(String text, String mood, String userId) =>
      ApiService.apiCall('/journal', 'POST', body: {'text': text, 'mood': mood, 'userId': userId});

  static Future<List<dynamic>> getHistory(String userId) =>
      ApiService.apiCallList('/journal', 'GET', queryParams: {'userId': userId});
}

class SafetyService {
  static Future<List<dynamic>> getContacts(String userId) =>
      ApiService.apiCallList('/safety/contacts', 'GET', queryParams: {'userId': userId});

  static Future<Map<String, dynamic>> addContact(String userId, String name, String phone) =>
      ApiService.apiCall('/safety/contacts', 'POST', body: {'userId': userId, 'name': name, 'phone': phone});

  static Future<Map<String, dynamic>> deleteContact(String contactId, String userId) =>
      ApiService.apiCall('/safety/contacts/$contactId', 'DELETE', queryParams: {'userId': userId});

  static Future<Map<String, dynamic>> activateCompanion({required String userId, required String userName, required double lat, required double lng}) =>
      ApiService.apiCall('/safety/activate', 'POST', body: {'userId': userId, 'userName': userName, 'lat': lat, 'lng': lng});
}

class SupportService {
  static Future<Map<String, dynamic>> sendMessage(String text, String userId) =>
      ApiService.apiCall('/support/chat', 'POST', body: {'text': text, 'userId': userId});
}
