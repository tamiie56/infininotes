import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../../../core/constants/app_constants.dart';

class ApiService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<String?> _getToken() async {
    return await _storage.read(key: AppConstants.tokenKey);
  }

  Map<String, String> _headers({bool auth = false, String? token}) {
    final headers = {'Content-Type': 'application/json'};
    if (auth && token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Future<Map<String, dynamic>> post(String url, Map<String, dynamic> body, {bool auth = false}) async {
    final token = auth ? await _getToken() : null;
    final response = await http.post(
      Uri.parse(url),
      headers: _headers(auth: auth, token: token),
      body: jsonEncode(body),
    );
    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> get(String url) async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse(url),
      headers: _headers(auth: true, token: token),
    );
    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> put(String url, Map<String, dynamic> body) async {
    final token = await _getToken();
    final response = await http.put(
      Uri.parse(url),
      headers: _headers(auth: true, token: token),
      body: jsonEncode(body),
    );
    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> patch(String url, {Map<String, dynamic>? body}) async {
    final token = await _getToken();
    final response = await http.patch(
      Uri.parse(url),
      headers: _headers(auth: true, token: token),
      body: body != null ? jsonEncode(body) : null,
    );
    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> delete(String url) async {
    final token = await _getToken();
    final response = await http.delete(
      Uri.parse(url),
      headers: _headers(auth: true, token: token),
    );
    return jsonDecode(response.body);
  }
}