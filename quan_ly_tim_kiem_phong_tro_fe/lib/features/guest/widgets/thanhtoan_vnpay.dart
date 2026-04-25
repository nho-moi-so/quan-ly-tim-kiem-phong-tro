import 'package:flutter/material.dart';

enum PaymentMethod {
  vnpay,
  cash,
}

class ThanhtoanVnpay extends StatelessWidget {
  final PaymentMethod selectedPayment;
  final ValueChanged<PaymentMethod> onChanged;

  const ThanhtoanVnpay({
    super.key,
    required this.selectedPayment,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(
          color: Colors.blue,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Phương thức thanh toán',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            RadioListTile<PaymentMethod>(
              contentPadding: EdgeInsets.zero,
              value: PaymentMethod.vnpay,
              groupValue: selectedPayment,
              title: const Text('Thanh toán qua VNPay'),
              secondary: Image.asset(
                'assets/images/vnpay.jpg',
                width: 45,
                height: 45,
              ),
              onChanged: (value) {
                if (value != null) {
                  onChanged(value);
                }
              },
            ),

            RadioListTile<PaymentMethod>(
              contentPadding: EdgeInsets.zero,
              value: PaymentMethod.cash,
              groupValue: selectedPayment,
              title: const Text('Phương Thức Khác'),
              secondary: const Icon(
                Icons.payments_outlined,
                color: Colors.green,
              ),
              onChanged: (value) {
                if (value != null) {
                  onChanged(value);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}