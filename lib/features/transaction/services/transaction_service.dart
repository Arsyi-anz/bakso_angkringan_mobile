import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class TransactionService {
  static const String baseUrl = 'https://bakso-angkringan-web-production-p47hnh.laravel.cloud/api';

  Future<List<Map<String, dynamic>>> getTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null || token.isEmpty) {
      throw Exception('Token tidak ditemukan. Silakan login kembali.');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/transaksi'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    print('STATUS: ${response.statusCode}');
    print('BODY: ${response.body}');

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      final transactions = data['data'];

      if (transactions is List) {
        return transactions
            .map((item) => Map<String, dynamic>.from(item))
            .toList();
      }

      return [];
    }

    throw Exception(
      data['message'] ?? 'Gagal mengambil riwayat transaksi.',
    );
  }
}