import 'package:cloud_firestore/cloud_firestore.dart'; // <-- Nhớ import Firestore
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/model/booking_request.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/features/guest/widgets/booking_request/booking_detail_dialog.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/model/contract.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/service/guest/contract_service.dart';

class BookingCard extends StatelessWidget {
  final dynamic data;
  final VoidCallback? onDelete;
  final VoidCallback? onView;

  const BookingCard({
    super.key,
    required this.data,
    this.onDelete,
    this.onView,
  });

  bool get _isContract => data is Contract;
  //bool get _isBooking => data is BookingRequest;

  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  String _formatCurrency(int amount) {
    final formatter = NumberFormat('#,###', 'vi_VN');
    return '${formatter.format(amount)} VNĐ';
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return const Color.fromARGB(255, 87, 172, 44);
      case 'Hoạt động':
        return Colors.green;
      case 'approved':
        return Colors.green;
      case 'expired':
        return Colors.red;
      case 'cancelled':
      case 'rejected':
        return Colors.grey;
      case 'completed':
        return Colors.green;
      default:
        return Colors.blue;
    }
  }
  String _getStatusText(String status) {
  switch (status.toLowerCase()) {
    case 'active':
      return 'Hoạt động';
    case 'created':
      return 'Đã tạo';

    case 'completed':
      return 'Hoàn thành';

    default:
      return 'Không xác định';
  }
}

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double fontSize = screenWidth * 0.035;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _buildLeftLabels(fontSize),
                ),
              ),
              Container(
                width: 1,
                height: _isContract ? 140 : 100,
                color: Colors.grey.shade300,
                margin: const EdgeInsets.symmetric(horizontal: 8),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _buildRightValues(fontSize),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: onDelete ?? _defaultDelete,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade50,
                    foregroundColor: Colors.red,
                  ),
                  child: const Text("Xóa"),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: onView ?? () => _defaultView(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  child: Text(_isContract ? "Chi Tiết" : "Xem"),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<Widget> _buildLeftLabels(double fontSize) {
    if (_isContract) {
      return [
        _buildRow(Icons.description, "Mã Hợp Đồng:", fontSize),
        _buildRow(Icons.person, "Người Thuê:", fontSize),
        _buildRow(Icons.calendar_today, "Thời Hạn:", fontSize),
        // _buildRow(Icons.attach_money, "Tổng Tiền:", fontSize),
        _buildRow(Icons.circle, "Trạng Thái:", fontSize),
      ];
    }
    // } else if (_isBooking) {
    //   return [
    //     _buildRow(Icons.home, "Mã Đơn:", fontSize),
    //     _buildRow(Icons.person, "Tên Khách:", fontSize),
    //     _buildRow(Icons.calendar_today, "Checkin-Checkout:", fontSize),
    //     _buildRow(Icons.circle, "Trạng Thái:", fontSize),
    //   ];
    // }
    return [];
  }

  List<Widget> _buildRightValues(double fontSize) {
    if (_isContract) {
      Contract contract = data as Contract;

      final String endDateDisplay = contract.endDate != null
          ? _formatDate(contract.endDate!)
          : "Không giới hạn";

      return [
        _buildValue(
          contract.contractID.length > 7
              ? contract.contractID.substring(0, 7).toUpperCase()
              : contract.contractID,
          fontSize,
        ),

        _buildValue(
          (contract.fullName?.isNotEmpty ?? false)
              ? contract.fullName!
              : 'Lý Thụy Mỹ Ngọc',
          fontSize,
        ),
        _buildValue(
          "${_formatDate(contract.startDate)} - $endDateDisplay",
          fontSize,
        ),
        // _buildValue(_formatCurrency(contract.total), fontSize),
        _buildValue(
          _getStatusText(contract.status),
          fontSize,
          statusColor: _getStatusColor(contract.status),
        ),
      ];
    }
    // } else if (_isBooking) {
    //   BookingRequest booking = data as BookingRequest;
    //   return [
    //     _buildValue(booking.id ?? "", fontSize),
    //     _buildValue(booking.userId ?? "Không rõ", fontSize),
    //     _buildValue(
    //       "${booking.checkinDate} - ${booking.checkoutDate}",
    //       fontSize,
    //     ),
    //     _buildValue(
    //       booking.status ?? "Chờ duyệt",
    //       fontSize,
    //       statusColor: _getStatusColor(booking.status ?? "pending"),
    //     ),
    //   ];
    // }
    return [];
  }

  Widget _buildRow(IconData icon, String label, double fontSize) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: fontSize, color: Colors.black54),
          const SizedBox(width: 6),
          Expanded(
            child: Text(label, style: TextStyle(fontSize: fontSize)),
          ),
        ],
      ),
    );
  }

  Widget _buildValue(String value, double fontSize, {Color? statusColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (statusColor != null)
            Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.only(right: 4, top: 6),
              decoration: BoxDecoration(
                color: statusColor,
                shape: BoxShape.circle,
              ),
            ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w500),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  void _defaultDelete() {}

  void _defaultView(BuildContext context) {
    if (_isContract) {
      _showContractDetailDialog(context);
    }
  }

  Future<void> _showContractDetailDialog(BuildContext context) async {
    Contract contract = data as Contract;

    final String endDateDetail = contract.endDate != null
        ? _formatDate(contract.endDate!)
        : 'Không giới hạn';
    final String? roomPassword = await _fetchRoomPassword(
      contract.ApartmentId ?? "",
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chi Tiết Hợp Đồng'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow(
                'Mã hợp đồng:',
                contract.contractID.length > 7
                    ? contract.contractID.substring(0, 7).toUpperCase()
                    : contract.contractID,
              ),
              _buildDetailRow('Người thuê:', contract.fullName ?? 'Lý Thụy Mỹ Ngọc'),
              _buildDetailRow('Ngày bắt đầu:', _formatDate(contract.startDate)),
              _buildDetailRow('Ngày kết thúc:', endDateDetail),
              // _buildDetailRow('Tổng tiền:', _formatCurrency(contract.total)),
              _buildDetailRow('Trạng thái:', _getStatusText(contract.status)),
              _buildDetailRow('Mật khẩu phòng:', roomPassword ?? 'Không có'),
              _buildDetailRow('Ngày tạo:', _formatDate(contract.createdDate)),
              _buildDetailRow('Cập nhật:', _formatDate(contract.updateDate)),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  Future<String?> _fetchRoomPassword(String apartmentId) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('apartment')
          .doc(apartmentId)
          .get();

      return doc.data()?['Password'] as String?;
    } catch (e) {
      print('Lỗi khi lấy mật khẩu phòng: $e');
      return null;
    }
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
