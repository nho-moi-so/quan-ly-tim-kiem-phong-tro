import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/model/contract.dart';
class ContractService {
  //connect to firebase
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  //=================getAllContracts
  Future<List<Contract>> getAllContracts() async {
    List<Contract> contracts = [];
    QuerySnapshot snapshot = await firestore.collection("contract").get();
    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      contracts.add(Contract.fromMap(doc.id, data));
    }
    return contracts;
  }

  //=======================getContractById
  Future<Contract> getContractById(String id) async {
    DocumentSnapshot snapshot = await firestore.collection("contract").doc(id).get();
    if (!snapshot.exists) {
      throw Exception('Contract with ID $id not found');
    }
    final data = snapshot.data() as Map<String, dynamic>;
    return Contract.fromMap(snapshot.id, data);
  }

  //===================createContract
  Future<Contract> createContract(Contract contract) async {
    DocumentReference docRef = await firestore.collection("contract").add(contract.toMap());

    // Lấy lại dữ liệu vừa add từ Firestore
    DocumentSnapshot snapshot = await docRef.get();
    final data = snapshot.data() as Map<String, dynamic>;

    // Trả về Contact mới, dùng fromMap (không cần sửa model)
    return Contract.fromMap(docRef.id, data);
  }

  //===================updateContract
  Future<Contract> updateContract(Contract contract) async {
    await firestore.collection("contract").doc(contract.contractID).update(contract.toMap());
    return contract;
  }

  //==========================deleteContract
  Future<void> deleteContract(String contractID) async {
    await firestore.collection("contract").doc(contractID).delete();
  }
  //getContractByApartmentId
  Future<List<Contract>> getContractByApartmentId(String apartmentId) async {
    List<Contract> contracts = [];
    QuerySnapshot snapshot = await firestore
        .collection("contract")
        .where("ApartmentId", isEqualTo: apartmentId)
        .get();
    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      contracts.add(Contract.fromMap(doc.id, data));
    }
    return contracts;
  }
}