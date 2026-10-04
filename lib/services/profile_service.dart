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
}
