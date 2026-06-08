import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/features/guest/controller/wallet_controller.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  double balance = 0;

  final user = FirebaseAuth.instance.currentUser;

  final TextEditingController amountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    print("Current User = ${FirebaseAuth.instance.currentUser}");
    loadBalance();
  }

  Future<void> loadBalance() async {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .get();

    if (doc.exists) {
      setState(() {
        balance = (doc.data()?['Balance'] ?? 0).toDouble();
      });

      print("BALANCE = $balance");
    }
  }

  String formatVND(double amount) {
    final formatter = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');

    return formatter.format(amount);
  }

  Future<void> depositMoney() async {
    print("===== BẮT ĐẦU NẠP TIỀN =====");

    final amount = int.tryParse(amountController.text);

    print("Amount: $amount");

    if (amount == null || amount <= 0) {
      print("Số tiền không hợp lệ");
      return;
    }

    print("User ID: ${user?.uid}");

    final result = await WalletController().deposit(
      userId: user!.uid,
      amount: amount,
    );

    print("Kết quả API:");
    print(result);

    if (result['success']) {
      print("API SUCCESS");

      await loadBalance();

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Nạp tiền thành công")));
    } else {
      print("API FAIL");
      print(result['message']);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(result['message'])));
    }
  }

  Widget quickAmountButton(double amount) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          amountController.text = amount.toInt().toString();
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.blue),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              "${(amount / 1000).toInt()}K",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Ví Tiền")),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),

              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2196F3), Color(0xFF64B5F6)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  const Text(
                    "Số dư hiện tại",
                    style: TextStyle(color: Colors.white70),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    formatVND(balance),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              "Nạp nhanh",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                quickAmountButton(100000),
                quickAmountButton(200000),
                quickAmountButton(500000),
              ],
            ),

            const SizedBox(height: 24),

            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,

              decoration: InputDecoration(
                labelText: "Nhập số tiền",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 50,

              child: ElevatedButton(
                onPressed: depositMoney,

                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),

                child: const Text(
                  "Nạp Tiền",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
