import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login.dart';
import 'createClass.dart';
import '../modules/classe.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'class_detail_page.dart';


class Teacher extends StatefulWidget {
  const Teacher({Key? key}) : super(key: key);

  static List<ClassModule> teacherClasses = [];

  @override
  State<Teacher> createState() => _TeacherState();
}

class _TeacherState extends State<Teacher> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    _animation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    // Fetch teacher's classes from Firestore
    fetchTeacherClasses();
  }

  Future<void> fetchTeacherClasses() async {
    String teacherId = FirebaseAuth.instance.currentUser?.uid ?? '';
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('classes')
          .where('teacherId', isEqualTo: teacherId)
          .get();

      print(
          "Query Snapshot: $querySnapshot"); // Check if the query snapshot is not null

      List<ClassModule> classes = querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        print("Fetched Data: $data"); // Check the fetched data for each class

        Timestamp timestamp = data['year'] as Timestamp;
        DateTime year = timestamp.toDate();

        return ClassModule(
          classname: data['classname'],
          year: year,
          speciality: data['speciality'],
          description: data['description'],
          teacherEmail: data['teacherEmail'],
          teacherId: data['teacherId'],
          studentEmails: List<String>.from(data['studentEmails']),
        );
      }).toList();

      setState(() {
        Teacher.teacherClasses = classes;
      });
    } catch (error) {
      print('Error fetching teacher classes: $error');
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Teacher"),
        actions: [
          IconButton(
            onPressed: () {
              logout(context);
            },
            icon: Icon(
              Icons.logout,
            ),
          )
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "Start Class For Your Students",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16), // Add some spacing
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => CreateClassForm()),
                    );
                  },
                  child: Column(
                    children: [
                      Image.asset(
                        'assets/image4.jpg', // Replace with the actual image asset path
                        width: 150,
                        height: 150,
                      ),
                      Text(
                        "Create Class",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: Teacher.teacherClasses.length,
              itemBuilder: (context, index) {
                final classModule = Teacher.teacherClasses[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ClassDetailPage(classModule: classModule),
                      ),
                    );
                  },
                  child: ListTile(
                    title: Text(classModule.classname),
                    subtitle: Text(classModule.speciality),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> logout(BuildContext context) async {
    CircularProgressIndicator();
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => Login(),
      ),
    );
  }
}
