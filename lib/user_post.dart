import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:withme_flutter/user_edit_post.dart';
import 'package:withme_flutter/user_post_view.dart';

class UserPost extends StatelessWidget {
  final String name;
  final String location;
  final String postImageUrl;
  final String userPhotoUrl;
  final String postDate;
  final int yummys;
  final int comments;
  final String postId;
  final String userId;

  UserPost.partial({
    required this.postId,
    required this.userId,
    required this.name,
    required this.postImageUrl,
    required this.userPhotoUrl,
    required this.postDate,
    required this.yummys,
    required this.comments,
    required this.location,
  });

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
                                  icon: Icon(Icons.delete_outline, size: 60, color: Colors.white),
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
                      Expanded(
                        child: Column(
                          children: [
                            IconButton(
                              onPressed: () {
                                Navigator.push(context,
                                  MaterialPageRoute(builder: (context) => UserEditPost(
                                      userId: userId,
                                      postId: postId),
                                  ),
                                );
                              },
                              icon: Icon(Icons.edit, size: 60, color: Colors.white),
                            ),
                            SizedBox(height: 10,),
                            Text("EDIT",style: TextStyle(
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
        .ref().child('users/$userId/posts/$postId');
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

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            margin: EdgeInsets.only(bottom: 20,top: 20),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      child: CircleAvatar(
                        backgroundColor: Colors.grey,
                        radius: 25,
                        backgroundImage: userPhotoUrl.isNotEmpty ?
                            NetworkImage(userPhotoUrl) :
                            AssetImage('assets/default_avatar.png') as ImageProvider,
                      ),
                    ),
                    SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(name,
                          style: TextStyle(
                            fontFamily: 'DM Serif Display',
                            fontSize: 20,
                          ),
                        ),
                        Row(
                          children: [
                            Icon(Icons.location_on, size: 18),
                            SizedBox(width: 4),
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
                Container(
                    margin: EdgeInsets.only(top: 10),
                    height: 250,
                    color: Colors.grey[300],
                    child: Center(
                      child: postImageUrl.isNotEmpty
                          ? Image.network(postImageUrl, fit: BoxFit.cover)
                          : Icon(Icons.photo_camera, size: 50),
                      ),
                    ),
                Container(
                  height: 50,
                  child: Row(
                    children: [
                      Expanded(
                      flex: 3,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Image.asset('assets/withme_yummy.png', width: 25),
                          SizedBox(width: 10),
                          Text(
                            yummys.toString(),
                            style: TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Row(
                        children: [
                          Image.asset('assets/withme_comment.png', width: 25),
                          SizedBox(width: 10),
                          Text(
                            comments.toString(),
                            style: TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 4,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            postDate,
                            style: TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}