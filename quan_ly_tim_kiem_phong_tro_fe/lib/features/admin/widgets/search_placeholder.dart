import 'package:flutter/material.dart';
import '../theme/app_text_styles.dart';

class SearchPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Text(
      'Tìm kiếm người dùng…',
      style: AppTextStyles.hintText,
    );
  }
}
