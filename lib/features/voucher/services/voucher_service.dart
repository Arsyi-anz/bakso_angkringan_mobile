import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/voucher_model.dart';

class VoucherService {
  static const String baseUrl = 'https://bakso-angkringan-web-production-p47hnh.laravel.cloud/api';

  Future<List<VoucherModel>> getVouchers() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null || token.isEmpty) {
      throw Exception(
        'Token tidak ditemukan. Silakan login kembali.',
      );
    }

    final response = await http.get(
      Uri.parse('$baseUrl/voucher'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    print('VOUCHER STATUS: ${response.statusCode}');
    print('VOUCHER BODY: ${response.body}');

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      final vouchers = data['data'];

      if (vouchers is List) {
        return vouchers
            .map(
              (item) => VoucherModel.fromJson(
                Map<String, dynamic>.from(item),
              ),
            )
            .toList();
      }

      return [];
    }

    throw Exception(
      data['message'] ?? 'Gagal mengambil data voucher.',
    );
  }
}