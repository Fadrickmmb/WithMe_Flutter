import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:withme_flutter/user_add_post_page.dart';
import 'package:withme_flutter/user_home_page.dart';
import 'package:withme_flutter/user_profile_page.dart';
import 'package:withme_flutter/user_search_page.dart';
import 'post_model.dart';
import 'user_post.dart';

class UserViewProfile extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => _UserViewProfile();
}

class _UserViewProfile extends State<UserViewProfile>{
  late String name = '';
  late String followers = '';
  late String posts = '';
  late String following = '';
  late String userBio = '';
  late String userAvatar = '';
  late String postId = '';
  late String userId = '';
  late String postDate = '';
  late String location = '';
  late int commentsNumber = 0;
  late int yummys = 0;
  String followStatus = 'Follow';
  int _selectedIndex = 0;
  late List postList = [];

  @override
  void initState() {
    super.initState();
    _fetchInfo();
    _fetchPost();
    checkFollowStatus();
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
            name = userData?['name'] ?? 'User not found';
            followers = userData?['numberFollowers'] ?? '0';
            following = userData?['numberFollowing'] ?? '0';
            userBio = userData?['userBio'] ?? 'User';
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

  Future<void> _fetchPost() async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User? user = auth.currentUser;

    if (user != null) {
      final DatabaseReference postRef = FirebaseDatabase.instance.ref().child(
          'users/${user.uid}/posts');
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
                  comments: {},
                );
              }).toList().cast<Post>() ?? [];
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

  Future<void> checkFollowStatus() async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User? user = auth.currentUser;
    final snapshot = await FirebaseDatabase.instance.ref()
        .child('users')
        .child(user!.uid)
        .child("following")
        .child(userId)
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
        .child(userId);
    final followersReference = FirebaseDatabase.instance.ref()
        .child('users')
        .child(userId)
        .child("followers")
        .child(user!.uid);

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
      setState(() {
        followStatus = "Unfollow";
      });
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

          //Header
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              //header
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
                      child: Image.asset('assets/withme_yummy.png', height:30),
                    ),
                    Container(
                      alignment: Alignment.centerRight,
                      child: Image.asset('assets/withme_comment.png', height:30),
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
                  backgroundImage: userAvatar.isNotEmpty ?
                  NetworkImage(userAvatar) : AssetImage('assets/small_logo.png'),
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
                padding: EdgeInsets.all(20),
                child: Text(userBio,style: TextStyle(
                  fontSize: 20,
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
                          Text(followers,style: TextStyle(
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
                          Text(posts,style: TextStyle(
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
                          Text(following,style: TextStyle(
                            fontSize: 20,
                            fontFamily: 'DM Serif Display',
                          ),
                          ),
                          Text('Yummys',style: TextStyle(
                            fontSize: 16,
                          ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton(onPressed: changeFollowStatus,
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
                child: Text(followStatus,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
              ),
              ListView.builder(
                primary: false,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount:postList.length,
                itemBuilder: (context,index){
                  final post = postList[index];
                  return UserPost.partial(
                    name: post.name ?? 'Unknown',
                    postImageUrl: post.postImageUrl ?? '',
                    userPhotoUrl: post.userPhotoUrl ?? '',
                    postId: postId ??'',userId: userId ?? '',
                    comments: commentsNumber,
                    postDate: postDate,
                    location: location,
                    yummys: yummys,);
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
          BottomNavigationBarItem(icon: Icon(Icons.person,size: 36,),label: ''),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }
}

