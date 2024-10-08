

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as ImD;

class UserAddPostPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _UserAddPostPage();
}

class _UserAddPostPage extends State<UserAddPostPage> {
  File? file;
  bool _isUploading = false;
  String postId = Uuid().v4();
  final TextEditingController _captionController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Pick image from gallery
  pickImageFromGallery() async {
    Navigator.pop(context);
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxHeight: 680,
      maxWidth: 970,
    );
    setState(() {
      if (pickedFile != null) {
        file = File(pickedFile.path); // Convert XFile to File
      }
    });
  }

  // Compress image before uploading
  compressPhoto() async {
    final tDirectory = await getTemporaryDirectory();
    final path = tDirectory.path;
    ImD.Image mImageFile = ImD.decodeImage(file!.readAsBytesSync())!;
    final compressedImageFile = File('$path/img_$postId.jpg')
      ..writeAsBytesSync(ImD.encodeJpg(mImageFile, quality: 90));
    setState(() {
      file = compressedImageFile;
    });
  }

  // Upload image to Firebase Storage
  Future<String> uploadPhoto(File imageFile) async {
    Reference storageReference =
    FirebaseStorage.instance.ref().child('posts').child('post_$postId.jpg');
    UploadTask uploadTask = storageReference.putFile(imageFile);
    TaskSnapshot storageTaskSnapshot = await uploadTask;
    String downloadUrl = await storageTaskSnapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  // Save post info to Firestore
  Future<void> savePostInfoToFirestore(String imageUrl) async {
    User? currentUser = _auth.currentUser;

    await _firestore.collection('posts').doc(postId).set({
      'postId': postId,
      'ownerId': currentUser!.uid,
      'username': currentUser.displayName,
      'description': _captionController.text,
      'imageUrl': imageUrl,
      'timestamp': DateTime.now(),
    });

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Post uploaded successfully!'),
    ));
  }

  // Handle post submission
  Future<void> handlePostSubmission() async {
    if (file != null) {
      setState(() {
        _isUploading = true;
      });

      await compressPhoto();
      String imageUrl = await uploadPhoto(file!);
      await savePostInfoToFirestore(imageUrl);

      setState(() {
        file = null;
        _isUploading = false;
        _captionController.clear();
        postId = Uuid().v4(); // Generate a new post ID for the next post
      });

      Navigator.pop(context); // Navigate back to the home page after posting
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Please select an image.'),
      ));
    }
  }

  takeImage(mContext) {
    return showDialog(
      context: mContext,
      builder: (context) {
        return SimpleDialog(
          backgroundColor: Colors.grey[800],
          title: Text(
            "New Post",
            style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
          ),
          children: <Widget>[
            SimpleDialogOption(
              child: Text("Select image from gallery", style: TextStyle(color: Colors.white)),
              onPressed: pickImageFromGallery,
            ),
            SimpleDialogOption(
              child: Text("Cancel", style: TextStyle(color: Colors.white)),
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
            ),
          ],
        );
      },
    );
  }

  // Display the upload screen
  Widget displayAddScreen() {
    return Container(
      color: Theme.of(context).colorScheme.secondary.withOpacity(0.5),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(Icons.add_photo_alternate, color: Colors.grey, size: 200.0),
          Padding(
            padding: EdgeInsets.only(top: 20.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(9.0),
                ),
              ),
              child: Text("Upload Image", style: TextStyle(color: Colors.white, fontSize: 20.0)),
              onPressed: () => takeImage(context),
            ),
          ),
        ],
      ),
    );
  }

  // Display the form for adding a description and submitting the post
  Widget displayAddFormScreen() {
    return Scaffold(
      appBar: AppBar(
        title: Text('Describe Post and Submit'),
        actions: [
          TextButton(
            onPressed: handlePostSubmission,
            child: Text(
              'Post',
              style: TextStyle(color: Colors.black, fontSize: 16),
            ),
          ),
        ],
      ),
      body: ListView(
        children: [
          if (_isUploading) LinearProgressIndicator(),
          Container(
            height: 230.0,
            width: MediaQuery.of(context).size.width * 0.8,
            child: Center(
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: FileImage(file!),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Padding(padding: EdgeInsets.only(top: 12.0)),
          ListTile(
            title: TextField(
              controller: _captionController,
              decoration: InputDecoration(
                hintText: 'Enter a description...',
                border: InputBorder.none,
              ),
            ),
          ),
          Divider(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: file == null ? displayAddScreen() : displayAddFormScreen(),
    );
  }
}