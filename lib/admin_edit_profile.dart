import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:withme_flutter/auth_login.dart';
import 'package:withme_flutter/user_add_post_page.dart';
import 'package:withme_flutter/user_home_page.dart';
import 'package:withme_flutter/user_profile_page.dart';
import 'package:withme_flutter/user_search_page.dart';

import 'admin_add_post_page.dart';
import 'admin_home_page.dart';
import 'admin_profile_page.dart';
import 'admin_search_page.dart';
import 'mod_home_page.dart';

class AdminEditProfile extends StatefulWidget {
  @override
  _AdminEditProfilePageState createState() => _AdminEditProfilePageState();
}

class _AdminEditProfilePageState extends State<AdminEditProfile> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String userAvatar = '';
  String userId = '';
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  int _selectedIndex = 0;

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

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<String?> _uploadImage(File imageFile) async {
    try {
      final storageRef = FirebaseStorage.instance.ref().child('user_profile_pictures/$userId.jpg');
      await storageRef.putFile(imageFile);
      return await storageRef.getDownloadURL();
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  Future<void> _updateUserProfile() async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User? user = auth.currentUser;

    if (user != null) {
      String? imageUrl;
      if (_imageFile != null) {
        imageUrl = await _uploadImage(_imageFile!);
      }

      final DatabaseReference userRef = FirebaseDatabase.instance.ref().child('users/${user.uid}');
      await userRef.update({
        'name': _nameController.text,
        'userBio': _bioController.text,
        'userPhotoUrl': imageUrl ?? userAvatar,
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Profile updated successfully!")));
    }

    if (_passwordController.text.isNotEmpty) {
      try {
        await user!.updatePassword(_passwordController.text.trim());
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Password updated successfully!')),
        );
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating password: $error')),
        );
      }
    }

    Navigator.pop(context);
  }

  Future<void> _logoutUser() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => AuthLogin()),
          (route) => false,
    );
  }

  Future<void> _onItemTapped(int index) async {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 0) {
      final FirebaseAuth auth = FirebaseAuth.instance;
      final User? user = auth.currentUser;

      if (user != null) {
        try {
          final DatabaseReference adminRef = FirebaseDatabase.instance.ref().child('admin/${user.uid}');
          final DataSnapshot adminSnapshot = await adminRef.get();

          if (adminSnapshot.exists) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AdminHomePage()),
            );
            return;
          }

          final DatabaseReference modRef = FirebaseDatabase.instance.ref().child('mod/${user.uid}');
          final DataSnapshot modSnapshot = await modRef.get();

          if (modSnapshot.exists) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ModHomePage()),
            );
            return;
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("User role not found.")),
          );

        } catch (e) {
          print("Error checking user role: $e");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Failed to load user role.")),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("User not logged in.")),
        );
      }
    } else if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => AdminSearchPage()),
      );
    } else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => AdminAddPostPage()),
      );
    } else if (index == 3) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => AdminProfilePage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile'),
        backgroundColor: Colors.grey,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            CircleAvatar(
              backgroundColor: Colors.grey,
              radius: 50,
              backgroundImage: _imageFile != null
                  ? FileImage(_imageFile!)
                  : userAvatar.isNotEmpty
                  ? NetworkImage(userAvatar)
                  : AssetImage('assets/small_logo.png') as ImageProvider,
            ),
            TextButton(
              onPressed: _pickImage,
              child: Text('Change Profile Picture'),
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
              maxLines: 1,
            ),
            SizedBox(height: 20),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: "New Password",
                border: OutlineInputBorder(),
              ),
              obscureText: true,
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
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: Image.asset('assets/withme_home.png', height: 30,),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Image.asset('assets/withme_search.png', height: 30,),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Image.asset('assets/withme_newpost.png', height: 30,),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: CircleAvatar(
              backgroundColor: Colors.grey,
              radius: 20,
              backgroundImage: userAvatar.isNotEmpty
                  ? NetworkImage(userAvatar)
                  : AssetImage('assets/small_logo.png'),
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
}
