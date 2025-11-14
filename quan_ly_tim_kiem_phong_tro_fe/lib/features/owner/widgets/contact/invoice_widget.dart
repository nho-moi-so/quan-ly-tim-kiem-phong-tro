import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class InvoiceWidget extends StatelessWidget {
  final double dailyRate;
  final int numberOfDays;
  final double otherFees;
  final double taxRate; // phần trăm thuế (ví dụ: 10 nghĩa là 10%)
  final double discount;
  final VoidCallback? onDownload;
  final bool isDownloading;

  const InvoiceWidget({
    super.key,
    required this.dailyRate,
    required this.numberOfDays,
    this.otherFees = 0,
    this.taxRate = 0,
    this.discount = 0,
    this.onDownload,
    this.isDownloading = false,
  });

  String formatCurrency(double amount) {
    final formatter = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
    return formatter.format(amount);
  }

  double get subtotal => dailyRate * numberOfDays;
  double get taxAmount => (subtotal + otherFees) * (taxRate / 100);
  double get totalBeforeDiscount => subtotal + otherFees + taxAmount;
  double get totalAmount => totalBeforeDiscount - discount;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.shade100, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Body
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Daily rate
                _buildInvoiceRow(
                  icon: Icons.calendar_today_rounded,
                  iconColor: Colors.blue.shade600,
                  label: 'Giá mỗi ngày',
                  value: formatCurrency(dailyRate),
                  isSubItem: false,
                ),
                const SizedBox(height: 12),

                // Number of days
                _buildInvoiceRow(
                  icon: Icons.event_note_rounded,
                  iconColor: Colors.green.shade600,
                  label: 'Số ngày',
                  value: '$numberOfDays ngày',
                  isSubItem: false,
                ),
                const SizedBox(height: 12),

                // Subtotal (daily rate × days)
                _buildInvoiceRow(
                  icon: Icons.calculate_rounded,
                  iconColor: Colors.purple.shade400,
                  label: 'Tạm tính',
                  value: formatCurrency(subtotal),
                  isSubItem: false,
                  valueColor: Colors.purple.shade700,
                ),

                if (otherFees > 0) ...[
                  const SizedBox(height: 12),
                  _buildInvoiceRow(
                    icon: Icons.more_horiz_rounded,
                    iconColor: Colors.orange.shade600,
                    label: 'Phí khác',
                    value: formatCurrency(otherFees),
                    isSubItem: false,
                  ),
                ],

                if (taxRate > 0) ...[
                  const SizedBox(height: 12),
                  _buildInvoiceRow(
                    icon: Icons.account_balance_rounded,
                    iconColor: Colors.amber.shade700,
                    label: 'Thuế ($taxRate%)',
                    value: formatCurrency(taxAmount),
                    isSubItem: false,
                  ),
                ],

                if (discount > 0) ...[
                  const SizedBox(height: 12),
                  _buildInvoiceRow(
                    icon: Icons.local_offer_rounded,
                    iconColor: Colors.red.shade400,
                    label: 'Giảm giá',
                    value: '- ${formatCurrency(discount)}',
                    isSubItem: false,
                    valueColor: Colors.red.shade600,
                  ),
                ],

                const SizedBox(height: 16),
                Divider(thickness: 2, color: Colors.blue.shade100),
                const SizedBox(height: 16),

                // Total
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.blue.shade50,
                        Colors.blue.shade100.withOpacity(0.5),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue.shade200, width: 2),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.blue.shade600,
                              Colors.blue.shade400,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.payments_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'TỔNG THANH TOÁN',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1F2937),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      Text(
                        formatCurrency(totalAmount),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Download button at bottom
            if (onDownload != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                backgroundColor: Colors.blue.shade600,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
                ),
                onPressed: isDownloading ? null : onDownload,
                icon: isDownloading
                  ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.black,
                    ),
                  )
                  : const Icon(Icons.download_rounded, size: 20, color: Colors.black),
                label: Text(
                isDownloading ? 'Đang tải hóa đơn...' : 'Tải hóa đơn',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                  color: Colors.black,
                ),
                ),
              ),
              ),
            ),
          ],
          ),
    );
  }

  Widget _buildInvoiceRow({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    bool isSubItem = false,
    Color? valueColor,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: iconColor.withOpacity(0.3)),
          ),
          child: Icon(icon, size: 20, color: iconColor),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: isSubItem ? 14 : 15,
              fontWeight: isSubItem ? FontWeight.w500 : FontWeight.w600,
              color: const Color(0xFF4B5563),
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isSubItem ? 14 : 16,
            fontWeight: FontWeight.w700,
            color: valueColor ?? const Color(0xFF1F2937),
          ),
        ),
      ],
    );
  }
}
