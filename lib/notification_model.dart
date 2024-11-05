class NotificationModel {
  String? notificationId;
  String? senderName;
  String? followerName;
  String? followerId;
  String? message;
  String? notDate;
  String? postId;
  String? postOwnerId;
  String? followedId;
  String? type;

  NotificationModel();

  // comment notification
  NotificationModel.Comment({
    required this.notificationId,
    required this.senderName,
    required this.message,
    required this.notDate,
    required this.postId,
    required this.postOwnerId
  }) {
    type = 'comment';
  }

  // following notification
  NotificationModel.Follow({
    required this.notificationId,
    required this.followerId,
    this.notDate,
    this.followerName,
    this.followedId,
    this.message
  }) {
   type = 'follow';
  }
}