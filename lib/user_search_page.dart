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
    String searchText = _searchController.text.trim().toLowerCase();

    if (searchText.length < 5) {
      setState(() {
        _userName = 'Please enter at least 5 characters';
        _userUid = '';
      });
      return;
    }

    try {

      DatabaseEvent event = await _databaseRef.once();

      if (event.snapshot.value != null) {
        Map<String, dynamic> usersMap = Map<String, dynamic>.from(event.snapshot.value as Map);


        String? foundUid;
        String? foundName;
        usersMap.forEach((uid, userData) {
          String userName = (userData['name'] as String).toLowerCase();
          if (userName.startsWith(searchText)) {
            foundUid = uid;
            foundName = userData['name'];
            return;
          }
        });

        if (foundUid != null && foundName != null) {
          setState(() {
            _userName = foundName!;
            _userUid = foundUid!;
          });
        } else {
          setState(() {
            _userName = 'No matching user found';
            _userUid = '';
          });
        }
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
