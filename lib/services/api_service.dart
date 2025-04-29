import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:hive/hive.dart';

class ApiService {
  String baseUrl = 'http://192.168.123.183/Pioneer/backend';

  ApiService();

  Future<http.Response> get(String endpoint, {String? token}) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final headers = await _getHeaders(token);
    final response = await http.get(url, headers: headers);
    _handleResponse(response);
    return response;
  }

  Future<http.Response> post(String endpoint, Map<String, dynamic> data, {String? token}) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final headers = await _getHeaders(token);
    final response = await http.post(url, headers: headers, body: jsonEncode(data));
    _handleResponse(response);
    return response;
  }

  Future<http.Response> put(String endpoint, Map<String, dynamic> data, {String? token}) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final headers = await _getHeaders(token);
    final response = await http.put(url, headers: headers, body: jsonEncode(data));
    _handleResponse(response);
    return response;
  }

  Future<http.Response> patch(String endpoint, Map<String, dynamic> data, {String? token}) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final headers = await _getHeaders(token);
    final response = await http.patch(url, headers: headers, body: jsonEncode(data));
    _handleResponse(response);
    return response;
  }

  Future<http.Response> delete(String endpoint, {String? token}) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final headers = await _getHeaders(token);
    final response = await http.delete(url, headers: headers);
    _handleResponse(response);
    return response;
  }

  Future<Map<String, String>> _getHeaders(String? providedToken) async {
    String? token = providedToken;
    
    if (token == null) {
      var box = Hive.box('authBox');
      token = box.get('token');
    }

    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      if (response.body.isNotEmpty) {
        try {
          final errorData = jsonDecode(response.body);
          return {
            'success': false,
            'message': errorData['message'] ?? 'An error occurred',
            'statusCode': response.statusCode,
          };
        } catch (e) {
          return {
            'success': false,
            'message': 'Failed to parse error response: ${response.body}',
            'statusCode': response.statusCode,
          };
        }
      } else {
        return {
          'success': false,
          'message': 'Request failed with status code: ${response.statusCode}',
          'statusCode': response.statusCode,
        };
      }
    }

    if (response.body.isEmpty) {
      return {
        'success': false,
        'message': 'Empty response received',
        'statusCode': response.statusCode,
      };
    }

    return {
      'success': true,
      'message': 'Request successful',
      'statusCode': response.statusCode,
      'data': jsonDecode(response.body),
    };
  }
}