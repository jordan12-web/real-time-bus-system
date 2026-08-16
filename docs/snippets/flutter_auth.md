# Flutter Authentication & Token Refresh Snippet

This snippet demonstrates a clean, robust HTTP authentication client for Flutter using `http` and `flutter_secure_storage` with automatic token refresh on HTTP 401.

```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiClient {
  static const String baseUrl = 'http://localhost:3000';
  final _storage = const FlutterSecureStorage();

  // Save tokens after login/signup
  Future<void> saveTokens(String accessToken, String refreshToken) async {
    await _storage.write(key: 'accessToken', value: accessToken);
    await _storage.write(key: 'refreshToken', value: refreshToken);
  }

  // Get current access token
  Future<String?> getAccessToken() async {
    return await _storage.read(key: 'accessToken');
  }

  // Login request
  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await saveTokens(data['accessToken'], data['refreshToken']);
      return data;
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['error'] ?? 'Login failed');
    }
  }

  // Authenticated GET request with automatic refresh retry
  Future<http.Response> getAuthenticated(String endpoint) async {
    String? token = await getAccessToken();
    var response = await http.get(
      Uri.parse('$baseUrl$endpoint'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    // If 401 Unauthorized, attempt token refresh
    if (response.statusCode == 401) {
      final refreshed = await refreshAccessToken();
      if (refreshed) {
        token = await getAccessToken();
        response = await http.get(
          Uri.parse('$baseUrl$endpoint'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );
      }
    }

    return response;
  }

  // Refresh access token logic
  Future<bool> refreshAccessToken() async {
    final refreshToken = await _storage.read(key: 'refreshToken');
    if (refreshToken == null) return false;

    final response = await http.post(
      Uri.parse('$baseUrl/auth/refresh'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'refreshToken': refreshToken}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await saveTokens(data['accessToken'], data['refreshToken']);
      return true;
    } else {
      await _storage.deleteAll();
      return false;
    }
  }
}
```
