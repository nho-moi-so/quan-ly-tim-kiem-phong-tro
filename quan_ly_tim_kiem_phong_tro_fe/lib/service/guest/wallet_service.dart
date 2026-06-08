import 'package:cloud_firestore/cloud_firestore.dart';

class WalletService {
  Future<double> getBalance(String userId) async {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .get();

    if (!doc.exists) return 0;

    return (doc.data()?['balance'] ?? 0).toDouble();
  }
}