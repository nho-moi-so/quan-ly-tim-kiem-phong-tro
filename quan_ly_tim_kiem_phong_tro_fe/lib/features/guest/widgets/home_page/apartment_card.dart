import 'package:flutter/material.dart';
class ApartmentCard extends StatelessWidget {
  const ApartmentCard({super.key});

  @override
  Widget build(BuildContext context) {
    final cardWidth = MediaQuery.of(context).size.width * 0.9;

    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
          child:Image.asset('assets/images/1696583537720.png')

        ),
        Container(
          width: cardWidth,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(15)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 5,
                offset: Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'MiniHouse Cần Thơ',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    '4.500.000đ',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF4285F4),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Text(
                '45 Nguyễn Văn Cừ, Cần Thơ',
                style: TextStyle(fontSize: 12, color: Color(0xFF4B5563)),
              ),
              SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InfoItem(icon: Icons.bed, text: '1 Giường'),
                  InfoItem(icon: Icons.bathtub, text: '1 Phòng Tắm'),
                  InfoItem(icon: Icons.people, text: '2 người'),
                ],
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  CircleAvatar(
                    radius: 12,
                    backgroundImage: AssetImage('assets/images/1696583537720.png'),
                  ),

                  SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Em bông',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 13.6,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        'Được đăng bởi',
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFF4B5563),
                        ),
                      ),
                    ],
                  ),
                  Spacer(),
                  Container(
                    padding: EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.favorite_border, size: 16),
                  ),
                ],
              ),
            ],
          ),
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
    return Row(
      children: [
        Icon(icon, color: Color(0xFF4B5563), size: 14),
        SizedBox(width: 4),
        Text(text, style: TextStyle(fontSize: 11, color: Color(0xFF4B5563))),
      ],
    );
  }
}
