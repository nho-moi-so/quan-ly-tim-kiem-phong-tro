
import 'package:quan_ly_tim_kiem_phong_tro_fe/features/owner/viewmodel/chat_item_viewmodel.dart';

class MessageController {

  //getSummaryMessage - == fake data - done 
  List<ChatItemViewModel> getSummaryMessage(String ownerId) {
    return [
      ChatItemViewModel(
        avatarUrl: "https://placehold.co/36x45",
        name: "Pamiuoi",
        message: "Dạ Phòng 203 còn trống ko ạ",
        status: "Online",
      ),
      ChatItemViewModel(
        avatarUrl: "https://placehold.co/36x45",
        name: "Nguyen Van A",
        message: "Dạ Phòng 203 còn trống ko ạ",
        status: "Offline",
      ),
      ChatItemViewModel(
        avatarUrl: "https://placehold.co/36x45",
        name: "Nguyen Van B",
        message: "Dạ Phòng 203 còn trống ko ạ",
        status: "Online",
      ),
      ChatItemViewModel(
        avatarUrl: "https://placehold.co/36x45",
        name: "Nguyen Van C",
        message: "Dạ Phòng 203 còn trống ko ạ",
        status: "Offline",
      ),
    ];
  }
}
