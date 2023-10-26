import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../login.dart';
import './classDetail.dart';

class Student extends StatefulWidget {
  const Student({super.key});

  @override
  State<Student> createState() => _StudentState();
}

class _StudentState extends State<Student> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late User _user;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _user = _auth.currentUser!;
    _isLoading = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Student"),
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
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            color: Theme.of(context).appBarTheme.backgroundColor,
            padding: EdgeInsets.all(16.0),
            child: Center(
              child: Text(
                "Join a Class",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : FutureBuilder<QuerySnapshot>(
                    future: FirebaseFirestore.instance
                        .collection('classes')
                        .where('studentEmails', arrayContains: _user.email)
                        .get(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator();
                      }
                      if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      }
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return Text('No classes found for this student.');
                      }

                      return ListView.builder(
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context, index) {
                          var classData = snapshot.data!.docs[index].data()
                              as Map<String, dynamic>;
                          var className = (classData['classname'] as String?) ??
                              'Unknown Class';
                          var classDescription =
                              (classData['description'] as String?) ?? '';

                          // var classModule = ClassModule(
                          //   documentId: snapshot.data!.docs[index].id,
                          // );

                          return GestureDetector(
                            onTap: () {
                              // Navigate to the class detail page
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      ClassDetailPage(classname:className),
                                ),
                              );
                            },
                            child: ListTile(
                              title: Text(className),
                              subtitle: Text(classDescription),
                              leading: Image.asset(
                                'assets/image5.png', // Replace with actual image path
                                width: 150,
                                height: 150,
                              ),
                            ),
                          );
                        },
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
    await _auth.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => Login(),
      ),
    );
  }
}
