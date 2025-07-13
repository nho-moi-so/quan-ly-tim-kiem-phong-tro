import 'package:flutter/material.dart';


class SearchHomeSection extends StatelessWidget {
  const SearchHomeSection({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Container(
      width: width * 0.9,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.6),
        border: Border.all(color: const Color(0xFFF3F4F6)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInputField(Icons.location_on, 'Nhập địa chỉ & khu vực bạn cần tìm'),
          const SizedBox(height: 12),
          _buildInputField(Icons.home_work, 'Nhà nguyên căn'),
          const SizedBox(height: 12),
          _buildInputField(Icons.attach_money, 'Mức Giá'),
          const SizedBox(height: 12),
          _buildInputField(Icons.group, 'Số người ở'),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildButton('Checkin', width: width * 0.4),
              _buildButton('Checkout', width: width * 0.4),
            ],
          ),
          const SizedBox(height: 16),
          _buildSearchButton(),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildTag('Cho nuôi thú cưng'),
              _buildTag('Gần trường đại học'),
              _buildTag('Có bãi đậu xe'),
              _buildTag('An ninh & bảo mật'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInputField(IconData icon, String label) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF4285F4)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: const Color(0xFF4285F4)),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFFCCCCCC),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButton(String text, {required double width}) {
    return SizedBox(
      width: width,
      height: 36,
      child: OutlinedButton(
        onPressed: () {},
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Color(0xFF4285F4)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildSearchButton() {
    return SizedBox(
      width: double.infinity,
      height: 45,
      child: ElevatedButton.icon(
        onPressed: () {},
        icon: const Icon(Icons.search, size: 20),
        label: const Text('Search'),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4285F4),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
        ),
      ),
    );
  }

  Widget _buildTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0x56688EC4)),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFF4B5563),
          fontSize: 11,
        ),
      ),
    );
  }
}
