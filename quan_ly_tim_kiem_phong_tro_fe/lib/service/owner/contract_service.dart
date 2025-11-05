import 'package:quan_ly_tim_kiem_phong_tro_fe/model/contract.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
class ContractService {
  //connect to firebase
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  //=================getAllContracts
  Future<List<Contract>> getAllContracts() async {
    List<Contract> contracts = [];
    QuerySnapshot snapshot = await firestore.collection("contracts").get();
    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      contracts.add(Contract.fromMap(doc.id, data));
    }
    return contracts;
  }

  //=======================getContractById
  Future<Contract> getContractById(String id) async {
    DocumentSnapshot snapshot = await firestore.collection("contracts").doc(id).get();
    final data = snapshot.data() as Map<String, dynamic>;
    return Contract.fromMap(snapshot.id, data);
  }

  //===================createContract
  Future<Contract> createContract(Contract contract) async {
    DocumentReference docRef = await firestore.collection("contracts").add(contract.toMap());

    // Lấy lại dữ liệu vừa add từ Firestore
    DocumentSnapshot snapshot = await docRef.get();
    final data = snapshot.data() as Map<String, dynamic>;

    // Trả về Contact mới, dùng fromMap (không cần sửa model)
    return Contract.fromMap(docRef.id, data);
  }

  //===================updateContract
  Future<Contract> updateContract(Contract contract) async {
    await firestore.collection("contracts").doc(contract.contractID).update(contract.toMap());
    return contract;
  }

  //==========================deleteContract
  Future<void> deleteContract(String contractID) async {
    await firestore.collection("contracts").doc(contractID).delete();
  }
}