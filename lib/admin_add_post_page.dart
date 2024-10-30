import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:fluttertoast/fluttertoast.dart';
// import 'package:location/location.dart';

class AdminAddPostPage extends StatefulWidget {
  @override
  _AdminAddPostPageState createState() => _AdminAddPostPageState();
}

class _AdminAddPostPageState extends State<AdminAddPostPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref().child('admin');
  final Reference _storageRef = FirebaseStorage.instance.ref().child('posts');
  final ImagePicker _picker = ImagePicker();

  final TextEditingController _contentController = TextEditingController();
  String _userName = '';
  String _userPhotoUrl = '';
  User? _currentUser;
  File? _imageFile;

  bool _isLoading = false;
  String _location = '';
  double? _latitude;
  double? _longitude;

  // GoogleMapController? _mapController;
  // final LatLng _initialLocation = LatLng(37.7749, -122.4194); // Default coordinates (San Francisco)

  @override
  void initState() {
    super.initState();
    _currentUser = _auth.currentUser;
    _fetchUserInfo();
  }

  Future<void> _fetchUserInfo() async {
    if (_currentUser != null) {
      final DatabaseReference userRef = _dbRef.child(_currentUser!.uid);
      final DataSnapshot snapshot = await userRef.get();
      if (snapshot.exists) {
        final userData = snapshot.value as Map;
        setState(() {
          _userName = userData['name'] ?? 'Admin';
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
    if (_contentController.text.isEmpty || _imageFile == null || _latitude == null || _longitude == null) {
      Fluttertoast.showToast(msg: "Please complete all fields, select a photo, and set location");
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

      final postData = {
        'content': _contentController.text,
        'location': _location,
        'latitude': _latitude,
        'longitude': _longitude,
        'postImageUrl': postImageUrl,
        'userId': _currentUser!.uid,
        'userName': _userName,
        'userPhotoUrl': _userPhotoUrl,
        'postDate': DateTime.now().toString(),
      };

      await _dbRef.child(_currentUser!.uid).child('posts').child(postId).set(postData);

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
      _contentController.clear();
      _imageFile = null;
      _location = '';
    });
  }

  // void _onMapCreated(GoogleMapController controller) {
  //   _mapController = controller;
  // }
  //
  // void _setLocation(LatLng position) {
  //   setState(() {
  //     _latitude = position.latitude;
  //     _longitude = position.longitude;
  //     _location = "${position.latitude}, ${position.longitude}";
  //   });
  // }

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
                Text(
                  _userName,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
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
            //
            // Container(
            //   height: 200,
            //   child: GoogleMap(
            //     onMapCreated: _onMapCreated,
            //     initialCameraPosition: CameraPosition(
            //       target: _initialLocation,
            //       zoom: 14.0,
            //     ),
            //     markers: {
            //       if (_latitude != null && _longitude != null)
            //         Marker(
            //           markerId: MarkerId("selected_location"),
            //           position: LatLng(_latitude!, _longitude!),
            //           draggable: true,
            //           onDragEnd: _setLocation,
            //         )
            //     },
            //     onTap: _setLocation,
            //   ),
            // ),
            Text("Location: $_location"),
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