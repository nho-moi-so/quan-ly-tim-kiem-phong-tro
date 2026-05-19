import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class VNPayService {
  Future<bool> pay({
    required String bookingId,
    required int amount,
    required String orderInfo,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(
          'https://us-central1-management-seeking-apartment.cloudfunctions.net/createVNPayUrl',
        ),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'bookingId': bookingId,
          'amount': amount,
          'orderInfo': orderInfo,
        }),
      );

      final jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 200 &&
          jsonResponse['success'] == true) {
        final paymentUrl =
            jsonResponse['paymentUrl'];

        if (paymentUrl != null) {
          await launchUrl(
            Uri.parse(paymentUrl),
            mode: LaunchMode.externalApplication,
          );

          return true;
        }
      }

      return false;
    } catch (e) {
      throw Exception('Lỗi VNPay: $e');
    }
  }
}