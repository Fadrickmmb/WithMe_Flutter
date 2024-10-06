import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:withme_flutter/comment_design.dart';
import 'package:withme_flutter/user_add_post_page.dart';
import 'package:withme_flutter/user_edit_profile.dart';
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
  late String ownername = '';
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
    _fetchPostInfo();
    _fetchCommentInfo();
    print('Received userId: ${widget.userId}');
    print('Received postId: ${widget.postId}');
  }

  Future<void> _fetchPostInfo() async {
    final DatabaseReference postRef = FirebaseDatabase.instance.ref().child('users/${widget.userId}/posts/${widget.postId}');

    try {
      final DataSnapshot snapshot = await postRef.get();
      if (snapshot.exists) {
        final postData = snapshot.value as Map?;
        if(postData != null){
          setState(() {
            ownername = postData?['name'] ?? '';
            content = postData?['content'] ?? '';
            postImageUrl = postData?['postImageUrl'] ?? '';
            userPhotoUrl = postData?['userImageUrl'] ?? '';
            location = postData?['location'] ?? '';
            postDate = postData?['postDate'] ?? '';
            yummys = int.tryParse(postData?['yummys']?.toString() ?? '0') ?? 0;
            commentsNumber = int.tryParse(postData?['commentsNumber']?.toString() ?? '0') ?? 0;
          });
        }
      } else {
        print('Post not found.');
      }
    } catch (e) {
      print("Error fetching post detail: $e");
    }
  }

  Future<void> _fetchCommentInfo() async {
    final DatabaseReference commentsRef = FirebaseDatabase.instance.ref().child('users/${widget.userId}/posts/${widget.postId}/comments');

    try {
      final DataSnapshot commentSnapshot = await commentsRef.get();
      if (commentSnapshot.exists) {
        final commentData = commentSnapshot.value as Map<dynamic, dynamic>?;
        if (commentData != null) {
          setState(() {
            comments = commentData.values.map((comment) {
              final commentMap = comment as Map<dynamic, dynamic>;
              return Comment.partial(
                name: commentMap['name'] ?? 'Anonymous',
                date: commentMap['date'] ?? 'Unknown date',
                text: commentMap['text'] ?? 'No content',
              );
            }).toList();
          });
        }
      }
    } catch (e) {
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
                          NetworkImage(userPhotoUrl) : AssetImage('assets/small_logo.png') as ImageProvider,
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              ownername,
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
                        return CommentWidget(
                            name: comment.name ?? 'Anonymous',
                            text: comment.text ?? 'No comment.',
                            date: comment.date ?? 'Unknown date',
                        );
                      },
                    ),
                    SizedBox(height: 40,),
                    ElevatedButton(onPressed: (){
                      Navigator.pop(context);
                    },
                      style: ButtonStyle(
                        backgroundColor: WidgetStatePropertyAll<Color>(Color(0xFF1A2F31)),
                        shape: WidgetStateProperty.all(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        padding: WidgetStateProperty.all<EdgeInsets>(EdgeInsets.all(10),),
                        fixedSize: MaterialStateProperty.all<Size>(Size(200.0, 60.0),),
                      ),
                      child: Text('Back',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
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
