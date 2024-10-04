import 'package:withme_flutter/post_model.dart';

class User{
  String? name;
  String? email;
  String? id;
  int? numberPosts;
  int? numberFollowers;
  int? numberFollowing;
  String? userPhotoUrl;
  String? userBio;
  Map<String, Post>? posts;

  User();

  User.register({
    required this.name,
    required this.email,
    required this.id});

  User.full({
    required this.name,
    required this.email,
    required this.id,
    required this.numberPosts,
    required this.numberFollowers,
    required this.numberFollowing,
    required this.userPhotoUrl,
    required this.userBio,
    required this.posts});

  Map<String, Post>? getPosts() => posts;
  setPosts(Map<String, Post> posts) => this.posts = posts;
}