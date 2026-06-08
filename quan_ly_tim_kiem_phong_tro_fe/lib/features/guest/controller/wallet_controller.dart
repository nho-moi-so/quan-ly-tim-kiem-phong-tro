import 'dart:convert';
import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class WalletController {
  Future<Map<String, dynamic>> deposit({
    required String userId,
    required int amount,
  }) async {
    try {
      final String? serverDomain = dotenv.env['HOST_SERVER'];

      if (serverDomain == null || serverDomain.isEmpty) {
        throw Exception('HOST_SERVER chưa được cấu hình');
      }

      final uri = Uri.parse('$serverDomain/api/transactions/deposit');

      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'amount': amount, 'userId': userId}),
      );
      print("Status code: ${response.statusCode}");
      print("Response body:");
      print(response.body);

      final jsonResponse = jsonDecode(response.body);

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          jsonResponse['status'] == 'success') {
        return {
          'success': true,
          'message': jsonResponse['message'],
          'transactionId': jsonResponse['data']['transactionId'],
        };
      }

      return {
        'success': false,
        'message': jsonResponse['message'] ?? 'Nạp tiền thất bại',
      };
    } catch (e, stackTrace) {
      print("===== LỖI API =====");
      print(e);
      print(stackTrace);
      return {'success': false, 'message': e.toString()};
    }
  }
}
