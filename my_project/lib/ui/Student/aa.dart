// import 'package:flutter/material.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:file_picker/file_picker.dart';
// import 'dart:io';
// import 'package:image_picker/image_picker.dart';

// class AppealsPage extends StatefulWidget {
//   final String className;
//   final String classId;
//   final String teacherEmail;
//   final String studentId;
//   final String studentName;

//   AppealsPage({
//     required this.className,
//     required this.classId,
//     required this.teacherEmail,
//     required this.studentId,
//     required this.studentName,
//   });

//   @override
//   _AppealsPageState createState() => _AppealsPageState();
// }

// class _AppealsPageState extends State<AppealsPage> {
//   late TextEditingController _descriptionController;
//   List<File> _attachedFiles = [];
//   FirebaseStorage _storage = FirebaseStorage.instance;
//   FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   bool _isUploading = false;
//   late TextEditingController _appealMessageController;
//   late File _selectedImage;
//   @override
//   void initState() {
//     super.initState();
//     _descriptionController = TextEditingController();
//     _appealMessageController = TextEditingController();
//   }

//   @override
//   void dispose() {
//     _descriptionController.dispose();
//     _appealMessageController.dispose();
//     super.dispose();
//   }

//   Future<void> _chooseImage() async {
//     try {
//       final pickedFile =
//           await ImagePicker().pickImage(source: ImageSource.gallery);

//       if (pickedFile != null) {
//         setState(() {
//           _selectedImage = File(pickedFile.path);
//         });
//       }
//     } catch (e) {
//       print('Error choosing image: $e');
//     }
//   }

//   Future<void> _chooseFiles() async {
//     try {
//       FilePickerResult? result = await FilePicker.platform.pickFiles(
//         allowMultiple: true,
//         type: FileType.custom,
//         allowedExtensions: ['pdf', 'doc', 'docx'], // Adjust allowed file types
//       );

//       if (result != null) {
//         setState(() {
//           _attachedFiles = result.paths.map((path) => File(path!)).toList();
//         });
//       } else {
//         print('No files were selected.');
//       }
//     } catch (e) {
//       print('Error choosing files: $e');
//     }
//   }

//   Future<void> _submitAppeal() async {
//     try {
//       List<String> fileUrls = [];

//       for (File file in _attachedFiles) {
//         String fileName = DateTime.now().millisecondsSinceEpoch.toString();
//         Reference storageReference = _storage.ref().child('appeals/$fileName');
//         UploadTask uploadTask = storageReference.putFile(file);

//         await uploadTask.whenComplete(() async {
//           String downloadURL = await storageReference.getDownloadURL();
//           fileUrls.add(downloadURL);
//         });
//       }
//       if (_selectedImage != null) {
//         String imageFileName =
//             DateTime.now().millisecondsSinceEpoch.toString() + '.jpg';
//         Reference imageStorageReference =
//             _storage.ref().child('images/$imageFileName');
//         UploadTask imageUploadTask =
//             imageStorageReference.putFile(_selectedImage);

//         await imageUploadTask.whenComplete(() async {
//           String imageUrl = await imageStorageReference.getDownloadURL();
//           fileUrls.add(imageUrl);
//         });
//       }

//       Map<String, dynamic> appealData = {
//         'className': widget.className,
//         'classId': widget.classId,
//         'teacherEmail': widget.teacherEmail,
//         'studentId': widget.studentId,
//         'studentName': widget.studentName,
//         'description': _descriptionController.text,
//         'appealMessage': _appealMessageController.text,
//         'fileUrls': fileUrls,
//         'timestamp': FieldValue.serverTimestamp(),
//         'imageUrls': fileUrls, // Add image URLs to the appeal data
//       };

//       await _firestore.collection('appeals').add(appealData);

//       _descriptionController.clear();
//       setState(() {
//         _attachedFiles.clear();
//       });

//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Appeal submitted successfully!')),
//       );
//     } catch (e) {
//       print('Error submitting appeal: $e');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error submitting appeal. Please try again.')),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Submit Appeal'),
//       ),
//       body: SingleChildScrollView(
//         // Wrap the Column with SingleChildScrollView
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: [
//               Center(
//                 child: Text(
//                   'Submit New Appeal',
//                   style: TextStyle(
//                     fontSize: 20,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.blueAccent,
//                   ),
//                 ),
//               ),
//               TextFormField(
//                 controller: _appealMessageController,
//                 decoration: InputDecoration(
//                   labelText: 'Appeal Message',
//                 ),
//               ),
//               SizedBox(height: 20),
//               ElevatedButton(
//                 onPressed: _isUploading ? null : _chooseFiles,
//                 child: Text('Attach Files'),
//               ),
//               SizedBox(height: 20),
//               ElevatedButton(
//                 onPressed: _isUploading
//                     ? null
//                     : _chooseImage, // Call _chooseImage for selecting images
//                 child: Text('Pick Image'),
//               ),
//               SizedBox(height: 20),
//               ElevatedButton(
//                 onPressed: _attachedFiles.isNotEmpty && !_isUploading
//                     ? _submitAppeal
//                     : null,
//                 child: Text('Submit Appeal'),
//               ),
//               SizedBox(height: 20), // Add this SizedBox for spacing

//               if (_isUploading) CircularProgressIndicator(),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
