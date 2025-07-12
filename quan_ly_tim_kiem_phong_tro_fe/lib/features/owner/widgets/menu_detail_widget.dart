//done
import 'package:flutter/material.dart';

class MenuDetailWidget extends StatelessWidget {
  const MenuDetailWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 208,
      height: 385,
      padding: const EdgeInsets.only(left: 9, top: 34),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMenuItem('Dashboard'),
          _buildMenuItem('Quản Lý Bài Đăng', iconUrl: "https://placehold.co/18x18"),
          _buildMenuItem(
            'Lịch Sử Đặt Phòng',
            iconUrl: "https://placehold.co/18x18",
            isButton: true,
            onPressed: () {},
          ),
          _buildMenuItem('Rooms', iconUrl: "https://placehold.co/18x18"),
          _buildMenuItem('Liên Hệ Khách Hàng', iconUrl: "https://placehold.co/18x18", highlight: true),
          _buildMenuItem('Logout', iconUrl: "https://placehold.co/18x18"),
          const Divider(color: Color(0xFFBFBFBF)),
          _buildMenuItem('Settings', iconUrl: "https://placehold.co/18x18"),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    String title, {
    String? iconUrl,
    bool highlight = false,
    bool isButton = false,
    VoidCallback? onPressed,
  }) {
    final content = Row(
      children: [
        if (iconUrl != null)
          Container(
            width: 18,
            height: 18,
            margin: const EdgeInsets.only(right: 10),
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(iconUrl),
                fit: BoxFit.contain,
              ),
            ),
          ),
        Text(
          title,
          style: TextStyle(
            color: highlight ? Colors.white : Colors.black,
            fontSize: 14,
            fontFamily: 'Noto Sans',
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );

    final container = Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: ShapeDecoration(
        color: highlight ? const Color(0xFF4285F4) : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      child: content,
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: isButton && onPressed != null
          ? TextButton(
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size(0, 0),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              onPressed: onPressed,
              child: container,
            )
          : container,
    );
  }
}
