import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:withme_flutter/report_model.dart';
import 'package:withme_flutter/user_add_post_page.dart';
import 'package:withme_flutter/user_home_page.dart';
import 'package:withme_flutter/user_post_view.dart';
import 'package:withme_flutter/user_profile_page.dart';
import 'package:withme_flutter/user_search_page.dart';
import 'post_model.dart';
import 'user_post.dart';

class UserViewProfile extends StatefulWidget{
  final String followerId;
  UserViewProfile({required this.followerId});

  @override
  State<StatefulWidget> createState() => _UserViewProfile();
}

class _UserViewProfile extends State<UserViewProfile>{
  late String name = '';
  late String followerBio = '';
  late String followerAvatar = '';
  late String userAvatar = '';
  late int numberFollowers = 0;
  late int numberFollowing = 0;
  late int numberPosts = 0;
  late String postId = '';
  late String followerId = '';
  late String userId = '';
  late String postDate = '';
  late String location = '';
  late int commentsNumber = 0;
  late int yummys = 0;
  String followStatus = 'Follow';
  String reportUserStatus = 'Report user';
  bool isReported = true;
  int _selectedIndex = 0;
  late List postList = [];

  @override
  void initState() {
    super.initState();
    _fetchInfo();
    _fetchPost();
    _fetchUserAvatar();
    _fetchNumberFollowers();
    _fetchNumberFollowing();
    checkFollowStatus();
    _checkUserReported();
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

  Future<void> _fetchInfo() async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User? user = auth.currentUser;

    if (user != null) {
      final DatabaseReference userRef = FirebaseDatabase.instance.ref().child(
          'users/${widget.followerId}');
      final DatabaseReference postRef = userRef.child('posts');

      try{
        final DataSnapshot snapshot = await userRef.get();

        if (snapshot.exists) {
          final userData = snapshot.value as Map?;
          setState(() {
            followerId = userData?['id'] ?? 'User not found';
            name = userData?['name'] ?? 'User not found';
            followerBio = userData?['userBio'] ?? 'User';
            followerAvatar = userData?['userPhotoUrl'] ?? '';
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
          SnackBar(content: Text("User not found."))
      );
    }
  }

  Future<void> _fetchPost() async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User? user = auth.currentUser;

    if (user != null) {
      final DatabaseReference postRef = FirebaseDatabase.instance.ref().child(
          'users/${widget.followerId}/posts');
      try{
        final DataSnapshot postsSnapshot = await postRef.get();
        if (postsSnapshot.exists) {
          final postsData = postsSnapshot.value as Map?;
          if(postsData != null) {
            setState(() {
              postList = postsData?.values.map((postData) {
                return Post.full(
                  name: postData['name'],
                  location: postData['location'],
                  postImageUrl: postData['postImageUrl'],
                  postDate: postData['postDate'],
                  yummys: postData['yummys'],
                  commentsNumber: postData['commentsNumber'],
                  userPhotoUrl: postData['userPhotoUrl'],
                  postId: postData['postId'],
                  userId: postData['userId'],
                  content: postData['content'],
                );
              }).toList().cast<Post>() ?? [];
              numberPosts = postsData.length;
            });
            print('Postlist length: ${postList.length}');

          } else {
            print("No posts found for user.");
          }
        }
      } catch(e) {
        print("error fetching user data $e");
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Failed to load user's posts."))
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("user not logged in."))
      );
    }
  }

  Future<void> _fetchNumberFollowers() async{
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User? user = auth.currentUser;

    if (user != null) {
      final DatabaseReference followersRef = FirebaseDatabase.instance.ref()
          .child('users/${widget.followerId}/followers');

      try {
        final DataSnapshot snapshot = await followersRef.get();
        int followersCount = 0;
        if (snapshot.exists) {
          followersCount = snapshot.children.length;
        }
        setState(() {
          numberFollowers = followersCount;
        });
      } catch (e) {
        print("Error fetching number of followers: $e");
      }
    }
  }

  Future<void> _fetchNumberFollowing() async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User? user = auth.currentUser;

    if (user != null) {
      final DatabaseReference followingRef = FirebaseDatabase.instance.ref()
          .child('users/${widget.followerId}/following');

      try {
        final DataSnapshot snapshot = await followingRef.get();
        int followingCount = 0;
        if (snapshot.exists) {
          followingCount = snapshot.children.length;
        }
        setState(() {
          numberFollowing = followingCount;
        });
      } catch (e) {
        print("Error fetching number of following: $e");
      }
    }
  }

  Future<void> checkFollowStatus() async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User? user = auth.currentUser;
    final snapshot = await FirebaseDatabase.instance.ref()
        .child('users')
        .child(user!.uid)
        .child("following")
        .child(widget.followerId)
        .once();

    if (snapshot.snapshot.exists) {
      setState(() {
        followStatus = "Unfollow";
      });
    } else {
      setState(() {
        followStatus = "Follow";
      });
    }
  }

  Future<void> changeFollowStatus() async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User? user = auth.currentUser;
    final followingReference = FirebaseDatabase.instance.ref()
        .child('users')
        .child(user!.uid)
        .child("following")
        .child(widget.followerId);
    final followersReference = FirebaseDatabase.instance.ref()
        .child('users')
        .child(userId)
        .child("followers")
        .child(user!.uid);
    final DatabaseReference notificationRef = FirebaseDatabase.instance
        .ref().child('users/${followerId}/notifications');
    final DateTime today = DateTime.now();
    final String formattedDate = "${today.year.toString()}-${today.month
        .toString().padLeft(2,'0')}-${today.day.toString().padLeft(2,'0')}";

    final snapshot = await followingReference.once();
    if (snapshot.snapshot.exists) {
      await followingReference.remove();
      await followersReference.remove();
      setState(() {
        followStatus = "Follow";
      });
    } else {
      await followingReference.set(true);
      await followersReference.set(true);

      String? notificationId = notificationRef.push().key;
      await notificationRef.child(notificationId!).set({
        'notificationId': notificationId ?? "",
        'followerId': userId,
        'notDate': formattedDate,
        'followerName': user.displayName ?? 'Anonymous',
        'message': '${user.displayName ?? 'Anonymous'} started following you.',
      });

      setState(() {
        followStatus = "Unfollow";
      });
    }
  }

  void _showUserReportDialog(BuildContext context) {
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
                    icon: Icon(Icons.close),
                  ),
                ],
              ),
              Icon(Icons.warning_amber,color: Colors.white,),
              SizedBox(height: 20),
              Text("Are you sure you want to report this user?",style: TextStyle(
                color: Colors.white,
              ),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      await _reportUser(context);
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

  Future<void> _reportUser(BuildContext context) async{
    final DatabaseReference reportUserRef = FirebaseDatabase.instance
        .ref().child('reportedUsers');
    final String? reportId = reportUserRef.push().key;
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User? user = auth.currentUser;

    if (reportId != null) {
      final Report reportUser = Report.reportUser(
        reportId: reportId,
        userId: followerId,
        userReportingId: user?.uid,
      );

      try {
        await reportUserRef.child(reportId).set({
          'reportId': reportUser.reportId,
          'userId': reportUser.userId,
          'userReportingId': reportUser.userReportingId,
        });
        setState(() {
          reportUserStatus = "Reported.";
          isReported = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Post reported successfully.")),
        );
        Navigator.of(context).pop();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error reporting post: $e")),
        );
      }
    }
  }

  Future<void> _checkUserReported() async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User? user = auth.currentUser;

    if (user != null) {
      final Query reportUserRef = FirebaseDatabase.instance.ref()
          .child('reportedUsers').orderByChild('userReportingId')
          .equalTo(user.uid);

      try {
        final DataSnapshot snapshot = await reportUserRef.get();
        bool alreadyReported = false;

        if (snapshot.exists) {
          final reports = snapshot.value as Map<dynamic, dynamic>?;
          if (reports != null) {
            for (var report in reports.values) {
              if (report['userId'] == widget.followerId) {
                alreadyReported = true;
                break;
              }
            }
          }
        }

        setState(() {
          isReported = !alreadyReported;
          reportUserStatus = alreadyReported ? "Reported" : "Report user";
        });

      } catch (e) {
        print("Error checking if user is already reported: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to check report status.")),
        );
      }
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
                    Container(
                      padding: EdgeInsets.fromLTRB(0,0,10,0),
                      alignment: Alignment.centerRight,
                      child: Icon(Icons.notifications),
                    ),
                  ],
                ),
              ),
              //insert content here
              Container(
                alignment: Alignment.center,
                padding: EdgeInsets.fromLTRB(0, 50, 0, 0),
                child: CircleAvatar(
                  backgroundColor: Colors.grey,
                  radius: 70,
                  backgroundImage: followerAvatar.isNotEmpty ?
                  NetworkImage(followerAvatar) : AssetImage('assets/small_logo.png'),
                ),
              ),
              SizedBox(height: 20,),
              Container(
                padding: EdgeInsets.all(20),
                child: Text(name.toUpperCase(),style: TextStyle(
                  fontSize: 26,
                  fontFamily: 'DM Serif Display',
                ),
                ),
              ),
              Container(
                padding: EdgeInsets.fromLTRB(0, 10, 0, 30),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          Text('$numberFollowers',style: TextStyle(
                            fontSize: 20,
                            fontFamily: 'DM Serif Display',
                          ),
                          ),
                          Text('Followers',style: TextStyle(
                            fontSize: 16,
                          ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          Text('$numberPosts',style: TextStyle(
                            fontSize: 20,
                            fontFamily: 'DM Serif Display',
                          ),
                          ),
                          Text('Posts',style: TextStyle(
                            fontSize: 16,
                          ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          Text('$numberFollowing',style: TextStyle(
                            fontSize: 20,
                            fontFamily: 'DM Serif Display',
                          ),
                          ),
                          Text('Following',style: TextStyle(
                            fontSize: 16,
                          ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Text('Bio',style: TextStyle(
                fontSize: 26,
                fontFamily: 'DM Serif Display',
              ),
              ),
              SizedBox(height: 20,),
              Text(followerBio,style: TextStyle(
                fontSize: 20,
                fontFamily: 'DM Serif Display',
              ),
              ),
              SizedBox(height: 60,),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(onPressed: changeFollowStatus,
                    style: ButtonStyle(
                      backgroundColor: WidgetStatePropertyAll<Color>(Color(0xFF1A2F31)),
                      shape: WidgetStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      padding: WidgetStateProperty.all<EdgeInsets>(EdgeInsets.all(10),),
                      fixedSize: MaterialStateProperty.all<Size>(Size(150.0, 60.0),),
                    ),
                    child: Text(followStatus,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  SizedBox(width: 30),
                  ElevatedButton(onPressed:() {
                      if(isReported){
                        _showUserReportDialog(context);
                      }
                    },
                    style: ButtonStyle(
                    backgroundColor: WidgetStatePropertyAll<Color>(Color(0xFF1A2F31)),
                    shape: WidgetStateProperty.all(
                    RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                    ),
                    ),
                    padding: WidgetStateProperty.all<EdgeInsets>(EdgeInsets.all(10),),
                    fixedSize: MaterialStateProperty.all<Size>(Size(150.0, 60.0),),
                    ),
                    child: Text(reportUserStatus,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18
                      ),
                    ),
                  ),
                ],
              ),
              ListView.builder(
                primary: false,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: postList.length,
                itemBuilder: (context, index) {
                  final post = postList[index];
                  print('Post ID: ${post.postId}');

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => UserPostView(
                            userId: post.userId,
                            postId: post.postId,
                          ),
                        ),
                      );
                    },
                    child: UserPost.partial(
                      postId: post.postId ?? '',
                      userId: post.userId ?? '',
                      name: post.name ?? 'Unknown',
                      postImageUrl: post.postImageUrl ?? 'assets/small.logo.png',
                      userPhotoUrl: post.userPhotoUrl ?? 'assets/small_logo.png',
                      yummys: post.yummys ?? 0,
                      location: post.location ?? 'No location provided',
                      postDate: post.postDate ?? 'No date provided',
                      comments: post.commentsNumber ?? 0,
                    ),
                  );
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
            NetworkImage(userAvatar) :
            AssetImage('assets/small_logo.png'),
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

