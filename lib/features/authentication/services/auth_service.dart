import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String baseUrl = 'https://bakso-angkringan-web-production-p47hnh.laravel.cloud/';

  Future<Map<String, dynamic>> login({
    required String noHp,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'no_hp': noHp,
        'password': password,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      final prefs = await SharedPreferences.getInstance();

      await prefs.setString(
        'token',
        data['token'],
      );

      final customerData = data['data'];

      if (customerData is Map &&
          customerData['id'] != null) {
        await prefs.setInt(
          'customer_id',
          (customerData['id'] as num).toInt(),
        );
      }

      return data;
    }

    throw Exception(
      data['message'] ?? 'Login gagal. Silakan coba lagi.',
    );
  }

  Future<Map<String, dynamic>> register({
    required String nama,
    required String noHp,
    required String password,
    required String passwordConfirmation,
    String? kodeReferral,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'nama': nama,
        'no_hp': noHp,
        'password': password,
        'password_confirmation': passwordConfirmation,
        if (kodeReferral != null &&
            kodeReferral.trim().isNotEmpty)
          'kode_referral': kodeReferral.trim(),
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 201) {
      final prefs =
          await SharedPreferences.getInstance();

      await prefs.setString(
        'token',
        data['token'],
      );

      final customerData = data['data'];

      if (customerData is Map &&
          customerData['id'] != null) {
        await prefs.setInt(
          'customer_id',
          (customerData['id'] as num).toInt(),
        );
      }

      return data;
    }

    if (response.statusCode == 422 &&
        data['errors'] != null) {
      final errors =
          data['errors'] as Map<String, dynamic>;

      final firstError = errors.values.first;

      if (firstError is List &&
          firstError.isNotEmpty) {
        throw Exception(
          firstError.first.toString(),
        );
      }
    }

    throw Exception(
      data['message'] ??
          'Registrasi gagal. Silakan coba lagi.',
    );
  }

  Future<void> logout() async {
    final prefs =
        await SharedPreferences.getInstance();

    final token = prefs.getString('token');

    if (token != null && token.isNotEmpty) {
      final response = await http.post(
        Uri.parse('$baseUrl/logout'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode != 200) {
        throw Exception(
          'Logout gagal. Silakan coba lagi.',
        );
      }
    }

    // Hapus token lokal setelah logout berhasil
    await prefs.remove('token');
  }
}