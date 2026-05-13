import 'dart:convert';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class BookingController {
  /// ================= CREATE BOOKING =================
  Future<Map<String, dynamic>> createBooking({
    required String apartmentId,
    required DateTime startDate,
    required DateTime endDate,
    required String userId,
  }) async {
    try {
      /// 1. Validate dữ liệu
      final validation = _validateBookingInputs(
        apartmentId: apartmentId,
        startDate: startDate,
        endDate: endDate,
        userId: userId,
      );

      if (!validation['isValid']) {
        return {
          'success': false,
          'message': validation['message'],
          'errorCode': 'VALIDATION_ERROR',
        };
      }

      /// 2. Lấy HOST_SERVER
      final String? serverDomain = dotenv.env['HOST_SERVER'];

      if (serverDomain == null || serverDomain.isEmpty) {
        throw Exception('HOST_SERVER chưa được cấu hình');
      }

      /// 3. Gọi API đặt phòng
      final uri = Uri.parse('$serverDomain/api/book');

      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'apartmentId': apartmentId,
          'startDate':
              startDate.millisecondsSinceEpoch ~/ 1000,
          'endDate':
              endDate.millisecondsSinceEpoch ~/ 1000,
          'userId': userId,
        }),
      );

      final jsonResponse =
          jsonDecode(response.body);

      if (response.statusCode == 200 &&
          jsonResponse['status'] ==
              'success') {
        return {
          'success': true,
          'message':
              jsonResponse['message'] ??
              'Đặt phòng thành công',
          'data': jsonResponse['data'],
        };
      }

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
  }) {
    if (apartmentId.trim().isEmpty) {
      return {
        'isValid': false,
        'message': 'Apartment ID không hợp lệ',
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
    return {
      'success': false,
      'message': error.toString(),
      'errorCode': 'BOOKING_ERROR',
    };
  }
}