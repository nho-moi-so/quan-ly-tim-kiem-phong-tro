//apartment widgets
//util
import 'package:flutter/material.dart';

export 'logo_widget.dart';
export 'tag_with_icon_widget.dart';
export 'post/search_bar_widget.dart';
export 'common/loading_widget.dart';
export 'apartment/label_title_widget.dart';
//message
export 'message/chat_item_widget.dart';

Future<void> showDateTimePicker({
  required BuildContext context,
  required DateTime initialDateTime,
  required ValueChanged<DateTime> onDateTimeChanged,
}) async {
  final DateTime? date = await showDatePicker(
    context: context,
    initialDate: initialDateTime,
    firstDate: DateTime(2000),
    lastDate: DateTime(2100),
  );

  if (date != null) {
    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initialDateTime),
    );

    if (time != null) {
      final DateTime newDateTime = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );

      onDateTimeChanged(newDateTime);

      // Hiện thông báo (SnackBar)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã chọn: ${_formatDateTime(newDateTime)}'),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }
}

String _formatDateTime(DateTime dt) {
  return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year} '
         '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
}