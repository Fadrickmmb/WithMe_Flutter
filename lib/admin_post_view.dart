import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:withme_flutter/comment_design.dart';
import 'package:withme_flutter/user_add_post_page.dart';
import 'package:withme_flutter/user_home_page.dart';
import 'package:withme_flutter/user_profile_page.dart';
import 'package:withme_flutter/user_search_page.dart';

import 'admin_add_post_page.dart';
import 'admin_home_page.dart';
import 'admin_profile_page.dart';
import 'admin_search_page.dart';
import 'comment_model.dart';
import 'mod_home_page.dart';

class AdminPostView extends StatefulWidget {
  final String postId;
  final String userId;

  AdminPostView({required this.userId, required this.postId});

  @override
  State<StatefulWidget> createState() => _AdminPostView();
}

class _AdminPostView extends State<AdminPostView> {
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
  late String loggedUserId = '';
  late List<Comment> comments = [];
  int _selectedIndex = 0;
  late FirebaseAuth auth = FirebaseAuth.instance;

  void initState(){
    super.initState();
    _fetchUserAvatar();
    _fetchPostInfo();
    _fetchCommentInfo();
    print('Received userId: ${widget.userId}');
    print('Received postId: ${widget.postId}');
  }

  Future<void> _fetchUserAvatar() async {
    final User? loggedUser = auth.currentUser;

    if (loggedUser != null) {
      final DatabaseReference userRef = FirebaseDatabase.instance.ref().
      child('users/${loggedUser.uid}');
      try{
        final DataSnapshot snapshot = await userRef.get();
        if (snapshot.exists) {
          final userData = snapshot.value as Map?;
          setState(() {
            loggedUserId = loggedUser.uid;
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
    final DatabaseReference commentsRef = FirebaseDatabase.instance.ref()
        .child('users/${widget.userId}/posts/${widget.postId}/comments');

    try {
      final DataSnapshot commentSnapshot = await commentsRef.get();
      if (commentSnapshot.exists) {
        final commentData = commentSnapshot.value as Map<dynamic, dynamic>?;
        if (commentData != null) {
          setState(() {
            comments = commentData.values.map((comment) {
              final commentMap = comment as Map<dynamic, dynamic>;
              return Comment.full(
                name: commentMap['name'] ?? 'Anonymous',
                date: commentMap['date'] ?? 'Unknown date',
                text: commentMap['text'] ?? 'No content',
                userId: commentMap['userId'] ?? 'Unknown user',
                postId: commentMap['postId'] ?? 'Unknown post id',
                commentId: commentMap['commentId'] ?? 'Unknown comment id',
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

  void _showDeletePostDialog(BuildContext context) {
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
                              icon: Icon(Icons.delete_outlined, size: 60, color: Colors.white),
                            ),
                            SizedBox(height: 10,),
                            Text("DELETE",style: TextStyle(
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
        .ref().child('users/${widget.userId}/posts/${widget.postId}');
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

  void _showDeleteCommentDialog(BuildContext context, String commentId, String postId, String userId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[850],
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    icon: Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
              Icon(Icons.delete_outlined, color: Colors.white),
              SizedBox(height: 20),
              Text(
                "Are you sure you want to delete this comment?",
                style: TextStyle(color: Colors.white),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _deleteComment(context, commentId, postId, userId);
                    },
                    child: Text("Yes"),
                  ),
                  SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text("No"),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _deleteComment(BuildContext context, String commentId, String postId, String userId) async {
    final DatabaseReference commentReference = FirebaseDatabase.instance.ref()
        .child('users/$userId/posts/$postId/comments/$commentId');
    final DatabaseReference postReference = FirebaseDatabase.instance.ref()
        .child('users/$userId/posts/$postId');

    try {
      await commentReference.remove();
      setState(() {
        comments.removeWhere((comment) => comment.commentId == commentId);
        commentsNumber -= 1;
      });

      await postReference.update({
        'commentsNumber': commentsNumber,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Comment deleted successfully.")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error deleting comment: $e")),
      );
    }
  }

  Future<void> _onItemTapped(int index) async {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 0) {
      final FirebaseAuth auth = FirebaseAuth.instance;
      final User? user = auth.currentUser;

      if (user != null) {
        try {
          final DatabaseReference adminRef = FirebaseDatabase.instance.ref().child('admin/${user.uid}');
          final DataSnapshot adminSnapshot = await adminRef.get();

          if (adminSnapshot.exists) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AdminHomePage()),
            );
            return;
          }

          final DatabaseReference modRef = FirebaseDatabase.instance.ref().child('mod/${user.uid}');
          final DataSnapshot modSnapshot = await modRef.get();

          if (modSnapshot.exists) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ModHomePage()),
            );
            return;
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("User role not found.")),
          );

        } catch (e) {
          print("Error checking user role: $e");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Failed to load user role.")),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("User not logged in.")),
        );
      }
    } else if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => AdminSearchPage()),
      );
    } else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => AdminAddPostPage()),
      );
    } else if (index == 3) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => AdminProfilePage()),
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
                          padding: EdgeInsets.fromLTRB(0,0,10,0),
                          alignment: Alignment.centerRight,
                          child: Icon(Icons.menu),
                        ),
                        Container(
                          alignment: Alignment.centerRight,
                          child: Icon(Icons.notifications),
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
                            if(widget.userId != loggedUserId) {
                              _showDeletePostDialog(context);
                            }
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
                          reportComment: (){
                            if (comment.commentId != null && comment.userId != null) {
                              _showDeleteCommentDialog(context, comment.commentId!, comment.postId!, comment.userId!);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("Error reporting comment.")),
                              );
                            }
                          },
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
