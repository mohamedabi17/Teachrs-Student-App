class ClassModule {
  final String classname;
  final DateTime year;
  final String speciality;
  final String description;
  final String teacherEmail; // Add teacher email
  final String teacherId; // Add teacher ID
  final List<String> studentEmails; // Add list of student emails

  ClassModule({
    required this.classname,
    required this.speciality,
    required this.description,
    required this.year,
    required this.teacherEmail,
    required this.teacherId,
    required this.studentEmails,
  });

  Map<String, dynamic> toMap() {
    return {
      'classname': classname,
      'year': year,
      'speciality': speciality,
      'description': description,
      'teacherEmail': teacherEmail,
      'teacherId': teacherId,
      'studentEmails': studentEmails,
    };
  }
}
