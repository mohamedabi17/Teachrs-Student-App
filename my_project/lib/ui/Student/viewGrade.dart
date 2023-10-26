import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ViewGradePage extends StatefulWidget {
  final String className;

  ViewGradePage({required this.className});

  @override
  _ViewGradePageState createState() => _ViewGradePageState();
}

class _ViewGradePageState extends State<ViewGradePage> {
  String studEmail = "";

  @override
  void initState() {
    super.initState();
    fetchStudentEmail(); // Fetch student email when the widget is initialized
  }

  Future<void> fetchStudentEmail() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userDocument = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDocument.exists) {
          setState(() {
            studEmail = userDocument['email'];
          });
        }
      }
    } catch (e) {
      print('Error fetching student email: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('View Grade'),
      ),
      body: FutureBuilder(
        future: fetchStudentGrade(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error.toString()}'));
          } else if (!snapshot.hasData || snapshot.data == null) {
            return Center(child: Text('No grade available'));
          }

          String grade = snapshot.data.toString();

          return Center(
            child: Text(
              'Your grade in ${widget.className}: $grade',
              style: TextStyle(fontSize: 18),
            ),
          );
        },
      ),
    );
  }

  Future<String?> fetchStudentGrade() async {
    try {
      DocumentSnapshot studentSnapshot = await FirebaseFirestore.instance
          .collection('grades')
          .doc(
              studEmail) // Assuming each student's email is used as the document ID
          .get();

      if (studentSnapshot.exists) {
        Map<String, dynamic>? studentData =
            studentSnapshot.data() as Map<String, dynamic>?; // Explicit cast
        if (studentData != null) {
          String grade = studentData[widget.className] ?? 'N/A';
          return grade;
        }
      } else {
        return null;
      }
    } catch (e) {
      print('Error fetching student grade: $e');
      return null;
    }
  }
}
