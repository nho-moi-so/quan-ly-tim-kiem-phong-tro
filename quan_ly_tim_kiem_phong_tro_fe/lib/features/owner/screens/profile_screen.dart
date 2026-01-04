import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/features/owner/screens/change_password_screen.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/features/owner/screens/edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  Map<String, dynamic>? userData;
  bool isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _loadUserData();
  }
  
  Future<void> _loadUserData() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final doc = await _firestore.collection('users').doc(user.uid).get();
        if (doc.exists) {
          setState(() {
            userData = doc.data();
            isLoading = false;
          });
        }
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      debugPrint('Error loading user data: $e');
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: screenHeight * 0.05),
                    // Header với nút quay lại
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.arrow_back_ios_new_rounded),
                          color: const Color(0xFF4C6FFF),
                        ),
                        const Text(
                          'Thông tin cá nhân',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    
                    // Avatar section
                    Center(
                      child: Column(
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                colors: [Color(0xFF4C6FFF), Color(0xFF8B5CF6)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF4C6FFF).withOpacity(0.3),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                userData?['Fullname']?.toString().substring(0, 1).toUpperCase() ?? 'U',
                                style: const TextStyle(
                                  fontSize: 40,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            userData?['Fullname'] ?? 'Chưa cập nhật',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1F2937),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF4C6FFF).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              _getRoleDisplay(userData?['Role']),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF4C6FFF),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Information Cards
                    _buildInfoCard(
                      icon: Icons.person_outline_rounded,
                      title: 'Họ và tên',
                      value: userData?['Fullname'] ?? 'Chưa cập nhật',
                      color: const Color(0xFF4C6FFF),
                    ),
                    const SizedBox(height: 12),
                    
                    _buildInfoCard(
                      icon: Icons.email_outlined,
                      title: 'Email',
                      value: _auth.currentUser?.email ?? 'Chưa cập nhật',
                      color: const Color(0xFF10B981),
                    ),
                    const SizedBox(height: 12),
                    
                    _buildInfoCard(
                      icon: Icons.phone_outlined,
                      title: 'Số điện thoại',
                      value: userData?['Phone'] ?? 'Chưa cập nhật',
                      color: const Color(0xFFF59E0B),
                    ),
                    const SizedBox(height: 12),
                    
                    _buildInfoCard(
                      icon: Icons.badge_outlined,
                      title: 'Vai trò',
                      value: _getRoleDisplay(userData?['Role']),
                      color: const Color(0xFF8B5CF6),
                    ),
                    
                    if (userData?['Role'].toLowerCase() == 'owner') ...[
                      const SizedBox(height: 12),
                      _buildInfoCard(
                        icon: Icons.credit_card_outlined,
                        title: 'CCCD',
                        value: userData?['CCCD'] ?? 'Chưa cập nhật',
                        color: const Color(0xFFEF4444),
                      ),
                      const SizedBox(height: 12),
                      _buildInfoCard(
                        icon: Icons.verified_outlined,
                        title: 'Trạng thái',
                        value: _getStatusDisplay(userData?['Status']),
                        color: _getStatusColor(userData?['Status']),
                      ),
                    ],
                    
                    const SizedBox(height: 32),
                    
                    // Action buttons
                    _buildActionButton(
                      icon: Icons.edit_outlined,
                      label: 'Chỉnh sửa thông tin',
                      onTap: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditProfileScreen(userData: userData),
                          ),
                        );
                        
                        // Reload data if updated
                        if (result == true) {
                          _loadUserData();
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    
                    _buildActionButton(
                      icon: Icons.lock_outline_rounded,
                      label: 'Đổi mật khẩu',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ChangePasswordScreen(),
                          ),
                        );
                      },
                    ),
                    
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
    );
  }
  
  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE5E7EB),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F2937),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF4C6FFF).withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFF4C6FFF).withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: const Color(0xFF4C6FFF),
              size: 22,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF4C6FFF),
                ),
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: Color(0xFF4C6FFF),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
  
  String _getRoleDisplay(String? role) {
    switch (role?.toLowerCase()) {
      case 'owner':
        return 'Chủ căn hộ';
      case 'guest':
        return 'Khách thuê';
      case 'admin':
        return 'Quản trị viên';
      default:
        return 'Chưa xác định';
    }
  }
  
  String _getStatusDisplay(String? status) {
    switch (status?.toLowerCase()) {
      case 'approved':
        return 'Đã xác minh';
      case 'pending':
        return 'Chờ xác minh';
      case 'rejected':
        return 'Bị từ chối';
      default:
        return 'Chưa xác minh';
    }
  }
  
  Color _getStatusColor(String? status) {
    switch (status) {
      case 'approved':
        return const Color(0xFF10B981);
      case 'pending':
        return const Color(0xFFF59E0B);
      case 'rejected':
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFF6B7280);
    }
  }
}
