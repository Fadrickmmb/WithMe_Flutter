import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:withme_flutter/auth_login.dart';

class UserEditProfile extends StatefulWidget {
  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<UserEditProfile> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  String userAvatar = '';
  String userId = '';

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User? user = auth.currentUser;

    if (user != null) {
      final DatabaseReference userRef = FirebaseDatabase.instance.ref().child('users/${user.uid}');
      final DataSnapshot snapshot = await userRef.get();

      if (snapshot.exists) {
        final userData = snapshot.value as Map?;
        setState(() {
          userId = user.uid;
          _nameController.text = userData?['name'] ?? 'User not found';
          _bioController.text = userData?['userBio'] ?? '';
          userAvatar = userData?['userPhotoUrl'] ?? '';
        });
      }
    }
  }

  Future<void> _updateUserProfile() async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User? user = auth.currentUser;

    if (user != null) {
      final DatabaseReference userRef = FirebaseDatabase.instance.ref().child('users/${user.uid}');
      await userRef.update({
        'name': _nameController.text,
        'userBio': _bioController.text,
        'userPhotoUrl': userAvatar,
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Profile updated successfully!")));
      Navigator.pop(context);
    }
  }

  Future<void> _logoutUser() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => AuthLogin()),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile'),
        backgroundColor: Colors.grey,
        // actions: [
        //   IconButton(
        //     icon: Icon(Icons.logout),
        //     onPressed: _logoutUser,
        //   ),
        // ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            CircleAvatar(
              backgroundColor: Colors.grey,
              radius: 50,
              backgroundImage: userAvatar.isNotEmpty
                  ? NetworkImage(userAvatar)
                  : AssetImage('assets/small_logo.png') as ImageProvider,
            ),
            SizedBox(height: 20),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: "Name",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _bioController,
              decoration: InputDecoration(
                labelText: "Bio",
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _updateUserProfile,
              child: Text('Save Changes'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 10),
                textStyle: TextStyle(fontSize: 16),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _logoutUser,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 10),
                textStyle: TextStyle(fontSize: 16),
              ),
              child: Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}



