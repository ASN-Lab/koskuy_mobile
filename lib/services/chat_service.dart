import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import 'auth_service.dart';

class ChatService {
  static Future<List<dynamic>> getMessages(int recipientId) async {
    final token = await AuthService.getToken();
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/messages/$recipientId'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      return jsonResponse['data'] ?? [];
    } else {
      throw Exception('Gagal memuat pesan');
    }
  }

  static Future<Map<String, dynamic>> sendMessage(int recipientId, String body) async {
    final token = await AuthService.getToken();
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/messages/$recipientId'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({'body': body}),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      return jsonResponse['data'] ?? jsonResponse;
    } else {
      throw Exception('Gagal mengirim pesan');
    }
  }
}
