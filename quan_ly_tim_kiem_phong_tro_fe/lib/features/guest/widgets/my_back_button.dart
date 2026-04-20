import 'package:flutter/material.dart';

class MyBackButton extends StatelessWidget {
  const MyBackButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 10,
      left: 10,
      child: IconButton(
        icon: const Icon(Icons.arrow_back, size: 28, color: Colors.black),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }
}
