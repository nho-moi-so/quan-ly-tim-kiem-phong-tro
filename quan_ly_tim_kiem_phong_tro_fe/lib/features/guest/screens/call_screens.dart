import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CallScreens extends StatelessWidget {
  const CallScreens({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      builder: (context, child) {
        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                  child: Align(
                    alignment: Alignment.topRight,
                    child: Icon(Icons.close, size: 28.sp),
                  ),
                ),
                Column(
                  children: [
                    CircleAvatar(
                      radius: 60.r,
                      backgroundImage: const AssetImage("assets/images/avt1.jpg"),
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      "Pamiuoi",
                      style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      "Calling",
                      style: TextStyle(
                          fontSize: 16.sp,
                          color: Colors.blue,
                          fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      "1:25",
                      style: TextStyle(fontSize: 16.sp),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      "Call in progress",
                      style: TextStyle(fontSize: 14.sp, color: Colors.grey),
                    ),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: 32.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildCallButton(Icons.mic, Colors.white, Colors.black),
                      SizedBox(width: 20.w),
                      _buildCallButton(Icons.call_end, Colors.red, Colors.white),
                      SizedBox(width: 20.w),
                      _buildCallButton(Icons.videocam, Colors.white, Colors.black),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCallButton(IconData icon, Color backgroundColor, Color iconColor) {
    return Container(
      width: 60.r,
      height: 60.r,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Icon(icon, color: iconColor, size: 28.sp),
    );
  }
}
