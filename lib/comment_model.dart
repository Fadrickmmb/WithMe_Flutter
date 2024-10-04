class Comment {
  String? name;
  String? text;
  String? date;
  String? userId;
  String? postId;
  String? commentId;

  Comment();

  Comment.full({
    required this.name,
    required this.text,
    required this.date,
    required this.userId,
    required this.postId,
    required this.commentId,
  });

  Comment.partial({
    required this.name,
    required this.text,
    required this.date,
    required this.commentId,
  });

}