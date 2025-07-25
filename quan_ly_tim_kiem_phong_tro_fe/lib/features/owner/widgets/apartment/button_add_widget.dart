import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ButtonAddWidget extends StatelessWidget {
  final String title;
  final Widget screen;

  const ButtonAddWidget({super.key, required this.title, required this.screen});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 47,
      child: ElevatedButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => screen),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4285F4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          elevation: 0,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              'assets/Plus circle.svg',
              width: 24,
              height: 24,
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                title,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 12,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
