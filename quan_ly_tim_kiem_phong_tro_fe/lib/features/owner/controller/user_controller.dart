import 'package:quan_ly_tim_kiem_phong_tro_fe/model/user.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/service/owner/user_service.dart';

class UserController {
  final UserService _userService = UserService();

  /// Kiểm tra xem user có quyền đăng bài không
  /// Return: Map với 'canPost' (bool) và 'status' (String)
  Future<Map<String, dynamic>> checkOwnerPermission(String uid) async {
    User? user = await _userService.getUserById(uid);

    bool canPost = user.role?.toUpperCase() == 'OWNER' && user.status?.toUpperCase() == 'APPROVED';

    return {'canPost': canPost, 'status': user.status};
  }

  /// Gửi yêu cầu xác minh quyền chủ nhà
  Future<bool> requestOwnerPermission(String uid) async {
    // TODO: Gọi _userService.updateUserStatus(uid, 'PENDING')
    User user = await _userService.getUserById(uid);
    if (user.userID != null) {
      await _userService.updateUserStatus(uid, 'PENDING');
      return true;
    }
    return false;
    
  }
}