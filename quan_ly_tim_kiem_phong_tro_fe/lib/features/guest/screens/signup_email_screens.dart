import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
//import 'package:firebase_auth/firebase_auth.dart';
//import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/features/guest/controller/auth_controller.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/features/guest/screens/login_screens.dart';

class SignUpEmailScreen extends StatefulWidget {
  const SignUpEmailScreen({super.key});

  @override
  State<SignUpEmailScreen> createState() => _SignUpEmailScreenState();
}

class _SignUpEmailScreenState extends State<SignUpEmailScreen> {
  final fullnameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmController = TextEditingController();

  // File? cccdFront;
  // File? cccdBack;

  final ImagePicker picker = ImagePicker();
  bool hidePassword = true;
  bool hideConfirm = true;
  bool acceptTerms = false;

  final AuthController _authController = AuthController();

  /// ROLE
  String selectedRole = "guest";

  Future<void> signUp() async {
    final result = await _authController.registerUser(
      username: fullnameController.text.trim(),
      phone: phoneController.text.trim(),
      email: emailController.text.trim(),
      password: passwordController.text,
      confirmPassword: confirmController.text,
      role: selectedRole,
      // cccdFront: cccdFront,
      // cccdBack: cccdBack,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          result["message"] ??
              (result["success"] ? "Đăng ký thành công!" : "Đăng ký thất bại!"),
        ),
        backgroundColor: result["success"] ? Colors.green : Colors.red,
      ),
    );

    if (result["success"]) {
      Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
    }
  }

  // Future<void> pickFront() async {
    // final XFile? image = await picker.pickImage(source: ImageSource.gallery);

  //   if (image != null) {
  //     setState(() {
  //       cccdFront = File(image.path);
  //     });
  //   }
  // }

  // Future<void> pickBack() async {
  //   final XFile? image = await picker.pickImage(source: ImageSource.gallery);

  //   if (image != null) {
  //     setState(() {
  //       cccdBack = File(image.path);
  //     });
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF3F3F3),

      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 60),

                Image.asset("assets/images/logo.png", height: 120),

                const SizedBox(height: 15),

                const Text(
                  "Smart rentals, simple living.",
                  style: TextStyle(color: Colors.grey),
                ),

                const SizedBox(height: 40),

                /// fullname
                TextField(
                  controller: fullnameController,
                  decoration: InputDecoration(
                    hintText: "Your fullname",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                /// EMAIL
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    hintText: "Email Address",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                /// PHONE
                TextField(
                  controller: phoneController,
                  decoration: InputDecoration(
                    hintText: "Số điện thoại",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                /// PASSWORD
                TextField(
                  controller: passwordController,
                  obscureText: hidePassword,
                  decoration: InputDecoration(
                    hintText: "Password",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        hidePassword ? Icons.visibility_off : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          hidePassword = !hidePassword;
                        });
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                /// CONFIRM PASSWORD
                TextField(
                  controller: confirmController,
                  obscureText: hideConfirm,
                  decoration: InputDecoration(
                    hintText: "Confirm password",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        hideConfirm ? Icons.visibility_off : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          hideConfirm = !hideConfirm;
                        });
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                /// ROLE
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Register as",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),

                    RadioListTile(
                      title: const Text("Chủ Nhà"),
                      value: "owner",
                      groupValue: selectedRole,
                      onChanged: (value) {
                        setState(() {
                          selectedRole = value!;
                        });
                      },
                    ),

                    RadioListTile(
                      title: const Text("Khách Hàng"),
                      value: "guest",
                      groupValue: selectedRole,
                      onChanged: (value) {
                        setState(() {
                          selectedRole = value!;
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                /// CCCD UPLOAD
                // Column(
                //   crossAxisAlignment: CrossAxisAlignment.start,
                //   children: [
                //     const Text(
                //       "Upload CCCD (Không Bắt Buộc)",
                //       style: TextStyle(
                //         fontWeight: FontWeight.bold,
                //         fontSize: 15,
                //       ),
                //     ),

                    // const SizedBox(height: 10),

                    /// FRONT
                    // GestureDetector(
                    //   onTap: pickFront,
                    //   child: Container(
                    //     height: 120,
                    //     width: double.infinity,
                    //     decoration: BoxDecoration(
                    //       border: Border.all(color: Colors.grey),
                    //       borderRadius: BorderRadius.circular(10),
                    //     ),
                    //     child: cccdFront == null
                    //         ? const Center(child: Text("Upload CCCD Mặt Trước"))
                    //         : Image.file(cccdFront!, fit: BoxFit.cover),
                    //   ),
                    // ),

                    // const SizedBox(height: 10),

                //     /// BACK
                //     GestureDetector(
                //       onTap: pickBack,
                //       child: Container(
                //         height: 120,
                //         width: double.infinity,
                //         decoration: BoxDecoration(
                //           border: Border.all(color: Colors.grey),
                //           borderRadius: BorderRadius.circular(10),
                //         ),
                //         child: cccdBack == null
                //             ? const Center(child: Text("Upload CCCD Mặt Sau"))
                //             : Image.file(cccdBack!, fit: BoxFit.cover),
                //       ),
                //     ),
                //   ],
                // ),

                /// TERMS
                Row(
                  children: [
                    Checkbox(
                      value: acceptTerms,
                      onChanged: (value) {
                        setState(() {
                          acceptTerms = value!;
                        });
                      },
                    ),
                    const Expanded(
                      child: Text(
                        "I accept the terms and privacy policy",
                        style: TextStyle(fontSize: 13),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                /// SIGN UP BUTTON
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: signUp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff4A7DE0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      "Sign Up",
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Already have an account? "),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const LoginScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        "Log in",
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
