import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import FirebaseFirestore
import 'teacher.dart'; // Import the Teacher class
import '../modules/classe.dart'; // Import the ClassModule class

class CreateClassForm extends StatefulWidget {
  @override
  _CreateClassFormState createState() => _CreateClassFormState();
}

class _CreateClassFormState extends State<CreateClassForm> {
  final TextEditingController classNameController = TextEditingController();
  final TextEditingController yearController =
      TextEditingController(); // Add year controller
  final TextEditingController specialityController =
      TextEditingController(); // Add speciality controller
  final TextEditingController descriptionController = TextEditingController();
  List<TextField> studentEmailFields = [];

  String statusMessage = ''; // Store status message

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Create Class"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Image.asset('assets/image5.png'), // Add the image here
              TextField(
                controller: classNameController,
                decoration: InputDecoration(labelText: "Class Name"),
              ),
              TextField(
                controller: yearController, // Use year controller
                decoration: InputDecoration(labelText: "Year"),
              ),
              TextField(
                controller: specialityController, // Use speciality controller
                decoration: InputDecoration(labelText: "Speciality"),
              ),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(labelText: "Description"),
              ),
              SizedBox(height: 20),
              Text("Student Emails:"),
              Column(children: studentEmailFields),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    studentEmailFields.add(
                      TextField(
                        controller: TextEditingController(),
                        decoration: InputDecoration(labelText: "Student Email"),
                      ),
                    );
                  });
                },
                child: Text("Add Student Email"),
              ),
              SizedBox(height: 20), // Add spacing
              ElevatedButton(
                onPressed: () async {
                  String teacherId =
                      FirebaseAuth.instance.currentUser?.uid ?? '';
                  String teacherEmail =
                      FirebaseAuth.instance.currentUser?.email ?? '';

                  final newClass = ClassModule(
                    classname: classNameController.text,
                    year: DateTime.now(),
                    speciality: specialityController.text,
                    description: descriptionController.text,
                    teacherEmail: teacherEmail,
                    teacherId: teacherId,
                    studentEmails: studentEmailFields
                        .map((textField) => textField.controller?.text ?? '')
                        .toList(),
                  );

                  try {
                    await FirebaseFirestore.instance
                        .collection('classes')
                        .add(newClass.toMap());

                    Teacher.teacherClasses.add(newClass);
                    statusMessage = 'Class registered successfully!';
                  } catch (error) {
                    statusMessage = 'An error occurred. Please try again.';
                  }

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(statusMessage)),
                  );

                  Navigator.pop(context); // Go back to teacher home
                },
                child: Text("Create Class"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    classNameController.dispose();
    yearController.dispose();
    specialityController.dispose();
    descriptionController.dispose();
    super.dispose();
  }
}
