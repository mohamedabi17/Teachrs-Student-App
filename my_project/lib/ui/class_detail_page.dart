import 'package:flutter/material.dart';
import 'package:my_project/ui/grades.dart';
import '../modules/classe.dart';
import './classtime.dart';
import './assignements.dart';
import './Viewappeals.dart';

class ClassDetailPage extends StatelessWidget {
  final ClassModule classModule;

  ClassDetailPage({required this.classModule});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(classModule.classname),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 20),
              Image.asset(
                'assets/image5.png', // Replace with the actual image asset path
                width: 150,
                height: 150,
              ),
              SizedBox(height: 20),
              Text(
                "Class Name: ${classModule.classname}",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text("Speciality: ${classModule.speciality}"),
              SizedBox(height: 10),
              Text("Description: ${classModule.description}"),
              SizedBox(height: 10),
              Text("Year: ${classModule.year.year}"),
              SizedBox(height: 10),
              Text("Teacher Email: ${classModule.teacherEmail}"),
              SizedBox(height: 10),
              Text("Student Emails:"),
              Column(
                children: classModule.studentEmails
                    .map((email) => Text(email))
                    .toList(),
              ),
              SizedBox(height: 20), // Add some spacing
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TeacherViewAppealsPage(
                            teacherEmail: classModule
                                .teacherEmail, // Pass the teacher's email
                            className:
                                classModule.classname, // Pass the class name
                          ),
                        ),
                      );
                    },
                    child: Column(
                      children: [
                        Image.asset(
                          'assets/image8.jpg',
                          width: MediaQuery.of(context).size.width / 2 - 20,
                          height: 100,
                        ),
                        SizedBox(height: 8),
                        Text(
                          "Appeals",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AssignmentPage(
                            className:
                                classModule.classname, // Pass the class name
                            teacherName: classModule
                                .teacherEmail, // Pass the teacher email
                          ),
                        ),
                      );
                    },
                    child: Column(
                      children: [
                        Image.asset(
                          'assets/image6.jpg',
                          width: MediaQuery.of(context).size.width / 2 - 20,
                          height: 100,
                        ),
                        SizedBox(height: 8),
                        Text(
                          "Assignments",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20), // Add some spacing
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => GradesPage(
                            classModule: this
                                .classModule, // Pass the classModule to GradesPage
                          ),
                        ),
                      );
                    },
                    child: Column(
                      children: [
                        Image.asset(
                          'assets/image7.jpg',
                          width: MediaQuery.of(context).size.width / 2 - 20,
                          height: 100,
                        ),
                        SizedBox(height: 8),
                        Text(
                          "Grades",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ClassTimePage()),
                      );
                    },
                    child: Column(
                      children: [
                        Image.asset(
                          'assets/image9.jpg',
                          width: MediaQuery.of(context).size.width / 2 - 20,
                          height: 100,
                        ),
                        SizedBox(height: 8),
                        Text(
                          "Class Time",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20), // Add some spacing
            ],
          ),
        ),
      ),
    );
  }
}
