import 'package:quan_ly_tim_kiem_phong_tro_fe/model/transaction.dart';
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

  Future<Map<String, dynamic>> requestWithdraw({
    required TransactionModel transaction,
    required double currentBalance,
  }) async {
    try {
      if (transaction.amount <= 0) {
        return {
          'success': false,
          'message': 'Số tiền rút phải lớn hơn 0',
        };
      }

      if (transaction.amount > currentBalance) {
        return {
          'success': false,
          'message': 'Số tiền rút không được vượt quá số dư hiện tại',
        };
      }

      final User user = await _userService.getUserById(transaction.userId);
      if (user.userID == null) {
        return {
          'success': false,
          'message': 'Không tìm thấy người dùng',
        };
      }

      await _userService.createTransaction(transaction);
      return {
        'success': true,
        'message': 'Đã gửi yêu cầu rút tiền thành công',
      };
    } catch (_) {
      return {
        'success': false,
        'message': 'Có lỗi xảy ra khi gửi yêu cầu rút tiền',
      };
    }
  }

  Future<Map<String, dynamic>> getPendingWithdrawSummary(String uid) async {
    try {
      final pendingTransactions = await _userService.getPendingWithdrawTransactionsByUser(uid);
      final double pendingAmount = pendingTransactions.fold<double>(
        0,
        (sum, transaction) => sum + transaction.amount,
      );

      return {
        'success': true,
        'pendingAmount': pendingAmount,
        'pendingCount': pendingTransactions.length,
      };
    } catch (_) {
      return {
        'success': false,
        'pendingAmount': 0.0,
        'pendingCount': 0,
      };
    }
  }

  Future<Map<String, dynamic>> undoPendingWithdrawRequests(String uid) async {
    try {
      final pendingTransactions = await _userService.getPendingWithdrawTransactionsByUser(uid);
      if (pendingTransactions.isEmpty) {
        return {
          'success': false,
          'message': 'Không có yêu cầu rút tiền đang chờ để hoàn tác',
        };
      }

      await _userService.undoAllPendingWithdrawTransactionsByUser(uid);
      return {
        'success': true,
        'message': 'Đã hoàn tác yêu cầu rút tiền đang chờ',
      };
    } catch (_) {
      return {
        'success': false,
        'message': 'Không thể hoàn tác yêu cầu rút tiền',
      };
    }
  }
}