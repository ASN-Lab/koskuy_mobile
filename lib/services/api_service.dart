import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/kos.dart';
import '../models/thrift.dart';

class ApiService {
  static Future<List<Kos>> getKosList({String? search, String? genderType, String? minPrice, String? maxPrice}) async {
    final queryParams = <String, String>{};
    if (search != null && search.isNotEmpty) queryParams['search'] = search;
    if (genderType != null && genderType.isNotEmpty) queryParams['gender_type'] = genderType;
    if (minPrice != null && minPrice.isNotEmpty) queryParams['min_price'] = minPrice;
    if (maxPrice != null && maxPrice.isNotEmpty) queryParams['max_price'] = maxPrice;

    final uri = Uri.parse('${ApiConfig.baseUrl}/kos').replace(queryParameters: queryParams);
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      final List data = jsonResponse['data']['data'];
      return data.map((e) => Kos.fromJson(e)).toList();
    } else {
      throw Exception('Gagal memuat daftar kos');
    }
  }

  static Future<Kos> getKosDetail(int id) async {
    final response = await http.get(Uri.parse('${ApiConfig.baseUrl}/kos/$id'));
    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      return Kos.fromJson(jsonResponse['data']);
    } else {
      throw Exception('Kos tidak ditemukan');
    }
  }

  static Future<List<ThriftProduct>> getThriftList({String? search, String? categoryId}) async {
    final queryParams = <String, String>{};
    if (search != null && search.isNotEmpty) queryParams['search'] = search;
    if (categoryId != null && categoryId.isNotEmpty) queryParams['category_id'] = categoryId;

    final uri = Uri.parse('${ApiConfig.baseUrl}/thrift').replace(queryParameters: queryParams);
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      final List data = jsonResponse['data']['data'];
      return data.map((e) => ThriftProduct.fromJson(e)).toList();
    } else {
      throw Exception('Gagal memuat produk thrift');
    }
  }

  static Future<ThriftProduct> getThriftDetail(int id) async {
    final response = await http.get(Uri.parse('${ApiConfig.baseUrl}/thrift/$id'));
    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      return ThriftProduct.fromJson(jsonResponse['data']);
    } else {
      throw Exception('Produk tidak ditemukan');
    }
  }

  static Future<List<Category>> getCategories() async {
    final response = await http.get(Uri.parse('${ApiConfig.baseUrl}/categories'));
    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      final List data = jsonResponse['data'];
      return data.map((e) => Category.fromJson(e)).toList();
    } else {
      throw Exception('Gagal memuat kategori');
    }
  }
}
