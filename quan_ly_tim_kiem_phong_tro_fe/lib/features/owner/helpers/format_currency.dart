import 'package:intl/intl.dart';

String formatCurrency(dynamic amount) {
  double value;
  if (amount == null) {
    value = 0.0;
  } else if (amount is num) {
    value = amount.toDouble();
  } else {
    value = double.tryParse(amount.toString()) ?? 0.0;
  }
  final formatter = NumberFormat("#,##0", "vi_VN");
  return formatter.format(value);
}