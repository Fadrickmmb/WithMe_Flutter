import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:withme_flutter/user_add_post_page.dart';
import 'package:withme_flutter/user_edit_profile.dart';
import 'package:withme_flutter/user_home_page.dart';
import 'package:withme_flutter/user_post_view.dart';
import 'package:withme_flutter/user_profile_page.dart';
import 'package:withme_flutter/user_search_page.dart';
import 'post_model.dart';
import 'user_post.dart';

class UserEditPost extends StatefulWidget{
  final String postId;
  final String userId;

  UserEditPost({required this.postId, required this.userId});

  @override
  State<StatefulWidget> createState() => _UserEditPost();
}

class _UserEditPost extends State<UserEditPost>{
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _userReference = FirebaseDatabase.instance
      .ref().child('users');
  final Reference _storageReference = FirebaseStorage.instance
      .ref().child("post_images");
  TextEditingController _editLocationController = TextEditingController();
  TextEditingController _editContentController = TextEditingController();
  File? _image;
  final picker = ImagePicker();
  String? _downloadUrl;
  late String userAvatar = '';
  late String postId = '';
  late String userId = '';
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _fetchInfo();
    _fetchPostInfo();
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

  Future<void> _fetchPostInfo() async {
    final DatabaseReference postRef = FirebaseDatabase.instance.ref().child('users/${widget.userId}/posts/${widget.postId}');

    try {
      final DataSnapshot snapshot = await postRef.get();
      if (snapshot.exists) {
        final postData = snapshot.value as Map?;
        if(postData != null){
          setState(() {
            _editLocationController.text = postData['location'] ?? '';
            _editContentController.text = postData['content'] ?? '';
            _downloadUrl = postData['postImageUrl'];
          });
        }
      } else {
        print('Post not found.');
      }
    } catch (e) {
      print("Error fetching post detail: $e");
    }
  }

  Future<void> _saveEditedPost() async {
    final user = _auth.currentUser;
    if(user != null) {
      DatabaseReference postReference = _userReference
          .child(user.uid).child("posts").child(widget.postId);
      Map<String, Object> editedPost = {
        "location": _editLocationController.text,
        "content": _editContentController.text,
      };

      if(_image != null){
        Reference fileReference = _storageReference.child("${widget.postId}.jpg");
        UploadTask uploadTask = fileReference.putFile(_image!);
        TaskSnapshot snapshot = await uploadTask;
        String downloadUrl = await snapshot.ref.getDownloadURL();
        editedPost['postImageUrl'] = downloadUrl;
      }

      await postReference.update(editedPost);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Post updated successfuly."),
        ),
      );
      Navigator.pop(context);
    }
  }

  Future<void> _editPicture() async {
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if(pickedImage != null){
        _image = File(pickedImage.path);
      }
    });
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
        MaterialPageRoute(builder: (context) => UserEditProfile()),
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

          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                alignment: Alignment.center,
                padding: EdgeInsets.fromLTRB(0,40,0,0),
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
              SizedBox(height: 20,),
              Text("Edit Post", style: TextStyle(
                  fontSize: 26,
                  fontFamily: 'DM Serif Display',
                ),
              ),
              SizedBox(height: 40,),
              Container(
                alignment: Alignment.centerLeft,
                child: Text("Location", style: TextStyle(
                    fontSize: 20,
                    fontFamily: 'DM Serif Display',
                  ),
                ),
              ),
              TextField(
                decoration: InputDecoration(
                  hintText: _editLocationController.text,
                  hintStyle: TextStyle(
                      fontFamily: 'DM Serif Display',
                      fontSize: 20,
                    ),
                ),
              ),
              SizedBox(height: 20,),
              Container(
                alignment: Alignment.centerLeft,
                child: Text("Content", style: TextStyle(
                  fontSize: 20,
                  fontFamily: 'DM Serif Display',
                ),
                ),
              ),
              TextField(
                decoration: InputDecoration(
                  hintText: _editContentController.text,
                  hintStyle: TextStyle(
                    fontFamily: 'DM Serif Display',
                    fontSize: 20,
                  ),
                ),
              ),
              SizedBox(height: 30,),
              ElevatedButton(
                  onPressed: (){
                    _editPicture();
                  },
                  style: ButtonStyle(
                    backgroundColor: WidgetStatePropertyAll<Color>(Color(0xFF1A2F31)),
                    shape: WidgetStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    padding: WidgetStateProperty.all<EdgeInsets>(EdgeInsets.all(10),),
                    fixedSize: MaterialStateProperty.all<Size>(Size(120.0, 50.0),),
                  ),
                  child: Text("Edit picture", style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
              ),
              SizedBox(height: 30,),
              Container(
                width: double.infinity,
                height: 200,
                color: Colors.grey,
                child: Center(
                  child: Text("Edited Picture"),
                ),
              ),
              SizedBox(height: 30,),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: (){
                      Navigator.of(context).pop();
                    },
                    style: ButtonStyle(
                      backgroundColor: WidgetStatePropertyAll<Color>(Color(0xFF1A2F31)),
                      shape: WidgetStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      padding: WidgetStateProperty.all<EdgeInsets>(EdgeInsets.all(10),),
                      fixedSize: MaterialStateProperty.all<Size>(Size(120.0, 50.0),),
                    ),
                    child: Text("Cancel", style: TextStyle(
                        color: Colors.white),
                    ),
                  ),
                  SizedBox(width: 20,),
                  ElevatedButton(
                    onPressed: (){
                      _saveEditedPost();
                    },
                    style: ButtonStyle(
                      backgroundColor: WidgetStatePropertyAll<Color>(Color(0xFF1A2F31)),
                      shape: WidgetStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      padding: WidgetStateProperty.all<EdgeInsets>(EdgeInsets.all(10),),
                      fixedSize: MaterialStateProperty.all<Size>(Size(120.0, 50.0),),
                    ),
                    child: Text("Save", style: TextStyle(
                        color: Colors.white),
                    ),
                  ),
                ],
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
          BottomNavigationBarItem(icon: CircleAvatar(
            backgroundColor: Colors.grey,
            radius: 20,
            backgroundImage: userAvatar.isNotEmpty ?
            NetworkImage(userAvatar) : AssetImage('assets/small_logo.png'),
          ),
              label: ''),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }
}