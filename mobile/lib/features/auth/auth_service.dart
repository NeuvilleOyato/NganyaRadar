import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants.dart';

class AuthService {
  Future<Map<String, dynamic>> loginDriver(
    String phone,
    String password,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConstants.apiBaseUrl}/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phone_number': phone, 'password': password}),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['access_token'];
        final driver = data['driver']; // Ensure backend returns this!

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', token);

        // Return success map
        return {
          'success': true,
          'nganyaId': driver != null ? driver['assigned_nganya_id'] : null,
        };
      } else {
        return {'success': false, 'error': 'Login failed: ${response.body}'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Connection error: $e'};
    }
  }

  Future<Map<String, dynamic>> registerDriver(
    String phone,
    String password,
    String fullName,
    String vehicleName,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConstants.apiBaseUrl}/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'phone_number': phone,
          'password': password,
          'full_name': fullName,
          'nganya_name': vehicleName,
        }),
      );

      if (response.statusCode == 201) {
        return {'success': true};
      } else {
        return {
          'success': false,
          'error': 'Registration failed: ${response.body}',
        };
      }
    } catch (e) {
      return {'success': false, 'error': 'Connection error: $e'};
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }
}
