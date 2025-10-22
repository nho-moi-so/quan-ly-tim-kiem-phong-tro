class User {
  final String? userID;
  final String? fullName;
  final String? email;
  final String? phone;
  final String? password;
  final String? role;
  final String? username;
  final String? approvalStatus;
  final bool? viewFeedback;
  final bool? viewStatistics;
  final String? adminCCCD;
  final String? ownerStatus;
  final String? ownerCCCD;
  final String? guestStatus;
  final int? reviewCount;

  User({
    this.userID,
    this.fullName,
    this.email,
    this.phone,
    this.password,
    this.role,
    this.username,
    this.approvalStatus,
    this.viewFeedback,
    this.viewStatistics,
    this.adminCCCD,
    this.ownerStatus,
    this.ownerCCCD,
    this.guestStatus,
    this.reviewCount,
  });
}
