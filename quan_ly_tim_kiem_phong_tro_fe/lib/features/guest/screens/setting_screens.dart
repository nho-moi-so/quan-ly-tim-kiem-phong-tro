import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SettingScreens extends StatefulWidget {
  const SettingScreens({super.key});

  @override
  State<SettingScreens> createState() => _SettingScreensState();
}

class _SettingScreensState extends State<SettingScreens> {
  bool isNotificationOn = true;
  double balance = 2500000;

  String formatVND(double amount) {
    final formatter = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');
    return formatter.format(amount);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: CustomScrollView(
        slivers: [

          // ===== HEADER =====
          SliverAppBar(
            expandedHeight: 180,
            pinned: true,
            backgroundColor: Colors.blue,
            leading: const Icon(Icons.settings),
            title: const Text('Cài Đặt'),
            centerTitle: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                alignment: Alignment.bottomLeft,
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: const [
                    CircleAvatar(
                      radius: 24,
                      child: Icon(Icons.person),
                    ),
                    SizedBox(width: 12),
                    Text(
                      'Mỹ Ngọc',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ===== CONTENT =====
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // Wallet
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF2196F3), Color(0xFF64B5F6)],
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Ví Tiền',
                          style: TextStyle(color: Colors.white70),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          formatVND(balance),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  _sectionTitle('Cài Đặt Tài Khoản'),
                  _tile('Chỉnh Sửa Hồ Sơ'),
                  _tile('Thay Đổi Mật Khẩu'),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Push notifications'),
                    value: isNotificationOn,
                    onChanged: (v) => setState(() => isNotificationOn = v),
                  ),

                  const SizedBox(height: 16),

                  _sectionTitle('Khác'),
                  _tile('Bảo Vệ Tài Khoản'),
                  _tile('Điều Khoản Và Điều Kiện'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.grey,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _tile(String title) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () {},
    );
  }
}
