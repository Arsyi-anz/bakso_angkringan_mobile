import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class InstagramStoryService {
  static const String baseUrl = 'https://bakso-angkringan-web-production-p47hnh.laravel.cloud/api';

  Future<Map<String, dynamic>> submitStory(String link) async {
    final prefs = await SharedPreferences.getInstance();

    final token = prefs.getString('token');

    final response = await http.post(
      Uri.parse('$baseUrl/bukti-ig-story'),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'url_bukti': link,
      }),
    );

    final body = jsonDecode(response.body);

    if (response.statusCode >= 200 &&
        response.statusCode < 300) {
      return body;
    }

    throw Exception(
      body['message'] ??
          'Gagal mengirim bukti Instagram.',
    );
  }

  Future<List<dynamic>> getMyStories() async {
    final prefs = await SharedPreferences.getInstance();

    final token = prefs.getString('token');

    final response = await http.get(
      Uri.parse('$baseUrl/bukti-ig-story'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    final body = jsonDecode(response.body);

    if (response.statusCode >= 200 &&
        response.statusCode < 300) {
      final data = body['data'];

      if (data is List) {
        return data;
      }

      return [];
    }

    throw Exception(
      body['message'] ??
          'Gagal mengambil data Instagram.',
    );
  }
}