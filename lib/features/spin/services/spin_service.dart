import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class SpinService {
  final String baseUrl = 'http://127.0.0.1:8000/api';

  Future<Map<String, dynamic>> getStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null || token.isEmpty) {
      throw Exception('Token tidak ditemukan.');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/spin/status'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    final body = jsonDecode(response.body);

    if (response.statusCode != 200) {
      throw Exception(
        body['message'] ?? 'Gagal memuat status spin.',
      );
    }

    return Map<String, dynamic>.from(body['data']);
  }

  Future<Map<String, dynamic>> spin({
    int? transaksiId,
    int? buktiIgStoryId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null || token.isEmpty) {
      throw Exception('Token tidak ditemukan.');
    }

    final data = <String, dynamic>{};

    if (transaksiId != null) {
      data['transaksi_id'] = transaksiId;
    }

    if (buktiIgStoryId != null) {
      data['bukti_ig_story_id'] = buktiIgStoryId;
    }

    final response = await http.post(
      Uri.parse('$baseUrl/spin'),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(data),
    );

    final body = jsonDecode(response.body);

    if (response.statusCode != 201) {
      throw Exception(
        body['message'] ?? 'Spin gagal.',
      );
    }

    return Map<String, dynamic>.from(body);
  }
}