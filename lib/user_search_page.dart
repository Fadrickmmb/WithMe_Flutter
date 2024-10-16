import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class UserSearchPage extends StatefulWidget {
  const UserSearchPage({super.key});

  @override
  State<UserSearchPage> createState() => _UserSearchPageState();
}

class _UserSearchPageState extends State<UserSearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref("users");

  String _userName = '';
  String _userUid = '';

  Future<void> _searchUser() async {
    try {
      DatabaseEvent event = await _databaseRef.limitToFirst(1).once();
      if (event.snapshot.value != null) {
        Map<String, dynamic> userMap = Map<String, dynamic>.from(event.snapshot.value as Map);
        String firstUid = userMap.keys.first;
        String firstUserName = userMap[firstUid]['name'];

        setState(() {
          _userName = firstUserName;
          _userUid = firstUid;
        });
      } else {
        setState(() {
          _userName = 'No users found';
          _userUid = '';
        });
      }
    } catch (e) {
      setState(() {
        _userName = 'Error occurred: $e';
        _userUid = '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Search'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Search User',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _searchUser,
              child: const Text('Search'),
            ),
            const SizedBox(height: 20),
            Text(
              _userName.isNotEmpty
                  ? 'User: $_userName\nUID: $_userUid'
                  : 'No user found',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
