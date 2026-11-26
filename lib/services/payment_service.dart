import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import 'auth_service.dart';

class PaymentService {
  static Future<Map<String, String>> _getHeaders() async {
    final token = await AuthService.getToken();
    return {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  static Future<Map<String, dynamic>> initiatePayment(String type, int id, String method) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/payments'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer ${await AuthService.getToken()}',
      },
      body: json.encode({
        'type': type,
        'id': id,
        'method': method,
      }),
    );

    final data = json.decode(response.body);
    if (response.statusCode == 200 && data['success']) {
      return data;
    } else {
      throw Exception(data['message'] ?? 'Gagal inisiasi pembayaran');
    }
  }

  static Future<Map<String, dynamic>> uploadProof(String type, int id, File proofFile) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/payments/$id/proof');
    final request = http.MultipartRequest('POST', uri);
    
    final token = await AuthService.getToken();
    request.headers['Authorization'] = 'Bearer $token';
    request.headers['Accept'] = 'application/json';
    
    request.fields['type'] = type;
    request.files.add(await http.MultipartFile.fromPath('proof', proofFile.path));

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    
    final data = json.decode(response.body);
    if (response.statusCode == 200 && data['success']) {
      return data;
    } else {
      throw Exception(data['message'] ?? 'Gagal mengunggah bukti');
    }
  }

  static Future<Map<String, dynamic>> getPaymentStatus(String type, int id) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/payments/$type/$id'),
      headers: await _getHeaders(),
    );

    final data = json.decode(response.body);
    if (response.statusCode == 200 && data['success']) {
      return data;
    } else {
      throw Exception(data['message'] ?? 'Gagal memuat status pembayaran');
    }
  }
}
