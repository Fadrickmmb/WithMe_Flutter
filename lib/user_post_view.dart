import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:withme_flutter/comment_design.dart';
import 'package:withme_flutter/user_add_post_page.dart';
import 'package:withme_flutter/user_edit_post.dart';
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
  late String userAvatar = '';
  late String location = '';
  late String postDate = '';
  late int yummys = 0;
  late int commentsNumber = 0;
  late String postId = '';
  late String date = '';
  late String text = '';
  late List<Comment> comments = [];
  int _selectedIndex = 0;

  void initState(){
    super.initState();
    _fetchPostInfo();
    _fetchCommentInfo();
    print('Received userId: ${widget.userId}');
    print('Received postId: ${widget.postId}');
  }

  Future<void> _fetchUserAvatar() async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User? user = auth.currentUser;

    if (user != null) {
      final DatabaseReference userRef = FirebaseDatabase.instance.ref().child(
          'users/${user.uid}');
      try{
        final DataSnapshot snapshot = await userRef.get();
        if (snapshot.exists) {
          final userData = snapshot.value as Map?;
          setState(() {
            userAvatar = userData?['userPhotoUrl'] ?? '';
          });
        }
      } catch(e) {
        print("error fetching user data $e");
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Failed to load user data."))
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("user not logged in."))
      );
    }
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
            userPhotoUrl = postData?['userPhotoUrl'] ?? '';
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

  Future<void> _addCommentToDatabase(String commentText) async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final user = auth.currentUser;
    final DatabaseReference postReference = FirebaseDatabase.instance
        .ref().child('users/${widget.userId}/posts/${widget.postId}/comments');

    if(user != null) {
      final String commentId = postReference.push().key ?? "";
      final DateTime today = DateTime.now();
      final String formattedDate = "${today.year.toString()}-${today.month.toString().padLeft(2,'0')}-${today.day.toString().padLeft(2,'0')}"
          "${today.hour.toString().padLeft(2,'0')}:${today.minute.toString().padLeft(2,'0')}";
      final commentInfo = Comment.full(
        name: user.displayName ?? 'Anonymous',
        text: commentText,
        date: formattedDate,
        userId: user.uid,
        postId: widget.postId,
        commentId: commentId,
      );

      try{
        await postReference.child(commentId).set({
          'commentId': commentInfo.commentId,
          'name': commentInfo.name,
          'text': commentInfo.text,
          'date': commentInfo.date,
          'userId': commentInfo.userId,
          'postId': commentInfo.postId,
        });
        setState(() {
          comments.add(Comment.partial(
              name: commentInfo.name,
              text: commentInfo.text,
              date: commentInfo.date
          ));
        });
      } catch (e) {
        print("Error adding comment: $e");
      }
    } else {
      print("User is not logged in.");
    }

  }

  void _showPostDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context){
          return Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              width: 250,
              decoration: BoxDecoration(
                color: Colors.grey[850],
                borderRadius: BorderRadius.circular(10),
              ),
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: IconButton(
                      onPressed: (){
                        Navigator.of(context).pop();
                      },
                      icon: Icon(Icons.close, color: Colors.white,),
                    ),
                  ),
                  SizedBox(height: 20,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            IconButton(
                              onPressed: () {
                                _deletePost(context);
                              },
                              icon: Icon(Icons.warning_amber, size: 60, color: Colors.white),
                            ),
                            SizedBox(height: 10,),
                            Text("REPORT",style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }
    );
  }

  Future <void> _deletePost(BuildContext context)  async{
    final DatabaseReference postReference = FirebaseDatabase.instance
        .ref().child('users/${widget.userId}userId/posts/${widget.postId}');
    try{
      await postReference.remove();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Post deleted successfuly."),),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Error deleting post: $e"),),
      );
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
        MaterialPageRoute(builder: (context) => UserAddPostPage(),
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
                        GestureDetector(
                          onTap: (){
                            _showPostDialog(context);
                          },
                          child: Row(
                            children: [
                              Icon(Icons.circle, size: 7),
                              SizedBox(width: 5,),
                              Icon(Icons.circle, size: 7),
                              SizedBox(width: 5,),
                              Icon(Icons.circle, size: 7),
                            ],
                          ),
                        ),
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
                    SizedBox(height: 10,),
                    Container(
                      padding: EdgeInsets.all(5),
                      alignment: Alignment.topLeft,
                      child: Text(content, textAlign: TextAlign.start, style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      ),
                    ),
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
                    SizedBox(height: 20,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
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
                            fixedSize: MaterialStateProperty.all<Size>(Size(150.0, 50.0),),
                          ),
                          child: Text('Back',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        SizedBox(width: 20,),
                        ElevatedButton(onPressed: (){
                          showDialog(
                            context: context,
                            builder: (BuildContext context){
                              TextEditingController commentController = TextEditingController();
                              return AlertDialog(
                                title: Text("Add a comment:"),
                                content: TextField(
                                  controller: commentController,
                                  decoration: InputDecoration(hintText: 'Write your comment here'),
                                ),
                                actions: <Widget> [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: Text("Cancel"),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      String commentText = commentController.text.trim();
                                      if(commentText.isNotEmpty) {
                                        _addCommentToDatabase(commentText);
                                        Navigator.of(context).pop();
                                      } else {
                                        print("Comment is empty.");
                                      }
                                    },
                                    child: Text("Comment"),
                                  ),
                                ],
                              );
                            },
                          );
                        }, style: ButtonStyle(
                          backgroundColor: WidgetStatePropertyAll<Color>(Color(0xFF1A2F31)),
                          shape: WidgetStateProperty.all(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          padding: WidgetStateProperty.all<EdgeInsets>(EdgeInsets.all(10),),
                          fixedSize: MaterialStateProperty.all<Size>(Size(150.0, 50.0),),
                        ),
                          child: Text('Comment',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
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
          BottomNavigationBarItem(icon: CircleAvatar(
            backgroundColor: Colors.grey,
            radius: 20,
            backgroundImage: userAvatar.isNotEmpty ?
            NetworkImage(userAvatar) : AssetImage('assets/small_logo.png'),
          ),
              label: ''),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }
}
