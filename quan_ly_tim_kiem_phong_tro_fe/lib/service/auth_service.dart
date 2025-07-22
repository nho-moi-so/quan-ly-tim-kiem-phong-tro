import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SignUpViewModel {
  String username = '';
  String phone = '';
  String email = '';
  String password = '';

  SignUpViewModel({
    this.username = '',
    this.phone = '',
    this.email = '',
    this.password = ''
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
        'Username': signUpViewModel.username,
        'Phone': signUpViewModel.phone,
        'Email': signUpViewModel.email,
        'Role': 'guest'
        // Không lưu password dạng plain text!
      });

      return true;
    } catch (e) {
      print('Error registering user: $e');
      return false;
    }
  }


  //=======================HAM DANG NHAP================
  Future<Map<String, dynamic>?> loginUser(String email, String password) async {
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
        return null;
      }
    } catch (e) {
      print('Error logging in user: $e');
      return null;
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
