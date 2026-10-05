import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import 'auth_service.dart';

class NotificationService {
  static Future<List<dynamic>> getNotifications() async {
    final token = await AuthService.getToken();
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/notifications'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      return json.decode(response.body)['data'];
    }
    throw Exception('Gagal memuat notifikasi');
  }

  static Future<void> markAsRead(int id) async {
    final token = await AuthService.getToken();
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/notifications/$id/read'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode != 200) {
      throw Exception('Gagal menandai notifikasi');
    }
  }
}