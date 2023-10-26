import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

class AssignmentPage extends StatefulWidget {
  final String className;
  final String teacherName;

  AssignmentPage({required this.className, required this.teacherName});

  @override
  _AssignmentPageState createState() => _AssignmentPageState();
}

class _AssignmentPageState extends State<AssignmentPage> {
  late TextEditingController _commentController;
  late TextEditingController _instructionsController;
  List<File> _uploadedFiles = [];
  FirebaseStorage _storage = FirebaseStorage.instance;
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _commentController = TextEditingController();
    _instructionsController =
        TextEditingController(); // Initialize _instructionsController
  }

  Future<void> _uploadFile(File file) async {
    setState(() {
      _isUploading = true;
    });

    try {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference storageReference =
          _storage.ref().child('assignments/${widget.className}/$fileName');
      UploadTask uploadTask = storageReference.putFile(file);

      await uploadTask.whenComplete(() async {
        String downloadURL = await storageReference.getDownloadURL();
        setState(() {
          _uploadedFiles.add(file);
        });
      });
    } catch (e) {
      print('Error uploading file: $e');
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  Future<void> _chooseFiles() async {
    FilePickerResult? pickedFiles = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.any,
    );

    if (pickedFiles != null) {
      List<File> files =
          pickedFiles.files.map((file) => File(file.path!)).toList();
      setState(() {
        _uploadedFiles.addAll(files);
      });
    }
  }

  Future<void> _postAssignment() async {
    try {
      List<String> fileUrls = [];

      for (File file in _uploadedFiles) {
        String fileName = DateTime.now().millisecondsSinceEpoch.toString();
        Reference storageReference =
            _storage.ref().child('assignments/${widget.className}/$fileName');
        UploadTask uploadTask = storageReference.putFile(file);

        await uploadTask.whenComplete(() async {
          String downloadURL = await storageReference.getDownloadURL();
          fileUrls.add(downloadURL);
        });
      }

      Map<String, dynamic> assignmentData = {
        'className': widget.className,
        'teacherName': widget.teacherName,
        'instructions': _instructionsController.text, // Include instructions
        'comment': _commentController.text,
        'fileUrls': fileUrls,
        'timestamp': FieldValue.serverTimestamp(),
      };

      DocumentReference assignmentRef =
          await _firestore.collection('assignments').add(assignmentData);

      // Store the assignment ID as a field in the document
      await assignmentRef.update({'assignmentId': assignmentRef.id});

      _commentController.clear();
      setState(() {
        _uploadedFiles.clear();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Assignment created successfully!')),
      );
    } catch (e) {
      print('Error posting assignment: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error posting assignment. Please try again.')),
      );
    }
  }


  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Post Assignment to Class Students'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Text(
                'Create New Assignment',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isUploading ? null : _chooseFiles,
              child: Text('Choose Files'),
            ),
            SizedBox(height: 20),
            if (_uploadedFiles.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _uploadedFiles.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: Icon(Icons.insert_drive_file),
                      title: Text(_uploadedFiles[index].path.split('/').last),
                    );
                  },
                ),
              ),
            SizedBox(height: 20),
            TextFormField(
              // Add TextFormField for instructions
              controller: _instructionsController,
              decoration: InputDecoration(
                labelText: 'Instructions',
              ),
            ),
            ElevatedButton(
              onPressed: _uploadedFiles.isNotEmpty && !_isUploading
                  ? _postAssignment
                  : null,
              child: Text('Create Assignment'),
            ),
            if (_isUploading) CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
