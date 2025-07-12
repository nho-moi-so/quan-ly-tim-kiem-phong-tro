import 'dart:ui';

class RoomCardInfo {
  final String roomName;
  final String tenantName;
  final String price;
  final String status;
  final VoidCallback onViewDetail;
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
