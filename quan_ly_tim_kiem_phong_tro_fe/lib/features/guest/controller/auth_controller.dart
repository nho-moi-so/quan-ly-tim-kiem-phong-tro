import 'dart:convert';
import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class AuthController {
  /// ================= REGISTER =================
  Future<Map<String, dynamic>> registerUser({
    required String username,
    required String phone,
    required String email,
    required String password,
    required String confirmPassword,
    String role = 'guest',
    File? cccdFront,
    File? cccdBack,
  }) async {
    try {
      /// 1. Validate dữ liệu
      final validation = _validateRegistrationInputs(
        username: username,
        phone: phone,
        email: email,
        password: password,
        confirmPassword: confirmPassword,
      );

      if (!validation['isValid']) {
        return {
          'success': false,
          'message': validation['message'],
          'errorCode': 'VALIDATION_ERROR',
        };
      }

      final String? serverDomain = dotenv.env['HOST_SERVER'];

      if (serverDomain == null || serverDomain.isEmpty) {
        throw Exception('HOST_SERVER chưa được cấu hình');
      }

      /// 2. Upload ảnh CCCD
      String? cccdFrontUrl;
      String? cccdBackUrl;

      if (cccdFront != null) {
        cccdFrontUrl = await _uploadImage(
          serverDomain: serverDomain,
          imageFile: cccdFront,
        );
      }

      if (cccdBack != null) {
        cccdBackUrl = await _uploadImage(
          serverDomain: serverDomain,
          imageFile: cccdBack,
        );
      }

      /// 3. Gọi API đăng ký
      final uri = Uri.parse('$serverDomain/api/users');

      final body = {
        "balance": 0,
        "cccd": "Chưa cập nhật",
        "email": email.trim(),
        "fullName": username.trim(),
        "password": password,
        "phone": phone.trim(),
        "role": role.toUpperCase(),
        "status": "ACTIVE",
        "cccdFront": cccdFrontUrl,
        "cccdBack": cccdBackUrl,
      };

      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      final jsonResponse = jsonDecode(response.body);

      if (jsonResponse['status'] == 'success') {
        return {
          'success': true,
          'message':
              jsonResponse['message'] ?? 'Đăng ký thành công',
          'data': jsonResponse['data'],
        };
      }

      return {
        'success': false,
        'message':
            jsonResponse['message'] ?? 'Đăng ký thất bại',
        'errorCode': 'REGISTER_FAILED',
      };
    } catch (e) {
      return _handleRegistrationError(e);
    }
  }
  Future<Map<String, dynamic>> loginUser({
  required String email,
  required String password,
}) async {
  try {
    final String? serverDomain = dotenv.env['HOST_SERVER'];

    if (serverDomain == null || serverDomain.isEmpty) {
      throw Exception('HOST_SERVER chưa được cấu hình');
    }

    final uri = Uri.parse('$serverDomain/api/auth/login');

    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'email': email.trim(),
        'password': password,
      }),
    );

    final jsonResponse = jsonDecode(response.body);

    if (response.statusCode == 200 &&
        jsonResponse['status'] == 'success') {
      return {
        'success': true,
        'message':
            jsonResponse['message'] ?? 'Đăng nhập thành công',
        'data': jsonResponse['data'],
      };
    }

    return {
      'success': false,
      'message':
          jsonResponse['message'] ?? 'Đăng nhập thất bại',
      'errorCode': 'LOGIN_FAILED',
    };
  } catch (e) {
    return {
      'success': false,
      'message': e.toString(),
      'errorCode': 'LOGIN_ERROR',
    };
  }
}

  /// ================= UPLOAD IMAGE =================
  Future<String> _uploadImage({
    required String serverDomain,
    required File imageFile,
  }) async {
    final uri = Uri.parse(
      '$serverDomain/api/util/upload',
    );

    final request = http.MultipartRequest(
      'POST',
      uri,
    );

    request.files.add(
      await http.MultipartFile.fromPath(
        'file',
        imageFile.path,
      ),
    );

    final streamedResponse = await request.send();
    final response =
        await http.Response.fromStream(
      streamedResponse,
    );

    if (response.statusCode == 200 ||
        response.statusCode == 201) {
      final jsonResponse =
          jsonDecode(response.body);

      if (jsonResponse['status'] == 'success') {
        return jsonResponse['data']['url'];
      }
    }

    throw Exception(
      'Upload ảnh thất bại: ${response.body}',
    );
  }

  /// ================= VALIDATE =================
  Map<String, dynamic>
      _validateRegistrationInputs({
    required String username,
    required String phone,
    required String email,
    required String password,
    required String confirmPassword,
  }) {
    if (username.trim().isEmpty) {
      return {
        'isValid': false,
        'message': 'Vui lòng nhập họ tên',
      };
    }

    if (phone.trim().isEmpty) {
      return {
        'isValid': false,
        'message': 'Vui lòng nhập số điện thoại',
      };
    }

    if (!_isValidPhone(phone)) {
      return {
        'isValid': false,
        'message': 'Số điện thoại không hợp lệ',
      };
    }

    if (email.trim().isEmpty) {
      return {
        'isValid': false,
        'message': 'Vui lòng nhập email',
      };
    }

    if (!_isValidEmail(email)) {
      return {
        'isValid': false,
        'message': 'Email không hợp lệ',
      };
    }

    if (password.length < 6) {
      return {
        'isValid': false,
        'message':
            'Mật khẩu phải có ít nhất 6 ký tự',
      };
    }

    if (password != confirmPassword) {
      return {
        'isValid': false,
        'message':
            'Mật khẩu xác nhận không khớp',
      };
    }

    return {
      'isValid': true,
    };
  }

  bool _isValidEmail(String email) {
    final regex = RegExp(
      r'^[\w\-.]+@([\w-]+\.)+[\w-]{2,4}$',
    );
    return regex.hasMatch(email);
  }

  bool _isValidPhone(String phone) {
    final regex = RegExp(r'^0\d{9}$');
    return regex.hasMatch(phone);
  }

  /// ================= ERROR HANDLER =================
  Map<String, dynamic>
      _handleRegistrationError(
    dynamic error,
  ) {
    return {
      'success': false,
      'message': error.toString(),
      'errorCode': 'REGISTER_ERROR',
    };
  }
}