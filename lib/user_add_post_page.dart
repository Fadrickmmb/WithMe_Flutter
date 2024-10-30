import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';

class UserAddPostPage extends StatefulWidget {
  @override
  _UserAddPostPageState createState() => _UserAddPostPageState();
}

class _UserAddPostPageState extends State<UserAddPostPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Reference _storageRef = FirebaseStorage.instance.ref().child('posts');
  DatabaseReference getUserPostRef(String userId) {
    return FirebaseDatabase.instance.ref().child('users/$userId/posts');
  }

  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  User? _currentUser;
  String _userName = '';
  String _userPhotoUrl = '';

  @override
  void initState() {
    super.initState();
    _currentUser = _auth.currentUser;
    _fetchUserInfo();
  }

  Future<void> _fetchUserInfo() async {
    if (_currentUser != null) {
      final DatabaseReference userRef = FirebaseDatabase.instance.ref().child('users/${_currentUser!.uid}');
      final DataSnapshot snapshot = await userRef.get();
      if (snapshot.exists) {
        final userData = snapshot.value as Map;
        setState(() {
          _userName = userData['name'] ?? 'User';
          _userPhotoUrl = userData['userPhotoUrl'] ?? '';
        });
      }
    }
  }

  Future<void> _selectPhoto() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _createPost() async {
    if (_locationController.text.isEmpty || _contentController.text.isEmpty || _imageFile == null) {
      Fluttertoast.showToast(msg: "Please complete all fields and select a photo");
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final String postId = DateTime.now().millisecondsSinceEpoch.toString();
    final Reference postImageRef = _storageRef.child('$postId.jpg');

    try {
      final UploadTask uploadTask = postImageRef.putFile(_imageFile!);
      final TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => {});
      final String postImageUrl = await taskSnapshot.ref.getDownloadURL();
      final DatabaseReference userPostRef = getUserPostRef(_currentUser!.uid).child(postId);

      final postData = {
        'content': _contentController.text,
        'location': _locationController.text,
        'postImageUrl': postImageUrl,
        'userId': _currentUser!.uid,
        'userName': _userName,
        'userPhotoUrl': _userPhotoUrl,
        'postDate': DateTime.now().toString(),
        'yummys': 0,
        'commentsNumber': 0,
      };

      await userPostRef.set(postData);

      Fluttertoast.showToast(msg: "Post created successfully!");
      _clearFields();
    } catch (e) {
      Fluttertoast.showToast(msg: "Failed to create post");
      print('Error: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _clearFields() {
    setState(() {
      _locationController.clear();
      _contentController.clear();
      _imageFile = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Post'),
        backgroundColor: Colors.grey,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.grey,
                  radius: 25,
                  backgroundImage: _userPhotoUrl.isNotEmpty
                      ? NetworkImage(_userPhotoUrl)
                      : AssetImage('assets/small_logo.png') as ImageProvider,
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _userName,
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 20),

            TextField(
              controller: _locationController,
              decoration: InputDecoration(
                labelText: "Location",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),

            TextField(
              controller: _contentController,
              decoration: InputDecoration(
                labelText: "Content",
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            SizedBox(height: 20),

            _imageFile != null
                ? Image.file(_imageFile!)
                : IconButton(
              icon: Icon(Icons.add_a_photo),
              onPressed: _selectPhoto,
              iconSize: 50,
            ),
            SizedBox(height: 20),

            ElevatedButton(
              onPressed: _createPost,
              child: Text('Post'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                textStyle: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}