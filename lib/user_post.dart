import 'package:flutter/material.dart';
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
                    Row(
                      children: [
                        Icon(Icons.circle, size: 7),
                        SizedBox(width: 5,),
                        Icon(Icons.circle, size: 7),
                        SizedBox(width: 5,),
                        Icon(Icons.circle, size: 7),
                      ],
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UserPostView(postId: postId,userId: userId),
                      ),
                    );
                  },
                  child: Container(
                    margin: EdgeInsets.only(top: 10),
                    height: 250,
                    color: Colors.grey[300],
                    child: Center(
                      child: postImageUrl.isNotEmpty
                          ? Image.network(postImageUrl, fit: BoxFit.cover)
                          : Icon(Icons.photo_camera, size: 50),
                      ),
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