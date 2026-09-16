import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/features/owner/controller/user_controller.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/features/owner/helpers/format_currency.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/features/owner/helpers/status_constants.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/features/owner/screens/change_password_screen.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/features/owner/screens/edit_profile_screen.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/model/transaction.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/service/wallet_service.dart';

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
  Map<String, dynamic> walletInfo = {'hasWallet': false};
  bool isWalletLoading = true;
  
  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadWalletInfo();
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

  Future<void> _loadWalletInfo() async {
    try {
      final info = await WalletService().getKeystoreDisplayInfo();
      if (mounted) {
        setState(() {
          walletInfo = info;
          isWalletLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isWalletLoading = false;
        });
      }
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
                      icon: Icons.account_balance_wallet_outlined,
                      title: 'Số dư hiện tại',
                      value: userData?['Balance'] != null ? formatCurrency(userData!['Balance']).toString() : 'Chưa cập nhật',
                      color: const Color(0xFFFB923C),
                      onTap: () => _showWithdrawDialog(),
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
                        value: getStatusDisplayProfileScreen(userData?['Status']),
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
                    
                    // Verification request button (chỉ hiển thị cho owner với status ACTIVE)
                    if (userData?['Role']?.toLowerCase() == 'owner' && 
                        userData?['Status']?.toLowerCase() == 'active') ...[
                      const SizedBox(height: 12),
                      _buildVerificationButton(),
                    ],

                    const SizedBox(height: 24),

                    // ─── Section: Ví Blockchain ───
                    _buildSectionTitle('Ví Fabric'),
                    const SizedBox(height: 12),
                    _buildWalletSection(),

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
    VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
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
              if (onTap != null)
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Color(0xFF6B7280),
                  size: 16,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showWithdrawDialog() async {
    final TextEditingController amountController = TextEditingController();
    final TextEditingController noteController = TextEditingController();
    final String? uid = _auth.currentUser?.uid;
    final UserController userController = UserController();

    double pendingAmount = 0;
    int pendingCount = 0;
    if (uid != null) {
      final pendingSummary = await userController.getPendingWithdrawSummary(uid);
      pendingAmount = (pendingSummary['pendingAmount'] ?? 0).toDouble();
      pendingCount = (pendingSummary['pendingCount'] ?? 0) as int;
    }

    bool isSubmitting = false;
    bool isUndoing = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFFAFBFF),
                  Color(0xFFFFFFFF),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFE0E7FF),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF4C6FFF), Color(0xFF6B8AFF)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF4C6FFF).withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.account_balance_wallet_rounded,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Yêu cầu rút tiền',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Noto Sans',
                      color: Color(0xFF1F2937),
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Số dư hiện tại: ${formatCurrency(_getCurrentBalance()).toString()}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F9FF),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFFE0E7FF),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Số tiền đang yêu cầu rút: ${formatCurrency(pendingAmount).toString()}',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Số yêu cầu đang chờ: $pendingCount',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: (pendingCount == 0 || isUndoing || uid == null)
                          ? null
                          : () async {
                              setDialogState(() {
                                isUndoing = true;
                              });

                              final result = await userController.undoPendingWithdrawRequests(uid);
                              final bool success = result['success'] == true;

                              if (success) {
                                setDialogState(() {
                                  pendingAmount = 0;
                                  pendingCount = 0;
                                });
                              }

                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Row(
                                    children: [
                                      Icon(
                                        success ? Icons.check_circle_rounded : Icons.error_rounded,
                                        color: Colors.white,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(child: Text((result['message'] ?? '').toString())),
                                    ],
                                  ),
                                  backgroundColor: success
                                      ? const Color(0xFF10B981)
                                      : const Color(0xFFEF4444),
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              );

                              setDialogState(() {
                                isUndoing = false;
                              });
                            },
                      icon: isUndoing
                          ? const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Color(0xFFEF4444),
                              ),
                            )
                          : const Icon(
                              Icons.undo_rounded,
                              size: 16,
                              color: Color(0xFFEF4444),
                            ),
                      label: const Text(
                        'Hoàn tác yêu cầu rút',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFEF4444),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: amountController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Số tiền muốn rút',
                      hintText: 'Nhập số tiền',
                      filled: true,
                      fillColor: Colors.white,
                      labelStyle: const TextStyle(color: Color(0xFF6B7280)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF4C6FFF), width: 1.5),
                      ),
                    ),
                  ),
                  // const SizedBox(height: 12),
                  // TextField(
                  //   controller: noteController,
                  //   maxLines: 2,
                  //   decoration: InputDecoration(
                  //     labelText: 'Thông tin tài khoản ngân hàng',
                  //     hintText: 'STK:0123456789\nTên tài khoản: NGUYEN VAN A',
                  //     filled: true,
                  //     fillColor: Colors.white,
                  //     labelStyle: const TextStyle(color: Color(0xFF6B7280)),
                  //     border: OutlineInputBorder(
                  //       borderRadius: BorderRadius.circular(12),
                  //       borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                  //     ),
                  //     enabledBorder: OutlineInputBorder(
                  //       borderRadius: BorderRadius.circular(12),
                  //       borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                  //     ),
                  //     focusedBorder: OutlineInputBorder(
                  //       borderRadius: BorderRadius.circular(12),
                  //       borderSide: const BorderSide(color: Color(0xFF4C6FFF), width: 1.5),
                  //     ),
                  //   ),
                  // ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 44,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3F4F6),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFFE5E7EB),
                              width: 1,
                            ),
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: isSubmitting ? null : () => Navigator.pop(dialogContext),
                              borderRadius: BorderRadius.circular(12),
                              child: const Center(
                                child: Text(
                                  'Hủy',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'Inter',
                                    color: Color(0xFF6B7280),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          height: 44,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF4C6FFF), Color(0xFF6B8AFF)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF4C6FFF).withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: isSubmitting
                                  ? null
                                  : () async {
                                      final uid = _auth.currentUser?.uid;
                                      if (uid == null) {
                                        if (!context.mounted) return;
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: const Text('Không tìm thấy người dùng đăng nhập'),
                                            backgroundColor: const Color(0xFFEF4444),
                                            behavior: SnackBarBehavior.floating,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                          ),
                                        );
                                        return;
                                      }

                                      final double amount = _parseMoneyInput(amountController.text);
                                      final double balance = _getCurrentBalance() - pendingAmount;

                                      setDialogState(() {
                                        isSubmitting = true;
                                      });

                                      final transaction = TransactionModel(
                                        id: '',
                                        amount: amount,
                                        paymentMethod: 'Chuyển khoản',
                                        gatewayTransactionId: null,
                                        paymentDate: DateTime.now(),
                                        type: 'WITHDRAW',
                                        status: 'PENDING',
                                        userId: uid,
                                        invoiceId: null,
                                      );

                                      final result = await UserController().requestWithdraw(
                                        transaction: transaction,
                                        currentBalance: balance,
                                      );

                                      if (!context.mounted) return;
                                      Navigator.pop(dialogContext);

                                      final bool success = result['success'] == true;
                                      final String message = (result['message'] ?? '').toString();

                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Row(
                                            children: [
                                              Icon(
                                                success ? Icons.check_circle_rounded : Icons.error_rounded,
                                                color: Colors.white,
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(child: Text(message)),
                                            ],
                                          ),
                                          backgroundColor: success
                                              ? const Color(0xFF10B981)
                                              : const Color(0xFFEF4444),
                                          behavior: SnackBarBehavior.floating,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                        ),
                                      );
                                    },
                              borderRadius: BorderRadius.circular(12),
                              child: Center(
                                child: isSubmitting
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Text(
                                        'Gửi yêu cầu',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          fontFamily: 'Inter',
                                          color: Colors.white,
                                          letterSpacing: 0.3,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            ),
          ),
        ),
      ),
    );
  }

  double _getCurrentBalance() {
    final dynamic balanceValue = userData?['Balance'];
    if (balanceValue is num) {
      return balanceValue.toDouble();
    }

    if (balanceValue is String) {
      return _parseMoneyInput(balanceValue);
    }

    return 0;
  }

  double _parseMoneyInput(String input) {
    final String cleaned = input.replaceAll(RegExp(r'[^0-9.]'), '');
    return double.tryParse(cleaned) ?? 0;
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
  
  Widget _buildVerificationButton() {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4C6FFF), Color(0xFF6B8AFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4C6FFF).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showVerificationConfirmDialog(),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.verified_user_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Gửi yêu cầu xác minh',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  void _showVerificationConfirmDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFFAFBFF),
                Color(0xFFFFFFFF),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFE0E7FF),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon Header
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF4C6FFF), Color(0xFF6B8AFF)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF4C6FFF).withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.verified_user_rounded,
                    color: Colors.white,
                    size: 48,
                  ),
                ),
                const SizedBox(height: 20),
                // Title
                const Text(
                  'Yêu cầu xác minh',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Noto Sans',
                    color: Color(0xFF1F2937),
                    letterSpacing: -0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                // Message
                const Text(
                  'Bạn cần được Admin phê duyệt quyền chủ nhà trước khi đăng bài.\n\nGửi yêu cầu ngay?',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    fontFamily: 'Noto Sans',
                    color: Color(0xFF6B7280),
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                // Action Buttons
                Row(
                  children: [
                    // Cancel Button
                    Expanded(
                      child: Container(
                        height: 44,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFFE5E7EB),
                            width: 1,
                          ),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => Navigator.pop(context),
                            borderRadius: BorderRadius.circular(12),
                            child: const Center(
                              child: Text(
                                'Để sau',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Inter',
                                  color: Color(0xFF6B7280),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Confirm Button
                    Expanded(
                      child: Container(
                        height: 44,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF4C6FFF), Color(0xFF6B8AFF)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF4C6FFF).withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () async {
                              final uid = _auth.currentUser!.uid;
                              final success = await UserController().requestOwnerPermission(uid);
                              
                              if (!context.mounted) return;
                              Navigator.pop(context);
                              
                              if (success) {
                                // Reload user data
                                await _loadUserData();
                                
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Row(
                                      children: [
                                        Icon(Icons.check_circle_rounded, color: Colors.white),
                                        SizedBox(width: 8),
                                        Expanded(
                                          child: Text('Đã gửi yêu cầu thành công! Vui lòng chờ Admin duyệt.'),
                                        ),
                                      ],
                                    ),
                                    backgroundColor: const Color(0xFF10B981),
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    duration: const Duration(seconds: 3),
                                  ),
                                );
                              } else {
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Row(
                                      children: [
                                        Icon(Icons.error_rounded, color: Colors.white),
                                        SizedBox(width: 8),
                                        Text('Có lỗi xảy ra. Vui lòng thử lại!'),
                                      ],
                                    ),
                                    backgroundColor: const Color(0xFFEF4444),
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                );
                              }
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: const Center(
                              child: Text(
                                'Gửi Yêu Cầu',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Inter',
                                  color: Colors.white,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
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
  
  
  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'approved':
        return const Color(0xFF10B981);
      case 'pending':
        return const Color(0xFFF59E0B);
      case 'rejected':
        return const Color(0xFFEF4444);
      case 'active':
        return const Color(0xFF4C6FFF);
      default:
        return const Color(0xFF6B7280);
    }
  }

  // ─────────────────────────────────────────────────────
  // WALLET SECTION WIDGETS
  // ─────────────────────────────────────────────────────

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF4C6FFF), Color(0xFF8B5CF6)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1F2937),
            letterSpacing: -0.3,
          ),
        ),
      ],
    );
  }

  Widget _buildWalletSection() {
    if (isWalletLoading) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE5E7EB)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Center(
          child: SizedBox(
            height: 24,
            width: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    final bool hasWallet = walletInfo['hasWallet'] == true;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // ── Wallet status card ──
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: hasWallet
                          ? [const Color(0xFF10B981), const Color(0xFF34D399)]
                          : [const Color(0xFF9CA3AF), const Color(0xFFD1D5DB)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: (hasWallet
                                ? const Color(0xFF10B981)
                                : const Color(0xFF9CA3AF))
                            .withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Icon(
                    hasWallet
                        ? Icons.account_balance_wallet_rounded
                        : Icons.wallet_outlined,
                    color: Colors.white,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        hasWallet ? 'Ví đã được cài đặt' : 'Chưa có ví',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: hasWallet
                              ? const Color(0xFF065F46)
                              : const Color(0xFF6B7280),
                        ),
                      ),
                      const SizedBox(height: 3),
                      if (hasWallet) ...[
                        Text(
                          'MSP: ${walletInfo['mspId'] ?? 'N/A'}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF6B7280),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          'Loại: ${walletInfo['type'] ?? 'N/A'}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF6B7280),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ] else
                        const Text(
                          '',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF9CA3AF),
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                    ],
                  ),
                ),
                // Badge trạng thái
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: hasWallet
                        ? const Color(0xFFD1FAE5)
                        : const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    hasWallet ? '✓ Active' : 'None',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: hasWallet
                          ? const Color(0xFF065F46)
                          : const Color(0xFF6B7280),
                    ),
                  ),
                ),
              ],
            ),
          ),

          if (hasWallet) ...[
            // ── Key status indicators ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _buildKeyBadge(
                    '🔑 Private Key',
                    walletInfo['hasPrivateKey'] == true,
                  ),
                  const SizedBox(width: 8),
                  _buildKeyBadge(
                    '📜 Certificate',
                    walletInfo['hasCertificate'] == true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
          ],

          // ── Divider ──
          Container(height: 1, color: const Color(0xFFF3F4F6)),

          // ── Action buttons ──
          if (hasWallet) ...[
            _buildWalletActionTile(
              icon: Icons.visibility_rounded,
              iconColor: const Color(0xFF4C6FFF),
              label: 'Xem thông tin & Xuất Backup',
              subtitle: 'Xem chi tiết ví và lưu file an toàn',
              onTap: _showSecurityQuizDialog,
            ),
            Container(height: 1, color: const Color(0xFFF3F4F6)),
          ],
          _buildWalletActionTile(
            icon: Icons.download_rounded,
            iconColor: const Color(0xFF10B981),
            label: 'Nhập ví từ file backup',
            subtitle: 'Khôi phục ví từ keystore.json',
            onTap: _importWallet,
          ),
          if (hasWallet) ...[
            Container(height: 1, color: const Color(0xFFF3F4F6)),
            _buildWalletActionTile(
              icon: Icons.delete_outline_rounded,
              iconColor: const Color(0xFFEF4444),
              label: 'Xoá ví khỏi thiết bị',
              subtitle: 'Chỉ xoá local, không xoá tài khoản',
              onTap: _confirmDeleteWallet,
              isDestructive: true,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildKeyBadge(String label, bool isPresent) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: isPresent
              ? const Color(0xFFECFDF5)
              : const Color(0xFFFEF2F2),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isPresent
                ? const Color(0xFF6EE7B7)
                : const Color(0xFFFCA5A5),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isPresent ? Icons.check_circle_rounded : Icons.cancel_rounded,
              size: 14,
              color: isPresent
                  ? const Color(0xFF059669)
                  : const Color(0xFFDC2626),
            ),
            const SizedBox(width: 5),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isPresent
                      ? const Color(0xFF065F46)
                      : const Color(0xFF991B1B),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWalletActionTile({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDestructive
                            ? const Color(0xFFEF4444)
                            : const Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF9CA3AF),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: isDestructive
                    ? const Color(0xFFEF4444).withOpacity(0.6)
                    : const Color(0xFF9CA3AF),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────
  // WALLET ACTIONS
  // ─────────────────────────────────────────────────────

  Future<void> _showSecurityQuizDialog() async {
    int currentStep = 0;
    int? selectedAnswer;
    bool showError = false;
    
    final questions = [
      {
        'question': '1. Ví này mất rồi có thể nhờ quản trị viên cung cấp lại không?',
        'options': [
          'Có, tôi có thể nhờ quản trị viên khôi phục',
          'Không, chỉ có tôi mới có thể khôi phục bằng file backup',
        ],
        'correctIndex': 1,
        'explanation': 'Sai rồi! Ví Fabric hoạt động theo cơ chế bảo mật nghiêm ngặt. Quản trị viên không hề giữ hay biết private key của bạn, nên KHÔNG THỂ khôi phục ví giúp bạn nếu bạn làm mất file backup.',
      },
      {
        'question': '2. Nếu có người nào đó yêu cầu bạn cung cấp file backup hoặc private key, bạn có cung cấp không?',
        'options': [
          'Có, nếu họ là quản trị viên hoặc nhân viên hỗ trợ',
          'Không, tuyệt đối không cung cấp cho bất kỳ ai',
        ],
        'correctIndex': 1,
        'explanation': 'Sai rồi! Không một ai (kể cả quản trị viên hay nhân viên hỗ trợ) có quyền yêu cầu bạn cung cấp file backup hoặc private key. Bất kỳ ai yêu cầu đều là lừa đảo. Nếu bạn cung cấp, họ có thể chiếm quyền điều khiển ví của bạn.',
      }
    ];

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) {
          final currentQ = questions[currentStep];
          final isAnswered = selectedAnswer != null;

          return Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            backgroundColor: Colors.white,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.security_rounded, color: Color(0xFF4C6FFF), size: 28),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Kiểm tra bảo mật',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1F2937),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded, color: Color(0xFF9CA3AF)),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Để bảo vệ an toàn cho bạn, vui lòng trả lời các câu hỏi sau trước khi xem hoặc xuất thông tin ví:',
                      style: TextStyle(fontSize: 14, color: Color(0xFF4B5563)),
                    ),
                    const SizedBox(height: 16),
                    LinearProgressIndicator(
                      value: (currentStep + 1) / questions.length,
                      backgroundColor: const Color(0xFFE5E7EB),
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF4C6FFF)),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    const SizedBox(height: 24),
                    
                    Text(
                      currentQ['question'] as String,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF1F2937), height: 1.4),
                    ),
                    const SizedBox(height: 12),
                    
                    ...(currentQ['options'] as List<String>).asMap().entries.map((entry) {
                      return _buildRadioOption(
                        title: entry.value,
                        value: entry.key,
                        groupValue: selectedAnswer,
                        onChanged: (val) => setState(() { selectedAnswer = val; showError = false; }),
                      );
                    }).toList(),

                    if (showError) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF2F2),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFFCA5A5)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.error_outline_rounded, color: Color(0xFFEF4444), size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                currentQ['explanation'] as String,
                                style: const TextStyle(color: Color(0xFFB91C1C), fontSize: 13, height: 1.4),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: !isAnswered ? null : () {
                          if (selectedAnswer == currentQ['correctIndex']) {
                            if (currentStep < questions.length - 1) {
                              setState(() {
                                currentStep++;
                                selectedAnswer = null;
                                showError = false;
                              });
                            } else {
                              WalletService().loadKeystore().then((keystore) {
                                if (keystore != null && mounted) {
                                  Navigator.pop(ctx);
                                  _showWalletInfoAndExport(keystore);
                                }
                              });
                            }
                          } else {
                            setState(() { showError = true; });
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4C6FFF),
                          disabledBackgroundColor: const Color(0xFFE5E7EB),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(
                          currentStep < questions.length - 1 ? 'Tiếp theo' : 'Hoàn thành',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRadioOption({
    required String title,
    required int value,
    required int? groupValue,
    required ValueChanged<int?> onChanged,
  }) {
    final isSelected = value == groupValue;
    return InkWell(
      onTap: () => onChanged(value),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFEFF6FF) : Colors.white,
          border: Border.all(
            color: isSelected ? const Color(0xFF4C6FFF) : const Color(0xFFE5E7EB),
            width: isSelected ? 1.5 : 1,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked_rounded : Icons.radio_button_unchecked_rounded,
              color: isSelected ? const Color(0xFF4C6FFF) : const Color(0xFF9CA3AF),
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected ? const Color(0xFF1E3A8A) : const Color(0xFF4B5563),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showWalletInfoAndExport(Map<String, dynamic> keystore) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF0FDF4),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 36),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Thông tin ví Fabric',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Color(0xFF1F2937)),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: Column(
                    children: [
                      _buildInfoRow('Loại ví', keystore['type']?.toString() ?? 'Fabric Keystore'),
                      const SizedBox(height: 12),
                      _buildInfoRow('MSP ID', keystore['mspId']?.toString() ?? 'N/A'),
                      const SizedBox(height: 12),
                      _buildInfoRow('Trạng thái', 'Đang hoạt động'),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _buildKeyDisplay('Public Key (Certificate)', keystore['certificate']?.toString(), isPrivate: false),
                const SizedBox(height: 16),
                _buildKeyDisplay('Private Key', keystore['privateKey']?.toString(), isPrivate: true),
                const SizedBox(height: 24),
                const Text(
                  'Vui lòng lưu trữ file backup (keystore.json) ở nơi an toàn. Không chia sẻ file này cho bất kỳ ai!',
                  style: TextStyle(fontSize: 13, color: Color(0xFF6B7280), height: 1.5),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(ctx);
                      _exportWallet();
                    },
                    icon: const Icon(Icons.download_rounded, color: Colors.white),
                    label: const Text(
                      'Xuất file Backup',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildKeyDisplay(String label, String? keyContent, {bool isPrivate = false}) {
    if (keyContent == null || keyContent.isEmpty) return const SizedBox();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1F2937))),
            IconButton(
              icon: const Icon(Icons.copy_rounded, size: 18, color: Color(0xFF4C6FFF)),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: keyContent));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        const Icon(Icons.check_circle_rounded, color: Colors.white),
                        const SizedBox(width: 8),
                        Text('Đã sao chép $label'),
                      ],
                    ),
                    backgroundColor: const Color(0xFF10B981),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              splashRadius: 20,
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isPrivate ? const Color(0xFFFEF2F2) : const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: isPrivate ? const Color(0xFFFCA5A5) : const Color(0xFFE5E7EB)),
          ),
          child: SelectableText(
            keyContent,
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 11,
              color: isPrivate ? const Color(0xFF991B1B) : const Color(0xFF4B5563),
            ),
            maxLines: 4,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280))),
        Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1F2937))),
      ],
    );
  }

  Future<void> _exportWallet() async {
    _showLoadingSnackBar('Đang xuất file ví...');
    final result = await WalletService().exportKeystoreFile();
    if (!mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    _showResultSnackBar(result['success'] == true, result['message'] ?? '');
  }

  Future<void> _importWallet() async {
    final result = await WalletService().importKeystoreFile();
    if (!mounted) return;
    _showResultSnackBar(result['success'] == true, result['message'] ?? '');
    if (result['success'] == true) {
      _loadWalletInfo(); // Reload wallet info
    }
  }

  void _confirmDeleteWallet() {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE5E7EB)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.delete_forever_rounded,
                  color: Color(0xFFEF4444),
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Xoá ví khỏi thiết bị?',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1F2937),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF7ED),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFFED7AA)),
                ),
                child: const Text(
                  '⚠️ Hành động này sẽ xoá ví khỏi thiết bị này. Nếu bạn chưa backup file keystore.json, ví sẽ không thể khôi phục!',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF92400E),
                    fontWeight: FontWeight.w500,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        side: const BorderSide(color: Color(0xFFE5E7EB)),
                      ),
                      child: const Text(
                        'Huỷ',
                        style: TextStyle(
                          color: Color(0xFF6B7280),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(ctx);
                        final ok = await WalletService().deleteKeystore();
                        if (!mounted) return;
                        _showResultSnackBar(
                          ok,
                          ok ? 'Đã xoá ví khỏi thiết bị.' : 'Xoá ví thất bại.',
                        );
                        if (ok) _loadWalletInfo();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEF4444),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Xoá ví',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLoadingSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 12),
            Text(message),
          ],
        ),
        backgroundColor: const Color(0xFF4C6FFF),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 30),
      ),
    );
  }

  void _showResultSnackBar(bool success, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              success ? Icons.check_circle_rounded : Icons.error_rounded,
              color: Colors.white,
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor:
            success ? const Color(0xFF10B981) : const Color(0xFFEF4444),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}

