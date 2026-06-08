import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DashboardService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Lấy ID của owner hiện tại
  String? get currentUserId => _auth.currentUser?.uid;

  DateTime? _parseDateTime(dynamic val) {
    if (val == null) return null;
    if (val is Timestamp) return val.toDate();
    if (val is String) return DateTime.tryParse(val);
    return null;
  }

  /// Lấy thống kê tổng quan về phòng
  Future<RoomStatistics> getRoomStatistics() async {
    try {
      final userId = currentUserId;
      if (userId == null) {
        throw Exception('User not logged in');
      }

      // Lấy tất cả phòng của owner
      final apartmentsSnapshot = await _firestore
          .collection('apartment')
          .where('UserID', isEqualTo: userId)
          .get();

      int totalRooms = apartmentsSnapshot.docs.length;
      int rentedCount = 0;
      int availableCount = 0;
      int maintenanceCount = 0;

      List<String> apartmentIds = apartmentsSnapshot.docs.map((doc) => doc.id).toList();
      Set<String> rentedApartmentIds = {};

      if (apartmentIds.isNotEmpty) {
        // Chia apartmentIds thành các batch nhỏ (Firestore giới hạn whereIn = 10)
        for (int i = 0; i < apartmentIds.length; i += 10) {
          final batchIds = apartmentIds.sublist(
            i,
            i + 10 > apartmentIds.length ? apartmentIds.length : i + 10,
          );

          final contractsSnapshot = await _firestore
              .collection('contract')
              .where('ApartmentId', whereIn: batchIds)
              .get();

          for (var contract in contractsSnapshot.docs) {
            final data = contract.data();
            // Filter statuses client-side since using whereIn on ApartmentId
            final status = (data['Status'] ?? '').toString().toLowerCase();
            if (status != 'pending' && status != 'created' && status != 'active') continue;

            final endDate = _parseDateTime(data['EndDate']);
            if (endDate != null && endDate.isAfter(DateTime.now())) {
              rentedApartmentIds.add(data['ApartmentId']);
            }
          }
        }
      }

      for (var doc in apartmentsSnapshot.docs) {
        if (rentedApartmentIds.contains(doc.id)) {
          rentedCount++;
        } else {
          String status = doc.data()['Status'] ?? '';
          if (status.toLowerCase() == 'maintenance' || status.toLowerCase() == 'bảo trì') {
            maintenanceCount++;
          } else {
            availableCount++;
          }
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

  /// Lấy doanh thu theo năm (nhóm theo 12 tháng)
  Future<Map<String, List<double>>> getYearlyIncome() async {
    try {
      final userId = currentUserId;
      if (userId == null) {
        throw Exception('User not logged in');
      }

      // Lấy tất cả phòng của owner
      final apartmentsSnapshot = await _firestore
          .collection('apartment')
          .where('UserID', isEqualTo: userId)
          .get();

      List<String> apartmentIds = apartmentsSnapshot.docs.map((doc) => doc.id).toList();

      print("--1--${apartmentIds}");

      final DateTime now = DateTime.now();
      // 3 năm gần nhất
      final List<int> years = [now.year - 2, now.year - 1, now.year];

      Map<String, List<double>> incomeData = {
        'Năm ${years[0]}': List.filled(12, 0.0),
        'Năm ${years[1]}': List.filled(12, 0.0),
        'Năm ${years[2]}': List.filled(12, 0.0),
      };

      if (apartmentIds.isEmpty) {
        return incomeData;
      }

      final DateTime startDate = DateTime(years[0], 1, 1);

      // Chia apartmentIds thành các batch nhỏ (Firestore giới hạn whereIn = 10)
      for (int i = 0; i < apartmentIds.length; i += 10) {
        final batchIds = apartmentIds.sublist(
          i,
          i + 10 > apartmentIds.length ? apartmentIds.length : i + 10,
        );
        final invoicesSnapshot = await _firestore
            .collection('invoice')
            .where('ApartmentId', whereIn: batchIds)
            .where('Status', isEqualTo: 'PAID')
            .get();


        for (var invoice in invoicesSnapshot.docs) {
          final data = invoice.data();
          final paymentDate = _parseDateTime(data['IssueDate']);
          if (paymentDate == null) continue;
          final amount = (data['TotalAmount'] as num?)?.toDouble() ?? 0.0;
          final String yearKey = 'Năm ${paymentDate.year}';
          if (incomeData.containsKey(yearKey)) {
            final monthIndex = paymentDate.month - 1; // 0 to 11
            if (monthIndex >= 0 && monthIndex < 12) {
              incomeData[yearKey]![monthIndex] += amount / 1000000; // triệu đồng
            }
          }
        }
      }

      return incomeData;
    } catch (e) {
      print('Error getting yearly income: $e');
      final now = DateTime.now();
      return {
        'Năm ${now.year}': List.filled(12, 0.0),
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
          createdDate: _parseDateTime(data['CreatedDate']) ?? DateTime.now(),
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

