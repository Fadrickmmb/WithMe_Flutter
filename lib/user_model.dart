import 'package:flutter/material.dart';

class User {
  String name;
  String email;
  String id;
  Map<String, Post>? posts;
  String? numberPosts;
  String? numberFollowers;
  String? numberYummys;
  String? userPhotoUrl;
  String? userBio;

  User({
    required this.name,
    required this.email,
    required this.id,
    this.numberPosts,
    this.numberFollowers,
    this.numberYummys,
    this.userPhotoUrl,
    this.userBio,
    Map<String, Post>? posts,
  }) : posts = posts ?? {};


  User.empty()
      : name = '',
        email = '',
        id = '',
        posts = {},
        numberPosts = '',
        numberFollowers = '',
        numberYummys = '',
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


  String? get numberPostsValue => numberPosts;
  set numberPostsValue(String? posts) {
    numberPosts = posts;
  }

  String? get numberFollowersValue => numberFollowers;
  set numberFollowersValue(String? followers) {
    numberFollowers = followers;
  }


  String? get numberYummysValue => numberYummys;
  set numberYummysValue(String? yummys) {
    numberYummys = yummys;
  }


  Map<String, Post>? get postsValue => posts;
  set postsValue(Map<String, Post>? newPosts) {
    posts = newPosts ?? {};
  }
}

class Post {

}
