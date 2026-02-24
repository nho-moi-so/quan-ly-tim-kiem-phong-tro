import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http; // Để gọi API upload
import 'package:quan_ly_tim_kiem_phong_tro_fe/service/auth_service.dart';
/// Controller quản lý logic authentication
/// Tách biệt logic nghiệp vụ khỏi UI
class AuthController {
  final AuthService _authService = AuthService();

  /// Đăng ký người dùng mới
  /// 
  /// Trả về Map với:
  /// - success: bool
  /// - message: String (thông báo lỗi hoặc thành công)
  /// - errorCode: String? (mã lỗi nếu có)
  Future<Map<String, dynamic>> registerUser({
    required String username,
    required String phone,
    required String email,
    required String password,
    required String confirmPassword,
    String role = 'guest', // 'guest' hoặc 'owner'
  }) async {
    try {
      // Validate inputs
      final validationResult = _validateRegistrationInputs(
        username: username,
        phone: phone,
        email: email,
        password: password,
        confirmPassword: confirmPassword,
      );

      if (!validationResult['isValid']) {
        return {
          'success': false,
          'message': validationResult['message'],
          'errorCode': 'VALIDATION_ERROR',
        };
      }

      // Create SignUpViewModel
      final signUpViewModel = SignUpViewModel(
        username: username.trim(),
        phone: phone.trim(),
        email: email.trim().toLowerCase(),
        password: password,
        role: role,
      );

      // // Call service to register
      // final result = await _authService.registerUser(signUpViewModel);

      final String? serverDomain = dotenv.env['SERVER_DOMAIN'];
      if (serverDomain == null) {
        throw Exception('SERVER_DOMAIN not defined in .env file');
      }
      var uri = Uri.parse('$serverDomain/api/users');
      Map<String, dynamic> body ={
        'email': email,
        'fullName': username,
        'password': password,
        'phone': phone,
        'role': role.toUpperCase(),
        'status': 'ACTIVE',
      };
      var response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );
      if(response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'message': 'Đăng ký thành công! Vui lòng đăng nhập.',
        };
      } else if (response.statusCode == 400) {
        var jsonResponse = jsonDecode(response.body);
        return {
          'success': false,
          'message': "Đăng ký thất bại: ${jsonResponse['message']}",
          'errorCode': 'REGISTRATION_FAILED',
        };
      } else {
        throw Exception('Failed to register user: ${response.body}');
      }
      
    } catch (e) {
      return _handleRegistrationError(e);
    }
  }

  /// Đăng nhập người dùng
  /// 
  /// Trả về Map với:
  /// - success: bool
  /// - message: String
  /// - userData: Map? (thông tin user nếu đăng nhập thành công)
  /// - role: String? (vai trò của user)
  Future<Map<String, dynamic>> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      // Validate inputs
      if (email.trim().isEmpty || password.isEmpty) {
        return {
          'success': false,
          'message': 'Vui lòng nhập đầy đủ email và mật khẩu',
          'errorCode': 'EMPTY_FIELDS',
        };
      }

      if (!_isValidEmail(email)) {
        return {
          'success': false,
          'message': 'Email không hợp lệ',
          'errorCode': 'INVALID_EMAIL',
        };
      }

      // Call service to login
      final userData = await _authService.loginUser(
        email.trim().toLowerCase(),
        password,
      );

      // Check account status
      if(userData['Status'].toString().toLowerCase() == "locked"){
        return {
          'success': false,
          'message': 'Tài khoản của bạn đã bị khóa. Vui lòng liên hệ quản trị viên.',
          'errorCode': 'ACCOUNT_LOCKED',
        };
      }
      
      return {
        'success': true,
        'message': 'Đăng nhập thành công!',
        'userData': userData,
        'role': userData['Role'] as String?,
      };
    } on EmailNotFoundException catch (e) {
      return {
        'success': false,
        'message': e.message,
        'errorCode': e.errorCode,
      };
    } on WrongPasswordException catch (e) {
      return {
        'success': false,
        'message': e.message,
        'errorCode': e.errorCode,
      };
    } on UserDisabledException catch (e) {
      return {
        'success': false,
        'message': e.message,
        'errorCode': e.errorCode,
      };
    } on UserDataNotFoundException catch (e) {
      return {
        'success': false,
        'message': e.message,
        'errorCode': e.errorCode,
      };
    } on AuthException catch (e) {
      return {
        'success': false,
        'message': e.message,
        'errorCode': e.errorCode,
      };
    } catch (e) {
      return _handleLoginError(e);
    }
  }

  /// Đăng xuất người dùng
  Future<Map<String, dynamic>> logoutUser() async {
    try {
      await _authService.logoutUser();
      return {
        'success': true,
        'message': 'Đăng xuất thành công',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Đăng xuất thất bại: ${e.toString()}',
        'errorCode': 'LOGOUT_FAILED',
      };
    }
  }

  // ============ Private Helper Methods ============

  /// Validate registration inputs
  Map<String, dynamic> _validateRegistrationInputs({
    required String username,
    required String phone,
    required String email,
    required String password,
    required String confirmPassword,
  }) {
    // Check empty fields
    if (username.trim().isEmpty) {
      return {
        'isValid': false,
        'message': 'Vui lòng nhập tên người dùng',
      };
    }

    if (phone.trim().isEmpty) {
      return {
        'isValid': false,
        'message': 'Vui lòng nhập số điện thoại',
      };
    }

    if (email.trim().isEmpty) {
      return {
        'isValid': false,
        'message': 'Vui lòng nhập email',
      };
    }

    if (password.isEmpty) {
      return {
        'isValid': false,
        'message': 'Vui lòng nhập mật khẩu',
      };
    }

    if (confirmPassword.isEmpty) {
      return {
        'isValid': false,
        'message': 'Vui lòng xác nhận mật khẩu',
      };
    }

    // Validate username length
    if (username.trim().length < 3) {
      return {
        'isValid': false,
        'message': 'Tên người dùng phải có ít nhất 3 ký tự',
      };
    }

    // Validate phone format (simple validation for Vietnamese phone numbers)
    if (!_isValidPhone(phone)) {
      return {
        'isValid': false,
        'message': 'Số điện thoại không hợp lệ (10 số, bắt đầu bằng 0)',
      };
    }

    // Validate email format
    if (!_isValidEmail(email)) {
      return {
        'isValid': false,
        'message': 'Email không hợp lệ',
      };
    }

    // Validate password strength
    if (password.length < 6) {
      return {
        'isValid': false,
        'message': 'Mật khẩu phải có ít nhất 6 ký tự',
      };
    }

    // Check password match
    if (password != confirmPassword) {
      return {
        'isValid': false,
        'message': 'Mật khẩu xác nhận không khớp',
      };
    }

    return {
      'isValid': true,
      'message': 'Validation successful',
    };
  }

  /// Validate email format
  bool _isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  /// Validate Vietnamese phone number
  bool _isValidPhone(String phone) {
    final phoneRegex = RegExp(r'^0[0-9]{9}$');
    return phoneRegex.hasMatch(phone.trim());
  }

  /// Handle registration errors
  Map<String, dynamic> _handleRegistrationError(dynamic error) {
    String message = 'Đăng ký thất bại';
    String? errorCode;

    final errorString = error.toString().toLowerCase();

    if (errorString.contains('email-already-in-use')) {
      message = 'Email đã được sử dụng';
      errorCode = 'EMAIL_IN_USE';
    } else if (errorString.contains('invalid-email')) {
      message = 'Email không hợp lệ';
      errorCode = 'INVALID_EMAIL';
    } else if (errorString.contains('weak-password')) {
      message = 'Mật khẩu quá yếu';
      errorCode = 'WEAK_PASSWORD';
    } else if (errorString.contains('network')) {
      message = 'Lỗi kết nối mạng';
      errorCode = 'NETWORK_ERROR';
    } else if (errorString.contains('too-many-requests')) {
      message = 'Quá nhiều yêu cầu. Vui lòng thử lại sau';
      errorCode = 'TOO_MANY_REQUESTS';
    }

    return {
      'success': false,
      'message': message,
      'errorCode': errorCode,
      'error': error.toString(),
    };
  }

  /// Handle login errors
  Map<String, dynamic> _handleLoginError(dynamic error) {
    String message = 'Đăng nhập thất bại';
    String? errorCode;

    final errorString = error.toString().toLowerCase();

    if (errorString.contains('user-not-found')) {
      message = 'Email không tồn tại';
      errorCode = 'USER_NOT_FOUND';
    } else if (errorString.contains('wrong-password') || 
               errorString.contains('invalid-credential')) {
      message = 'Mật khẩu không đúng';
      errorCode = 'WRONG_PASSWORD';
    } else if (errorString.contains('invalid-email')) {
      message = 'Email không hợp lệ';
      errorCode = 'INVALID_EMAIL';
    } else if (errorString.contains('user-disabled')) {
      message = 'Tài khoản đã bị vô hiệu hóa';
      errorCode = 'USER_DISABLED';
    } else if (errorString.contains('network')) {
      message = 'Lỗi kết nối mạng';
      errorCode = 'NETWORK_ERROR';
    } else if (errorString.contains('too-many-requests')) {
      message = 'Quá nhiều yêu cầu. Vui lòng thử lại sau';
      errorCode = 'TOO_MANY_REQUESTS';
    }

    return {
      'success': false,
      'message': message,
      'errorCode': errorCode,
      'error': error.toString(),
    };
  }
}
