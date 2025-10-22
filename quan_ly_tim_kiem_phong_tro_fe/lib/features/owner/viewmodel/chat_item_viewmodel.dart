class ChatItemViewModel {
  String avatarUrl;
  String name;
  String message;
  String status;

  String ownerId;
  String tenantId;

  ChatItemViewModel({
    required this.avatarUrl,
    required this.name,
    required this.message,
    required this.status,
    required this.ownerId,
    required this.tenantId,
  });
}