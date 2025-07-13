import 'package:flutter/material.dart';

class ApartmentBookingPassword extends StatelessWidget {
  final String password;
  const ApartmentBookingPassword({super.key, required this.password});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const Text(
            "Mật khẩu nhận phòng",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.lightBlueAccent.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              password,
              style: TextStyle(
                fontSize: screenWidth * 0.05,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
                letterSpacing: 2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
