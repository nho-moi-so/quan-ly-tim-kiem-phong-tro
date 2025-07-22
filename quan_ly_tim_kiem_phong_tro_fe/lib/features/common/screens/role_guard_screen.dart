import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RoleGuardScreen extends StatelessWidget {
  final List<String> allowedRoles;
  final Widget child;

  const RoleGuardScreen({super.key, required this.allowedRoles, required this.child});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      // Chưa đăng nhập → chuyển đến login
      Future.microtask(() => Navigator.pushReplacementNamed(context, '/login'));
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(user.uid).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        final userData = snapshot.data!.data() as Map<String, dynamic>;
        final userRole = userData['role'];

        if (allowedRoles.contains(userRole)) {
          return child;
        } else {
          return Scaffold(
            body: Center(
              child: Text(
                '🚫 Bạn không có quyền truy cập trang này.',
                style: TextStyle(fontSize: 18, color: Colors.red),
              ),
            ),
          );
        }
      },
    );
  }
}
