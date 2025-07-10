class User {
  final String userID;
  final String fullName;
  final String email;
  final String phone;
  final String password;
  final String role;
  final String username;
  final String approvalStatus;
  final bool viewFeedback;
  final bool viewStatistics;
  final String? adminCCCD;
  final String? ownerStatus;
  final String? ownerCCCD;
  final String? guestStatus;
  final int? reviewCount;

  User({
    required this.userID,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.password,
    required this.role,
    required this.username,
    required this.approvalStatus,
    required this.viewFeedback,
    required this.viewStatistics,
    this.adminCCCD,
    this.ownerStatus,
    this.ownerCCCD,
    this.guestStatus,
    this.reviewCount,
  });
}
