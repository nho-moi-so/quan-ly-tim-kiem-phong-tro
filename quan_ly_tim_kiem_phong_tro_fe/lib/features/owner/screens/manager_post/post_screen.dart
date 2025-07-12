import 'package:flutter/material.dart';

import '../../widgets/widgets.dart';

class PostScreen extends StatelessWidget {
  const PostScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          width: screenWidth,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: screenHeight * 0.05),
              Center(child: LogoWidget()),
                Row(
                children: [
                  // const TagWithIconWidget(),
                  const Spacer(),
                  // Button "Chủ trọ"
                  // ButtonAddWidget(),
                ],
                ),
              SizedBox(height: screenHeight * 0.02),
              FliterStatusWidget(),
              SizedBox(height: screenHeight * 0.02),
              LabelTitleWidget(title: "Danh sách bài đăng"),
              SearchBarWidget(),
              SizedBox(height: screenHeight * 0.02),

              RoomPostItemWidget(roomName : "Phòng 101",
                postDate: "01/01/2023",
                status: "Đang cho thuê",
                imageUrl: "https://via.placeholder.com/150"),
              RoomPostItemWidget(roomName : "Phòng 102",
                postDate: "02/01/2023",
                status: "Đã cho thuê",
                imageUrl: "https://via.placeholder.com/150"),
              RoomPostItemWidget(roomName : "Phòng 103",
                postDate: "03/01/2023",
                status: "Đang cho thuê",
                imageUrl: "https://via.placeholder.com/150"),
                RoomPostItemWidget(roomName : "Phòng 101",
                postDate: "01/01/2023",
                status: "Đang cho thuê",
                imageUrl: "https://via.placeholder.com/150"),
              RoomPostItemWidget(roomName : "Phòng 102",
                postDate: "02/01/2023",
                status: "Đã cho thuê",
                imageUrl: "https://via.placeholder.com/150"),
            ],
          ),
        ),
      ),
    );
  }
}