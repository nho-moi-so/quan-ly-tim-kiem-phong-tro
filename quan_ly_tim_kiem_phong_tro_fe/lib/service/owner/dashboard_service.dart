import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DashboardService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Lấy ID của owner hiện tại
  String? get currentUserId => _auth.currentUser?.uid;

  /// Lấy thống kê tổng quan về phòng
  Future<RoomStatistics> getRoomStatistics() async {
    try {
      final userId = currentUserId;
      if (userId == null) {
        throw Exception('User not logged in');
      }

      // Lấy tất cả phòng của owner
      final apartmentsSnapshot = await _firestore
          .collection('Apartments')
          .where('UserID', isEqualTo: userId)
          .get();

      int totalRooms = apartmentsSnapshot.docs.length;
      int rentedCount = 0;
      int availableCount = 0;
      int maintenanceCount = 0;

      for (var doc in apartmentsSnapshot.docs) {
        String status = doc.data()['Status'] ?? '';
        
        if (status.toLowerCase() == 'rented' || status.toLowerCase() == 'đang thuê') {
          rentedCount++;
        } else if (status.toLowerCase() == 'available' || status.toLowerCase() == 'còn trống') {
          availableCount++;
        } else if (status.toLowerCase() == 'maintenance' || status.toLowerCase() == 'bảo trì') {
          maintenanceCount++;
        }
      }

      return RoomStatistics(
        totalRooms: totalRooms,
        rentedCount: rentedCount,
        availableCount: availableCount,
        maintenanceCount: maintenanceCount,
      );
    } catch (e) {
      print('Error getting room statistics: $e');
      rethrow;
    }
  }

  /// Lấy doanh thu theo tháng (3 tháng gần nhất)
  Future<Map<String, List<double>>> getMonthlyIncome() async {
    try {
      final userId = currentUserId;
      if (userId == null) {
        throw Exception('User not logged in');
      }

      // Lấy tất cả phòng của owner
      final apartmentsSnapshot = await _firestore
          .collection('Apartments')
          .where('UserID', isEqualTo: userId)
          .get();

      List<String> apartmentIds = apartmentsSnapshot.docs.map((doc) => doc.id).toList();

      if (apartmentIds.isEmpty) {
        return {
          'Tháng 1': List.filled(30, 0.0),
          'Tháng 2': List.filled(30, 0.0),
          'Tháng 3': List.filled(30, 0.0),
        };
      }

      // Lấy invoices của 3 tháng gần nhất
      DateTime now = DateTime.now();
      DateTime threeMonthsAgo = DateTime(now.year, now.month - 2, 1);

      Map<String, List<double>> incomeData = {
        'Tháng ${now.month - 2}': List.filled(30, 0.0),
        'Tháng ${now.month - 1}': List.filled(30, 0.0),
        'Tháng ${now.month}': List.filled(30, 0.0),
      };

      // Chia apartmentIds thành các batch nhỏ (Firestore giới hạn whereIn = 10)
      for (int i = 0; i < apartmentIds.length; i += 10) {
        final batchIds = apartmentIds.sublist(
          i,
          i + 10 > apartmentIds.length ? apartmentIds.length : i + 10,
        );

        final invoicesSnapshot = await _firestore
            .collection('Invoices')
            .where('ApartmentId', whereIn: batchIds)
            .where('Status', isEqualTo: 'Đã thanh toán')
            .where('PaymentDate', isGreaterThanOrEqualTo: Timestamp.fromDate(threeMonthsAgo))
            .get();

        for (var invoice in invoicesSnapshot.docs) {
          final data = invoice.data();
          final paymentDate = (data['PaymentDate'] as Timestamp).toDate();
          final amount = (data['Total'] as num?)?.toDouble() ?? 0.0;

          // Tính tháng tương ứng
          int monthDiff = (paymentDate.year - now.year) * 12 + (paymentDate.month - now.month);
          String monthKey = 'Tháng ${paymentDate.month}';

          if (incomeData.containsKey(monthKey)) {
            int dayIndex = paymentDate.day - 1;
            if (dayIndex >= 0 && dayIndex < 30) {
              incomeData[monthKey]![dayIndex] += amount / 1000000; // Chuyển về triệu đồng
            }
          }
        }
      }

      return incomeData;
    } catch (e) {
      print('Error getting monthly income: $e');
      // Trả về dữ liệu mặc định nếu có lỗi
      return {
        'Tháng 1': List.filled(30, 0.0),
        'Tháng 2': List.filled(30, 0.0),
        'Tháng 3': List.filled(30, 0.0),
      };
    }
  }

  /// Lấy tổng doanh thu trong tháng hiện tại
  Future<double> getCurrentMonthRevenue() async {
    try {
      final userId = currentUserId;
      if (userId == null) {
        throw Exception('User not logged in');
      }

      // Lấy tất cả phòng của owner
      final apartmentsSnapshot = await _firestore
          .collection('Apartments')
          .where('UserID', isEqualTo: userId)
          .get();

      List<String> apartmentIds = apartmentsSnapshot.docs.map((doc) => doc.id).toList();

      if (apartmentIds.isEmpty) {
        return 0.0;
      }

      DateTime now = DateTime.now();
      DateTime startOfMonth = DateTime(now.year, now.month, 1);
      double totalRevenue = 0.0;

      // Chia apartmentIds thành các batch nhỏ
      for (int i = 0; i < apartmentIds.length; i += 10) {
        final batchIds = apartmentIds.sublist(
          i,
          i + 10 > apartmentIds.length ? apartmentIds.length : i + 10,
        );

        final invoicesSnapshot = await _firestore
            .collection('Invoices')
            .where('ApartmentId', whereIn: batchIds)
            .where('Status', isEqualTo: 'Đã thanh toán')
            .where('PaymentDate', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth))
            .get();

        for (var invoice in invoicesSnapshot.docs) {
          final amount = (invoice.data()['Total'] as num?)?.toDouble() ?? 0.0;
          totalRevenue += amount;
        }
      }

      return totalRevenue;
    } catch (e) {
      print('Error getting current month revenue: $e');
      return 0.0;
    }
  }

  /// Lấy số lượng hợp đồng sắp hết hạn (trong 30 ngày tới)
  Future<int> getExpiringContractsCount() async {
    try {
      final userId = currentUserId;
      if (userId == null) {
        throw Exception('User not logged in');
      }

      // Lấy tất cả phòng của owner
      final apartmentsSnapshot = await _firestore
          .collection('Apartments')
          .where('UserID', isEqualTo: userId)
          .get();

      List<String> apartmentIds = apartmentsSnapshot.docs.map((doc) => doc.id).toList();

      if (apartmentIds.isEmpty) {
        return 0;
      }

      DateTime now = DateTime.now();
      DateTime thirtyDaysLater = now.add(const Duration(days: 30));

      int expiringCount = 0;

      // Chia apartmentIds thành các batch nhỏ
      for (int i = 0; i < apartmentIds.length; i += 10) {
        final batchIds = apartmentIds.sublist(
          i,
          i + 10 > apartmentIds.length ? apartmentIds.length : i + 10,
        );

        final contractsSnapshot = await _firestore
            .collection('Contracts')
            .where('ApartmentId', whereIn: batchIds)
            .where('Status', isEqualTo: 'Active')
            .where('EndDate', isLessThanOrEqualTo: Timestamp.fromDate(thirtyDaysLater))
            .where('EndDate', isGreaterThanOrEqualTo: Timestamp.fromDate(now))
            .get();

        expiringCount += contractsSnapshot.docs.length;
      }

      return expiringCount;
    } catch (e) {
      print('Error getting expiring contracts count: $e');
      return 0;
    }
  }

  /// Lấy số lượng booking requests đang chờ
  Future<int> getPendingBookingRequestsCount() async {
    try {
      final userId = currentUserId;
      if (userId == null) {
        throw Exception('User not logged in');
      }

      // Lấy tất cả phòng của owner
      final apartmentsSnapshot = await _firestore
          .collection('Apartments')
          .where('UserID', isEqualTo: userId)
          .get();

      List<String> apartmentIds = apartmentsSnapshot.docs.map((doc) => doc.id).toList();

      if (apartmentIds.isEmpty) {
        return 0;
      }

      int pendingCount = 0;

      // Chia apartmentIds thành các batch nhỏ
      for (int i = 0; i < apartmentIds.length; i += 10) {
        final batchIds = apartmentIds.sublist(
          i,
          i + 10 > apartmentIds.length ? apartmentIds.length : i + 10,
        );

        final bookingRequestsSnapshot = await _firestore
            .collection('BookingRequest')
            .where('ApartmentId', whereIn: batchIds)
            .where('Status', isEqualTo: 'Pending')
            .get();

        pendingCount += bookingRequestsSnapshot.docs.length;
      }

      return pendingCount;
    } catch (e) {
      print('Error getting pending booking requests count: $e');
      return 0;
    }
  }

  /// Lấy danh sách phòng gần đây (5 phòng mới nhất)
  Future<List<RecentRoom>> getRecentRooms() async {
    try {
      final userId = currentUserId;
      if (userId == null) {
        throw Exception('User not logged in');
      }

      // Lấy tất cả apartments của user (không dùng orderBy để tránh cần index)
      final apartmentsSnapshot = await _firestore
          .collection('Apartments')
          .where('UserID', isEqualTo: userId)
          .get();

      List<RecentRoom> recentRooms = [];

      for (var doc in apartmentsSnapshot.docs) {
        final data = doc.data();
        recentRooms.add(RecentRoom(
          apartmentId: doc.id,
          codeApartment: data['CodeApartment'] ?? '',
          address: data['Address'] ?? '',
          status: data['Status'] ?? '',
          dailyRate: (data['DailyRate'] as num?)?.toDouble() ?? 0.0,
          pathImage: List<String>.from(data['PathImage'] ?? []),
          createdDate: data['CreatedDate'] != null 
              ? (data['CreatedDate'] as Timestamp).toDate()
              : DateTime.now(),
        ));
      }

      // Sort theo ngày tạo (mới nhất trước) và lấy 5 phòng đầu
      recentRooms.sort((a, b) => b.createdDate.compareTo(a.createdDate));
      return recentRooms.take(5).toList();
    } catch (e) {
      print('Error getting recent rooms: $e');
      return [];
    }
  }

  /// Lấy thống kê số khách thuê mới trong tháng
  Future<int> getNewTenantsThisMonth() async {
    try {
      final userId = currentUserId;
      if (userId == null) {
        throw Exception('User not logged in');
      }

      // Lấy tất cả phòng của owner
      final apartmentsSnapshot = await _firestore
          .collection('Apartments')
          .where('UserID', isEqualTo: userId)
          .get();

      List<String> apartmentIds = apartmentsSnapshot.docs.map((doc) => doc.id).toList();

      if (apartmentIds.isEmpty) {
        return 0;
      }

      DateTime now = DateTime.now();
      DateTime startOfMonth = DateTime(now.year, now.month, 1);

      int newTenantsCount = 0;

      // Chia apartmentIds thành các batch nhỏ
      for (int i = 0; i < apartmentIds.length; i += 10) {
        final batchIds = apartmentIds.sublist(
          i,
          i + 10 > apartmentIds.length ? apartmentIds.length : i + 10,
        );

        final contractsSnapshot = await _firestore
            .collection('Contracts')
            .where('ApartmentId', whereIn: batchIds)
            .where('StartDate', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth))
            .get();

        newTenantsCount += contractsSnapshot.docs.length;
      }

      return newTenantsCount;
    } catch (e) {
      print('Error getting new tenants count: $e');
      return 0;
    }
  }
}

// ============ Data Models ============

class RoomStatistics {
  final int totalRooms;
  final int rentedCount;
  final int availableCount;
  final int maintenanceCount;

  RoomStatistics({
    required this.totalRooms,
    required this.rentedCount,
    required this.availableCount,
    required this.maintenanceCount,
  });
}

class RecentRoom {
  final String apartmentId;
  final String codeApartment;
  final String address;
  final String status;
  final double dailyRate;
  final List<String> pathImage;
  final DateTime createdDate;

  RecentRoom({
    required this.apartmentId,
    required this.codeApartment,
    required this.address,
    required this.status,
    required this.dailyRate,
    required this.pathImage,
    required this.createdDate,
  });
}

