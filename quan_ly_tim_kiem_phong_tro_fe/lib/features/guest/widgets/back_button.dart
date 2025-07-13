import 'package:flutter/material.dart';

class BackButton extends StatelessWidget {
  final VoidCallback? onTap;

  const BackButton({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap ?? () => Navigator.pop(context),
      icon: const Icon(Icons.arrow_back, color: Colors.blue, size: 18),
      label: const Text(
        'Trở Về',
        style: TextStyle(color: Colors.blue),
      ),
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: Colors.blue),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}
