import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class UserAddPostPage extends StatefulWidget {
  @override
  _UserAddPostPageState createState() => _UserAddPostPageState();
}

class _UserAddPostPageState extends State<UserAddPostPage> {
  final TextEditingController _descriptionController = TextEditingController();
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _uploadPost() async {
    if (_imageFile != null) {
      try {

        final storageRef = FirebaseStorage.instance
            .ref()
            .child('posts/${DateTime.now().toIso8601String()}');
        await storageRef.putFile(_imageFile!);


        String imageUrl = await storageRef.getDownloadURL();


        String description = _descriptionController.text;

        // TODO: Add logic to save the image URL and description to Firestore (database)

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Post uploaded successfully!'),
        ));

        Navigator.pop(context);

      } catch (e) {
        print('Error uploading image: $e');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed to upload post.'),
        ));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Please add a photo.'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('With Me'),
        actions: [
          Icon(Icons.favorite),
          SizedBox(width: 10),
          Icon(Icons.chat_bubble_outline),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage: NetworkImage(
                      'https://example.com/profile.jpg'),
                ),
                SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('User', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    GestureDetector(
                      onTap: () {
                        // TODO: Add location picker logic here
                      },
                      child: Row(
                        children: [
                          Icon(Icons.location_on, size: 16),
                          SizedBox(width: 5),
                          Text('Add Location', style: TextStyle(fontSize: 14, color: Colors.grey)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 20),
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: _imageFile == null
                    ? Center(child: Text('+ ADD PHOTO', style: TextStyle(fontSize: 18)))
                    : Image.file(_imageFile!, fit: BoxFit.cover),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                hintText: 'Add Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _uploadPost,
              child: Text('Post'),
            ),
          ],
        ),
      ),
    );
  }
}
