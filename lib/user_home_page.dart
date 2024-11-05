import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:withme_flutter/user_add_post_page.dart';
import 'package:withme_flutter/user_profile_page.dart';
import 'package:withme_flutter/user_search_page.dart';

class UserHomePage extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<UserHomePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _userRef = FirebaseDatabase.instance.ref().child('users');

  List<Map<String, dynamic>> _posts = [];
  bool _isLoading = true;
  int _selectedIndex = 0;
  String userAvatar = '';

  @override
  void initState() {
    super.initState();
    _fetchPosts();
    _fetchUserAvatar();
  }

  Future<void> _fetchPosts() async {
    try {
      final User? currentUser = _auth.currentUser;
      if (currentUser == null) return;

      final DatabaseReference userPostsRef = _userRef.child(currentUser.uid).child('posts');
      final DataSnapshot snapshot = await userPostsRef.get();

      if (snapshot.exists) {
        final Map<dynamic, dynamic> postsData = snapshot.value as Map<dynamic, dynamic>;

        List<Map<String, dynamic>> posts = postsData.values.map((post) {
          return Map<String, dynamic>.from(post as Map);
        }).toList();

        setState(() {
          _posts = posts;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching posts: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchUserAvatar() async {
    try {
      final User? currentUser = _auth.currentUser;
      if (currentUser == null) return;

      final DatabaseReference userRef = _userRef.child(currentUser.uid);
      final DataSnapshot snapshot = await userRef.get();

      if (snapshot.exists) {
        final Map<dynamic, dynamic> userData = snapshot.value as Map<dynamic, dynamic>;
        setState(() {
          userAvatar = userData['userPhotoUrl'] ?? '';
        });
      }
    } catch (e) {
      print("Error fetching user avatar: $e");
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => UserSearchPage()),
        );
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => UserAddPostPage()),
        );
        break;
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => UserProfilePage()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        backgroundColor: Colors.grey,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _posts.isEmpty
          ? Center(child: Text("No posts available"))
          : ListView.builder(
        itemCount: _posts.length,
        itemBuilder: (context, index) {
          final post = _posts[index];
          return _buildPostCard(post);
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: Image.asset('assets/withme_home.png', height: 30),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Image.asset('assets/withme_search.png', height: 30),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Image.asset('assets/withme_newpost.png', height: 30),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: CircleAvatar(
              backgroundColor: Colors.grey,
              radius: 20,
              backgroundImage: userAvatar.isNotEmpty
                  ? NetworkImage(userAvatar)
                  : AssetImage('assets/small_logo.png') as ImageProvider,
            ),
            label: '',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }

  Widget _buildPostCard(Map<String, dynamic> post) {
    return Card(
      margin: EdgeInsets.all(10),
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: post['userPhotoUrl'] != null
                      ? NetworkImage(post['userPhotoUrl'])
                      : AssetImage('assets/small_logo.png') as ImageProvider,
                  radius: 25,
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post['userName'] ?? 'Unknown User',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        post['location'] ?? '',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Text(post['content'] ?? ''),
            SizedBox(height: 10),
            post['postImageUrl'] != null
                ? Image.network(post['postImageUrl'])
                : SizedBox.shrink(),
            SizedBox(height: 10),
            Align(
              alignment: Alignment.bottomRight,
              child: Text(
                post['postDate'] ?? '',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Flexible(
                  child: _buildActionButton(Icons.thumb_up, "Like", () {
                    print("Like button pressed for post: ${post['content']}");
                  }),
                ),
                Flexible(
                  child: _buildActionButton(Icons.comment, "Comment", () {
                    print("Comment button pressed for post: ${post['content']}");
                  }),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label, VoidCallback onPressed) {
    return InkWell(
      onTap: onPressed,
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey),
          SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}