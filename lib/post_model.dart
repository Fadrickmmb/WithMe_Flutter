import 'comment_model.dart';

class Post {
  String? content;  // ? means this variable can be null
  String? userId;
  String? postImageUrl;
  String? name;
  String? userPhotoUrl;
  String? location;
  String? postDate;
  int? yummys;
  int? commentsNumber;
  String? postId;
  Map<String, Comment>? comments;

  Post();

  Post.full({
    required this.content,
    required this.userId,
    required this.postImageUrl,
    required this.name,
    required this.userPhotoUrl,
    required this.location,
    required this.postDate,
    required this.yummys,
    required this.commentsNumber,
    required this.postId,
    required this.comments,
  });

  Post.partial({
    required this.userId,
    required this.postImageUrl,
    required this.postDate,
    required this.name,
    required this.location,
    required this.yummys,
    required this.commentsNumber,
    required this.userPhotoUrl,
    required this.postId,
  });

  Map<String, Comment>? getComments() => comments;
  setComments(Map<String, Comment> comments) => this.comments = comments;
}