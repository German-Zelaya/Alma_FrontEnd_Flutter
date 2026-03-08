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
  // ── Obtener token (Cognito JWT) ────────────────────────
  static Future<String?> _getToken() async {
    return await _storage.read(key: 'jwt_token');
  }

  // ── Guardar token tras login ───────────────────────────
  static Future<void> saveToken(String token) async {
    await _storage.write(key: 'jwt_token', value: token);
  }

  // ── Guardar userId tras login ──────────────────────────
  static Future<void> saveUserId(String userId) async {
    await _storage.write(key: 'user_id', value: userId);
  }

  // ── Obtener userId del storage ─────────────────────────
  static Future<String?> getUserId() async {
    return await _storage.read(key: 'user_id');
  }

  // ── Eliminar sesión al cerrar sesión ──────────────────
  static Future<void> clearToken() async {
    await _storage.delete(key: 'jwt_token');
    await _storage.delete(key: 'user_id');
  }

  // ══════════════════════════════════════════════════════
  //  REQUEST INTERNO — retorna dynamic (Map o List)
  // ══════════════════════════════════════════════════════
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
      switch (method.toUpperCase()) {
        case 'GET':
          response = await http.get(uri, headers: headers);
          break;
        case 'POST':
          response = await http.post(uri, headers: headers, body: jsonEncode(body ?? {}));
          break;
        case 'PUT':
          response = await http.put(uri, headers: headers, body: jsonEncode(body ?? {}));
          break;
        case 'PATCH':
          response = await http.patch(uri, headers: headers, body: jsonEncode(body ?? {}));
          break;
        case 'DELETE':
          response = await http.delete(uri, headers: headers);
          break;
        default:
          throw Exception('Método HTTP no soportado: $method');
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (response.body.isEmpty) return <String, dynamic>{};
        return jsonDecode(response.body);
      } else {
        throw ApiException(
          statusCode: response.statusCode,
          message: _parseErrorMessage(response.body),
        );
      }
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'Error de conexión: $e');
    }
  }

  // ══════════════════════════════════════════════════════
  //  FUNCIÓN PRINCIPAL — retorna Map<String, dynamic>
  // ══════════════════════════════════════════════════════
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

  // ══════════════════════════════════════════════════════
  //  VARIANTE LISTA — para endpoints que devuelven array
  // ══════════════════════════════════════════════════════
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

  static String _parseErrorMessage(String body) {
    try {
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

// ══════════════════════════════════════════════════════════
//  SERVICIOS POR MÓDULO
// ══════════════════════════════════════════════════════════

// ─── DEV 1: Auth + Diario ─────────────────────────────────
class AuthService {
  static Future<Map<String, dynamic>> login(String email, String password) =>
      ApiService.apiCall('/auth/login', 'POST',
          body: {'email': email, 'password': password});

  static Future<Map<String, dynamic>> register(
          String name, String email, String password) =>
      ApiService.apiCall('/auth/register', 'POST',
          body: {'name': name, 'email': email, 'password': password});

  static Future<void> logout() => ApiService.clearToken();
}

class JournalService {
  // POST /journal → { text } → { id, ai_response, createdAt }
  static Future<Map<String, dynamic>> createEntry(String text, String mood) =>
      ApiService.apiCall('/journal', 'POST', body: {'text': text, 'mood': mood});

  // GET /journal → [ { id, text, mood, ai_response, createdAt } ]
  static Future<Map<String, dynamic>> getHistory() =>
      ApiService.apiCall('/journal', 'GET');
}

// ─── DEV 2: Hábitos + Ciclo + Metas ──────────────────────
class HabitsService {
  static Future<Map<String, dynamic>> logHabit(String habit, bool value) =>
      ApiService.apiCall('/habits/log', 'POST', body: {
        'habit': habit,
        'value': value,
        'date': DateTime.now().toIso8601String()
      });

  static Future<Map<String, dynamic>> getWeeklySummary() =>
      ApiService.apiCall('/habits/summary', 'GET');
}

class CycleService {
  static Future<Map<String, dynamic>> getCurrentCycle() =>
      ApiService.apiCall('/cycle/current', 'GET');

  static Future<Map<String, dynamic>> logCycle(
          DateTime startDate, int length) =>
      ApiService.apiCall('/cycle/log', 'POST', body: {
        'startDate': startDate.toIso8601String(),
        'cycleLength': length
      });
}

class GoalsService {
  static Future<Map<String, dynamic>> getGoals() =>
      ApiService.apiCall('/goals', 'GET');

  static Future<Map<String, dynamic>> createGoal(
          String title, String category) =>
      ApiService.apiCall('/goals', 'POST',
          body: {'title': title, 'category': category});

  static Future<Map<String, dynamic>> getAdvice(String goalId) =>
      ApiService.apiCall('/goals/advice', 'POST', body: {'goalId': goalId});
}

// ─── DEV 3: Agenda + Crecimiento ─────────────────────────
class TasksService {
  static Future<Map<String, dynamic>> getTasks() =>
      ApiService.apiCall('/tasks', 'GET');

  static Future<Map<String, dynamic>> createTask(
          String title, String priority) =>
      ApiService.apiCall('/tasks', 'POST',
          body: {'title': title, 'priority': priority});

  static Future<Map<String, dynamic>> deleteTask(String id) =>
      ApiService.apiCall('/tasks/$id', 'DELETE');

  static Future<Map<String, dynamic>> toggleTask(String id, bool completed) =>
      ApiService.apiCall('/tasks/$id', 'PATCH',
          body: {'completed': completed});
}

class GrowthService {
  static Future<Map<String, dynamic>> getDailyTip() =>
      ApiService.apiCall('/growth/tip', 'GET');
}

// ─── DEV 4: Compañía + Soporte + Notificaciones ───────────

class SafetyService {
  /// Activa alerta de emergencia y notifica a los contactos de confianza.
  /// Requiere userId, userName y las coordenadas GPS del usuario.
  static Future<Map<String, dynamic>> activateCompanion({
    required String userId,
    required String userName,
    required double lat,
    required double lng,
  }) =>
      ApiService.apiCall('/safety/activate', 'POST', body: {
        'userId': userId,
        'userName': userName,
        'lat': lat,
        'lng': lng,
      });

  /// Obtiene la lista de contactos de emergencia del usuario.
  /// Devuelve un array: [{ id, userId, name, phone }]
  static Future<List<dynamic>> getContacts(String userId) =>
      ApiService.apiCallList('/safety/contacts', 'GET',
          queryParams: {'userId': userId});

  /// Crea un nuevo contacto de emergencia.
  static Future<Map<String, dynamic>> addContact(
          String userId, String name, String phone) =>
      ApiService.apiCall('/safety/contacts', 'POST',
          body: {'userId': userId, 'name': name, 'phone': phone});

  /// Elimina un contacto de emergencia por su ID.
  static Future<Map<String, dynamic>> deleteContact(
          String contactId, String userId) =>
      ApiService.apiCall('/safety/contacts/$contactId', 'DELETE',
          queryParams: {'userId': userId});
}

class SupportService {
  /// Envía un mensaje al chat de soporte IA (Bedrock).
  /// Requiere el userId en el header x-user-id.
  /// Respuesta: { response: string, isCrisis: bool }
  static Future<Map<String, dynamic>> sendMessage(
          String message, String userId) =>
      ApiService.apiCall('/support/chat', 'POST',
          body: {'message': message},
          extraHeaders: {'x-user-id': userId});
}

class NotificationsSmsService {
  /// Envía un SMS a una lista de números de teléfono.
  static Future<Map<String, dynamic>> sendSms(
          List<String> phones, String message) =>
      ApiService.apiCall('/notifications/send', 'POST',
          body: {'phones': phones, 'message': message});
}

class WhatsAppService {
  /// Envía un mensaje de WhatsApp a un número destino.
  static Future<Map<String, dynamic>> sendWhatsApp(
          String to, String message) =>
      ApiService.apiCall('/whatsapp/send', 'POST',
          body: {'to': to, 'message': message});
}

class NotificationsService {
  // POST /notifications/preferences → { dailyReminder, weeklyReport, cycleAlerts, reminderTime }
  static Future<Map<String, dynamic>> updatePreferences(
          Map<String, dynamic> prefs) =>
      ApiService.apiCall('/notifications/preferences', 'POST', body: prefs);
}
