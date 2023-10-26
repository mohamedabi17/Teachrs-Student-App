import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

class ViewAssignmentsPage extends StatefulWidget {
  final String className;

  ViewAssignmentsPage({required this.className});

  @override
  _ViewAssignmentsPageState createState() => _ViewAssignmentsPageState();
}

class _ViewAssignmentsPageState extends State<ViewAssignmentsPage> {
  CollectionReference _assignmentsCollection =
      FirebaseFirestore.instance.collection('assignments');

  late Stream<QuerySnapshot> _assignmentsStream;

  @override
  void initState() {
    super.initState();
    _assignmentsStream = _assignmentsCollection
        .where('className', isEqualTo: widget.className)
        .orderBy('timestamp', descending: true) // Order assignments by date
        .snapshots();
  }

  Future<void> _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Assignments for ${widget.className}'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: Text(
                  'Assignments for ${widget.className}',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                ),
              ),
            ),
            StreamBuilder<QuerySnapshot>(
              stream: _assignmentsStream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error loading assignments'));
                }

                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                // Data is available
                final assignmentDocs = snapshot.data!.docs;
                if (assignmentDocs.isEmpty) {
                  return Center(child: Text('No assignments available'));
                }

                return ListView.builder(
                  itemCount: assignmentDocs.length,
                  itemBuilder: (context, index) {
                    final assignmentData =
                        assignmentDocs[index].data() as Map<String, dynamic>;
                    final assignmentTitle = assignmentData['title'] ?? '';
                    final assignmentDescription =
                        assignmentData['description'] ?? '';
                    final assignmentInstructions =
                        assignmentData['instructions'] ?? '';
                    final fileUrls =
                        List<String>.from(assignmentData['fileUrls'] ?? []);

                    return Card(
                      elevation: 3,
                      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      child: Padding(
                        padding: EdgeInsets.all(10),
                        child: Center(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                assignmentTitle,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 10),
                              Text(
                                'Instructions: $assignmentInstructions',
                                style: TextStyle(fontSize: 16),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 10),
                              if (fileUrls.isNotEmpty)
                                Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: fileUrls.map((url) {
                                    String fileName = url.split('/').last;
                                    return ElevatedButton(
                                      onPressed: () {
                                        _launchURL(url);
                                      },
                                      child: Text('Download $fileName'),
                                    );
                                  }).toList(),
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
