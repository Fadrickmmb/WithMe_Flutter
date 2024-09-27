import 'package:flutter/material.dart';

class UserPost extends StatelessWidget {
  final String name;
  final String location='';
  //final String _postImageUrl;
  //final String _userPhotoUrl;
  final String postDate='';
  final int yummys = 0;
  final int comments = 0;
  UserPost({super.key, required this.name});

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
                        radius: 25,
                        backgroundColor: Colors.white,
                        child: Icon(Icons.person, size: 30),
                      ),
                    ),
                    SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Post Owner Name' + name,
                          style: TextStyle(
                            fontFamily: 'DM Serif Display',
                            fontSize: 20,
                          ),
                        ),
                        Row(
                          children: [
                            Icon(Icons.location_on, size: 18),
                            SizedBox(width: 4),
                            Text('Location Name' + location),
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
                Container(
                  margin: EdgeInsets.only(top: 10),
                  height: 250,
                  color: Colors.grey[300],
                  child: Center(
                    child: Icon(Icons.photo_camera, size: 50),
                  ),
                ),
                Container(
                  height: 50,
                  child: Row(
                    children: [
                      // Yummys
                      Expanded(
                        flex: 3,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Image.asset('assets/withme_yummy.png', width: 25),
                            SizedBox(width: 10),
                            Text(
                              'Yummys' + yummys.toString(),
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
                              'Comments' + comments.toString(),
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
                              'Date'+ postDate,
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
