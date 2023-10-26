import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class ClassTimePage extends StatefulWidget {
  @override
  _ClassTimePageState createState() => _ClassTimePageState();
}

class _ClassTimePageState extends State<ClassTimePage> {
  File? _image;
  TextEditingController _descriptionController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();

  Future<void> _uploadImage() async {
    if (_image != null) {
      try {
        String userId = FirebaseAuth.instance.currentUser?.uid ?? "";
        String imageName = DateTime.now().millisecondsSinceEpoch.toString();
        Reference storageReference = FirebaseStorage.instance
            .ref()
            .child('classTimeImages/$userId/$imageName');
        UploadTask uploadTask = storageReference.putFile(_image!);
        TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() {});

        // Save the image storage reference path in Firestore
        String imagePath = await storageReference.getDownloadURL();
        await FirebaseFirestore.instance.collection('classTimeJobs').add({
          'teacherId': userId,
          'imagePath': imagePath,
          'description': _descriptionController.text,
        });

        setState(() {
          _image = null;
          _descriptionController.text = "";
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Class Time Job saved successfully!')),
        );
      } catch (error) {
        print('Error uploading image: $error');
      }
    }
  }

  Future<void> _getImage() async {
    final pickedImage = await _imagePicker.pickImage(
      source: ImageSource.gallery,
    );

    if (pickedImage != null) {
      setState(() {
        _image = File(pickedImage.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("ClassTime Job"),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Text(
                  "Add a New Class Time Job ",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                  textAlign: TextAlign.center, // Added this line
                ),
              ),
            ),
            SizedBox(height: 20),
            _image != null
                ? Image.file(_image!)
                : Banner(
                    message: "add Image", location: BannerLocation.bottomEnd),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _getImage,
              child: Text("Upload ClassTime Job As an Image"),
            ),
            SizedBox(height: 20),
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: "Classtime Job Comment",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _image != null ? _uploadImage : null,
              child: Text("Save Class Time Job"),
            ),
          ],
        ),
      ),
    );
  }
}
