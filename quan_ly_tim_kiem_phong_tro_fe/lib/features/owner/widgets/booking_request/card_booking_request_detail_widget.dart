//done
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/features/owner/controller/booking_request_controller.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/features/owner/helpers/format_currency.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/features/owner/helpers/status_constants.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/features/owner/viewmodel/booking_request_detail.dart';

class CardBookingRequestDetailWidget extends StatefulWidget {
  final String bookingRequestId;

  const CardBookingRequestDetailWidget({
    super.key,
    required this.bookingRequestId,
  });

  @override
  State<CardBookingRequestDetailWidget> createState() => _CardBookingRequestDetailWidgetState();
}

class _CardBookingRequestDetailWidgetState extends State<CardBookingRequestDetailWidget> {
  bool isEditing = false;
  final BookingRequestController _bookingRequestController = BookingRequestController();
  
  //================================
  BookingRequestDetail? bookingRequestDetail;
  //============================================
  
  TextEditingController? passwordController;

  @override
  void initState() {
    super.initState();
    _loadBookingRequestDetail();
  }

  Future<void> _loadBookingRequestDetail() async {
    bookingRequestDetail = await _bookingRequestController.getBookingRequestById(widget.bookingRequestId);
    print("==1==${bookingRequestDetail?.roomNumber}");
    passwordController = TextEditingController(text: bookingRequestDetail!.password);
    print("==2==${bookingRequestDetail!.password}");
    setState(() {});
  }

  String _formatDateTime(dynamic dateTime) {
    try {
      late DateTime parsedDateTime;
      if (dateTime is String) {
        parsedDateTime = DateTime.parse(dateTime);
      } else if (dateTime is DateTime) {
        parsedDateTime = dateTime;
      } else {
        return dateTime.toString();
      }
      String day = parsedDateTime.day.toString().padLeft(2, '0');
      String month = parsedDateTime.month.toString().padLeft(2, '0');
      String year = parsedDateTime.year.toString();
      String hour = parsedDateTime.hour.toString().padLeft(2, '0');
      String minute = parsedDateTime.minute.toString().padLeft(2, '0');
      return '$hour:$minute $day/$month/$year';
    } catch (e) {
      return dateTime.toString();
    }
  }



  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return const Color(0xFFF59E0B);
      case 'approved':
        return const Color(0xFF10B981);
      case 'cancelled':
        return const Color(0xFFEF4444);
      case 'completed':
        return const Color(0xFF8B5CF6);
      default:
        return const Color(0xFF6B7280);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (bookingRequestDetail == null || passwordController == null) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4C6FFF)),
        ),
      );
    }
    
  final statusColor = _getStatusColor(bookingRequestDetail!.status ?? '');

  final screenWidth = MediaQuery.of(context).size.width;
  final double dialogWidth = math.min(screenWidth * 0.92, 720);

  return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: SingleChildScrollView(
        child: Container(
          width: dialogWidth,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFF8F9FF),
                Color(0xFFFFFFFF),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header với gradient
              Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF4C6FFF), Color(0xFF6B8FFF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Icon(Icons.receipt_long_rounded, color: Colors.white, size: 28),
                  const Text(
                    'Thông tin chi tiết',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.close_rounded, color: Colors.white),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                ],
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Customer Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.white, Color(0xFFF8F9FF)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Color(0xFFE0E7FF), width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0xFF4C6FFF).withOpacity(0.08),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFF4C6FFF), Color(0xFF6B8FFF)],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Color(0xFF4C6FFF).withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Icon(Icons.person_rounded, color: Colors.white, size: 32),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                bookingRequestDetail!.fullName ?? '',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1F2937),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(Icons.meeting_room_rounded, size: 16, color: Color(0xFF6B7280)),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Phòng số ${bookingRequestDetail!.roomNumber ?? ''} | Người thuê',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF6B7280),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Info Section
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Color(0xFFE5E7EB), width: 1.5),
                    ),
                    child: Column(
                      children: [
                        buildInfoRow('Mã đơn phòng', bookingRequestDetail!.bookingCode ?? '', Icons.qr_code_2_rounded),
                        const Divider(height: 24),
                        buildInfoRow('Email', bookingRequestDetail!.email!, Icons.email_rounded),
                        const Divider(height: 24),
                        buildInfoRow('Số điện thoại', bookingRequestDetail!.phoneNumber!, Icons.phone_rounded),
                        const Divider(height: 24),
                        buildInfoRow('Số người ở tối đa', '${bookingRequestDetail!.numberOfPeople} Người', Icons.groups_rounded),
                        const Divider(height: 24),
                        buildInfoRow('Check-in', _formatDateTime(bookingRequestDetail!.checkInDate!), Icons.login_rounded),
                        const Divider(height: 24),
                        buildInfoRow('Check-out', _formatDateTime(bookingRequestDetail!.checkOutDate!), Icons.logout_rounded),
                        const Divider(height: 24),
                        buildInfoRowWithStatus('Trạng thái', getStatusInVietnameseCardBookingRequestDetailWidget(bookingRequestDetail!.status ?? ''), statusColor),
                        const Divider(height: 24),
                        buildInfoRow('Tiền phòng', '${formatCurrency(bookingRequestDetail!.price ?? 0.0)} VND', Icons.attach_money_rounded),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 20),
            // Row(
            //   children: [
            //     Expanded(
            //       flex: 3,
            //       child: Text(
            //         'Mật khẩu cung cấp:',
            //         style: TextStyle(fontWeight: FontWeight.w600),
            //       ),
            //     ),
            //     Expanded(
            //       flex: 4,
            //       child: TextField(
            //         controller: passwordController,
            //         enabled: isEditing,
            //         decoration: InputDecoration(
            //           border: OutlineInputBorder(),
            //           isDense: true,
            //           contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            //         ),
            //       ),
            //     ),
            //     IconButton(
            //       icon: Icon(isEditing ? Icons.check : Icons.edit),
            //       onPressed: () async {
            //         if (isEditing) {
            //           // Cập nhật mật khẩu
            //           bool result = await BookingRequestController().updateBookingRequestPassword(bookingRequestDetail?.bookingCode!, passwordController?.text);
            //           // Lưu mật khẩu
            //           ScaffoldMessenger.of(context).showSnackBar(
            //             SnackBar(content: Text('Đã lưu mật khẩu: ${passwordController?.text}')),
            //           );
            //           if(result){
            //             print("Cập nhật mật khẩu thành công");
            //           } else {
            //             print("Cập nhật mật khẩu thất bại");
            //           }
            //         }
            //         setState(() {
            //           isEditing = !isEditing;
            //         });
            //       },
            //     ),
            //   ],
            // ),
                  // Action Buttons
                  Row(
                    children: [
                      // Expanded(
                      //   child: Container(
                      //     height: 54,
                      //     decoration: BoxDecoration(
                      //       gradient: LinearGradient(
                      //         colors: [Color(0xFF10B981), Color(0xFF059669)],
                      //       ),
                      //       borderRadius: BorderRadius.circular(14),
                      //       boxShadow: [
                      //         BoxShadow(
                      //           color: Color(0xFF10B981).withOpacity(0.3),
                      //           blurRadius: 12,
                      //           offset: const Offset(0, 6),
                      //         ),
                      //       ],
                      //     ),
                      //     child: ElevatedButton(
                      //       onPressed: () {
                      //         ScaffoldMessenger.of(context).showSnackBar(
                      //           SnackBar(
                      //             content: Row(
                      //               children: [
                      //                 Icon(Icons.info_rounded, color: Colors.white),
                      //                 const SizedBox(width: 8),
                      //                 Text('Thông tin người thuê: ${bookingRequestDetail!.fullName}'),
                      //               ],
                      //             ),
                      //             backgroundColor: Color(0xFF10B981),
                      //             behavior: SnackBarBehavior.floating,
                      //             shape: RoundedRectangleBorder(
                      //               borderRadius: BorderRadius.circular(12),
                      //             ),
                      //           ),
                      //         );
                      //       },
                      //       style: ElevatedButton.styleFrom(
                      //         backgroundColor: Colors.transparent,
                      //         shadowColor: Colors.transparent,
                      //         shape: RoundedRectangleBorder(
                      //           borderRadius: BorderRadius.circular(14),
                      //         ),
                      //       ),
                      //       child: Row(
                      //         mainAxisAlignment: MainAxisAlignment.center,
                      //         children: const [
                      //           Icon(Icons.person_search_rounded, size: 20),
                      //           SizedBox(width: 8),
                      //           Text(
                      //             'Xem thông tin',
                      //             style: TextStyle(
                      //               fontSize: 15,
                      //               fontWeight: FontWeight.w600,
                      //             ),
                      //           ),
                      //         ],
                      //       ),
                      //     ),
                      //   ),
                      // ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          height: 54,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: Color(0xFF4C6FFF), width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: Color(0xFF4C6FFF).withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Color(0xFF4C6FFF),
                              side: BorderSide.none,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(Icons.close_rounded, size: 20),
                                SizedBox(width: 8),
                                Text(
                                  'Đóng',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
    );
  }

  Widget buildInfoRow(String title, String value, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF4C6FFF).withOpacity(0.1), Color(0xFF6B8FFF).withOpacity(0.05)],
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 20, color: Color(0xFF4C6FFF)),
        ),
        const SizedBox(width: 12),
        Flexible(
          flex: 3,
          child: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: Color(0xFF6B7280),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          flex: 5,
          child: Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 14,
              color: Color(0xFF1F2937),
            ),
            softWrap: true,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget buildInfoRowWithStatus(String title, String status, Color statusColor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF4C6FFF).withOpacity(0.1), Color(0xFF6B8FFF).withOpacity(0.05)],
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(Icons.info_rounded, size: 20, color: Color(0xFF4C6FFF)),
        ),
        const SizedBox(width: 12),
        Flexible(
          flex: 3,
          child: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: Color(0xFF6B7280),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          flex: 5,
          child: Container(
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
              status,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
              softWrap: true,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ],
    );
  }
}
