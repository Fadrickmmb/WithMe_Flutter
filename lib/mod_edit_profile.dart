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

class ModEditProfile extends StatefulWidget {
  @override
  _ModEditProfileState createState() => _ModEditProfileState();
}

class _ModEditProfileState extends State<ModEditProfile> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String modAvatar = '';
  String modId = '';
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _fetchModData();
  }

  Future<void> _fetchModData() async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User? user = auth.currentUser;

    if (user != null) {
      final DatabaseReference modRef = FirebaseDatabase.instance.ref().child('mod/${user.uid}');
      final DataSnapshot snapshot = await modRef.get();

      if (snapshot.exists) {
        final modData = snapshot.value as Map?;
        setState(() {
          modId = user.uid;
          _nameController.text = modData?['name'] ?? 'Moderator not found';
          _bioController.text = modData?['userBio'] ?? '';
          modAvatar = modData?['userPhotoUrl'] ?? '';
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
      final storageRef = FirebaseStorage.instance.ref().child('mod_profile_pictures/$modId.jpg');
      await storageRef.putFile(imageFile);
      return await storageRef.getDownloadURL();
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  Future<void> _updateModProfile() async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User? user = auth.currentUser;

    if (user != null) {
      String? imageUrl;
      if (_imageFile != null) {
        imageUrl = await _uploadImage(_imageFile!);
      }

      final DatabaseReference modRef = FirebaseDatabase.instance.ref().child('mod/${user.uid}');
      await modRef.update({
        'name': _nameController.text,
        'userBio': _bioController.text,
        'userPhotoUrl': imageUrl ?? modAvatar,
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Moderator profile updated successfully!")));
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

  Future<void> _logoutMod() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => AuthLogin()),
          (route) => false,
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => UserHomePage()),
        );
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => UserSearchPage()),
        );
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => UserAddPostPage()),
        );
        break;
      case 3:
        Navigator.pushReplacement(
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
                  : modAvatar.isNotEmpty
                  ? NetworkImage(modAvatar)
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
              onPressed: _updateModProfile,
              child: Text('Save Changes'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 10),
                textStyle: TextStyle(fontSize: 16),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _logoutMod,
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
              backgroundImage: modAvatar.isNotEmpty
                  ? NetworkImage(modAvatar)
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