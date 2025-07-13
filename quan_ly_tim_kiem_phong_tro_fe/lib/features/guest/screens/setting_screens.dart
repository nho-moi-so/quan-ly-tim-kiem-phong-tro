import 'package:flutter/material.dart';

class SettingScreens extends StatelessWidget {
  const SettingScreens({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Phần header màu xanh
          Container(
            height: screenHeight * 0.25,
            width: double.infinity,
            color: Colors.blue,
            padding: EdgeInsets.only(top: screenHeight * 0.06, left: 20, right: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Icon(Icons.settings, color: Colors.white, size: 28),
                Text(
                  'Settings',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
              ],
            ),
          ),

          // Nội dung trắng bo góc
          Positioned(
            top: screenHeight * 0.18,
            left: 0,
            right: 0,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Avatar + tên
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 24,
                        backgroundImage: AssetImage('assets/images/avatar.jpg'), // ảnh đại diện
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Mỹ Ngọc',
                        style: TextStyle(
                          fontSize: screenWidth * 0.045,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Account Settings
                  _sectionTitle("Account Settings"),
                  _buildTile("Edit profile", Icons.arrow_forward_ios),
                  _buildTile("Change password", Icons.arrow_forward_ios),
                  _buildSwitchTile(),

                  const SizedBox(height: 16),

                  // More
                  _sectionTitle("More"),
                  _buildTile("About us", Icons.arrow_forward_ios),
                  _buildTile("Privacy policy", Icons.arrow_forward_ios),
                  _buildTile("Terms and conditions", Icons.arrow_forward_ios),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Text(
          title,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildTile(String title, IconData trailingIcon) {
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      title: Text(title),
      trailing: Icon(trailingIcon, size: 16),
      onTap: () {}, // TODO: thêm logic điều hướng
    );
  }

  Widget _buildSwitchTile() {
    return StatefulBuilder(
      builder: (context, setState) {
        bool isOn = true;
        return SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text("Push notifications"),
          value: isOn,
          onChanged: (val) => setState(() => isOn = val),
        );
      },
    );
  }
}
