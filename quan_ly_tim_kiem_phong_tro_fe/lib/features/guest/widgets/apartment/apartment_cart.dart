import 'package:flutter/material.dart';

class ApartmentCart extends StatelessWidget {
  const ApartmentCart({super.key});

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double cardWidth = screenWidth * 0.9;
    final double imageHeight = cardWidth * 0.6; // Tạo tỷ lệ ảnh cố định

    return Center(
      child: Container(
        width: cardWidth,
        margin: EdgeInsets.symmetric(vertical: screenWidth * 0.03),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
              child: Stack(
                children: [
                  Image.asset(
                    'assets/images/1696583537720.png',
                    width: cardWidth,
                    height: imageHeight,
                    fit: BoxFit.cover,
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xAA34A853),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.local_offer, color: Colors.white, size: 14),
                              SizedBox(width: 4),
                              Text(
                                'Đã áp dụng',
                                style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                              ),
                              SizedBox(width: 6),
                              Text(
                                '-21%',
                                style: TextStyle(color: Color(0xFFFF0000), fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          SizedBox(height: 4),
                          Text(
                            '5.200.000đ',
                            style: TextStyle(color: Colors.white70, fontSize: 12, decoration: TextDecoration.lineThrough),
                          ),
                          Text(
                            '4.500.000đ',
                            style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: EdgeInsets.all(screenWidth * 0.03),
              child: buildCardInfo(context, screenWidth),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildCardInfo(BuildContext context, double screenWidth) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'MiniHouse Cần Thơ',
                style: TextStyle(fontSize: screenWidth * 0.045, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        SizedBox(height: screenWidth * 0.02),
        Text(
          '45 Nguyễn Văn Cừ, Cần Thơ',
          style: TextStyle(fontSize: screenWidth * 0.03, color: const Color(0xFF4B5563)),
        ),
        SizedBox(height: screenWidth * 0.03),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            InfoItem(icon: Icons.bed, text: '1 Giường'),
            InfoItem(icon: Icons.bathtub, text: '1 Phòng Tắm'),
            InfoItem(icon: Icons.people, text: '2 người'),
          ],
        ),
        SizedBox(height: screenWidth * 0.04),
        Row(
          children: [
            const CircleAvatar(
              radius: 12,
              backgroundImage: AssetImage('assets/images/1696583537720.png'),
            ),
            SizedBox(width: screenWidth * 0.02),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Em bông', style: TextStyle(fontWeight: FontWeight.w500, fontSize: screenWidth * 0.034)),
                Text('Được đăng bởi', style: TextStyle(fontSize: screenWidth * 0.027, color: const Color(0xFF4B5563))),
              ],
            ),
            const Spacer(),
            Container(
              padding: EdgeInsets.all(screenWidth * 0.015),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4)],
              ),
              child: Icon(Icons.favorite_border, size: screenWidth * 0.04),
            ),
          ],
        ),
      ],
    );
  }
}

class InfoItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const InfoItem({super.key, required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Row(
      children: [
        Icon(icon, color: const Color(0xFF4B5563), size: screenWidth * 0.035),
        SizedBox(width: screenWidth * 0.01),
        Text(text, style: TextStyle(fontSize: screenWidth * 0.03, color: const Color(0xFF4B5563))),
      ],
    );
  }
}
