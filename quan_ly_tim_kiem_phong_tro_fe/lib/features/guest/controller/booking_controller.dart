import 'dart:convert';
import 'dart:io';

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

    /// payment
    required String paymentMethod,

    /// tổng tiền
    required double amount,
  }) async {
    try {
      /// ================= VALIDATE =================
      final validation = _validateBookingInputs(
        apartmentId: apartmentId,
        startDate: startDate,
        endDate: endDate,
        userId: userId,
        amount: amount,
        paymentMethod: paymentMethod,
      );

      if (!validation['isValid']) {
        return {
          'success': false,
          'message': validation['message'],
          'errorCode': 'VALIDATION_ERROR',
        };
      }

      /// ================= HOST =================
      final String? serverDomain =
          dotenv.env['HOST_SERVER'];

      if (serverDomain == null ||
          serverDomain.isEmpty) {
        throw Exception(
          'HOST_SERVER chưa được cấu hình',
        );
      }

      /// ================= CREATE BOOKING =================
      final uri = Uri.parse(
        '$serverDomain/api/book',
      );

      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'apartmentId': apartmentId,
          'startDate':
              startDate.millisecondsSinceEpoch ~/
                  1000,
          'endDate':
              endDate.millisecondsSinceEpoch ~/
                  1000,
          'userId': userId,
          'paymentMethod': paymentMethod,
          'amount': amount,
        }),
      );

      final jsonResponse =
          jsonDecode(response.body);

      /// ================= BOOKING SUCCESS =================
      if (response.statusCode == 200 &&
          jsonResponse['status'] ==
              'success') {
        final bookingData =
            jsonResponse['data'];

        final bookingId =
            bookingData['bookingId']
                .toString();

        /// ================= VNPAY =================
        if (paymentMethod == 'vnpay') {
          final success =
              await VNPayService().pay(
            bookingId: bookingId,
            amount: amount.toInt(),
            orderInfo:
                'Thanh toán căn hộ $apartmentId',
          );

          if (!success) {
            return {
              'success': false,
              'message':
                  'Thanh toán VNPay thất bại',
            };
          }
        }

        /// ================= MOMO =================
        if (paymentMethod == 'momo') {
          final success =
              await MoMoService().pay(
            bookingId: bookingId,
            amount: amount.toInt(),
            orderInfo:
                'Thanh toán căn hộ $apartmentId',
          );

          if (!success) {
            return {
              'success': false,
              'message':
                  'Thanh toán MoMo thất bại',
            };
          }
        }

        return {
          'success': true,
          'message':
              jsonResponse['message'] ??
                  'Đặt phòng thành công',
          'data': bookingData,
        };
      }

      /// ================= BOOKING FAILED =================
      return {
        'success': false,
        'message':
            jsonResponse['message'] ??
                'Đặt phòng thất bại',
        'errorCode': 'BOOKING_FAILED',
      };
    } catch (e) {
      return _handleBookingError(e);
    }
  }

  /// ================= VALIDATE =================
  Map<String, dynamic>
      _validateBookingInputs({
    required String apartmentId,
    required DateTime startDate,
    required DateTime endDate,
    required String userId,
    required double amount,
    required String paymentMethod,
  }) {
    if (apartmentId.trim().isEmpty) {
      return {
        'isValid': false,
        'message':
            'Apartment ID không hợp lệ',
      };
    }

    if (userId.trim().isEmpty) {
      return {
        'isValid': false,
        'message': 'User ID không hợp lệ',
      };
    }

    if (endDate.isBefore(startDate)) {
      return {
        'isValid': false,
        'message':
            'Ngày trả phòng phải sau ngày nhận phòng',
      };
    }

    if (startDate.isBefore(DateTime.now())) {
      return {
        'isValid': false,
        'message':
            'Ngày nhận phòng không được trong quá khứ',
      };
    }

    return {
      'isValid': true,
    };
  }

  /// ================= ERROR HANDLER =================
  Map<String, dynamic>
      _handleBookingError(dynamic error) {
    if (error is SocketException) {
      return {
        'success': false,
        'message':
            'Không có kết nối internet',
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