import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class AuthService {
  static Future<Map<String, dynamic>> register({
    required String email,
    required String username,
    required String password,
    required String phone,
    required String role,
    // String cccd = 'Chưa cập nhật',
    double balance = 0,
  }) async {
    try {
      final String? serverDomain = dotenv.env['HOST_SERVER'];

      if (serverDomain == null || serverDomain.isEmpty) {
        throw Exception('HOST_SERVER chưa được cấu hình');
      }

      final uri = Uri.parse('$serverDomain/api/users/');
      final headers = {
        'Content-Type': 'application/json',
      };

      final body = {
        "balance": balance,
        // "cccd": cccd,
        "email": email.trim(),
        "fullName": username.trim(),
        "password": password,
        "phone": phone.trim(),
        "role": role.toUpperCase(),
        "status": "ACTIVE",
      };

      final response = await http.post(
        uri,
        headers: headers,
        body: jsonEncode(body),
      );

      final jsonResponse = jsonDecode(response.body);

      if (jsonResponse['status'] == 'success') {
        return {
          'success': true,
          'message': jsonResponse['message'] ?? 'Đăng ký thành công',
          'data': jsonResponse['data'],
        };
      }

      return {
        'success': false,
        'message': jsonResponse['message'] ?? 'Đăng ký thất bại',
        'errorCode': 'REGISTER_FAILED',
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
        'errorCode': 'NETWORK_ERROR',
      };
    }
  }
}