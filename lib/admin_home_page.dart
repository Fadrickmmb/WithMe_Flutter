import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'admin_create_user.dart';
import 'admin_add_post_page.dart';
import 'admin_profile_page.dart';
import 'admin_search_page.dart';
import 'admin_dashboard.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  _AdminHomePageState createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _adminRef = FirebaseDatabase.instance.ref().child('admin');
  List<Map<String, dynamic>> _posts = [];
  bool _isLoading = true;
  int _selectedIndex = 0;
  String userAvatar = '';

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _fetchPosts();
    _fetchAdminAvatar();
  }

  Future<void> _fetchPosts() async {
    try {
      final User? currentUser = _auth.currentUser;
      if (currentUser == null) return;

      final DataSnapshot snapshot = await _adminRef.child(currentUser.uid).child('posts').get();

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

  Future<void> _fetchAdminAvatar() async {
    try {
      final User? currentUser = _auth.currentUser;
      if (currentUser == null) return;

      final DataSnapshot snapshot = await _adminRef.child(currentUser.uid).get();

      if (snapshot.exists) {
        final Map<dynamic, dynamic> userData = snapshot.value as Map<dynamic, dynamic>;
        setState(() {
          userAvatar = userData['userPhotoUrl'] ?? '';
        });
      }
    } catch (e) {
      print("Error fetching admin avatar: $e");
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
          MaterialPageRoute(builder: (context) => AdminSearchPage()),
        );
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AdminAddPostPage()),
        );
        break;
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AdminProfilePage()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Home'),
        backgroundColor: Colors.grey,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(
                'ADMIN HOME PAGE',
                style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20.0),
              Expanded(
                child: _isLoading
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
              ),
              SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AdminCreateUserScreen()),
                  );
                },
                child: Text('To Create User'),
              ),
              SizedBox(height: 10.0),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AdminDashboard()),
                  );
                },
                child: Text('To Dashboard'),
              ),
            ],
          ),
        ),
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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post['userName'] ?? 'Unknown User',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Text(post['location'] ?? ''),
                  ],
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
                _buildActionButton(Icons.thumb_up, "Like", () {
                  print("Like button pressed for post: ${post['content']}");
                }),
                _buildActionButton(Icons.comment, "Comment", () {
                  print("Comment button pressed for post: ${post['content']}");
                }),
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