import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import 'auth_service.dart';

class ProfileService {
  static Future<Map<String, dynamic>> getProfile() async {
    final token = await AuthService.getToken();
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/me'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      return jsonResponse['data'];
    } else {
      throw Exception('Gagal memuat profil: ${response.statusCode} - ${response.body}');
    }
  }

  static Future<void> updateProfile({
    required String name,
    String? phone,
    String? password,
  }) async {
    final token = await AuthService.getToken();
    final body = <String, dynamic>{'name': name};
    if (phone != null && phone.isNotEmpty) body['phone'] = phone;
    if (password != null && password.isNotEmpty) body['password'] = password;

    final response = await http.put(
      Uri.parse('${ApiConfig.baseUrl}/me'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(body),
    );

    if (response.statusCode != 200) {
      throw Exception('Gagal memperbarui profil: ${response.body}');
    }
  }
}
