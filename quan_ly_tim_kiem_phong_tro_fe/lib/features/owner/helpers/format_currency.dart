import 'package:intl/intl.dart';

String formatCurrency(double amount) {
  final formatter = NumberFormat("#,##0", "vi_VN");
  return formatter.format(amount);
}