import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class AuthController {
  static const bool enableImageUpload = false;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

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
        };
      }

      /// 2. Tạo tài khoản Firebase Authentication
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final String uid = credential.user!.uid;

      String? cccdFrontUrl;
      String? cccdBackUrl;

      /// 3. Chỉ upload ảnh khi bật tính năng
      if (enableImageUpload) {
        if (cccdFront != null) {
          cccdFrontUrl = await _uploadImage(
            file: cccdFront,
            path: 'users/$uid/cccd_front.jpg',
          );
        }

        if (cccdBack != null) {
          cccdBackUrl = await _uploadImage(
            file: cccdBack,
            path: 'users/$uid/cccd_back.jpg',
          );
        }
      }

      /// 4. Lưu thông tin Firestore
      await _firestore.collection('users').doc(uid).set({
        'uid': uid,
        'fullName': username.trim(),
        'phone': phone.trim(),
        'email': email.trim(),
        'role': role.toUpperCase(),
        'cccdFront': cccdFrontUrl,
        'cccdBack': cccdBackUrl,
        'isVerified': false,
        'createdAt': FieldValue.serverTimestamp(),
      });

      /// 5. Đăng xuất ngay sau khi đăng ký
      /// để tránh Firebase tự đăng nhập
      await _auth.signOut();

      return {
        'success': true,
        'message': 'Đăng ký thành công',
        'uid': uid,
      };
    } on FirebaseAuthException catch (e) {
      return {
        'success': false,
        'message': _handleFirebaseAuthError(e),
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Đã xảy ra lỗi: $e',
      };
    }
  }

  /// ================= LOGIN =================
  Future<Map<String, dynamic>> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      if (email.trim().isEmpty || password.isEmpty) {
        return {
          'success': false,
          'message': 'Vui lòng nhập đầy đủ thông tin',
        };
      }

      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final uid = credential.user!.uid;

      final userDoc =
          await _firestore.collection('users').doc(uid).get();

      if (!userDoc.exists) {
        return {
          'success': false,
          'message': 'Không tìm thấy thông tin người dùng',
        };
      }

      return {
        'success': true,
        'message': 'Đăng nhập thành công',
        'user': userDoc.data(),
      };
    } on FirebaseAuthException catch (e) {
      return {
        'success': false,
        'message': _handleLoginError(e),
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Đã xảy ra lỗi: $e',
      };
    }
  }

  /// ================= LOGOUT =================
  Future<void> logout() async {
    await _auth.signOut();
  }

  /// ================= UPLOAD IMAGE =================
  Future<String> _uploadImage({
    required File file,
    required String path,
  }) async {
    final ref = _storage.ref().child(path);
    final uploadTask = await ref.putFile(file);
    return await uploadTask.ref.getDownloadURL();
  }

  /// ================= VALIDATE =================
  Map<String, dynamic> _validateRegistrationInputs({
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
        'message': 'Mật khẩu phải có ít nhất 6 ký tự',
      };
    }

    if (password != confirmPassword) {
      return {
        'isValid': false,
        'message': 'Mật khẩu xác nhận không khớp',
      };
    }

    return {'isValid': true};
  }

  bool _isValidEmail(String email) {
    final regex =
        RegExp(r'^[\w\-.]+@([\w-]+\.)+[\w-]{2,4}$');
    return regex.hasMatch(email);
  }

  bool _isValidPhone(String phone) {
    final regex = RegExp(r'^0\d{9}$');
    return regex.hasMatch(phone);
  }

  /// ================= REGISTER ERROR =================
  String _handleFirebaseAuthError(
      FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'Email đã được sử dụng';
      case 'invalid-email':
        return 'Email không hợp lệ';
      case 'weak-password':
        return 'Mật khẩu quá yếu';
      case 'network-request-failed':
        return 'Lỗi kết nối mạng';
      default:
        return e.message ?? 'Đăng ký thất bại';
    }
  }

  /// ================= LOGIN ERROR =================
  String _handleLoginError(
      FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'Email chưa được đăng ký';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Mật khẩu không chính xác';
      case 'invalid-email':
        return 'Email không hợp lệ';
      case 'network-request-failed':
        return 'Lỗi kết nối mạng';
      default:
        return e.message ?? 'Đăng nhập thất bại';
    }
  }
}