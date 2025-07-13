import 'package:flutter/material.dart';

class BottomTabbar extends StatelessWidget {
  const BottomTabbar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: const [
          _BottomNavItem(icon: Icons.home, label: 'Trang chủ', isActive: true),
          _BottomNavItem(icon: Icons.search, label: 'Tìm Kiếm'),
          _BottomNavItem(icon: Icons.message, label: 'Tin Nhắn'),
          _BottomNavItem(icon: Icons.person, label: 'Tài Khoản'),
        ],
      ),
    );
  }
}

class _BottomNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;

  const _BottomNavItem({
    required this.icon,
    required this.label,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isActive ? const Color(0xFF1C1B1F) : const Color(0xFFA09CAB);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 24, color: color),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}
