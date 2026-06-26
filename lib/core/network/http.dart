import 'dart:convert';
import 'package:http/http.dart' as http;

class HttpClient {
  static const String _baseUrl = 'http://192.168.3.59:8000'; // Android emulator → localhost

  final http.Client _client;

  HttpClient({http.Client? client}) : _client = client ?? http.Client();

  Map<String, String> _headers({String? token}) => {
    'Content-Type': 'application/json',
    if (token != null) 'Authorization': 'Bearer $token',
  };

  Future<Map<String, dynamic>> post(
      String path,
      Map<String, dynamic> body, {
        String? token,
      }) async {
    final response = await _client.post(
      Uri.parse('$_baseUrl$path'),
      headers: _headers(token: token),
      body: jsonEncode(body),
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> get(
      String path, {
        String? token,
      }) async {
    final response = await _client.get(
      Uri.parse('$_baseUrl$path'),
      headers: _headers(token: token),
    );
    return _handleResponse(response);
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    final decoded = jsonDecode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return decoded as Map<String, dynamic>;
    }
    final message = (decoded is Map && decoded.containsKey('detail'))
        ? decoded['detail'].toString()
        : 'Error ${response.statusCode}';
    throw Exception(message);
  }
}