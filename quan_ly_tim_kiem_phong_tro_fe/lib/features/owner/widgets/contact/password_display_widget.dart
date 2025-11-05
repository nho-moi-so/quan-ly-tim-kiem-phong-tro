import 'package:flutter/material.dart';

class PasswordDisplayWidget extends StatefulWidget {
  final String password;
  const PasswordDisplayWidget({super.key, required this.password});

  @override
  State<PasswordDisplayWidget> createState() => _PasswordDisplayWidgetState();
}

class _PasswordDisplayWidgetState extends State<PasswordDisplayWidget> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Mật khẩu nhận phòng",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        Center(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 40),
            decoration: BoxDecoration(
              color: const Color(0xFF90CAF9),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _obscure ? '●' * widget.password.length : widget.password,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _obscure = !_obscure;
                    });
                  },
                  child: Icon(
                    _obscure ? Icons.visibility_off : Icons.visibility,
                    color: Colors.black54,
                    size: 28,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}