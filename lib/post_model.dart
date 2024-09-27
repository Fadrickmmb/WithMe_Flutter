import 'package:flutter/material.dart';

import 'comment_model.dart';

class Post {
  String name;
  String userPhotoUrl;
  String postImageUrl;
  String location;
  String postDate;
  int yummys;
  List<Comment> comments;

  Post({
    required this.name,
    required this.userPhotoUrl,
    required this.postImageUrl,
    required this.location,
    required this.postDate,
  })  : yummys = 0,
        comments = [];

  void addYummy() {
    yummys++;
  }

  void addComment(Comment comment) {
    comments.add(comment);
  }
}