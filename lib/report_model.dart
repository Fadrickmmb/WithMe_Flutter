class Report {
  String? reportId;
  String? userId;
  String? postId;
  String? commentId;
  String? postOwnerId;
  String? commentOwnerId;
  String? userReportingId;

  Report();

  Report.reportUser({
    required this.reportId,
    required this.userId,
    required this.userReportingId,
  });

  Report.reportPost({
    required this.reportId,
    required this.postId,
    required this.postOwnerId,
    required this.userReportingId,
  });

  Report.reportComment({
    required this.reportId,
    required this.postId,
    required this.commentId,
    required this.postOwnerId,
    required this.commentOwnerId,
    required this.userReportingId,
  });
}
