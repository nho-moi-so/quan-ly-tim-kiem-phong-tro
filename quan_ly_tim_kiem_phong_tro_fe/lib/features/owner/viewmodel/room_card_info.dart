import 'dart:ui';

import 'package:quan_ly_tim_kiem_phong_tro_fe/features/owner/viewmodel/room_detail.dart';

class RoomCardInfo {
  final String roomName;
  final String tenantName;
  final String price;
  final String status;
  final Future<RoomDetail> Function() onViewDetail;
  final VoidCallback onDelete;
  final VoidCallback onEdit;
  final VoidCallback onContract;

  RoomCardInfo({
    this.roomName = '',
    this.tenantName = '',
    this.price = '',
    this.status = '',
    required this.onViewDetail,
    required this.onDelete,
    required this.onEdit,
    required this.onContract,
  });
}
