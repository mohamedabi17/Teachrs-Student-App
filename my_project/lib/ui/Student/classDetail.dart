import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_project/ui/assignements.dart';
import './appeals.dart'; // Import the AppealsPage if available
import './viewAssignements.dart';
import './viewGrade.dart';

class ClassDetailPage extends StatefulWidget {
  final String classname;

  ClassDetailPage({required this.classname});

  @override
  _ClassDetailPageState createState() => _ClassDetailPageState();
}

class _ClassDetailPageState extends State<ClassDetailPage> {
  late Stream<DocumentSnapshot<Map<String, dynamic>>> _classStream;

  @override
  void initState() {
    super.initState();
    _classStream = FirebaseFirestore.instance
        .collection('classes')
        .where('classname', isEqualTo: widget.classname)
        .snapshots()
        .map((snapshot) => snapshot.docs.first);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: _classStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(
              title: Text('Class Detail'),
            ),
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return Scaffold(
            appBar: AppBar(
              title: Text('Class Detail'),
            ),
            body: Center(
              child: Text('Class not found.'),
            ),
          );
        }

        var classData = snapshot.data!.data()!;
        var className = classData['classname'] as String?;
        var classDescription = classData['description'] as String?;
        var teacherEmail = classData['teacherEmail'] as String?;
        var studentId = classData['studentId'] as String?;
        var studentName = classData['studentName'] as String?;
        var classId = classData['classId'] as String?;
        return Scaffold(
          appBar: AppBar(
            title: Text(className ?? 'Class Detail'),
          ),
          body: SingleChildScrollView(
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.all(16),
                    child: Image.asset(
                      'assets/image5.png', // Replace with the actual image asset path
                      width: 150,
                      height: 150,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      className ?? 'No Name',
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Text(
                          classDescription ?? 'No Description',
                          style: TextStyle(fontSize: 16),
                        ),
                        SizedBox(height: 8),
                        Text(
                          teacherEmail ?? 'No Teacher Email',
                          style: TextStyle(fontSize: 16),
                        ),
                        SizedBox(height: 8),
                        Text(
                          studentName ?? 'No Student Name',
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
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
                              builder: (context) => ViewAssignmentsPage(
                                className: widget.classname,
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
                              "Assignements",
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
                              builder: (context) => AppealsPage(
                                className: widget.classname,
                                teacherEmail:
                                    teacherEmail ?? 'No Teacher Email',
                                studentId: studentId ?? 'No Student ID',
                                studentName: studentName ?? 'No Student Name',
                                classId: classId ?? 'No Class ID',
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
                              builder: (context) => ViewGradePage(
                                className: widget
                                    .classname, // Pass the class name// Pass the class name
                                // Pass any other required parameters here
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
                          // Navigator.push(
                          //   context,
                          //   MaterialPageRoute(
                          //     builder: (context) => ClassTimePage(),
                          //   ),
                          // );
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
      },
    );
  }
}
