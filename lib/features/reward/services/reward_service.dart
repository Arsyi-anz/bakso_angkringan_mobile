import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/reward_model.dart';

class RewardService {
  static const String baseUrl = 'https://bakso-angkringan-web-production-p47hnh.laravel.cloud/api';

  Future<RewardModel> getHampersReward() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null || token.isEmpty) {
      throw Exception(
        'Token tidak ditemukan. Silakan login kembali.',
      );
    }

    final response = await http.get(
      Uri.parse('$baseUrl/reward'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    print('REWARD STATUS: ${response.statusCode}');
    print('REWARD BODY: ${response.body}');

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      final rewardData = data['data'];

      if (rewardData is Map) {
        return RewardModel.fromJson(
          Map<String, dynamic>.from(rewardData),
        );
      }

      throw Exception(
        'Format data reward tidak valid.',
      );
    }

    throw Exception(
      data['message'] ?? 'Gagal mengambil data reward.',
    );
  }
}