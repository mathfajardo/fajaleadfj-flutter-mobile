import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiException implements Exception {
  final int status;
  final String message;

  ApiException(this.status, this.message);

  @override
  String toString() => message;
}

class Api {
  static const baseUrl = 'https://fajalead.api.shopb2b.com.br/api';

  static String? _token;

  static Future<String?> token() async {
    _token ??= (await SharedPreferences.getInstance()).getString('token');
    return _token;
  }

  static Future<void> _setToken(String? value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value == null) {
      await prefs.remove('token');
    } else {
      await prefs.setString('token', value);
    }
    _token = value;
  }

  static Future<Map<String, dynamic>> _send(
    String method,
    String path, [
    Map<String, dynamic>? body,
  ]) async {
    final request = http.Request(method, Uri.parse('$baseUrl$path'));
    request.headers['Content-Type'] = 'application/json';
    request.headers['Accept'] = 'application/json';
    final t = await token();
    if (t != null) request.headers['Authorization'] = 'Bearer $t';
    if (body != null) request.body = jsonEncode(body);

    final response = await http.Response.fromStream(await request.send());
    final data = response.body.isEmpty
        ? <String, dynamic>{}
        : jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(
        response.statusCode,
        data['message']?.toString() ?? 'Erro',
      );
    }
    return data;
  }

  static Future<Map<String, dynamic>> get(String path) => _send('GET', path);

  static Future<Map<String, dynamic>> post(
    String path,
    Map<String, dynamic> body,
  ) => _send('POST', path, body);

  static Future<Map<String, dynamic>> put(
    String path,
    Map<String, dynamic> body,
  ) => _send('PUT', path, body);

  static Future<Map<String, dynamic>> delete(String path) =>
      _send('DELETE', path);

  static Future<void> login(String email, String password) async {
    final data = await post('/login', {'email': email, 'password': password});
    await _setToken(data['data']['token'] as String);
  }

  static Future<bool> verificaToken() async {
    if (await token() == null) return false;
    try {
      await get('/login/verifica');
      return true;
    } catch (_) {
      return false;
    }
  }

  static Future<void> logout() async {
    try {
      await _send('POST', '/logout');
    } catch (_) {
    } finally {
      await _setToken(null);
    }
  }
}
