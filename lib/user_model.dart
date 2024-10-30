
import 'package:flutter/material.dart';
import 'package:withme_flutter/post_model.dart';

class User {
  late String name;
  late String email;
  late String id;
  late int? numberPosts;
  late int? numberFollowers;
  late int? numberFollowing;
  late String? userPhotoUrl;
  late String? userBio;
  late Map<String, Post>? posts;

  User.empty();

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

