import 'package:flutter/material.dart';

class User {
  String name;
  String email;
  String id;
  int? numberPosts;
  int? numberFollowers;
  int? numberFollowing;
  String? userPhotoUrl;
  String? userBio;
  Map<String, Post>? posts;


  User({
    required this.name,
    required this.email,
    required this.id,
    this.numberPosts,
    this.numberFollowers,
    this.numberFollowing,
    this.userPhotoUrl,
    this.userBio,
    Map<String, Post>? posts,
  }) : posts = posts ?? {};

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


  User.empty()
      : name = '',
        email = '',
        id = '',
        posts = {},
        numberPosts = 0,
        numberFollowers = 0,
        numberFollowing = 0,
        userPhotoUrl = '',
        userBio = '';


  String? get userBioValue => userBio;
  set userBioValue(String? bio) {
    userBio = bio;
  }

  String? get userPhotoUrlValue => userPhotoUrl;
  set userPhotoUrlValue(String? url) {
    userPhotoUrl = url;
  }


  int? get numberPostsValue => numberPosts;
  set numberPostsValue(int? posts) {
    numberPosts = posts;
  }

  int? get numberFollowersValue => numberFollowers;
  set numberFollowersValue(int? followers) {
    numberFollowers = followers;
  }


  int? get numberFollowingValue => numberFollowing;
  set numberYummysValue(int? following) {
    numberFollowing = following;
  }


  Map<String, Post>? get postsValue => posts;
  set postsValue(Map<String, Post>? newPosts) {
    posts = newPosts ?? {};
  }

}
  class Post {

  }