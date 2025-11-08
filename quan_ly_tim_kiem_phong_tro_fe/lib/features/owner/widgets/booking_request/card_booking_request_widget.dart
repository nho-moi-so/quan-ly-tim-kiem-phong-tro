import 'package:flutter/material.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/features/owner/widgets/booking_request/card_booking_request_detail_widget.dart';

// Thêm enum để phân biệt hành động
enum BookingAction { viewContract, viewDetails, refund }

class CardBookingRequestWidget extends StatefulWidget {
  final String bookingId;
  final String bookingCode;
  final String customerName;
  final String checkinCheckout;
  final String checkinDate;
  final String checkoutDate;
  final String status;
  final String? totalPrice;
  final Color statusColor;
  final IconData statusIcon;
  final String? cancelReason;
  final bool? isRefunded;
  final void Function(BookingAction action)? onConfirm;

  const CardBookingRequestWidget({
    super.key,
    required this.bookingId,
    required this.bookingCode,
    required this.customerName,
    required this.checkinCheckout,
    required this.checkinDate,
    required this.checkoutDate,
    required this.status,
    this.totalPrice,
    this.statusColor = const Color(0xFF34A853),
    this.statusIcon = Icons.verified,
    this.cancelReason,
    this.isRefunded,
    this.onConfirm,
  });
  
  @override
  State<CardBookingRequestWidget> createState() => _CardBookingRequestWidgetState();
}

class _CardBookingRequestWidgetState extends State<CardBookingRequestWidget> {

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return const Color(0xFF10B981);
      case 'canceled':
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFF6B7280);
    }
  }

  String _displayStatus(String status) {
    final s = status.toLowerCase();
    if (s.contains('approved') || s.contains('duyệt') || s.contains('xác nhận')) return 'Đã duyệt';
    if (s.contains('canceled') || s.contains('hủy') || s.contains('từ chối')) return 'Đã hủy';
    if (s.contains('pending') || s.contains('chờ')) return 'Chờ xử lý';
    if (s.contains('completed') || s.contains('hoàn thành')) return 'Hoàn thành';
    return status;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final statusColor = _getStatusColor(widget.status);
    
    return Container(
      width: screenWidth - 32,
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFAFBFF),
            Color(0xFFFFFFFF),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE0E7FF), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header with gradient
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [statusColor.withOpacity(0.1), statusColor.withOpacity(0.05)],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [statusColor, statusColor.withOpacity(0.8)],
                        ),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: statusColor.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.receipt_long_rounded, size: 20, color: Colors.white),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Mã Đơn',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                        Text(
                          '#${widget.bookingId}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [statusColor, statusColor.withOpacity(0.85)],
                    ),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: statusColor.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    _displayStatus(widget.status),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Body content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Customer info
                _buildInfoRow(
                  icon: Icons.person_rounded,
                  iconColor: const Color(0xFF4C6FFF),
                  label: 'Tên Khách',
                  value: widget.customerName,
                ),
                const SizedBox(height: 12),

                // Room code (mock data)
                _buildInfoRow(
                  icon: Icons.meeting_room_rounded,
                  iconColor: const Color(0xFF8B5CF6),
                  label: 'Mã Phòng',
                  value: widget.bookingCode
                ),
                const SizedBox(height: 12),

                // Check-in
                _buildInfoRow(
                  icon: Icons.login_rounded,
                  iconColor: const Color(0xFF10B981),
                  label: 'Check-in',
                  value: widget.checkinDate
                ),
                const SizedBox(height: 12),

                // Check-out
                _buildInfoRow(
                  icon: Icons.logout_rounded,
                  iconColor: const Color(0xFFEF4444),
                  label: 'Check-out',
                  value: widget.checkoutDate
                ),
                const SizedBox(height: 12),

                // Total price (mock data)
                _buildInfoRow(
                  icon: Icons.attach_money_rounded,
                  iconColor: const Color(0xFFF59E0B),
                  label: 'Tổng Tiền',
                  value: widget.totalPrice ?? 'Không có thông tin',
                  valueStyle: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFF59E0B),
                  ),
                ),

                // Thông tin bổ sung cho trạng thái Canceled
                if (widget.status == 'Canceled') ...[
                  const SizedBox(height: 12),
                  _buildInfoRow(
                    icon: Icons.info_rounded,
                    iconColor: const Color(0xFFEF4444),
                    label: 'Lý Do Hủy',
                    value: widget.cancelReason ?? 'Không có thông tin',
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow(
                    icon: Icons.credit_card_rounded,
                    iconColor: widget.isRefunded == true 
                      ? const Color(0xFF10B981) 
                      : const Color(0xFFF59E0B),
                    label: 'Hoàn Tiền',
                    value: widget.isRefunded == true ? 'Đã hoàn tiền' : 'Chưa hoàn tiền',
                    valueStyle: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: widget.isRefunded == true 
                        ? const Color(0xFF10B981) 
                        : const Color(0xFFF59E0B),
                    ),
                  ),
                ],
              ],
            ),
          ),

          const Divider(height: 1, thickness: 1, color: Color(0xFFE5E7EB)),
          const SizedBox(height: 12),

          // Action buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: _actionButton(
                    label: 'Xem',
                    icon: Icons.visibility_rounded,
                    bgColor: const Color(0xFF4C6FFF),
                    textColor: Colors.white,
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => CardBookingRequestDetailWidget(
                          bookingRequestId: widget.bookingId,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 8),
                ..._buildActionButtons(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    TextStyle? valueStyle,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [iconColor.withOpacity(0.15), iconColor.withOpacity(0.05)],
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: iconColor),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF6B7280),
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            value,
            style: valueStyle ?? const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1F2937),
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  List<Widget> _buildActionButtons() {
    List<Widget> actionButtons = [];
  if (widget.status.toLowerCase() == 'approved') {
      // Trạng thái Approved: Xem và Hợp đồng
      actionButtons.add(
        Expanded(
          child: _actionButton(
            label: 'Hợp Đồng',
            icon: Icons.description_rounded,
            bgColor: const Color(0xFF10B981),
            textColor: Colors.white,
            onTap: () {
              widget.onConfirm?.call(BookingAction.viewContract);
            },
          ),
        ),
      );
    } else if (widget.status.toLowerCase() == 'canceled') {
      // Trạng thái Canceled: nếu chưa hoàn tiền thì hiển thị nút Hoàn tiền
      if (widget.isRefunded != true) {
        actionButtons.add(
          Expanded(
            child: _actionButton(
              label: 'Hoàn tiền',
              icon: Icons.payments_rounded,
              bgColor: const Color(0xFFF59E0B),
              textColor: Colors.white,
              onTap: () {
                widget.onConfirm?.call(BookingAction.refund);
              },
            ),
          ),
        );
      }
    }

    return actionButtons;
  }

  Widget _actionButton({
    required String label,
    required IconData icon,
    required Color bgColor,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [bgColor, bgColor.withOpacity(0.85)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: bgColor.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    Icon(icon, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    Text('Bạn đã nhấn "$label"'),
                  ],
                ),
                backgroundColor: bgColor,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                duration: const Duration(seconds: 1),
              ),
            );
            onTap();
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 18, color: textColor),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: textColor,
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

}
