import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:http/http.dart' as http;

class TeacherViewAppealsPage extends StatefulWidget {
  final String teacherEmail;
  final String className;

  TeacherViewAppealsPage({
    required this.teacherEmail,
    required this.className,
  });

  @override
  _TeacherViewAppealsPageState createState() => _TeacherViewAppealsPageState();
}

class _TeacherViewAppealsPageState extends State<TeacherViewAppealsPage> {
  FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _downloadImage(String imageUrl) async {
    try {
      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode == 200) {
        // Save the image to the device's gallery or app's storage
        // You can use another package like path_provider to determine the storage path
        // For now, this example just shows a success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Image downloaded successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to download image')),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to download image')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Teacher View Appeals'),
      ),
      body: StreamBuilder(
        stream: _firestore
            .collection('appeals')
            .where('teacherEmail', isEqualTo: widget.teacherEmail)
            .where('className', isEqualTo: widget.className)
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
                child: Text('Error fetching appeals: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No appeals found.'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var appeal = snapshot.data!.docs[index];
              return Card(
                elevation: 3,
                margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        title: Center(
                          child: Text(
                            appeal['studentName'],
                            style: TextStyle(fontSize: 30),
                          ),
                        ),
                      ),
                      ListTile(
                        title: Center(
                          child: Text(
                            appeal['appealMessage'],
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'Date: ${appeal['timestamp']}',
                              style: TextStyle(fontSize: 14),
                            ),
                            if (appeal['fileUrls'] != null)
                              Column(
                                children: [
                                  SizedBox(height: 10),
                                  Text(
                                    'Attached Files:',
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  for (var fileUrl in appeal['fileUrls'])
                                    InkWell(
                                      onTap: () async {
                                        // Handle file URL tap
                                        // Download the file using file_url package or other methods
                                      },
                                      child: Text(
                                        fileUrl,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.blue,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            if (appeal['imageUrls'] != null)
                              Column(
                                children: [
                                  SizedBox(height: 10),
                                  Text(
                                    'Images:',
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  for (var imageUrl in appeal['imageUrls'])
                                    if (imageUrl.startsWith('http') ||
                                        imageUrl.startsWith('https'))
                                      InkWell(
                                        onTap: () {
                                          // Handle image tap here if needed
                                        },
                                        child: CachedNetworkImage(
                                          imageUrl: imageUrl,
                                          width: 100,
                                          height: 100,
                                          placeholder: (context, url) =>
                                              CircularProgressIndicator(),
                                          errorWidget: (context, url, error) =>
                                              Icon(Icons.error),
                                        ),
                                      ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
