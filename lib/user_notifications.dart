import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:withme_flutter/user_add_post_page.dart';
import 'package:withme_flutter/user_edit_profile.dart';
import 'package:withme_flutter/user_home_page.dart';
import 'package:withme_flutter/user_post_view.dart';
import 'package:withme_flutter/user_profile_page.dart';
import 'package:withme_flutter/user_search_page.dart';
import 'package:withme_flutter/user_view_profile.dart';
import 'notification_model.dart';
import 'post_model.dart';
import 'user_post.dart';

class UserNotifications extends StatefulWidget{
  final String userId;
  UserNotifications({required this.userId});

  @override
  State<StatefulWidget> createState() => _UserNotifications();
}

class _UserNotifications extends State<UserNotifications>{
  late String name = '';
  late String userId = '';
  late String userAvatar = '';
  late List<NotificationModel> notificationList = [];
  int _selectedIndex = 0;
  FirebaseAuth auth = FirebaseAuth.instance;
  DatabaseReference reference = FirebaseDatabase.instance.ref().child('users');

  @override
  void initState() {
    super.initState();
    _fetchInfo();
    _fetchNotification();
  }

  Future<void> _fetchInfo() async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User? user = auth.currentUser;

    if (user != null) {
      final DatabaseReference userRef = FirebaseDatabase.instance.ref().child(
          'users/${user.uid}');
      final DatabaseReference postRef = userRef.child('posts');

      try{
        final DataSnapshot snapshot = await userRef.get();

        if (snapshot.exists) {
          final userData = snapshot.value as Map?;
          setState(() {
            userId = userData?['id'] ?? 'User not found';
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

  Future<void> _fetchNotification() async {
    DatabaseReference notificationReference =
    reference.child(widget.userId).child('notifications');

    try {
      final DatabaseEvent event = await notificationReference.once();
      if (event.snapshot.exists) {
        Map<dynamic, dynamic> notificationsData =
        event.snapshot.value as Map<dynamic, dynamic>;

        List<NotificationModel> tempNotificationsList = [];

        notificationsData.forEach((notificationId, notificationData) {
          var userData = notificationData as Map<dynamic, dynamic>;
          if (userData.containsKey('postId')) {
            NotificationModel notification = NotificationModel.Comment(
              notificationId: userData['notificationId'] ?? '',
              senderName: userData['senderName'] ?? 'Unknown',
              message: userData['message'] ?? '',
              notDate: userData['notDate'] ?? '',
              postId: userData['postId'] ?? '',
              postOwnerId: userData['postOwnerId'] ?? '',
            );
            tempNotificationsList.add(notification);
          } else if (userData.containsKey('followerId')) {
            NotificationModel notification = NotificationModel.Follow(
              notificationId: userData['notificationId'],
              followerId: userData['followerId'] ?? '',
              notDate: userData['notDate'] ?? '',
              followerName: userData['followerName'] ?? 'Unknown',
              followedId: userData['followedId'] ?? '',
            );
            tempNotificationsList.add(notification);
          }
        });

        setState(() {
          notificationList = tempNotificationsList;
        });
      } else {
        print("No notifications found for userId: ${widget.userId}");
      }
    } catch (error) {
      print("Error loading notifications: $error");
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
        MaterialPageRoute(builder: (context) => UserAddPostPage()),
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
      body: SingleChildScrollView(
        child:
        Container(
          padding: EdgeInsets.all(20),
          width: double.infinity,
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                alignment: Alignment.center,
                padding: EdgeInsets.fromLTRB(0,30,0,0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Container(
                      alignment: Alignment.centerLeft,
                      child: Column(
                        children: [
                          Image.asset('assets/withme_logo.png', height:60),
                        ],
                      ),
                    ),
                    Expanded(child: SizedBox.shrink()),
                    GestureDetector(onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => UserNotifications(userId: userId)),
                      );
                    },
                      child: Container(
                        padding: EdgeInsets.fromLTRB(0, 0, 10, 0),
                        alignment: Alignment.centerRight,
                        child: Icon(Icons.notifications),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        IconButton(
                          onPressed: (){
                            Navigator.pop(context);
                          },
                          icon: Icon(Icons.arrow_back,size: 30,),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 9,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text("Notifications", textAlign: TextAlign.center, style: TextStyle(
                          fontFamily: 'DM Serif Display',
                          fontSize: 26,
                        ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
              ListView.builder(
                primary: false,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: notificationList.length,
                itemBuilder: (context, index) {
                  NotificationModel notification = notificationList[index];
                  if (notification.type == 'comment') {
                    return ListTile(
                      leading: Icon(Icons.comment, color: Colors.black),
                      title: Text(notification.message ?? ''),
                      trailing: Text(notification.notDate ?? ''),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => UserPostView(
                              userId: notification.postOwnerId ?? '',
                              postId: notification.postId ?? '',
                            ),
                          ),
                        );
                      },
                    );
                  } else if (notification.type == 'follow') {
                    return ListTile(
                      leading: Icon(Icons.person, color: Colors.black),
                      title: Text(notification.followerName != null
                          ? '${notification.followerName} started following you.' : 'New follower!'),
                      trailing: Text(notification.notDate ?? ''),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => UserViewProfile(
                              followerId: notification.followerId ?? '',
                            ),
                          ),
                        );
                      },

                    );
                  } else {
                    return Container();
                  }
                },
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(icon: Image.asset('assets/withme_home.png',height: 30,),label: ''),
          BottomNavigationBarItem(icon: Image.asset('assets/withme_search.png',height: 30,),label: ''),
          BottomNavigationBarItem(icon: Image.asset('assets/withme_newpost.png',height: 30,),label: ''),
          BottomNavigationBarItem(icon: CircleAvatar(
            backgroundColor: Colors.grey,
            radius: 20,
            backgroundImage: userAvatar.isNotEmpty ?
            NetworkImage(userAvatar) : AssetImage('assets/small_logo.png'),
          ), label: ''),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }
}