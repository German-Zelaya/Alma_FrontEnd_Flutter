// ════════════════════════════════════════════════════════════
//  CAPA DE SERVICIO API — api_service.dart
//  Función compartida: apiCall(route, method, body)
//  Todos los devs usan este archivo para llamar a la API
//  Equivalente al SDK compartido del Dev 1
// ════════════════════════════════════════════════════════════
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// ─── CONSTANTES ───────────────────────────────────────────
const String _baseUrl = 'https://TU_API_GATEWAY_URL.execute-api.us-east-1.amazonaws.com/prod';
// TODO: Reemplazar con la URL real del API Gateway del Dev 1

// ─── ALMACENAMIENTO SEGURO DE TOKEN ───────────────────────
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

  // ── Eliminar token al cerrar sesión ───────────────────
  static Future<void> clearToken() async {
    await _storage.delete(key: 'jwt_token');
  }

  // ══════════════════════════════════════════════════════
  //  FUNCIÓN PRINCIPAL — apiCall(route, method, body)
  //  Equivalente al apiCall() compartido del Dev 1
  // ══════════════════════════════════════════════════════
  static Future<Map<String, dynamic>> apiCall(
    String route,
    String method, {
    Map<String, dynamic>? body,
    Map<String, String>? queryParams,
  }) async {
    final token = await _getToken();
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
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
        if (response.body.isEmpty) return {};
        return jsonDecode(response.body) as Map<String, dynamic>;
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
//  SERVICIOS POR MÓDULO — referencia rápida para todos los devs
// ══════════════════════════════════════════════════════════

// ─── DEV 1: Auth + Diario ─────────────────────────────────
class AuthService {
  static Future<Map<String, dynamic>> login(String email, String password) =>
    ApiService.apiCall('/auth/login', 'POST', body: {'email': email, 'password': password});

  static Future<Map<String, dynamic>> register(String name, String email, String password) =>
    ApiService.apiCall('/auth/register', 'POST', body: {'name': name, 'email': email, 'password': password});

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
  // POST /habits/log → { habit, value, date }
  static Future<Map<String, dynamic>> logHabit(String habit, bool value) =>
    ApiService.apiCall('/habits/log', 'POST', body: {'habit': habit, 'value': value, 'date': DateTime.now().toIso8601String()});

  // GET /habits/summary → { summary: 'IA text', weeklyData: [...] }
  static Future<Map<String, dynamic>> getWeeklySummary() =>
    ApiService.apiCall('/habits/summary', 'GET');
}

class CycleService {
  // GET /cycle/current → { phase, day, recommendations: [...] }
  static Future<Map<String, dynamic>> getCurrentCycle() =>
    ApiService.apiCall('/cycle/current', 'GET');

  // POST /cycle/log → { startDate, cycleLength }
  static Future<Map<String, dynamic>> logCycle(DateTime startDate, int length) =>
    ApiService.apiCall('/cycle/log', 'POST', body: {'startDate': startDate.toIso8601String(), 'cycleLength': length});
}

class GoalsService {
  // GET /goals → [ { id, title, category, progress } ]
  static Future<Map<String, dynamic>> getGoals() =>
    ApiService.apiCall('/goals', 'GET');

  // POST /goals → { title, category }
  static Future<Map<String, dynamic>> createGoal(String title, String category) =>
    ApiService.apiCall('/goals', 'POST', body: {'title': title, 'category': category});

  // POST /goals/advice → { advice: 'IA text' }
  static Future<Map<String, dynamic>> getAdvice(String goalId) =>
    ApiService.apiCall('/goals/advice', 'POST', body: {'goalId': goalId});
}

// ─── DEV 3: Agenda + Crecimiento ─────────────────────────
class TasksService {
  // GET /tasks → [ { id, title, priority, completed, date } ]
  static Future<Map<String, dynamic>> getTasks() =>
    ApiService.apiCall('/tasks', 'GET');

  // POST /tasks → { title, priority }
  static Future<Map<String, dynamic>> createTask(String title, String priority) =>
    ApiService.apiCall('/tasks', 'POST', body: {'title': title, 'priority': priority});

  // DELETE /tasks/:id
  static Future<Map<String, dynamic>> deleteTask(String id) =>
    ApiService.apiCall('/tasks/$id', 'DELETE');

  // PATCH /tasks/:id → { completed }
  static Future<Map<String, dynamic>> toggleTask(String id, bool completed) =>
    ApiService.apiCall('/tasks/$id', 'PATCH', body: {'completed': completed});
}

class GrowthService {
  // GET /growth/tip → { tip: 'IA text', category }
  static Future<Map<String, dynamic>> getDailyTip() =>
    ApiService.apiCall('/growth/tip', 'GET');
}

// ─── DEV 4: Compañía + Soporte + Notificaciones ───────────
class SafetyService {
  // POST /safety/activate → SNS SMS a contactos
  static Future<Map<String, dynamic>> activateCompanion() =>
    ApiService.apiCall('/safety/activate', 'POST');

  // GET /safety/contacts → [ { name, phone } ]
  static Future<Map<String, dynamic>> getContacts() =>
    ApiService.apiCall('/safety/contacts', 'GET');

  // POST /safety/contacts → { name, phone }
  static Future<Map<String, dynamic>> addContact(String name, String phone) =>
    ApiService.apiCall('/safety/contacts', 'POST', body: {'name': name, 'phone': phone});
}

class SupportService {
  // POST /support/chat → { message, history } → { response, isCrisis }
  static Future<Map<String, dynamic>> sendMessage(String message, List<Map<String, String>> history) =>
    ApiService.apiCall('/support/chat', 'POST', body: {'message': message, 'history': history});
}

class NotificationsService {
  // POST /notifications/preferences → { dailyReminder, weeklyReport, cycleAlerts, reminderTime }
  static Future<Map<String, dynamic>> updatePreferences(Map<String, dynamic> prefs) =>
    ApiService.apiCall('/notifications/preferences', 'POST', body: prefs);
}
