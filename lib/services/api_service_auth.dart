import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import 'auth_service.dart';

class ApiService {
  // ... existing methods ...

  static Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/login'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email, 'password': password}),
    );

    final data = json.decode(response.body);
    if (response.statusCode == 200 && data['success'] == true) {
      await AuthService.saveToken(data['data']['token']);
      return data['data'];
    } else {
      throw Exception(data['message'] ?? 'Login gagal');
    }
  }

  static Future<Map<String, dynamic>> register(String name, String email, String password, String? phone) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/register'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'name': name,
        'email': email,
        'password': password,
        'phone': phone,
      }),
    );

    final data = json.decode(response.body);
    if (response.statusCode == 201 && data['success'] == true) {
      await AuthService.saveToken(data['data']['token']);
      return data['data'];
    } else {
      throw Exception(data['message'] ?? 'Registrasi gagal');
    }
  }

  static Future<void> bookKos(int kosId, String bookingDate, String? notes) async {
    final token = await AuthService.getToken();
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/bookings'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({
        'kos_id': kosId,
        'booking_date': bookingDate,
        'notes': notes,
      }),
    );

    final data = json.decode(response.body);
    if (response.statusCode != 201) {
      throw Exception(data['message'] ?? 'Gagal melakukan booking');
    }
  }
}
