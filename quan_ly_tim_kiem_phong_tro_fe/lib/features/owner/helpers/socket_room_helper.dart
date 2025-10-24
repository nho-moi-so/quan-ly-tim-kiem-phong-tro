import 'package:quan_ly_tim_kiem_phong_tro_fe/features/owner/controller/apartment_controller.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/service/owner/socket_service.dart';

/// Helper để join tất cả các room của user vào Socket.IO
class SocketRoomHelper {
  static Future<void> joinUserRooms(SocketService socketService, String userId) async {
    try {
      // Lấy danh sách mã phòng của user
      final apartmentController = ApartmentController();
      final roomCodes = await apartmentController.getRoomCodesByUser(userId);

      if (roomCodes.isEmpty) {
        print('⚠️ User không có phòng nào để join');
        return;
      }

      // Join tất cả các rooms
      socketService.joinRooms(roomCodes);
      print('✅ Đã join ${roomCodes.length} rooms cho user $userId');
    } catch (e) {
      print('❌ Lỗi khi join rooms: $e');
    }
  }

  /// Join một room đơn lẻ (dùng khi user tạo phòng mới)
  static void joinSingleRoom(SocketService socketService, String roomCode) {
    socketService.joinRoom(roomCode);
  }
}
