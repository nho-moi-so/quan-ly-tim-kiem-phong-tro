import 'package:cloud_firestore/cloud_firestore.dart';

class SignUpViewModel{
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
  Future<bool> registerUser(SignUpViewModel signUpViewModel) async {
    try {
      // await firestore.collection('users').add({
      //   'username': signUpViewModel.username,
      //   'phone': signUpViewModel.phone,
      //   'email': signUpViewModel.email,
      //   'password': signUpViewModel.confirmPassword,
      // });
      return true; // Registration successful
    } catch (e) {
      print('Error registering user: $e');
      return false; // Registration failed
    }
  }


}
