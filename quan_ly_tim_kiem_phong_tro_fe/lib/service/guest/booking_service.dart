import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/features/guest/controller/booking_controller.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/model/contract.dart';

class BookingService {
  final BookingController _bookingController = BookingController();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// ================= CREATE BOOKING =================
  Future<Map<String, dynamic>> createBooking({
    required String apartmentId,
    required DateTime startDate,
    required DateTime endDate,
    // required double amount,
    // required String paymentMethod,
  }) async {
    try {
      final user = _auth.currentUser;

      if (user == null) {
        return {
          'success': false,
          'message': 'Người dùng chưa đăng nhập',
          'errorCode': 'UNAUTHORIZED',
        };
      }

      /// 1. Gọi API Blockchain
      final apiResult = await _bookingController.createBooking(
        apartmentId: apartmentId,
        startDate: startDate,
        endDate: endDate,
        userId: user.uid,

        // paymentMethod: paymentMethod,

        // amount: amount,
      );

      if (!apiResult['success']) {
        return apiResult;
      }

      final bookingData = apiResult['data'];

      /// 2. Lưu Firebase
      final bookingRef = _firestore.collection('bookings').doc();

      await bookingRef.set({
        'id': bookingRef.id,
        'apartmentId': apartmentId,
        'tenantId': user.uid,
        'blockchainBookingId': bookingData['Id'],
        'escrowAmount': bookingData['EscrowAmount'],
        'fabricStatus': bookingData['Status'],
        'startDate': Timestamp.fromDate(startDate),
        'endDate': Timestamp.fromDate(endDate),
        'status': 'PENDING',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'source': 'BLOCKCHAIN',
      });

      return {
        'success': true,
        'message': 'Đặt phòng thành công',
        'bookingId': bookingRef.id,
        'blockchainData': bookingData,
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
        'errorCode': 'BOOKING_SERVICE_ERROR',
      };
    }
  }

  Future<List<Contract>> getBookingByUser(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('contract')
          .where('UserID', isEqualTo: userId)
          .get();

      return snapshot.docs.map((doc) {
        return Contract.fromMap(doc.id, doc.data());
      }).toList();
    } catch (e) {
      print("GET CONTRACT ERROR: $e");
      return [];
    }
  }
}
