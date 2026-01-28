import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// ============ Custom Exceptions ============
class AuthException implements Exception {
  final String message;
  final String? errorCode;

  AuthException({
    required this.message,
    this.errorCode,
  });

  @override
  String toString() => message;
}

class EmailNotFoundException extends AuthException {
  EmailNotFoundException()
      : super(
          message: 'Email không tồn tại',
          errorCode: 'USER_NOT_FOUND',
        );
}

class WrongPasswordException extends AuthException {
  WrongPasswordException()
      : super(
          message: 'Mật khẩu không đúng',
          errorCode: 'WRONG_PASSWORD',
        );
}

class UserDisabledException extends AuthException {
  UserDisabledException()
      : super(
          message: 'Tài khoản đã bị vô hiệu hóa',
          errorCode: 'USER_DISABLED',
        );
}

class UserDataNotFoundException extends AuthException {
  UserDataNotFoundException()
      : super(
          message: 'Không tìm thấy thông tin tài khoản',
          errorCode: 'USER_DATA_NOT_FOUND',
        );
}

class SignUpViewModel {
  String username = '';
  String phone = '';
  String email = '';
  String password = '';
  String role = 'guest'; // 'guest' hoặc 'owner'

  SignUpViewModel({
    this.username = '',
    this.phone = '',
    this.email = '',
    this.password = '',
    this.role = 'guest',
  });
  
}

class AuthService {
    //connect to firebase
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  //====================HAM DANG KY==============
  // Ví dụ sử dụng Firebase Auth để đăng ký và Firestore để lưu thông tin bổ sung
  Future<bool> registerUser(SignUpViewModel signUpViewModel) async {
    try {
      // Đăng ký với Firebase Auth
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: signUpViewModel.email,
        password: signUpViewModel.password,
      );

      // Lưu thông tin bổ sung vào Firestore
      await firestore.collection('users').doc(userCredential.user!.uid).set({
        'Fullname': signUpViewModel.username,
        'Phone': signUpViewModel.phone,
        'Email': signUpViewModel.email,
        'Role': signUpViewModel.role, // Lưu role được chọn
        'Balance': 0,
        'Status': 'ACTIVE',

        // Không lưu password dạng plain text!
      });

      return true;
    } catch (e) {
      print('Error registering user: $e');
      return false;
    }
  }


  //=======================HAM DANG NHAP================
  /// Đăng nhập người dùng
  /// 
  /// Throw các exception cụ thể:
  /// - EmailNotFoundException: Email không tồn tại
  /// - WrongPasswordException: Mật khẩu không đúng
  /// - UserDisabledException: Tài khoản đã bị vô hiệu hóa
  /// - AuthException: Lỗi khác
  Future<Map<String, dynamic>> loginUser(String email, String password) async {
    try {
      // Đăng nhập bằng Firebase Auth
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Lấy thông tin user từ Firestore
      DocumentSnapshot userDoc = await firestore.collection('users').doc(userCredential.user!.uid).get();

      if (userDoc.exists) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        // Trả về thông tin user, bao gồm cả role nếu có
        return userData;
      } else {
        // Nếu không tìm thấy user data trong Firestore
        throw UserDataNotFoundException();
      }
    } on FirebaseAuthException catch (e) {
      // Xử lý các exception từ Firebase Auth
      if (e.code == 'user-not-found') {
        throw EmailNotFoundException();
      } else if (e.code == 'wrong-password') {
        throw WrongPasswordException();
      } else if (e.code == 'invalid-credential') {
        // Firebase SDK mới trả về invalid-credential thay vì wrong-password
        throw WrongPasswordException();
      } else if (e.code == 'user-disabled') {
        throw UserDisabledException();
      } else {
        throw AuthException(
          message: 'Lỗi đăng nhập: ${e.message}',
          errorCode: e.code,
        );
      }
    } catch (e) {
      throw AuthException(
        message: 'Lỗi không xác định: ${e.toString()}',
        errorCode: 'UNKNOWN_ERROR',
      );
    }
  }

  //=======================HAM DANG XUAT================
  Future<void> logoutUser() async {
    try {
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      print('Error logging out user: $e');
    }
  }

}
