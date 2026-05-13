import 'package:cloud_functions/cloud_functions.dart';
import 'package:url_launcher/url_launcher.dart';

class VNPayService {
  final FirebaseFunctions _functions =
      FirebaseFunctions.instance;

  Future<bool> pay({
    required int amount,
    required String orderInfo,
  }) async {
    try {
      final result = await _functions
          .httpsCallable('createVNPayUrl')
          .call({
        'amount': amount,
        'orderInfo': orderInfo,
      });

      final paymentUrl =
          result.data['paymentUrl'];

      if (paymentUrl != null) {
        await launchUrl(
          Uri.parse(paymentUrl),
          mode: LaunchMode.externalApplication,
        );

        return true;
      }

      return false;
    } catch (e) {
      throw Exception('Lỗi VNPay: $e');
    }
  }
}