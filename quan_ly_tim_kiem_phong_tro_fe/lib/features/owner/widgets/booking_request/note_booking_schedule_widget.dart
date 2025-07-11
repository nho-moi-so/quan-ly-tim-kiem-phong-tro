//done
import 'package:flutter/material.dart';

class NoteBookingScheduleWidget extends StatelessWidget {
  const NoteBookingScheduleWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final width = MediaQuery.of(context).size.width;
    final cardWidth = width > 420 ? 400.0 : width * 0.95;

    return Center(
      child: Container(
        width: cardWidth,
        margin: const EdgeInsets.symmetric(vertical: 24, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
              decoration: BoxDecoration(
                color: const Color(0xFF4285F4),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.10),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Note Lịch',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 24,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  Icon(Icons.event_note, color: Colors.white, size: 28),
                ],
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _InfoRow(label: 'Tên Khách Hàng', value: 'Ngọc Ngọc'),
                  const SizedBox(height: 8),
                  _InfoRow(label: 'Checkin', value: '14h'),
                  _InfoRow(label: 'Checkout', value: '12h'),
                  const SizedBox(height: 8),
                  _InfoRow(label: 'Ngày', value: '17/06 - 19/06'),
                ],
              ),
            ),
            // Actions
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                color: Color(0xFFF7F7F7),
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _ActionButton(
                    text: 'CANCEL',
                    color: const Color(0xFF4285F4),
                    onPressed: () {},
                  ),
                  const SizedBox(width: 12),
                  _ActionButton(
                    text: 'OK',
                    color: Colors.white,
                    textColor: const Color(0xFF4285F4),
                    border: BorderSide(color: const Color(0xFF4285F4)),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          '$label: ',
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 15,
            color: Colors.black87,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 15,
              color: Colors.black54,
            ),
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String text;
  final Color color;
  final Color? textColor;
  final BorderSide? border;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.text,
    required this.color,
    this.textColor,
    this.border,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: textColor ?? Colors.white,
        side: border,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        textStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 15,
          letterSpacing: 1.1,
        ),
      ),
      onPressed: onPressed,
      child: Text(text),
    );
  }
}
