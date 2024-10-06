import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:withme_flutter/user_add_post_page.dart';
import 'package:withme_flutter/user_home_page.dart';
import 'package:withme_flutter/user_profile_page.dart';
import 'package:withme_flutter/user_search_page.dart';

import 'comment_model.dart';

class UserPostView extends StatefulWidget {
  final String postId;
  final String userId;

  UserPostView({required this.userId, required this.postId});

  @override
  State<StatefulWidget> createState() => _UserPostView();
}

class _UserPostView extends State<UserPostView> {
  late String content ='';
  late String postImageUrl = '';
  late String name = '';
  late String userPhotoUrl = '';
  late String location = '';
  late String postDate = '';
  late int yummys = 0;
  late int commentsNumber = 0;
  late String postId = '';
  late String date = '';
  late String text = '';
  late List<Comment> comments = []; //String is the comment id and Comment is the object comment
  int _selectedIndex = 0;

  void initState(){
    super.initState();
    _fetchUserInfo();
    _fetchPostInfo();
    _fetchCommentInfo();
  }
  
  Future<void> _fetchUserInfo() async {
    final DatabaseReference userRef = FirebaseDatabase.instance.ref().child('user/${widget.userId}');
    try{
      final DataSnapshot snapshot = await userRef.get();
      if(snapshot.exists) {
        final userData = snapshot.value as Map?;
        setState(() {
          name = userData?['name'] ?? 'Unknown';
          userPhotoUrl = userData?['userPhotoUrl'] ?? '';
        });
      }
    } catch(e) {
      print("Error fetching user info: $e");
    }
  }
  
  Future<void> _fetchPostInfo() async {
    final DatabaseReference postRef = FirebaseDatabase.instance.ref().child('user/${widget.userId}/posts/${widget.postId}');

    try{
      final DataSnapshot snapshot = await postRef.get();
      if(snapshot.exists) {
        final postData = snapshot.value as Map?;
        setState(() {
          content = postData?['content'] ?? '';
          userPhotoUrl = postData?['userPhotUrl'] ?? '';
          postImageUrl = postData?['postImageUrl'] ?? '';
          location = postData?['location'] ?? '';
          postDate = postData?['postDate'] ?? '';
          yummys = postData?['yummys'] ?? '';
          commentsNumber = postData?['commentsNumber'] ?? '';
        });
      }
    } catch(e) {
      print("Error fetching post detail: $e");
    }
  }

  Future<void> _fetchCommentInfo() async {
    final DatabaseReference commentsRef = FirebaseDatabase.instance.ref().child('user/${widget.userId}/posts/${widget.postId}/comments');

    try{
      final DataSnapshot commentSnapshot = await commentsRef.get();
      if(commentSnapshot.exists) {
        final commentData = commentSnapshot.value as Map?;
        if(commentData != null) {
          setState(() {
            comments = commentData.values.map((data){
              return Comment.partial(
                  name: data['name'] ?? '',
                  date: data['date'] ?? '',
                  text: data['text']  ?? '',
              );
            }).toList();
          });
        }
      }
    } catch(e) {
      print("Error fetching comment detail: $e");
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 0) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => UserHomePage()),
      );
    } else if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => UserSearchPage()),
      );
    } else if (index == 2) {
      Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => UserPostView(userId: widget.userId, postId: postId,
          ),
        ),
      );
    } else if (index == 3) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => UserProfilePage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 60.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Container(
                          alignment: Alignment.centerLeft,
                          child: Column(
                            children: [
                              Image.asset('assets/withme_logo.png', height: 60),
                            ],
                          ),
                        ),
                        Expanded(child: SizedBox.shrink()),
                        Container(
                          padding: EdgeInsets.fromLTRB(0, 0, 10, 0),
                          alignment: Alignment.centerRight,
                          child: Image.asset('assets/withme_yummy.png', height: 30),
                        ),
                        Container(
                          alignment: Alignment.centerRight,
                          child: Image.asset('assets/withme_comment.png', height: 30),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.grey,
                          radius: 25,
                          backgroundImage: userPhotoUrl.isNotEmpty ?
                          NetworkImage(userPhotoUrl) : AssetImage('assets/small_logo.png'),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: TextStyle(
                                fontFamily: 'DM Serif Display',
                                fontSize: 20,
                              ),
                            ),
                            Row(
                              children: [
                                Icon(Icons.location_on),
                                Text(location),
                              ],
                            ),
                          ],
                        ),
                        Spacer(),
                        Icon(Icons.more_vert),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Container(
                      height: 250,
                      color: Colors.grey[300],
                      child: Center(
                        child: postImageUrl.isNotEmpty
                            ? Image.network(
                          postImageUrl,
                          fit: BoxFit.cover,
                        )
                            : Icon(Icons.photo_camera, size: 50),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Row(
                            children: [
                              Image.asset('assets/withme_yummy.png', width: 25, height: 25),
                              const SizedBox(width: 10),
                              Text(yummys.toString(), style: TextStyle(fontSize: 12)),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Row(
                            children: [
                              Image.asset('assets/withme_comment.png', width: 25, height: 25),
                              const SizedBox(width: 10),
                              Text(commentsNumber.toString(), style: TextStyle(fontSize: 12)),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 4,
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Text(postDate, style: TextStyle(fontSize: 12)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ListView.builder(
                      shrinkWrap: true,
                      itemCount: comments.length,
                      itemBuilder: (context, index) {
                        final comment = comments[index];
                        return Comment.partial(
                            name: comment.name ?? '',
                            text: comment.text ?? '',
                            date: comment.date ?? '',
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(icon: Image.asset('assets/withme_home.png', height: 30), label: ''),
          BottomNavigationBarItem(icon: Image.asset('assets/withme_search.png', height: 30), label: ''),
          BottomNavigationBarItem(icon: Image.asset('assets/withme_newpost.png', height: 30), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.person, size: 36), label: ''),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }
}
