class Grade {
  final double td;
  final double tp;
  final double exam;
  final double moy;
  final String studentName;
  final String studentEmail;
  final String teacherName;
  final String classname;

  Grade({
    required this.td,
    required this.tp,
    required this.exam,
    required this.moy,
    required this.studentName,
    required this.studentEmail,
    required this.teacherName,
    required this.classname,
  });

  Map<String, dynamic> toMap() {
    return {
      'td': td,
      'tp': tp,
      'exam': exam,
      'moy': moy,
      'studentName': studentName,
      'studentEmail': studentEmail,
      'teacherName': teacherName,
      'classname': classname,
    };
  }

  factory Grade.fromMap(Map<String, dynamic> map) {
    return Grade(
      td: map['td'],
      tp: map['tp'],
      exam: map['exam'],
      moy: map['moy'],
      studentName: map['studentName'],
      studentEmail: map['studentEmail'],
      teacherName: map['teacherName'],
      classname: map['classname'],
    );
  }
}
