import 'dart:convert';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import 'package:quan_ly_tim_kiem_phong_tro_fe/service/guest/vnpay_service.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/service/guest/momo_service.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/features/guest/widgets/booking_request/total.dart';

class BookingController {
  /// ================= CREATE BOOKING =================
  Future<Map<String, dynamic>> createBooking({
    
    required String apartmentId,
    required DateTime startDate,
    required DateTime endDate,
    required String userId,
    //required String paymentMethod,
    //required double amount,
  }) async {
    print("===== CREATE BOOKING API =====");
    try {
      final String? serverDomain = dotenv.env['HOST_SERVER'];

      if (serverDomain == null || serverDomain.isEmpty) {
        throw Exception('HOST_SERVER chưa được cấu hình');
      }

      final uri = Uri.parse('$serverDomain/api/book');
      print("Calling: $uri");

      final dateFormat = DateFormat('yyyy-MM-dd');

      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'apartmentId': apartmentId,
          'startDate': dateFormat.format(startDate),
          'endDate': dateFormat.format(endDate),
          'userId': userId,
        }),
      );

      print("Status: ${response.statusCode}");
      print("Body: ${response.body}");

      final jsonResponse = jsonDecode(response.body);

      if ((response.statusCode != 200 && response.statusCode != 201) ||
          jsonResponse['status'] != 'success') {
        return {
          'success': false,
          'message': jsonResponse['message'] ?? 'Đặt phòng thất bại',
        };
      }

      final bookingData = jsonResponse['data'];

      final bookingId = bookingData['Id'].toString();

      // // VNPay
      // if (paymentMethod == 'vnpay') {
      //   final success = await VNPayService().pay(
      //     bookingId: bookingId,
      //     amount: amount.toInt(),
      //     orderInfo: 'Thanh toán căn hộ $apartmentId',
      //   );

      //   if (!success) {
      //     return {'success': false, 'message': 'Thanh toán VNPay thất bại'};
      //   }
      // }

      // // MoMo
      // if (paymentMethod == 'momo') {
      //   final success = await MoMoService().pay(
      //     bookingId: bookingId,
      //     amount: amount.toInt(),
      //     orderInfo: 'Thanh toán căn hộ $apartmentId',
      //   );

      //   if (!success) {
      //     return {'success': false, 'message': 'Thanh toán MoMo thất bại'};
      //   }
      // }

      return {
        'success': true,
        'message': jsonResponse['message'] ?? 'Đặt phòng thành công',
        'data': bookingData,
      };
    } catch (e) {
      return _handleBookingError(e);
    }
  }

  /// ================= VALIDATE =================
  Map<String, dynamic> _validateBookingInputs({
    required String apartmentId,
    required DateTime startDate,
    required DateTime endDate,
    required String userId,
    //required double amount,
    //required String paymentMethod,
  }) {
    if (apartmentId.trim().isEmpty) {
      return {'isValid': false, 'message': 'Apartment ID không hợp lệ'};
    }

    if (userId.trim().isEmpty) {
      return {'isValid': false, 'message': 'User ID không hợp lệ'};
    }

    if (endDate.isBefore(startDate)) {
      return {
        'isValid': false,
        'message': 'Ngày trả phòng phải sau ngày nhận phòng',
      };
    }

    if (startDate.isBefore(DateTime.now())) {
      return {
        'isValid': false,
        'message': 'Ngày nhận phòng không được trong quá khứ',
      };
    }

    return {'isValid': true};
  }

  /// ================= ERROR HANDLER =================
  Map<String, dynamic> _handleBookingError(dynamic error) {
    if (error is SocketException) {
      return {
        'success': false,
        'message': 'Không có kết nối internet',
        'errorCode': 'NO_INTERNET',
      };
    }

    return {
      'success': false,
      'message': error.toString(),
      'errorCode': 'BOOKING_ERROR',
    };
  }
}
