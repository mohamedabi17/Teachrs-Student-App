import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../modules/classe.dart';
import '../modules/grades.dart';

class GradesPage extends StatefulWidget {
  final ClassModule classModule;

  GradesPage({required this.classModule});

  @override
  _GradesPageState createState() => _GradesPageState();
}

class _GradesPageState extends State<GradesPage> {
  Map<String, TextEditingController> _tdControllers = {};
  Map<String, TextEditingController> _tpControllers = {};
  Map<String, TextEditingController> _examControllers = {};

  bool _gradesExist = false;
  String _currentStudentEmail = "";

  @override
  void dispose() {
    for (var controller in _tdControllers.values) {
      controller.dispose();
    }
    for (var controller in _tpControllers.values) {
      controller.dispose();
    }
    for (var controller in _examControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    for (var studentEmail in widget.classModule.studentEmails) {
      _tdControllers[studentEmail] = TextEditingController();
      _tpControllers[studentEmail] = TextEditingController();
      _examControllers[studentEmail] = TextEditingController();
    }

    // Fetch initial grades data
    _fetchInitialGrades();
  }

  void _fetchInitialGrades() async {
    for (var studentEmail in widget.classModule.studentEmails) {
      try {
        final gradesSnapshot = await FirebaseFirestore.instance
            .collection('grades')
            .where('studentEmail', isEqualTo: studentEmail)
            .where('classname', isEqualTo: widget.classModule.classname)
            .get();

        if (gradesSnapshot.docs.isNotEmpty) {
          final gradesData = gradesSnapshot.docs.first.data();
          _tdControllers[studentEmail]?.text = gradesData['td'].toString();
          _tpControllers[studentEmail]?.text = gradesData['tp'].toString();
          _examControllers[studentEmail]?.text = gradesData['exam'].toString();
        }
      } catch (error) {
        print("Error fetching initial grades: $error");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Grades"),
      ),
      body: Column(
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 20, bottom: 20),
              child: Text(
                "Tap Students Grades ",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            child: Table(
              border: TableBorder.all(),
              columnWidths: {
                0: FlexColumnWidth(1.0),
                1: FlexColumnWidth(1.0),
                2: FlexColumnWidth(1.0),
                3: FlexColumnWidth(1.0),
                4: FlexColumnWidth(1.0),
              },
              children: [
                TableRow(
                  children: [
                    TableCell(
                      child: Center(
                        child: Text("Student",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                    TableCell(
                      child: Center(
                        child: Text("TD",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                    TableCell(
                      child: Center(
                        child: Text("TP",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                    TableCell(
                      child: Center(
                        child: Text("EXAM",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                    TableCell(
                      child: Center(
                        child: Text("Edit",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
                for (var studentEmail in widget.classModule.studentEmails)
                  TableRow(
                    children: [
                      TableCell(
                        child: Center(
                          child: Text(studentEmail,
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                      TableCell(
                        child: Center(
                          child: TextField(
                            controller: _tdControllers[studentEmail],
                            textAlign: TextAlign
                                .center, // Align text within the TextField
                          ),
                        ),
                      ),
                      TableCell(
                        child: Center(
                          child: TextField(
                            controller: _tpControllers[studentEmail],
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      TableCell(
                        child: Center(
                          child: TextField(
                            controller: _examControllers[studentEmail],
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      TableCell(
                        child: Center(
                          child: ElevatedButton(
                            onPressed: () {
                              _showEditConfirmationDialog(studentEmail);
                            },
                            child: Text("Edit"),
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: _gradesExist ? _showUpdateConfirmationDialog : null,
            child: Text("Save Grades"),
          ),
        ],
      ),
    );
  }

  // Add this method to show the confirmation dialog before editing grades
  Future<void> _showEditConfirmationDialog(String studentEmail) async {
    final shouldEdit = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirm Edit"),
          content:
              Text("Are you sure you want to edit grades for $studentEmail?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text("Confirm"),
            ),
          ],
        );
      },
    );

    if (shouldEdit == true) {
      _editGrades(studentEmail);
    }
  }

  Future<void> _showUpdateConfirmationDialog() async {
    final shouldEdit = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirm Updating all the student grades"),
          content:
              Text("Are you sure you want to Update all students grades  ?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text("Confirm"),
            ),
          ],
        );
      },
    );

    if (shouldEdit == true) {
      _saveGrades();
    }
  }

  void _editGrades(String studentEmail) async {
    setState(() {
      _gradesExist = true;
      _currentStudentEmail = studentEmail;
    });

    try {
      final td = double.tryParse(_tdControllers[studentEmail]!.text) ?? 0.0;
      final tp = double.tryParse(_tpControllers[studentEmail]!.text) ?? 0.0;
      final exam = double.tryParse(_examControllers[studentEmail]!.text) ?? 0.0;
      final moy = (td + tp + exam) / 3;

      await FirebaseFirestore.instance
          .collection('grades')
          .where('studentEmail', isEqualTo: studentEmail)
          .where('classname', isEqualTo: widget.classModule.classname)
          .get()
          .then((gradesQuerySnapshot) async {
        if (gradesQuerySnapshot.docs.isEmpty) {
          // Create a new document if no document exists
          await FirebaseFirestore.instance.collection('grades').add({
            'studentEmail': studentEmail,
            'classname': widget.classModule.classname,
            'td': td,
            'tp': tp,
            'exam': exam,
            'moy': moy,
          });
        } else {
          // Update the existing document
          final gradesDocId = gradesQuerySnapshot.docs.first.id;
          await FirebaseFirestore.instance
              .collection('grades')
              .doc(gradesDocId)
              .update({
            'td': td,
            'tp': tp,
            'exam': exam,
            'moy': moy,
          });
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Grades updated successfully')),
        );
      });
    } catch (error) {
      print("Error updating grades: $error");
    }
  }

  Future<void> _saveGrades() async {
    for (var studentEmail in widget.classModule.studentEmails) {
      final td = double.parse(_tdControllers[studentEmail]!.text);
      final tp = double.parse(_tpControllers[studentEmail]!.text);
      final exam = double.parse(_examControllers[studentEmail]!.text);
      final moy = (td + tp + exam) / 3;

      final gradesQuerySnapshot = await FirebaseFirestore.instance
          .collection('grades')
          .where('studentEmail', isEqualTo: studentEmail)
          .where('classname', isEqualTo: widget.classModule.classname)
          .get();

      if (gradesQuerySnapshot.docs.isEmpty) {
        // Create a new document if no document exists
        await FirebaseFirestore.instance.collection('grades').add({
          'studentEmail': studentEmail,
          'classname': widget.classModule.classname,
          'td': td,
          'tp': tp,
          'exam': exam,
          'moy': moy,
        });
      } else {
        // Update the existing document
        final gradesDocId = gradesQuerySnapshot.docs.first.id;
        await FirebaseFirestore.instance
            .collection('grades')
            .doc(gradesDocId)
            .update({
          'td': td,
          'tp': tp,
          'exam': exam,
          'moy': moy,
        });
      }

      // Clear the text fields and update the UI
      _tdControllers[studentEmail]!.clear();
      _tpControllers[studentEmail]!.clear();
      _examControllers[studentEmail]!.clear();
    }

    _currentStudentEmail = "";
    setState(() {
      _gradesExist = false;
    });

    // Show a confirmation dialog or a snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Grades updated successfully')),
    );
  }
}
