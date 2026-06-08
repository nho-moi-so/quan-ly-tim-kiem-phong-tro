import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/model/contract.dart';

class ContractService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String collectionName = 'contract';

  // Lấy tất cả contracts (ít dùng, chủ yếu để test)
  Stream<List<Contract>> getAllContracts() {
    return _firestore
        .collection(collectionName)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => Contract.fromMap(
                  doc.id,
                  doc.data() as Map<String, dynamic>,
                ),
              )
              .toList(),
        );
  }

  // Lấy contracts theo UserID (Đây là hàm bạn cần dùng)
  Stream<List<Contract>> getContractsByUserId(String userId) {
    return _firestore
        .collection(collectionName)
        .where('UserID', isEqualTo: userId)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => Contract.fromMap(
                  doc.id,
                  doc.data() as Map<String, dynamic>,
                ),
              )
              .toList(),
        );
  }

  // Lấy contracts theo Status
  Stream<List<Contract>> getContractsByStatus(String status) {
    return _firestore
        .collection(collectionName)
        .where('Status', isEqualTo: status)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => Contract.fromMap(
                  doc.id,
                  doc.data() as Map<String, dynamic>,
                ),
              )
              .toList(),
        );
  }

  // Lấy một contract theo ID
  Future<Contract?> getContractById(String contractId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection(collectionName)
          .doc(contractId)
          .get();
      if (doc.exists) {
        return Contract.fromMap(doc.id, doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      print('Error getting contract: $e');
      return null;
    }
  }

  // Tạo contract mới
  Future<String?> createContract(Contract contract) async {
    try {
      DocumentReference docRef = await _firestore
          .collection(collectionName)
          .add(contract.toMap());
      return docRef.id;
    } catch (e) {
      print('Error creating contract: $e');
      return null;
    }
  }

  // Cập nhật contract
  Future<bool> updateContract(
    String contractId,
    Map<String, dynamic> updates,
  ) async {
    try {
      await _firestore
          .collection(collectionName)
          .doc(contractId)
          .update(updates);
      return true;
    } catch (e) {
      print('Error updating contract: $e');
      return false;
    }
  }

  // Cập nhật status của contract
  Future<bool> updateContractStatus(String contractId, String newStatus) async {
    try {
      await _firestore.collection(collectionName).doc(contractId).update({
        'Status': newStatus,
        'UpdateDate': Timestamp.now(),
      });
      return true;
    } catch (e) {
      print('Error updating contract status: $e');
      return false;
    }
  }

  // Xóa contract
  Future<bool> deleteContract(String contractId) async {
    try {
      await _firestore.collection(collectionName).doc(contractId).delete();
      return true;
    } catch (e) {
      print('Error deleting contract: $e');
      return false;
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

  Future<String> getUserName(String userId) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (!doc.exists) return "Không xác định";

      return doc.data()?['Fullname'] ?? "Không có tên";
    } catch (e) {
      print("Lỗi lấy tên user: $e");
      return "Lỗi";
    }
  }
}
