import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class MoMoService {
  final String functionUrl =
      'https://us-central1-management-seeking-apartment.cloudfunctions.net/createMomoPayment';

  Future<bool> pay({
    required String bookingId,
    required int amount,
    required String orderInfo,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(functionUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'bookingId': bookingId,
          'amount': amount,
          'orderInfo': orderInfo,
        }),
      );
      

      final data = jsonDecode(response.body);
      print(response.body);

      if (data['success'] == true) {
        final payUrl = data['payUrl'];

        await launchUrl(
          Uri.parse(payUrl),
          mode: LaunchMode.externalApplication,
        );

        return true;
      }

      return false;
    } catch (e) {
      print('MoMo error: $e');
      return false;
    }
  }
}