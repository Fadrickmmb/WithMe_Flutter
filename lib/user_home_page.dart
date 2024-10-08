

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:withme_flutter/user_add_post_page.dart';
import 'package:withme_flutter/user_search_page.dart';
import 'package:withme_flutter/user_profile_page.dart';

class UserHomePage extends StatefulWidget {
  @override
  _UserHomePageState createState() => _UserHomePageState();
}

class _UserHomePageState extends State<UserHomePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    UserHomePage(),
    UserSearchPage(),
    UserAddPostPage(),
    UserProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => _pages[_selectedIndex]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('posts').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No posts available.'));
          }

          final posts = snapshot.data!.docs;

          return ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];
              final imageUrl = post['imageUrl'];
              final description = post['description'];

              return Card(
                margin: EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (imageUrl != null)
                      Image.network(imageUrl, height: 200, width: double.infinity, fit: BoxFit.cover),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Text(description ?? '', style: TextStyle(fontSize: 16)),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => UserAddPostPage()),
          );
        },
        child: Icon(Icons.add),
        tooltip: 'Add Post',
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: Image.asset('assets/withme_home.png', height: 30),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Image.asset('assets/withme_search.png', height: 30),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Image.asset('assets/withme_newpost.png', height: 30),
            label: 'Add Post',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person, size: 36),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }
}



